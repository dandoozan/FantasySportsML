library(xgboost) #xgb.train, xgb.cv
library(caret) #dummyVars
library(Ckmeans.1d.dp) #xgb.plot.importance
library(randomForest) #randomForest
library(hydroGOF) #rmse
library(ggplot2) #visualization
library(ggthemes) #visualization
library(dplyr) #%>%
source('../ml-common/plot.R')
source('../ml-common/util.R')
source('source/_getData_2016.R')
source('source/_createTeam.R')

END_DATE = '2016-11-11'
Y_NAME = 'FantasyPoints'

#features excluded: FantasyPoints, Date, Name
F.ID = c('Date', 'Name', 'Position', 'Team', 'Opponent')
F.FANDUEL = c('Position', 'FPPG', 'GamesPlayed', 'Salary', 'Home', 'Team', 'Opponent', 'InjuryIndicator', 'InjuryDetails')
F.FANDUEL_FAST = c('Position', 'FPPG', 'GamesPlayed', 'Salary', 'Home', 'Team', 'Opponent', 'InjuryIndicator')
F.NUMBERFIRE = c('NF_Min', 'NF_Pts', 'NF_Reb', 'NF_Ast', 'NF_Stl', 'NF_Blk', 'NF_TO', 'NF_FP')
F.RG.PP = c('RG_ceil', 'RG_floor', 'RG_points', 'RG_ppdk', 'RG_line',  'RG_movement', 'RG_overunder', 'RG_total', 'RG_contr', 'RG_pownpct', 'RG_rank', 'RG_rankdiff', 'RG_saldiff', 'RG_deviation', 'RG_minutes', 'RG_rank20', 'RG_diff20', 'RG_rank_diff20', 'RG_salary20', 'RG_salary15', 'RG_salary19', 'RG_salary28', 'RG_salary43', 'RG_salary50', 'RG_salary58', 'RG_points15', 'RG_points19', 'RG_points20', 'RG_points28', 'RG_points43', 'RG_points50', 'RG_points51', 'RG_points58')
F.RG.ADVANCEDPLAYERSTATS = c('RG_ADV_D_RT', 'RG_ADV_O_RT', 'RG_ADV_POW_AST', 'RG_ADV_POW_BLK', 'RG_ADV_POW_PTS', 'RG_ADV_POW_REB', 'RG_ADV_POW_STL', 'RG_ADV_EFGPCT', 'RG_ADV_TSPCT', 'RG_ADV_USGPCT')
F.RG.MARKETWATCH = c('RG_MW_dk_current', 'RG_MW_dk_change', 'RG_MW_fa_current',  'RG_MW_fa_change', 'RG_MW_y_current', 'RG_MW_y_change', 'RG_MW_dd_current', 'RG_MW_dd_change', 'RG_MW_rstr_current', 'RG_MW_rstr_change', 'RG_MW_fd_current', 'RG_MW_fd_change', 'RG_MW_fdft_current', 'RG_MW_fdft_change')
#F.RG.DVP = c('RG_OPP_DVP_CFPPG', 'RG_OPP_DVP_CRK', 'RG_OPP_DVP_PFFPPG', 'RG_OPP_DVP_PFRK', 'RG_OPP_DVP_PGFPPG', 'RG_OPP_DVP_PGRK', 'RG_OPP_DVP_SFFPPG', 'RG_OPP_DVP_SFRK', 'RG_OPP_DVP_SGFPPG', 'RG_OPP_DVP_SGRK')
F.RG.OVD.BASIC = c('RG_OVD_AST', 'RG_OVD_STL', 'RG_OVD_FGM', 'RG_OVD_TO', 'RG_OVD_3PM', 'RG_OVD_BLK', 'RG_OVD_FGPCT', 'RG_OVD_REB', 'RG_OVD_PTS', 'RG_OVD_FGA')
F.RG.OVD.OPP.BASIC = c('RG_OVD_OPP_AST', 'RG_OVD_OPP_STL', 'RG_OVD_OPP_FGM', 'RG_OVD_OPP_TO', 'RG_OVD_OPP_3PM', 'RG_OVD_OPP_BLK', 'RG_OVD_OPP_FGPCT', 'RG_OVD_OPP_REB', 'RG_OVD_OPP_PTS', 'RG_OVD_OPP_FGA')
F.RG.BACK2BACK = c('RG_B2B_Situation')
F.RG.BACK2BACK.OPP = c('RG_B2B_OPP_Situation')
F.NBA.SEASON.PLAYER.TRADITIONAL = c('NBA_S_P_TRAD_GP', 'NBA_S_P_TRAD_W', 'NBA_S_P_TRAD_L', 'NBA_S_P_TRAD_W_PCT', 'NBA_S_P_TRAD_MIN', 'NBA_S_P_TRAD_FGM', 'NBA_S_P_TRAD_FGA', 'NBA_S_P_TRAD_FG_PCT', 'NBA_S_P_TRAD_FG3M', 'NBA_S_P_TRAD_FG3A', 'NBA_S_P_TRAD_FG3_PCT', 'NBA_S_P_TRAD_FTM', 'NBA_S_P_TRAD_FTA', 'NBA_S_P_TRAD_FT_PCT', 'NBA_S_P_TRAD_OREB', 'NBA_S_P_TRAD_DREB', 'NBA_S_P_TRAD_REB', 'NBA_S_P_TRAD_AST', 'NBA_S_P_TRAD_TOV', 'NBA_S_P_TRAD_STL', 'NBA_S_P_TRAD_BLK', 'NBA_S_P_TRAD_BLKA', 'NBA_S_P_TRAD_PF', 'NBA_S_P_TRAD_PFD', 'NBA_S_P_TRAD_PTS', 'NBA_S_P_TRAD_PLUS_MINUS', 'NBA_S_P_TRAD_DD2', 'NBA_S_P_TRAD_TD3')
F.NBA.SEASON.PLAYER.ADVANCED = c('NBA_S_P_ADV_OFF_RATING', 'NBA_S_P_ADV_DEF_RATING', 'NBA_S_P_ADV_NET_RATING', 'NBA_S_P_ADV_AST_PCT', 'NBA_S_P_ADV_AST_TO', 'NBA_S_P_ADV_AST_RATIO', 'NBA_S_P_ADV_OREB_PCT', 'NBA_S_P_ADV_DREB_PCT', 'NBA_S_P_ADV_REB_PCT', 'NBA_S_P_ADV_TM_TOV_PCT', 'NBA_S_P_ADV_EFG_PCT', 'NBA_S_P_ADV_TS_PCT', 'NBA_S_P_ADV_USG_PCT', 'NBA_S_P_ADV_PACE', 'NBA_S_P_ADV_PIE', 'NBA_S_P_ADV_FGM_PG', 'NBA_S_P_ADV_FGA_PG')
F.NBA.SEASON.PLAYER.DEFENSE = c('NBA_S_P_DEF_DEF_RATING', 'NBA_S_P_DEF_PCT_DREB', 'NBA_S_P_DEF_PCT_STL', 'NBA_S_P_DEF_PCT_BLK', 'NBA_S_P_DEF_OPP_PTS_OFF_TOV', 'NBA_S_P_DEF_OPP_PTS_2ND_CHANCE', 'NBA_S_P_DEF_OPP_PTS_FB', 'NBA_S_P_DEF_OPP_PTS_PAINT', 'NBA_S_P_DEF_DEF_WS')
F.NBA.PLAYERBIOS = c('NBA_PB_AGE', 'NBA_PB_PLAYER_HEIGHT_INCHES', 'NBA_PB_PLAYER_WEIGHT', 'NBA_PB_COLLEGE', 'NBA_PB_COUNTRY', 'NBA_PB_DRAFT_YEAR', 'NBA_PB_DRAFT_ROUND', 'NBA_PB_DRAFT_NUMBER')
F.NBA.PLAYERBIOS_NUM = c('NBA_PB_AGE', 'NBA_PB_PLAYER_HEIGHT_INCHES', 'NBA_PB_PLAYER_WEIGHT', 'NBA_PB_DRAFT_YEAR', 'NBA_PB_DRAFT_ROUND', 'NBA_PB_DRAFT_NUMBER')
F.RG.START = c('RG_START_Order', 'RG_START_Starter', 'RG_START_Status')
F.NBA.SEASON.TEAM.TRADITIONAL = c('NBA_S_T_TRAD_GP', 'NBA_S_T_TRAD_W', 'NBA_S_T_TRAD_L', 'NBA_S_T_TRAD_W_PCT', 'NBA_S_T_TRAD_MIN', 'NBA_S_T_TRAD_FGM', 'NBA_S_T_TRAD_FGA', 'NBA_S_T_TRAD_FG_PCT', 'NBA_S_T_TRAD_FG3M', 'NBA_S_T_TRAD_FG3A', 'NBA_S_T_TRAD_FG3_PCT', 'NBA_S_T_TRAD_FTM', 'NBA_S_T_TRAD_FTA', 'NBA_S_T_TRAD_FT_PCT', 'NBA_S_T_TRAD_OREB', 'NBA_S_T_TRAD_DREB', 'NBA_S_T_TRAD_REB', 'NBA_S_T_TRAD_AST', 'NBA_S_T_TRAD_TOV', 'NBA_S_T_TRAD_STL', 'NBA_S_T_TRAD_BLK', 'NBA_S_T_TRAD_BLKA', 'NBA_S_T_TRAD_PF', 'NBA_S_T_TRAD_PFD', 'NBA_S_T_TRAD_PTS', 'NBA_S_T_TRAD_PLUS_MINUS')
F.NBA.SEASON.OPPTEAM.TRADITIONAL = c('NBA_S_OPPT_TRAD_GP', 'NBA_S_OPPT_TRAD_W', 'NBA_S_OPPT_TRAD_L', 'NBA_S_OPPT_TRAD_W_PCT', 'NBA_S_OPPT_TRAD_MIN', 'NBA_S_OPPT_TRAD_FGM', 'NBA_S_OPPT_TRAD_FGA', 'NBA_S_OPPT_TRAD_FG_PCT', 'NBA_S_OPPT_TRAD_FG3M', 'NBA_S_OPPT_TRAD_FG3A', 'NBA_S_OPPT_TRAD_FG3_PCT', 'NBA_S_OPPT_TRAD_FTM', 'NBA_S_OPPT_TRAD_FTA', 'NBA_S_OPPT_TRAD_FT_PCT', 'NBA_S_OPPT_TRAD_OREB', 'NBA_S_OPPT_TRAD_DREB', 'NBA_S_OPPT_TRAD_REB', 'NBA_S_OPPT_TRAD_AST', 'NBA_S_OPPT_TRAD_TOV', 'NBA_S_OPPT_TRAD_STL', 'NBA_S_OPPT_TRAD_BLK', 'NBA_S_OPPT_TRAD_BLKA', 'NBA_S_OPPT_TRAD_PF', 'NBA_S_OPPT_TRAD_PFD', 'NBA_S_OPPT_TRAD_PTS', 'NBA_S_OPPT_TRAD_PLUS_MINUS')
F.MINE = c('OPP_DVP_FPPG', 'OPP_DVP_RANK', 'TEAM_RG_points', 'TEAMMATES_RG_points')

