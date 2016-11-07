
FACTOR_COLS = c('Position', 'Home', 'Team', 'Opponent', 'InjuryIndicator', 'InjuryDetails')

loadData = function() {
  data = read.csv(paste0('data/data_2016.csv'), stringsAsFactors=F, na.strings=c(''))

  #convert cols to factors
  for (col in FACTOR_COLS) {
    data[[col]] = factor(data[[col]])
  }

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

getContestData = function() {
  cat('Getting contest data...\n')
  return(read.csv(paste0('data/data_contests_2016.csv'), stringsAsFactors=F, na.strings=c('')))
}