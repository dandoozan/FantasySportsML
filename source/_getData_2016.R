
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
  for (colName in F.RG.PP) {
    data[is.na(data[[colName]]), colName] = 0
  }

  #For NBA_AGE, try to find the same player and fill in the NAs
  #with the age from another row
  #otherwise, set age manually
  namesWithAgeNAs = unique(data[is.na(data$NBA_SEASON_AGE), 'Name'])
  for (name in namesWithAgeNAs) {
    agesForPlayer = data[data$Name == name, 'NBA_SEASON_AGE']
    if (sum(!is.na(agesForPlayer)) > 0) {
      age = min(agesForPlayer, na.rm=T)
      data[(data$Name == name) & is.na(data$NBA_SEASON_AGE), 'NBA_SEASON_AGE'] = age
    }
  }
  #fill in the rest manually
  data[data$Name == 'Aaron Harrison', 'NBA_SEASON_AGE'] = 22
  data[data$Name == 'Arinze Onuaku', 'NBA_SEASON_AGE'] = 29
  data[data$Name == 'Brandan Wright', 'NBA_SEASON_AGE'] = 29
  data[data$Name == 'Brian Roberts', 'NBA_SEASON_AGE'] = 30
  data[data$Name == 'Bruno Caboclo', 'NBA_SEASON_AGE'] = 21
  data[data$Name == 'Caris LeVert', 'NBA_SEASON_AGE'] = 22
  data[data$Name == 'Chandler Parsons', 'NBA_SEASON_AGE'] = 28
  data[data$Name == 'Chinanu Onuaku', 'NBA_SEASON_AGE'] = 20
  data[data$Name == 'Christian Wood', 'NBA_SEASON_AGE'] = 21
  data[data$Name == 'Damjan Rudez', 'NBA_SEASON_AGE'] = 30
  data[data$Name == 'Derrick Jones Jr.', 'NBA_SEASON_AGE'] = 19
  data[data$Name == 'Derrick Williams', 'NBA_SEASON_AGE'] = 25
  data[data$Name == 'Devin Harris', 'NBA_SEASON_AGE'] = 33
  data[data$Name == 'Fred VanVleet', 'NBA_SEASON_AGE'] = 22
  data[data$Name == 'Jarnell Stokes', 'NBA_SEASON_AGE'] = 22
  data[data$Name == 'John Jenkins', 'NBA_SEASON_AGE'] = 25
  data[data$Name == 'Josh Huestis', 'NBA_SEASON_AGE'] = 24
  data[data$Name == 'Josh McRoberts', 'NBA_SEASON_AGE'] = 29
  data[data$Name == 'Jrue Holiday', 'NBA_SEASON_AGE'] = 26
  data[data$Name == 'Kelly Olynyk', 'NBA_SEASON_AGE'] = 25
  data[data$Name == 'Nerlens Noel', 'NBA_SEASON_AGE'] = 22
  data[data$Name == 'Patrick Beverley', 'NBA_SEASON_AGE'] = 28
  data[data$Name == 'Randy Foye', 'NBA_SEASON_AGE'] = 33
  data[data$Name == 'Reggie Bullock', 'NBA_SEASON_AGE'] = 25
  data[data$Name == 'Wayne Ellington', 'NBA_SEASON_AGE'] = 28
  data[data$Name == 'Alan Anderson', 'NBA_SEASON_AGE'] = 34
  data[data$Name == 'Brice Johnson', 'NBA_SEASON_AGE'] = 22
  data[data$Name == 'Danny Green', 'NBA_SEASON_AGE'] = 29
  data[data$Name == 'Danuel House', 'NBA_SEASON_AGE'] = 23
  data[data$Name == 'Festus Ezeli', 'NBA_SEASON_AGE'] = 27
  data[data$Name == 'Mike Scott', 'NBA_SEASON_AGE'] = 28
  data[data$Name == 'Paul Pierce', 'NBA_SEASON_AGE'] = 39
  data[data$Name == 'Tiago Splitter', 'NBA_SEASON_AGE'] = 31
  data[data$Name == 'Tim Quarterman', 'NBA_SEASON_AGE'] = 22
  data[data$Name == 'Alec Burks', 'NBA_SEASON_AGE'] = 25
  data[data$Name == 'Damian Jones', 'NBA_SEASON_AGE'] = 21
  data[data$Name == 'Gordon Hayward', 'NBA_SEASON_AGE'] = 26
  data[data$Name == 'Darren Collison', 'NBA_SEASON_AGE'] = 29
  data[data$Name == 'Marshall Plumlee', 'NBA_SEASON_AGE'] = 24
  data[data$Name == 'R.J. Hunter', 'NBA_SEASON_AGE'] = 23

  #Set all other NBA col NAs to 0
  for (colName in F.NBA) {
    data[is.na(data[[colName]]), colName] = 0
  }

  return(data)
}

featureEngineer = function(data) {
  cat('    Feature engineering...\n')

  #create OPP_DVP_FPPG and OPP_DVP_RANK, which is the opponent's
  #defense vs position points allowed and rank, respectively against
  #each player's own position
  data$OPP_DVP_FPPG = NA
  data$OPP_DVP_RANK = NA
  for (position in levels(data$Position)) {
    data[data$Position == position, 'OPP_DVP_FPPG'] = data[data$Position == position, paste0('RG_OPP_DVP_', position, 'FPPG')]
    data[data$Position == position, 'OPP_DVP_RANK'] = data[data$Position == position, paste0('RG_OPP_DVP_', position, 'RK')]
  }

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