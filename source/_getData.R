library(dplyr) #bind_rows

#2015 season
  #begin (day 1): 2015-10-27
  #use 10 days (day 11): 2015-11-06 (2142 obs)
  #10% (day 21): 2015-11-16
  #20% (day 42): 2015-12-08
  #50% (day 105): 2016-02-10
  #end (day 210): 2016-06-19

SEASON = '2015'
START_DATE = 'start'
SPLIT_DATE = '2015-11-16'
DATE_FORMAT = '%Y%m%d'

loadData = function() {
  data = read.csv(paste0('data/data_', SEASON, '.csv'), stringsAsFactors=F, na.strings=c(''))

  #remove Salary NAs because an NA means that the player was not an option to choose
  rowsWithSalaryNA = which(is.na(data$Salary))
  data = data[-rowsWithSalaryNA,]

  #remove rows that don't have data from stats.nba.com
  #it's all or nothing, so just check if one column has NAs, and I know the rest do as well
  rowsWithNoNbaData = which(is.na(data$W))
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
  data[is.na(data$Minutes_PrevGame), 'Minutes_PrevGame'] = 0
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

  #Set 'None' to 0 in DEF_WS (there's only 1).
  #I don't know what DEF_WS is, so i dont know if this is significant
  data[data$DEF_WS == 'None', 'DEF_WS'] = 0
  data$DEF_WS = as.numeric(data$DEF_WS)

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
  data$AvgFantasyPointsPerMin = ifelse(data$MIN == 0, 0, data$AvgFantasyPoints / data$MIN)

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
splitDataIntoTrainTest = function(data) {
  cat('    Splitting data into train/test...\n')

  startIndex = ifelse(START_DATE == 'start', 1, findFirstIndexOfDate(data, START_DATE))
  if (SPLIT_DATE == 'end') {
    train = data[startIndex:nrow(data),]
    test = NULL
  } else {
    splitIndex = findFirstIndexOfDate(data, SPLIT_DATE)
    endIndex = findLastIndexOfDate(data, SPLIT_DATE)
    train = data[startIndex:(splitIndex-1),]
    test = data[splitIndex:endIndex,]
  }
  return(list(train=train, test=test))
}

getData = function() {
  cat('Getting data (', START_DATE, '-', SPLIT_DATE, ')...\n', sep='')

  #load data
  full = loadData()

  #impute missing values
  full = imputeMissingValues(full)

  #do feature engineering
  full = featureEngineer(full)

  #split data into train, test
  trainTest = splitDataIntoTrainTest(full)
  train = trainTest$train
  test = trainTest$test

  return(list(train=train, test=test, full=full))
}
