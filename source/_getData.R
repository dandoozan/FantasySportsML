library(dplyr) #bind_rows

loadData = function(dateFormat) {
  data = read.csv('data/data.csv', stringsAsFactors=F, na.strings=c(''))

  #remove Salary NAs because an NA means that the player was not an option to choose
  rowsWithSalaryNA = which(is.na(data$Salary))
  data = data[-rowsWithSalaryNA,]

  #convert the date strings to Date objects
  data$Date = as.Date(as.character(data$Date), dateFormat)

  #Convert Position and Home to factors
  data$Position = factor(data$Position)
  data$Home = factor(data$Home)

  return(data)
}

findFirstIndexOfDate = function(data, date) {
  return(which(data$Date == date)[1])
}

findLastIndexOfDate = function(data, date) {
  dateIndices = which(data$Date == date)
  return(dateIndices[length(dateIndices)])
}

splitDataIntoTrainTest = function(data, date) {
  splitIndex = findFirstIndexOfDate(data, date)
  endIndex = findLastIndexOfDate(data, date)
  train = data[1:(splitIndex-1),]
  test = data[splitIndex:endIndex,]
  return(list(train=train, test=test))
}

imputeMissingValues = function(data) {
  cat('    Imputing missing values...\n')

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

getData = function(yName, date, dateFormat, oneHotEncode=F) {
  if (class(date) != 'Date') {
    stop('ERROR: date should be of class Date\n')
  }

  cat('Getting data...\n')

  #load data
  full = loadData(dateFormat)

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
  trainTest = splitDataIntoTrainTest(full, date)
  train = trainTest$train
  test = trainTest$test

  return(list(train=train, test=test, full=full))
}