F.BORUTA.CONFIRMED = c('FPPG', 'Salary', 'InjuryIndicator', 'InjuryDetails',
    'NF_Min', 'NF_Pts', 'NF_Reb', 'NF_Ast', 'NF_Stl', 'NF_Blk', 'NF_TO',
    'NF_FP', 'RG_ceil', 'RG_floor', 'RG_points', 'RG_ppdk', 'RG_line',
    'RG_overunder', 'RG_total', 'RG_contr', 'RG_pownpct', 'RG_deviation',
    'RG_minutes', 'RG_rank', 'RG_salary15', 'RG_salary19', 'RG_rank20',
    'RG_salary20', 'RG_salary28', 'RG_salary43', 'RG_salary50', 'RG_salary58',
    'RG_points15', 'RG_points19', 'RG_points20', 'RG_points28', 'RG_points43',
    'RG_points50', 'RG_points51', 'RG_points58', 'RG_ADV_POW_AST',
    'RG_ADV_POW_PTS', 'RG_ADV_POW_REB', 'RG_ADV_POW_STL', 'RG_ADV_USGPCT',
    'RG_START_Order', 'RG_START_Starter', 'RG_MW_dk_current',
    'RG_MW_fa_current', 'RG_MW_y_current', 'RG_MW_dd_current',
    'RG_MW_dd_change', 'RG_MW_rstr_current', 'RG_MW_fd_current',
    'RG_MW_fdft_current', 'NBA_S_P_TRAD_GP', 'NBA_S_P_TRAD_W',
    'NBA_S_P_TRAD_MIN', 'NBA_S_P_TRAD_FGM', 'NBA_S_P_TRAD_FGA',
    'NBA_S_P_TRAD_FG_PCT', 'NBA_S_P_TRAD_FG3A', 'NBA_S_P_TRAD_FTM',
    'NBA_S_P_TRAD_FTA', 'NBA_S_P_TRAD_DREB', 'NBA_S_P_TRAD_AST',
    'NBA_S_P_TRAD_TOV', 'NBA_S_P_TRAD_STL', 'NBA_S_P_TRAD_PF',
    'NBA_S_P_TRAD_PFD', 'NBA_S_P_TRAD_PTS', 'NBA_S_P_TRAD_PLUS_MINUS',
    'NBA_S_P_ADV_OFF_RATING', 'NBA_S_P_ADV_DEF_RATING', 'NBA_S_P_ADV_AST_TO',
    'NBA_S_P_ADV_AST_RATIO', 'NBA_S_P_ADV_TM_TOV_PCT', 'NBA_S_P_ADV_EFG_PCT',
    'NBA_S_P_ADV_TS_PCT', 'NBA_S_P_ADV_USG_PCT', 'NBA_S_P_ADV_PACE',
    'NBA_S_P_ADV_PIE', 'NBA_S_P_ADV_FGM_PG', 'NBA_S_P_ADV_FGA_PG',
    'NBA_S_P_DEF_DEF_RATING', 'NBA_S_P_DEF_PCT_STL',
    'NBA_S_P_DEF_OPP_PTS_OFF_TOV', 'NBA_S_P_DEF_OPP_PTS_2ND_CHANCE',
    'NBA_S_P_DEF_OPP_PTS_FB', 'NBA_S_P_DEF_OPP_PTS_PAINT',
    'NBA_S_T_TRAD_FG_PCT', 'NBA_S_T_TRAD_FG3M', 'NBA_S_T_TRAD_FG3_PCT',
    'TEAM_RG_points', 'TEAMMATES_RG_points')
