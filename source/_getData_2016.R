library(dplyr) #bind_rows

DATE_FORMAT = '%Y%m%d'

loadData = function() {
  data = read.csv(paste0('data/data_2016.csv'), stringsAsFactors=F, na.strings=c(''))
  return(data)
}

imputeMissingValues = function(data) {
  cat('    Imputing missing values...\n')
  return(data)
}

featureEngineer = function(data) {
  cat('    Feature engineering...\n')
  return(data)
}

getData = function() {
  cat('Getting data...\n')

  #load data
  full = loadData()

  #impute missing values
  full = imputeMissingValues(full)

  #do feature engineering
  full = featureEngineer(full)

  return(full)
}
