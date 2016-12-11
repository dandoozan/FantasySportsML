
#How to add dates (up to date before yesterday)
  #-create data_2016.csv (python source/python_scripts/createDataFile_2016.py)
    #-recheck the 'never' played names
    #-Resolve missing names
  #-create data_contests_2016.csv (python source/python_scripts/createContestFile.py)
  #-change END_DATE to new date
  #-d=getData()
  #-printNaCols(d)
    #-impute NAs
  #-rerun boruta
  #-retune xgb params


SEASON_START_DATE = '2016-10-25'
FACTOR_COLS = c('Position', 'Home', 'Team', 'Opponent', 'InjuryIndicator', 'InjuryDetails', 'RG_B2B_Situation', 'RG_B2B_OPP_Situation')

loadData = function() {
  data = read.csv(paste0('data/data_2016.csv'), stringsAsFactors=F, na.strings=c(''))

  #convert cols to factors
  for (col in FACTOR_COLS) {
    data[[col]] = factor(data[[col]])
  }

  return(data)
}

filterData = function(d, startDate, endDate) {
  #remove data before startDate and after endDate
  d = d[(d$Date >= startDate) & (d$Date <= endDate),]

  #remove GTD and OUT players
  d = d[d$InjuryIndicator == 'none',]

  #remove players who are not in RG and NF
  d = d[!is.na(d$RG_points) & !is.na(d$NF_FP),]

  #remove 3in4, 3in4-B2B, 4in5-B2B
  #d = d[d$RG_B2B_Situation != '3in4-B2B' & d$RG_B2B_Situation != '4in5-B2B',]

  return(d)
}

