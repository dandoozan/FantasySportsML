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
SPLIT_DATE = 'end'
DATE_FORMAT = '%Y%m%d'

loadData = function() {
  filename = paste0('data/data_', SEASON, '.csv')
  data = read.csv(filename, stringsAsFactors=F, na.strings=c(''))

  #remove Salary NAs because an NA means that the player was not an option to choose
  rowsWithSalaryNA = which(is.na(data$Salary))
  data = data[-rowsWithSalaryNA,]

  #remove rows that don't have data from stats.nba.com
  #it's all or nothing, so just check if one column has NAs, and I know the rest do as well
  rowsWithNoNbaData = which(is.na(data$AGE))
  data = data[-rowsWithNoNbaData,]

  #convert the date strings to Date objects
  data$Date = as.Date(as.character(data$Date), DATE_FORMAT)

  #Convert Position and Home to factors
  data$Position = factor(data$Position)
  data$Home = factor(data$Home)

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

  return(data)
}

featureEngineer = function(data) {
  cat('    Feature engineering...\n')

  #Add AvgFantasyPointsPerMin
  data$AvgFantasyPointsPerMin = ifelse(data$MIN == 0, 0, data$AvgFantasyPoints / data$MIN)

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
  cat('Getting data (start=', START_DATE, ', split=', SPLIT_DATE, ')...\n', sep='')

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