F.BORUTA.TENTATIVE = c('GamesPlayed', 'RG_diff20', 'RG_ADV_POW_BLK',
    'RG_MW_dk_change', 'NBA_S_P_TRAD_L', 'NBA_S_P_TRAD_W_PCT',
    'NBA_S_P_TRAD_FG3M', 'NBA_S_P_TRAD_FT_PCT', 'NBA_S_P_TRAD_OREB',
    'NBA_S_P_TRAD_REB', 'NBA_S_P_ADV_AST_PCT', 'NBA_S_P_ADV_OREB_PCT',
    'NBA_S_P_ADV_DREB_PCT', 'NBA_S_P_ADV_REB_PCT', 'NBA_S_P_DEF_PCT_DREB',
    'NBA_PB_AGE', 'NBA_PB_PLAYER_WEIGHT', 'NBA_PB_DRAFT_YEAR',
    'NBA_PB_DRAFT_ROUND', 'NBA_PB_DRAFT_NUMBER', 'NBA_S_T_TRAD_FGM',
    'NBA_S_T_TRAD_FG3A', 'NBA_S_T_TRAD_FT_PCT', 'NBA_S_T_TRAD_OREB',
    'NBA_S_T_TRAD_AST', 'NBA_S_T_TRAD_TOV', 'NBA_S_T_TRAD_STL',
    'NBA_S_T_TRAD_PTS')
