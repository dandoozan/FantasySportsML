
SEASON_START_DATE = '2016-10-25'
FACTOR_COLS = c('Position', 'Home', 'Team', 'Opponent', 'InjuryIndicator', 'InjuryDetails')

loadData = function() {
  data = read.csv(paste0('data/data_2016.csv'), stringsAsFactors=F, na.strings=c(''))

  #todo: uncomment this later after ive established a baseline with the first date
  #remove first date (2016-10-25) since it has GamesPlayed at like 76, and FPPG was based on last season
  #data = data[data$Date != SEASON_START_DATE,]

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