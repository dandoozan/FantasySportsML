
#How to add dates (up to date before yesterday)
  #-download rotoguru data (python source/python_scripts/scrapeRotoGuruDay.py)
  #-download nba data (python source/python_scripts/scrapeStatsNba.py)
  #-save nba playerbios json data (http://stats.nba.com/stats/leaguedashplayerbiostats?College=&Conference=&Country=&DateFrom=&DateTo=&Division=&DraftPick=&DraftYear=&GameScope=&GameSegment=&Height=&LastNGames=0&LeagueID=00&Location=&Month=0&OpponentTeamID=0&Outcome=&PORound=0&PerMode=PerGame&Period=0&PlayerExperience=&PlayerPosition=&Season=2016-17&SeasonSegment=&SeasonType=Regular+Season&ShotClockRange=&StarterBench=&TeamID=0&VsConference=&VsDivision=&Weight=)
  #-change END_DATE in createDataFile_2016.py
  #-create data_2016.csv (python source/python_scripts/createDataFile_2016.py)
    #-Resolve missing names
  #-create data_contests_2016.csv (python source/python_scripts/createContestFile.py)
  #-change END_DATE to new date


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

  #Set all other NBA col NAs to 0
  for (colName in F.NBA.TRADITIONAL) {
    data[is.na(data[[colName]]), colName] = 0
  }

  #set NAs to 0 or 'None' for players who haven't played this season (all of their
  #stats are NA because they aren't listed in NBA PlayerBios)
  playersWhoHaveNotPlayedThisSeason = c('Brandan Wright', 'Bruno Caboclo', 'Caris LeVert', 'Chinanu Onuaku', 'Derrick Jones Jr.', 'Devin Harris', 'Josh Huestis', 'Jrue Holiday', 'Nerlens Noel', 'Patrick Beverley', 'Reggie Bullock', 'Wayne Ellington', 'Brice Johnson', 'Festus Ezeli', 'Mike Scott', 'Paul Pierce', 'Tiago Splitter', 'Alec Burks', 'Damian Jones', 'Marshall Plumlee', 'R.J. Hunter')
  data[data$Name %in% playersWhoHaveNotPlayedThisSeason, c('NBA_AGE', 'NBA_PLAYER_HEIGHT_INCHES', 'NBA_PLAYER_WEIGHT', 'NBA_DRAFT_YEAR', 'NBA_DRAFT_ROUND', 'NBA_DRAFT_NUMBER')] = 0
  data[data$Name %in% playersWhoHaveNotPlayedThisSeason, c('NBA_COLLEGE', 'NBA_COUNTRY')] = 'None'
  data$NBA_COLLEGE = factor(data$NBA_COLLEGE)

  #set NAs to 'None' for players who don't have Country listed in NBA.com
  #There are 5 players
  playersWithNoCountry = c('Dario Saric', 'Semaj Christon', 'Jonathon Simmons', 'Tomas Satoransky', 'Jordan McRae')
  data[data$Name %in% playersWithNoCountry, 'NBA_COUNTRY'] = 'None'
  data$NBA_COUNTRY = factor(data$NBA_COUNTRY)

  #set 'Undrafted' to 0 in NBA_DRAFT_YEAR, NBA_DRAFT_ROUND, NBA_DRAFT_NUMBER
  #and make them numeric
  data[data$NBA_DRAFT_YEAR == 'Undrafted', 'NBA_DRAFT_YEAR'] = 0
  data[data$NBA_DRAFT_ROUND == 'Undrafted', 'NBA_DRAFT_ROUND'] = 0
  data[data$NBA_DRAFT_NUMBER == 'Undrafted', 'NBA_DRAFT_NUMBER'] = 0
  data$NBA_DRAFT_YEAR = as.numeric(data$NBA_DRAFT_YEAR)
  data$NBA_DRAFT_ROUND = as.numeric(data$NBA_DRAFT_ROUND)
  data$NBA_DRAFT_NUMBER = as.numeric(data$NBA_DRAFT_NUMBER)


  return(data)
}

getUniqueDates = function(data) {
  return(sort(unique(data$Date)))
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

  #add team RG expected points and teammates' RG expected scores
  data$TEAM_RG_points = 0
  dateStrs = getUniqueDates(data)
  for (dateStr in dateStrs) {
    teams = unique(data[data$Date == dateStr, 'Team',])
    for (team in teams) {
      indices = which((data$Date == dateStr) & (data$Team == team))
      data[indices, 'TEAM_RG_points'] = sum(data[indices, 'RG_points'])
    }
  }
  data$TEAMMATES_RG_points = round(data$TEAM_RG_points - data$RG_points, 2)

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