F.BORUTA.REJECTED = c('Position', 'Home', 'Team', 'Opponent', 'RG_movement',
    'RG_rankdiff', 'RG_saldiff', 'RG_rank_diff20', 'RG_ADV_D_RT',
    'RG_ADV_O_RT', 'RG_ADV_EFGPCT', 'RG_ADV_TSPCT', 'RG_START_Status',
    'RG_MW_fa_change', 'RG_MW_y_change', 'RG_MW_rstr_change',
    'RG_MW_fd_change', 'RG_MW_fdft_change', 'RG_OPP_DVP_CFPPG',
    'RG_OPP_DVP_CRK', 'RG_OPP_DVP_PFFPPG', 'RG_OPP_DVP_PFRK',
    'RG_OPP_DVP_PGFPPG', 'RG_OPP_DVP_PGRK', 'RG_OPP_DVP_SFFPPG',
    'RG_OPP_DVP_SFRK', 'RG_OPP_DVP_SGFPPG', 'RG_OPP_DVP_SGRK', 'RG_OVD_AST',
    'RG_OVD_STL', 'RG_OVD_FGM', 'RG_OVD_TO', 'RG_OVD_3PM', 'RG_OVD_BLK',
    'RG_OVD_FGPCT', 'RG_OVD_REB', 'RG_OVD_PTS', 'RG_OVD_FGA',
    'RG_OVD_OPP_AST', 'RG_OVD_OPP_STL', 'RG_OVD_OPP_FGM', 'RG_OVD_OPP_TO',
    'RG_OVD_OPP_3PM', 'RG_OVD_OPP_BLK', 'RG_OVD_OPP_FGPCT', 'RG_OVD_OPP_REB',
    'RG_OVD_OPP_PTS', 'RG_OVD_OPP_FGA', 'RG_B2B_Situation',
    'RG_B2B_OPP_Situation', 'NBA_S_P_TRAD_FG3_PCT', 'NBA_S_P_TRAD_BLK',
    'NBA_S_P_TRAD_BLKA', 'NBA_S_P_TRAD_DD2', 'NBA_S_P_TRAD_TD3',
    'NBA_S_P_ADV_NET_RATING', 'NBA_S_P_DEF_PCT_BLK', 'NBA_S_P_DEF_DEF_WS',
    'NBA_PB_PLAYER_HEIGHT_INCHES', 'NBA_PB_COLLEGE', 'NBA_PB_COUNTRY',
    'NBA_S_T_TRAD_GP', 'NBA_S_T_TRAD_W', 'NBA_S_T_TRAD_L',
    'NBA_S_T_TRAD_W_PCT', 'NBA_S_T_TRAD_MIN', 'NBA_S_T_TRAD_FGA',
    'NBA_S_T_TRAD_FTM', 'NBA_S_T_TRAD_FTA', 'NBA_S_T_TRAD_DREB',
    'NBA_S_T_TRAD_REB', 'NBA_S_T_TRAD_BLK', 'NBA_S_T_TRAD_BLKA',
    'NBA_S_T_TRAD_PF', 'NBA_S_T_TRAD_PFD', 'NBA_S_T_TRAD_PLUS_MINUS',
    'NBA_S_OPPT_TRAD_GP', 'NBA_S_OPPT_TRAD_W', 'NBA_S_OPPT_TRAD_L',
    'NBA_S_OPPT_TRAD_W_PCT', 'NBA_S_OPPT_TRAD_MIN', 'NBA_S_OPPT_TRAD_FGM',
    'NBA_S_OPPT_TRAD_FGA', 'NBA_S_OPPT_TRAD_FG_PCT', 'NBA_S_OPPT_TRAD_FG3M',
    'NBA_S_OPPT_TRAD_FG3A', 'NBA_S_OPPT_TRAD_FG3_PCT', 'NBA_S_OPPT_TRAD_FTM',
    'NBA_S_OPPT_TRAD_FTA', 'NBA_S_OPPT_TRAD_FT_PCT', 'NBA_S_OPPT_TRAD_OREB',
    'NBA_S_OPPT_TRAD_DREB', 'NBA_S_OPPT_TRAD_REB', 'NBA_S_OPPT_TRAD_AST',
    'NBA_S_OPPT_TRAD_TOV', 'NBA_S_OPPT_TRAD_STL', 'NBA_S_OPPT_TRAD_BLK',
    'NBA_S_OPPT_TRAD_BLKA', 'NBA_S_OPPT_TRAD_PF', 'NBA_S_OPPT_TRAD_PFD',
    'NBA_S_OPPT_TRAD_PTS', 'NBA_S_OPPT_TRAD_PLUS_MINUS', 'OPP_DVP_FPPG',
    'OPP_DVP_RANK')


