
SEASON_START_DATE = '2016-10-25'
FACTOR_COLS = c('Position', 'Home', 'Team', 'Opponent', 'InjuryIndicator', 'InjuryDetails')

loadData = function() {
  data = read.csv(paste0('data/data_2016.csv'), stringsAsFactors=F, na.strings=c(''))

  #remove first date (2016-10-25) since it has GamesPlayed at like 76, and FPPG was based on last season
  data = data[data$Date != SEASON_START_DATE,]

  #convert cols to factors
  for (col in FACTOR_COLS) {
    data[[col]] = factor(data[[col]])
  }

  return(data)
}

imputeMissingValues = function(data) {
  cat('    Imputing missing values...\n')

  #set all NAs to 0 in NumberFire cols (all the cols are predictive cols,
  #so if they dont have a value for a player, i think it's safe to assume
  #they're 'predicting' he'll get 0 in it
  for (colName in F.NUMBERFIRE) {
    data[is.na(data[[colName]]), colName] = 0
  }

  #set RG rank NAs to 0, but maybe consider something else (Inf?) since
  #generally lower rank is better, and since these don't have a rank, it
  #probably means that they're a bad player
  data[is.na(data$RG_rank), 'RG_rank'] = 0
  data[is.na(data$RG_rank20), 'RG_rank20'] = 0

  #set all NAs to 0 in RotoGrinder cols (same reason as above)
  for (colName in F.ROTOGRINDER) {
    data[is.na(data[[colName]]), colName] = 0
  }

  return(data)
}

featureEngineer = function(data) {
  cat('    Feature engineering...\n')
  return(data)
}

getData = function(endDate=NULL) {
  cat('Getting data...\n')

  #load data
  full = loadData()

  #remove any data after endDate
  if (!is.null(endDate)) {
    full = full[full$Date <= endDate,]
  }

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