library(dplyr) #bind_rows

#2015 season
  #begin (day 1): 20151027
  #use 10 days (day 11): 20151106 (2142 obs)
  #10% (day 21): 20151116
  #20% (day 42): 20151208
  #50% (day 105): 20160210
  #end (day 210): 20160619

SEASON = '2015'
START_DATE = as.Date('2015-10-27')
SPLIT_DATE = as.Date('2016-06-19')
splitDate = as.Date(SPLIT_DATE, DATE_FORMAT)
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
  splitIndex = findFirstIndexOfDate(data, SPLIT_DATE)
  if (splitIndex > -1) {
    endIndex = findLastIndexOfDate(data, SPLIT_DATE)
    train = data[1:(splitIndex-1),]
    test = data[splitIndex:endIndex,]
  } else {
    train = data
    test = NULL
  }
  return(list(train=train, test=test))
}

getData = function() {
  cat('Getting data...\n')

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