setup = function(algToUse, featuresToUse, endDate, prodRun, filename) {
  if (algToUse == 'xgb') {
    source('source/xgb_2016.R')
  } else if (algToUse == 'rf') {
    source('source/rf2_2016.R')
  }

  if (prodRun) cat('PROD RUN: ', filename, '\n', sep='')

  #load data
  data = getData(endDate)

  #print number of feature to use
  cat('Number of features to use: ', length(featuresToUse), '/', length(colnames(data)), '\n', sep='')

  return(data)
}

createBaseModel = function(data, yName, xNames, createModel, createPrediction, computeError) {

  #create model
  cat('Creating Model...\n', sep='')
  timeElapsed = system.time(baseModel <- createModel(data, yName, xNames))
  cat('    Time to compute model: ', timeElapsed[3], '\n', sep='')
  printModelResults(baseModel)

  #print trn/cv, train error
  printTrnCvTrainErrors(baseModel, data, yName, xNames, createModel, createPrediction, computeError)
  printRGTrnCVError(data, yName, xNames, createModel, computeError)

  return(baseModel)
}

findFirstIndexOfDate = function(data, date) {
  index = which(data$Date == date)
  if (length(index) > 0) {
    return(which(data$Date == date)[1])
  }
  return(-1)
}
findLastIndexOfDate = function(data, date) {
  dateIndices = which(data$Date == date)
  if (length(dateIndices) > 0) {
    return(dateIndices[length(dateIndices)])
  }
  return(-1)
}
splitDataIntoTrainTest = function(data, startDate, splitDate) {
  startIndex = ifelse(startDate == 'start', 1, findFirstIndexOfDate(data, startDate))
  if (splitDate == 'end') {
    train = data[startIndex:nrow(data),]
    test = NULL
  } else {
    splitIndex = findFirstIndexOfDate(data, splitDate)
    endIndex = findLastIndexOfDate(data, splitDate)
    train = data[startIndex:(splitIndex-1),]
    test = data[splitIndex:endIndex,]
  }
  return(list(train=train, test=test))
}

