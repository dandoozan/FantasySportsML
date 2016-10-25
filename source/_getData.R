library(dplyr) #bind_rows

loadData = function() {
  train = read.csv('data/train.csv', stringsAsFactors=F, na.strings=c(''))
  test = read.csv('data/test.csv', stringsAsFactors=F, na.strings=c(''))
  full = bind_rows(train, test)
  return(list(train=train, test=test, full=full))
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

getData = function(yName, oneHotEncode=F) {
  cat('Getting data...\n')

  #load data
  data = loadData()
  train = data$train
  test = data$test
  full = data$full

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

  #split the data back into train and test
  train = full[1:nrow(train),]
  test = full[(nrow(train)+1):nrow(full), names(full) != yName]

  return(list(train=train, test=test, full=full))
}
