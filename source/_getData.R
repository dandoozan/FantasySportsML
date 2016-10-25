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

  data = read.csv('data/data.csv')

  #impute missing values
  data = imputeMissingValues(data)

  #do feature engineering
  data = featureEngineer(data)

  #one hot encode factors
  if (oneHotEncode) {
    data = oneHotEncode(data)
  }

  return(data)
}