getHighestWinningScore = function(contestData, dateStr) {
  #return the highest winnning score for this date
  return(max(contestData[contestData$Date == dateStr, 'HighestScore'], na.rm=T))
}
getLowestWinningScore = function(contests, dateStr, type='all', entryFee=-1) {
  #return the lowest lastWinningScore; essentially, this is what i need to have won anything in any contest
  contests = contests[contests$Date == dateStr,]
  if (type != 'all') {
    if (type == '5050') {
      contests = contests[contests$Is5050 == 1,]
    } else if (type == 'non5050') {
      contests = contests[contests$Is5050 == 0,]
    }
  }
  if (entryFee > -1) {
    contests = contests[contests$EntryFee == entryFee,]
  }

  if (sum(!is.na(contests$LastWinningScore)) > 0) {
    return(median(contests$LastWinningScore, na.rm=T))
  }
  return(NA)
}

computeActualFP = function(team, test) {
  return(sum(getTeamIndividualActualFPs(team, test)))
}
getTeamIndividualActualFPs = function(team, test) {
  return(test[test$Name %in% team$Name, 'FantasyPoints'])
}

printRGTrnCVError = function(data, yName, xNames, createModel, computeError) {
  #split data into train, cv
  split = splitData(data, yName)
  train = split$train
  cv = split$cv

  #compute train and cv errors
  model = createModel(train, yName, xNames)
  trnError = computeError(train[, yName], train$RG_points)
  cvError = computeError(cv[, yName], cv$RG_points)
  trainError = computeError(data[, yName], data$RG_points)
  cat('    RG Trn/CV/Train: ', trnError, '/', cvError, '/', trainError, '\n', sep='')
}

plotScores = function(dateStrs, yLow, yHigh, lowest5050s=list(), labels5050=c(), greedyTeamExpected=c(), greedyTeamActual=c(), hillClimbingTeams=list(), medianActualFPs=c(), name='Scores', save=FALSE, main='Title') {
  cat('    Plotting Scores...\n')

  if (save) png(createPlotFilename(name, FILENAME), width=500, height=350)

  labels = c()
  colors = c()

  dates = as.Date(dateStrs)

  numHillClimbing = length(hillClimbingTeams)
  numLowest5050s = length(lowest5050s)

  #get ymin and ymax
  minValue = min(yLow, greedyTeamExpected, greedyTeamActual, medianActualFPs, na.rm=T)
  maxValue = max(yHigh, greedyTeamExpected, greedyTeamActual, medianActualFPs, na.rm=T)
  if (numLowest5050s > 0) {
    for (i in 1:numLowest5050s) {
      minValue = min(minValue, lowest5050s[[i]], na.rm=T)
      maxValue = max(maxValue, lowest5050s[[i]], na.rm=T)
    }
  }
  if (numHillClimbing > 0) {
    for (i in 1:numHillClimbing) {
      minValue = min(minValue, hillClimbingTeams[[i]], na.rm=T)
      maxValue = max(maxValue, hillClimbingTeams[[i]], na.rm=T)
    }
  }

  #draw band
  plot(dates, yLow, type='l', col='blue', ylim=c(minValue, maxValue+50), ylab='Fantasy Points', xlab='Date', xaxt='n', main=main)
  lines(dates, yHigh, col='blue')
  polygon(c(dates, rev(dates)), c(yHigh, rev(yLow)),
          col = "azure", border = NA)
  labels = c(labels, 'Tournament Results')
  colors = c(colors, 'blue')

  #draw lowest5050
  if (numLowest5050s > 0) {
    colors5050 = c('red', 'orange')
    for (i in 1:numLowest5050s) {
      lines(dates, lowest5050s[[i]], col=colors5050[i])
      labels = c(labels, labels5050[i])
      colors = c(colors, colors5050[i])
    }
  }

  #draw greedy expected
  if (length(greedyTeamExpected) > 0) {
    lines(dates, greedyTeamExpected, col='purple')
    labels = c(labels, 'My Team Expected')
    colors = c(colors, 'purple')
  }

  #draw hill climbing
  if (numHillClimbing > 0) {
    for (i in 1:numHillClimbing) {
      lines(dates, hillClimbingTeams[[i]], col='grey', lty=2)
    }
    #draw greedy as gray
    if (length(greedyTeamActual) > 0) {
      lines(dates, greedyTeamActual, col='grey')
    }
    labels = c(labels, 'My Teams')
    colors = c(colors, 'grey')

    #draw median
    if (length(medianActualFPs) > 0) {
      lines(dates, medianActualFPs, col='black')
      labels = c(labels, 'My Teams Median')
      colors = c(colors, 'black')
    }
  } else {
    if (length(greedyTeamActual) > 0) {
      #draw greedy as green
      lines(dates, greedyTeamActual, col='green')
      labels = c(labels, 'My Team Actual')
      colors = c(colors, 'green')
    }
  }

  legend(x='topright', legend=labels, fill=colors, inset=0.02)

  #add date axis
  axis.Date(side=1, dates, format="%m/%d")

  #add grid
  grid()

  if (save) dev.off()
}

