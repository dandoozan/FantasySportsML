library(dplyr) #bind_rows

loadData = function(dateFormat, season) {
  filename = paste0('data/data_', season, '.csv')
  data = read.csv(filename, stringsAsFactors=F, na.strings=c(''))

  #remove Salary NAs because an NA means that the player was not an option to choose
  rowsWithSalaryNA = which(is.na(data$Salary))
  data = data[-rowsWithSalaryNA,]

  #remove rows that don't have data from stats.nba.com
  #it's all or nothing, so just check if one column has NAs, and I know the rest do as well
  rowsWithNoNbaData = which(is.na(data$AGE))
  data = data[-rowsWithNoNbaData,]

  #convert the date strings to Date objects
  data$Date = as.Date(as.character(data$Date), dateFormat)

  #Convert Position and Home to factors
  data$Position = factor(data$Position)
  data$Home = factor(data$Home)

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

splitDataIntoTrainTest = function(data, date) {
  splitIndex = findFirstIndexOfDate(data, date)
  if (splitIndex > -1) {
    endIndex = findLastIndexOfDate(data, date)
    train = data[1:(splitIndex-1),]
    test = data[splitIndex:endIndex,]
  } else {
    train = data
    test = NULL
  }
  return(list(train=train, test=test))
}

imputeMissingValues = function(data) {
  cat('    Imputing missing values...\n')

  #Set NAs to 0s in AvgFantasyPoints, DaysPlayedPercent, FantasyPoints_PrevGame (all have the same 2 occurences: 281, 17524)
  #The NA means that the player was injured during the first game,so hadn't accumulated an avg or days played
  data[is.na(data$AvgFantasyPoints), 'AvgFantasyPoints'] = 0
  data[is.na(data$DaysPlayedPercent), 'DaysPlayedPercent'] = 0
  data[is.na(data$FantasyPoints_PrevGame), 'FantasyPoints_PrevGame'] = 0

  return(data)
}

featureEngineer = function(data) {
  cat('    Feature engineering...\n')
  return(data)
}

oneHotEncode = function(data) {
  cat('    One hot encoding variables...\n')
  dmy = caret::dummyVars('~.', data, fullRank=T)
  data = data.frame(predict(dmy, data))
  return(data)
}

getData = function(yName, season, splitDate, dateFormat, oneHotEncode=F) {
  if (class(splitDate) != 'Date') {
    stop('ERROR: date should be of class Date\n')
  }

  cat('Getting data...\n')

  #load data
  full = loadData(dateFormat, season)

  #impute missing values
  full = imputeMissingValues(full)

  #do feature engineering
  full = featureEngineer(full)

  #one hot encode factors
  #todo: perhaps one-hot-encode train and test separately.  I believe the reason
  #to do it separate is so that I don't 'leak' information to the train set when
  #there is a factor value in test that is not in train (but this would result in
  #an all-0s column for train, which wouldn't be used, so I'm not sure how big of
  #a problem the leaking information is).  For now, keep one-hot-encoding them together
  if (oneHotEncode) {
    full = oneHotEncode(full)
  }

  #split data into train, test
  trainTest = splitDataIntoTrainTest(full, splitDate)
  train = trainTest$train
  test = trainTest$test

  return(list(train=train, test=test, full=full))
}
