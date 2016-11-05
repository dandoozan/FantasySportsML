library(dplyr) #bind_rows

#2015 season
  #begin (day 1): 2015-10-27
  #use 10 days (day 11): 2015-11-06 (2142 obs)
  #10% (day 21): 2015-11-16
  #20% (day 42): 2015-12-08
  #50% (day 105): 2016-02-10
  #end (day 210): 2016-06-19

SEASON = '2015'
DATE_FORMAT = '%Y%m%d'

loadData = function() {
  data = read.csv(paste0('data/data_', SEASON, '.csv'), stringsAsFactors=F, na.strings=c(''))

  #remove Salary NAs because an NA means that the player was not an option to choose
  rowsWithSalaryNA = which(is.na(data$Salary))
  data = data[-rowsWithSalaryNA,]

  #remove rows that don't have data from stats.nba.com
  #it's all or nothing, so just check if one column has NAs, and I know the rest do as well
  rowsWithNoNbaData = which(is.na(data$SEASON_W))
  data = data[-rowsWithNoNbaData,]

  #convert the date strings to Date objects
  data$Date = as.Date(as.character(data$Date), DATE_FORMAT)

  #Convert Position, Home, Team, Opponent to factors
  data$Position = factor(data$Position)
  data$Home = factor(data$Home)
  data$Team = factor(data$Team)
  data$Opponent = factor(data$Opponent)
  data$COLLEGE = factor(data$COLLEGE)
  data$COUNTRY = factor(data$COUNTRY)

  return(data)
}

imputeMissingValues = function(data) {
  cat('    Imputing missing values...\n')

  #Set NAs to 0s in AvgFantasyPoints, DaysPlayedPercent, FantasyPoints_PrevGame (all have the same 2 occurences: 281, 17524)
  #The NA means that the player was injured during the first game,so hadn't accumulated an avg or days played
  data[is.na(data$AvgFantasyPoints), 'AvgFantasyPoints'] = 0
  data[is.na(data$DaysPlayedPercent), 'DaysPlayedPercent'] = 0
  data[is.na(data$FantasyPoints_PrevGame), 'FantasyPoints_PrevGame'] = 0
  data[is.na(data$StartedPercent), 'StartedPercent'] = 0

  #Set NAs to 0s for Salary_PrevGame (there are 129 of these)
  #If they don't have a salary, then it literally means their salary is 0
  data[is.na(data$Salary_PrevGame), 'Salary_PrevGame'] = 0

  #Set 'Undrafted' to -1 in DRAFT_YEAR, DRAFT_ROUND and DRAFT_NUMBER
  data[data$DRAFT_YEAR == 'Undrafted', 'DRAFT_YEAR'] = -1
  data$DRAFT_YEAR = as.numeric(data$DRAFT_YEAR)
  data[data$DRAFT_ROUND == 'Undrafted', 'DRAFT_ROUND'] = -1
  data$DRAFT_ROUND = as.numeric(data$DRAFT_ROUND)
  data[data$DRAFT_NUMBER == 'Undrafted', 'DRAFT_NUMBER'] = -1
  data$DRAFT_NUMBER = as.numeric(data$DRAFT_NUMBER)

  #Set NAs to 0s in OPP_TEAM_ features (they all have the same 38 NAs)
  #Set to 0 because the NA means that the opposing team hadn't played a game yet in
  #the season, so there wasn't any opposing team data available
  data[is.na(data[[F.NBA.T.OPP.TRADITIONAL[1]]]), c(F.NBA.T.OPP.TRADITIONAL)] = 0
  data[is.na(data[[F.NBA.T.OPP.ADVANCED[1]]]), c(F.NBA.T.OPP.ADVANCED)] = 0
  data[is.na(data[[F.NBA.T.OPP.FOURFACTORS[1]]]), c(F.NBA.T.OPP.FOURFACTORS)] = 0

  #Set NAs to 0s in PREV_GAME_ data (all but 2 are in the post season where I don't
  #have data from nba.com, so that's why they're NA (but perhaps I shouldn't set
  #them to 0 if i use the post season data someday). The 2 that are in the reg season
  #are for players that only played 1 min in their previous game)
  data[is.na(data$PREV_GAME_MIN), c(F.NBA.P.PREV1.TRADITIONAL, F.NBA.P.PREV1.ADVANCED, F.NBA.P.PREV1.DEFENSE)] = 0

  #Set 'None' to 0 in DEF_WS (there's only 1 DEF_WS, but there are 138 PREV_GAME_DEF_WS).
  #I don't know what DEF_WS is, so i dont know if this is significant
  data[data$SEASON_DEF_WS == 'None', 'SEASON_DEF_WS'] = 0
  data$SEASON_DEF_WS = as.numeric(data$SEASON_DEF_WS)
  data[data$PREV_GAME_DEF_WS == 'None', 'PREV_GAME_DEF_WS'] = 0
  data$PREV_GAME_DEF_WS = as.numeric(data$PREV_GAME_DEF_WS)

  return(data)
}