fillNAsInCols = function(d, colNames, value) {
  for (colName in colNames) {
    d[is.na(d[[colName]]), colName] = value
  }
  return(d)
}
imputeMissingValues = function(d) {
  cat('    Imputing missing values...\n')

  #first, create In[Site] (eg. InRotoGrinders) features
  d$InRotoGrinders = ifelse(is.na(d$RG_points), 0, 1)
  d$InNumberFire = ifelse(is.na(d$NF_FP), 0, 1)
  d$InRGAndNF = ifelse(d$InRotoGrinders == 1 & d$InNumberFire == 1, 1, 0)

  #----------F.NUMBERFIRE-----------
  #set all NAs to 0 in NumberFire cols (all the cols are predictive cols,
  #so if they dont have a value for a player, i think it's safe to assume
  #they're 'predicting' he'll get 0 in it
  d = fillNAsInCols(d, F.NUMBERFIRE, 0)

  #----------RG.PP-----------
  #set RG rank NAs to 0, but maybe consider something else (Inf?) since
  #generally lower rank is better, and since these don't have a rank, it
  #probably means that they're a bad player
  d = fillNAsInCols(d, c('RG_rank', 'RG_rank20'), 1000)

  #set all NAs to 0 in RotoGrinder cols (same reason as above)
  d = fillNAsInCols(d, F.RG.PP, 0)

  #----------RG.ADVANCEDPLAYERSTATS-----------
  #They all have 1454 NAs, which is a lot.  I guess set them all to 0, but that
  #is quite a lot of data that RG doesn't have on these players (about 40% of nrows), so
  #maybe it'd be better to remove RG.ADVANCEDPLAYERSTATS altogether
  d = fillNAsInCols(d, F.RG.ADVANCEDPLAYERSTATS, 0)

  #----------RG.MARKETWATCH-----------
  #Set the NAs to 0s for MarketWatch features. They all have the same 484
  #NAs.  I'm not sure that 0 is best, but that's all I can think of to do
  d = fillNAsInCols(d, F.RG.MARKETWATCH, 0)

  #----------RG.OPTIMALLINEUP-----------
  #Set all NAs to 0 for RG_OL_OnTeam because it means that the player was not
  #on the team.
  d = fillNAsInCols(d, 'RG_OL_OnTeam', 0)

  #----------RG.START-----------
  #The NAs in RG.START mean that the player did not play that day,
  #so set Starter=0, Order=20 (max order=15), and Status='B' (bc most are 'B')
  #There are 451 NAs in all 3 (they all have the same NAs)
  d = fillNAsInCols(d, 'RG_START_Order', 20)
  d = fillNAsInCols(d, 'RG_START_Starter', 0)
  d = fillNAsInCols(d, 'RG_START_Status', 'B')
  d$RG_START_Status = factor(d$RG_START_Status)

  #----------F.NBA.SEASON.PLAYER.[X]-----------
  #Set all NBA col NAs to 0.  These all have the same 754 NA rows
  d = fillNAsInCols(d, F.NBA.SEASON.PLAYER.TRADITIONAL, 0)
  d = fillNAsInCols(d, F.NBA.SEASON.PLAYER.ADVANCED, 0)
  d = fillNAsInCols(d, F.NBA.SEASON.PLAYER.DEFENSE, 0)

  #----------F.NBA.PLAYERBIOS-----------
  #set NAs to 0 or 'None' for players who haven't played this season (all of their
  #stats are NA because they aren't listed in NBA PlayerBios)
  d = fillNAsInCols(d, c('NBA_PB_AGE', 'NBA_PB_PLAYER_HEIGHT_INCHES', 'NBA_PB_PLAYER_WEIGHT', 'NBA_PB_DRAFT_YEAR'), 0)
  d = fillNAsInCols(d, c('NBA_PB_DRAFT_ROUND', 'NBA_PB_DRAFT_NUMBER'), 1000)
  d = fillNAsInCols(d, c('NBA_PB_COLLEGE', 'NBA_PB_COUNTRY'), 'None')
  d$NBA_PB_COLLEGE = factor(d$NBA_PB_COLLEGE)
  d$NBA_PB_COUNTRY = factor(d$NBA_PB_COUNTRY)

  #set 'Undrafted' to 0 in NBA_DRAFT_YEAR and 1000 in NBA_DRAFT_ROUND, NBA_DRAFT_NUMBER
  #and make them numeric
  d[d$NBA_PB_DRAFT_YEAR == 'Undrafted', 'NBA_PB_DRAFT_YEAR'] = 0
  d[d$NBA_PB_DRAFT_ROUND == 'Undrafted', 'NBA_PB_DRAFT_ROUND'] = 1000
  d[d$NBA_PB_DRAFT_NUMBER == 'Undrafted', 'NBA_PB_DRAFT_NUMBER'] = 1000
  d$NBA_PB_DRAFT_YEAR = as.numeric(d$NBA_PB_DRAFT_YEAR)
  d$NBA_PB_DRAFT_ROUND = as.numeric(d$NBA_PB_DRAFT_ROUND)
  d$NBA_PB_DRAFT_NUMBER = as.numeric(d$NBA_PB_DRAFT_NUMBER)

  #----------F.NBA.TODAY-----------
  #Set alll NAs to 0s for NBA TODAY stats.  There were 1296 NAs and all
  #of them had FantasyPoints of 0, so they are for players who did not play
  d = fillNAsInCols(d, F.NBA.TODAY, 0)

  #----------NBA.SEASON.TEAM.TRADITIONAL and NBA.SEASON.OPPTEAM.TRADITIONAL-----------
  #The NAs are for team's first games (because I look for the previous day's
  #data, but since there is none, then the NBA_TEAM_[X] features are NA), so set
  #them all to 0 (they all have the same 345 NAs)
  d = fillNAsInCols(d, F.NBA.SEASON.TEAM.TRADITIONAL, 0)
  d = fillNAsInCols(d, F.NBA.SEASON.OPPTEAM.TRADITIONAL, 0)

  return(d)
}