makeTeams = function(data, yName, xNames, maxCov, numHillClimbingTeams, createTeamPrediction, toPlot, prodRun) {
  cat('Now let\'s see how I would\'ve done each day...\n')

  contestData = getContestData()

  cat('    Creating teams with max cov:', maxCov, '\n')
  #these are arrays to plot later
  myRmses = c()
  nfRmses = c()
  rgRmses = c()
  fdRmses = c()
  teamRatios = c()
  myTeamExpectedFPs = c()
  myTeamActualFPs = c()
  myTeamRmses = c()
  myTeamGreedyExpectedFPs = c()
  myTeamHillClimbingExpectedFPs = c()
  highestWinningScores = c()
  lowestWinningScores = c()
  lowestWinningScores_5050_1 = c()
  lowestWinningScores_5050_2 = c()
  myTeamHillClimbingActualFPs = vector('list', numHillClimbingTeams)
  for (i in 1:numHillClimbingTeams) myTeamHillClimbingActualFPs[[i]] = numeric()
  medianActualFPs = c()

  dateStrs = getUniqueDates(data)[-1] #-1 uses all but the first element
  for (dateStr in dateStrs) {
    cat('    ', dateStr, ': ', sep='')

    #split data into train, test
    trainTest = splitDataIntoTrainTest(data, 'start', dateStr)
    train = trainTest$train
    test = trainTest$test

    prediction = createTeamPrediction(train, test, yName, xNames)

    myRmse = computeError(test[[yName]], prediction)
    nfRmse = computeError(test[[yName]], test$NF_FP)
    rgRmse = computeError(test[[yName]], test$RG_points)
    fdRmse = computeError(test[[yName]], test$FPPG)

    #create my teams for today
    predictionDF = test
    predictionDF[[yName]] = prediction
    myTeamGreedy = createTeam_Greedy(predictionDF, maxCov=maxCov)
    myTeamExpectedFP = computeTeamFP(myTeamGreedy)
    myTeamActualFP = computeActualFP(myTeamGreedy, test)
    myTeamRmse = computeError(getTeamIndividualActualFPs(myTeamGreedy, test), myTeamGreedy$FantasyPoints)
    allMyTeamActualFPs = c(myTeamActualFP)
    if (prodRun || toPlot == 'multiscores') {
      for (i in 1:numHillClimbingTeams) {
        hillClimbingActualFP = computeActualFP(createTeam_HillClimbing(predictionDF, maxCov=maxCov), test)
        myTeamHillClimbingActualFPs[[i]] = c(myTeamHillClimbingActualFPs[[i]], hillClimbingActualFP)
        allMyTeamActualFPs = c(allMyTeamActualFPs, hillClimbingActualFP)
      }
    }
    medianActualFP = median(allMyTeamActualFPs)
    medianActualFPs = c(medianActualFPs, medianActualFP)

    #get actual fanduel winning score for currday
    highestWinningScore = getHighestWinningScore(contestData, dateStr)
    lowestWinningScore = getLowestWinningScore(contestData, dateStr, type='non5050')
    lowestWinningScore_5050_1 = getLowestWinningScore(contestData, dateStr, type='5050', entryFee=1)
    lowestWinningScore_5050_2 = getLowestWinningScore(contestData, dateStr, type='5050', entryFee=2)

    #print results
    cat('allRmse=', round(myRmse, 2), sep='')
    cat(', teamRmse=', round(myTeamRmse, 2), sep='')
    #cat(', expected=', round(myTeamExpectedFP, 2), sep='')
    #cat(', actual=', round(myTeamActualFP, 2), sep='')
    cat(', medianActual=', round(medianActualFP, 2), sep='')
    cat(', low=', round(lowestWinningScore, 2), sep='')
    #cat(', ', whichTeamITook, sep='')
    #cat(', high=', round(highestWinningScore, 2), sep='')
    cat('\n')

    #add data to arrays to plot
    myRmses = c(myRmses, myRmse)
    fdRmses = c(fdRmses, fdRmse)
    nfRmses = c(nfRmses, nfRmse)
    rgRmses = c(rgRmses, rgRmse)
    myTeamExpectedFPs = c(myTeamExpectedFPs, myTeamExpectedFP)
    myTeamActualFPs = c(myTeamActualFPs, myTeamActualFP)
    myTeamRmses = c(myTeamRmses, myTeamRmse)
    highestWinningScores = c(highestWinningScores, highestWinningScore)
    lowestWinningScores = c(lowestWinningScores, lowestWinningScore)
    lowestWinningScores_5050_1 = c(lowestWinningScores_5050_1, lowestWinningScore_5050_1)
    lowestWinningScores_5050_2 = c(lowestWinningScores_5050_2, lowestWinningScore_5050_2)
  }

  #print mean of rmses
  cat('Mean RMSE of all players/team: ', mean(myRmses), '/', mean(myTeamRmses), '\n', sep='')

  #print myteam score / lowestWinningScore ratio, call it "scoreRatios"
  scoreRatios = myTeamActualFPs/lowestWinningScores
  cat('Mean myScore/lowestScore ratio: ', mean(scoreRatios), '\n', sep='')

  return(list(
    dateStrs=dateStrs,
    myRmses=myRmses,
    fdRmses=fdRmses,
    nfRmses=nfRmses,
    rgRmses=rgRmses,
    myTeamExpectedFPs=myTeamExpectedFPs,
    myTeamActualFPs=myTeamActualFPs,
    myTeamHillClimbingActualFPs=myTeamHillClimbingActualFPs,
    medianActualFPs=medianActualFPs,
    myTeamRmses=myTeamRmses,
    scoreRatios=scoreRatios,
    highestWinningScores=highestWinningScores,
    lowestWinningScores=lowestWinningScores,
    lowestWinningScores_5050_1=lowestWinningScores_5050_1,
    lowestWinningScores_5050_2=lowestWinningScores_5050_2
  ))
}