computeAttendedTopXPctCollege = function(data, topPercent) {
  #topPercent should be in decimal format (eg. .1 for 10%)
  sortedCollegeOccurrences = sort(table(data[data$COLLEGE != 'None', 'COLLEGE']), decreasing=T)
  topColleges = names(sortedCollegeOccurrences[1:ceiling(length(sortedCollegeOccurrences) * topPercent)])
  return (as.numeric(data$COLLEGE %in% topColleges))
}
featureEngineer = function(data) {
  cat('    Feature engineering...\n')

  #Add AvgFantasyPointsPerMin
  data$AvgFantasyPointsPerMin = ifelse(data$SEASON_MIN == 0, 0, data$AvgFantasyPoints / data$SEASON_MIN)

  #Add SalaryIncreased
  data$SalaryIncreased = as.numeric(data$Salary > data$Salary_PrevGame)

  #Add WasDrafted
  data$WasDrafted = as.numeric(data$DRAFT_YEAR != -1)

  #Add AttendedTop5PctCollege (top 5%)
  #which are: Kentucky, Kansas, Duke, North Carolina, UCLA, Arizona, Florida
  data$AttendedTop5PctCollege = computeAttendedTopXPctCollege(data, .05)

  #Add AttendedTop10PctCollege (top 10%)
  #which are: Kentucky, Kansas, Duke, North Carolina, UCLA, Arizona, Florida, Texas, Connecticut, Wake Forest, Syracuse, Michigan, Southern California
  data$AttendedTop10PctCollege = computeAttendedTopXPctCollege(data, .1)

  #Add AttendedTop20PctCollege (top 20%)
  #which are: Kentucky, Kansas, Duke, North Carolina, UCLA, Arizona, Florida, Texas, Connecticut, Wake Forest, Syracuse, Michigan, Southern California, Louisiana State, Georgia Tech, Georgetown, Ohio State, Washington, Michigan State, Marquette, Villanova, Stanford, Wisconsin, Tennessee, Oklahoma State
  data$AttendedTop20PctCollege = computeAttendedTopXPctCollege(data, .2)

  #Add AttendedTop50PctCollege (top 50%)
  data$AttendedTop50PctCollege = computeAttendedTopXPctCollege(data, .5)

  #Create Starter feature (StartedPercent >= 0.95)
  data$Starter = as.numeric(data$StartedPercent >= 0.95)

  return(data)
}

findFirstIndexOfDate = function(data, date) {
  index = which(data$Date == date)
  if (length(index) > 0) {
    return(which(data$Date == date)[1])
  }
  return(-1)
}
findLastIndexOfDate = function(data, date) {
  dateIndices = which(data$Date == date)
  if (length(dateIndices) > 0) {
    return(dateIndices[length(dateIndices)])
  }
  return(-1)
}
splitDataIntoTrainTest = function(data, startDate, splitDate) {
  cat('    Splitting data into train/test...\n')

  startIndex = ifelse(startDate == 'start', 1, findFirstIndexOfDate(data, startDate))
  if (splitDate == 'end') {
    train = data[startIndex:nrow(data),]
    test = NULL
  } else {
    splitIndex = findFirstIndexOfDate(data, splitDate)
    endIndex = findLastIndexOfDate(data, splitDate)
    train = data[startIndex:(splitIndex-1),]
    test = data[splitIndex:endIndex,]
  }
  return(list(train=train, test=test))
}

getData = function(startDate='start', splitDate='end') {
  cat('Getting data (', startDate, '-', splitDate, ')...\n', sep='')

  #load data
  full = loadData()

  #impute missing values
  full = imputeMissingValues(full)

  #do feature engineering
  full = featureEngineer(full)

  #split data into train, test
  trainTest = splitDataIntoTrainTest(full, startDate, splitDate)
  train = trainTest$train
  test = trainTest$test

  return(list(train=train, test=test, full=full))
}