getUniqueDates = function(d) {
  return(sort(unique(d$Date)))
}
computeFP = function(pts, ast, blk, reb, stl, tov) {
  return(pts + (ast*1.5) + (blk*2) + (reb*1.2) + (stl*2) + (tov*-1))
}
computeFpPerMin = function(fp, min) {
  return(ifelse(fp == 0 & min == 0, 0, fp / min))
}
featureEngineer = function(d) {
  cat('    Feature engineering...\n')

  #compute FP
  d$FP = computeFP(d$NBA_TODAY_PTS, d$NBA_TODAY_AST, d$NBA_TODAY_BLK, d$NBA_TODAY_REB, d$NBA_TODAY_STL, d$NBA_TODAY_TOV)
  d$FP0 = ifelse(d$FP < 0, 0, d$FP) #set all FPs < 0 to 0
  d$FP1 = d$FP + runif(length(d$FP), -1, 1) #add random +/-1
  d$FP2 = d$FP + runif(length(d$FP), -2, 2) #add random +/-2
  d$AVG_FP = computeFP(d$NBA_S_P_TRAD_PTS, d$NBA_S_P_TRAD_AST, d$NBA_S_P_TRAD_BLK, d$NBA_S_P_TRAD_REB, d$NBA_S_P_TRAD_STL, d$NBA_S_P_TRAD_TOV)

  d$FP_PER_MIN = computeFpPerMin(d[[FP_NAME]], d[[MINUTES_NAME]])
  #add this ifelse to handle the 5 cases where RG predicts some FP for players, but also predicts that they'll play 0 minutes, which causes Inf when doing fp/min
  d$RG_FpPerMin = ifelse(d$RG_minutes == 0, 0, computeFpPerMin(d$RG_points, d$RG_minutes))
  d$NF_FpPerMin = computeFpPerMin(d$NF_FP, d$NF_Min)

  #compute MeanFP, StDevFP, MinFP, COV
  d$MeanFP = 0
  d$StDevFP = 0
  d$MinFP = 0
  d$MeanFpPerMin = 0
  d$MeanMinutes = 0
  d$PrevGameFpPerMin = 0
  names = unique(d$Name)
  for (name in names) {
    playerData = d[d$Name == name,]
    dateStrs = getUniqueDates(playerData)[-1]
    for (dateStr in dateStrs) {
      playerDataUpToDateWhenPlayed = playerData[playerData$Date < dateStr & playerData[[MINUTES_NAME]] > 0,]
      if (nrow(playerDataUpToDateWhenPlayed) > 0) {
        row = which(d$Name == name & d$Date == dateStr)

        fpsUpToDate = playerDataUpToDateWhenPlayed$FP
        d[row, 'MeanFP'] = mean(fpsUpToDate)
        d[row, 'StDevFP'] = psd(fpsUpToDate)
        d[row, 'MinFP'] = min(fpsUpToDate)

        d[row, 'MeanFpPerMin'] = mean(playerDataUpToDateWhenPlayed[[FP_PER_MIN_NAME]])
        d[row, 'MeanMinutes'] = mean(playerDataUpToDateWhenPlayed[[MINUTES_NAME]])

        #add prev game features
        prevDateStr = tail(playerDataUpToDateWhenPlayed$Date, 1)
        prevGameRow = which(d$Name == name & d$Date == prevDateStr)
        d[row, 'PrevGameFpPerMin'] = d[prevGameRow, FP_PER_MIN_NAME]
      }
    }
  }
  d$COV = ifelse(d$MeanFP == 0, Inf, d$StDevFP / d$MeanFP)

  #----------F.RG.PP-----------
  #add team RG expected points and teammates' RG expected scores
  d$TEAM_RG_points = 0
  dateStrs = getUniqueDates(d)
  for (dateStr in dateStrs) {
    teams = unique(d[d$Date == dateStr, 'Team',])
    for (team in teams) {
      indices = which((d$Date == dateStr) & (d$Team == team))
      d[indices, 'TEAM_RG_points'] = sum(d[indices, 'RG_points'])
    }
  }
  d$TEAMMATES_RG_points = round(d$TEAM_RG_points - d$RG_points, 2)

  #----------F.RG.DVP-----------
  #create OPP_DVP_FPPG and OPP_DVP_RANK, which is the opponent's
  #defense vs position points allowed and rank, respectively against
  #each player's own position
  d$OPP_DVP_FPPG = NA
  d$OPP_DVP_RANK = NA
  for (position in levels(d$Position)) {
    d[d$Position == position, 'OPP_DVP_FPPG'] = d[d$Position == position, paste0('RG_OPP_DVP_', position, 'FPPG')]
    d[d$Position == position, 'OPP_DVP_RANK'] = d[d$Position == position, paste0('RG_OPP_DVP_', position, 'RK')]
  }

  return(d)
}

getData = function(startDate='2016-10-26', endDate=as.character(Sys.Date())) {

  cat('Getting data (', format(as.Date(startDate), '%m/%d'),'-', format(as.Date(endDate), '%m/%d'),')...\n', sep='')

  #load data
  full = loadData()

  #filter data
  full = filterData(full, startDate, endDate)

  #impute missing values
  full = imputeMissingValues(full)

  #do feature engineering
  full = featureEngineer(full)

  return(full)
}

getContestData = function() {
  cat('    Getting contest data...\n')
  return(read.csv(paste0('data/data_contests_2016.csv'), stringsAsFactors=F, na.strings=c('')))
}

#----------------- utility functions ----------------
getDataForDate = function(d, dateStr) {
  return(d[d$Date == dateStr,])
}
getDataUpToDate = function(d, dateStr) {
  return(d[d$Date < dateStr,])
}