makePlots = function(toPlot, data, yName, xNames, filename, teamStats=list(), prodRun) {
  cat('Creating plots...\n')
  doPlots(toPlot, prodRun, data, yName, xNames, filename)
  if (prodRun || toPlot == 'fi') plotImportances(baseModel, xNames, save=prodRun)
  if (length(teamStats) > 0) {
    if (prodRun || toPlot == 'scores') plotScores(teamStats$dateStrs, teamStats$lowestWinningScores, teamStats$highestWinningScores, lowest5050s=list(teamStats$lowestWinningScores_5050_1, teamStats$lowestWinningScores_5050_2), labels5050=c('50/50 $1 Contests', '50/50 $2 Contests'), greedyTeamExpected=teamStats$myTeamExpectedFPs, greedyTeamActual=teamStats$myTeamActualFPs, main='My Team Vs. Actual Contests', name='Scores', save=prodRun)
    if (prodRun || toPlot == 'multiscores') plotScores(teamStats$dateStrs, teamStats$lowestWinningScores, teamStats$highestWinningScores, lowest5050s=list(teamStats$lowestWinningScores_5050_1, teamStats$lowestWinningScores_5050_2), labels5050=c('50/50 $1 Contests', '50/50 $2 Contests'), greedyTeamActual=teamStats$myTeamActualFPs, hillClimbingTeams=teamStats$myTeamHillClimbingActualFPs, medianActualFPs=teamStats$medianActualFPs, main='My Teams Vs. Actual Contests', name='Multiscores', save=prodRun)
    if (prodRun || toPlot == 'rmse_scoreratios') plotByDate2Axis(teamStats$dateStrs, teamStats$myRmses, ylab='RMSE', ylim=c(5, 12), y2=teamStats$scoreRatios, y2lim=c(0, 1.5), y2lab='Score Ratio', main='RMSEs and Score Ratios', save=prodRun, name='RMSE_ScoreRatios', filename=filename)
    if (prodRun || toPlot == 'rmses') plotLinesByDate(teamStats$dateStrs, list(teamStats$myRmses, teamStats$fdRmses, teamStats$nfRmses, teamStats$rgRmses), ylab='RMSEs', labels=c('Me', 'FanDuel', 'NumberFire', 'RotoGrinder'), main='My Prediction Vs Other Sites', save=prodRun, name='RMSEs', filename=filename)
  }
}