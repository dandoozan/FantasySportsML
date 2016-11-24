#todo:
#D-Add dates up to yesterday (11/18): 71_nov18_xgb:  10/27-11/18, 104/230, 266, 41, 6.707493/7.760857, 1.653, 6.719638/7.945174/6.88318, Inf, 7.879964/16.12162, 0.9473712
#D-Use NBA FP as Y_NAME: 73_nbaFp_xgb: 10/27-11/18, 104/260, 266, 43, 6.69183/7.771218, 1.574, 6.653663/8.075014/6.870274, Inf, 7.942952/18.6436, 0.9284567
#D-Remove GTD and Out players: 74_rmGtdOut_xgbL: 10/27-11/18, 102/261, 266, 37, 6.938448/8.016219, 0.914, 6.930815/7.886743/7.095053, Inf, 8.103604/14.58009, 0.9388279
#D-Plot balance: 75_balance_xgb: 10/27-11/18, 102/261, 266, 37, 6.938448/8.016219, 0.921, 6.930815/7.886743/7.095053, Inf, Gain=$4, 8.103604/14.58009, 0.919391
#D-Fix bug in createDataFile: 76_dataBug_xgb: 10/27-11/18, 102/261, 266, 37, 6.938443/8.016218, 0.93, 6.930815/7.886737/7.095035, Inf, $4, 8.09966/14.42227, 0.9167998

#-verify double up contests
#-Use AVG_FP, NBA_S_P_TRAD_GP: dates=11/05-11/18, train/cvErrors=7.669375/9.117033, Trn/CV/Train=7.703522/8.877059/7.814077
#-Add InjuryIndicator: 7.275631/8.38811,  7.347842/8.29548/7.404794
#-Add NBA_S_P_ADV_PACE:

#-use combination of MAX_COV, floor, ceil, hillClimbing numTries to get good prediction
#-gblinear might be slightly better but it takes longer and plotImportances doesn't work, so use gbtree for now
#-remove 10/26 and add RG Offense Vs Defense Advanced
#-remove F.RG.ADVANCEDPLAYERSTATS bc there are too many NAs
#-increase numTries in createTeam_HillClimbing to get a better hill climbing team
#-rescrape all nba data to get updated stats
#-make sure 11/20 has all data for all players and teams that played that day since I scraped it late
#-maybe only use data from 11/5 onward or only the last X (2?) weeks

rm(list = ls())
setwd('/Users/dan/Desktop/ML/df')

#Globals
PROD_RUN = T
NUMBER = '76'
NAME = 'dataBug'

PLOT = 'balance' #fi, scores, cv
START_DATE = '2016-10-26' #'2016-11-05'
END_DATE = '2016-11-18'
PLOT_START_DATE = '2016-10-27'
MAX_COV = Inf
NUM_HILL_CLIMBING_TEAMS = 10
CONTESTS_TO_PLOT = list(
  #list(type='FIFTY_FIFTY', entryFee=2, maxEntries=100, maxEntriesPerUser=1, winAmount=1.8, label='50/50, $2, 100, Single-Entry', color='red' ),
  list(type='DOUBLE_UP', entryFee=2, maxEntries=568, maxEntriesPerUser=1, winAmount=2, label='DoubleUp, $2, 568, Single-Entry', color='red' ))
ALG = 'xgb'
MAKE_TEAMS = PROD_RUN || PLOT == 'scores' || PLOT == 'multiscores' || PLOT == 'balance'
FILENAME = paste0(NUMBER, '_', NAME, '_', ALG)
Y_NAME = 'FP'
STARTING_BALANCE = 25

source('source/_main_common.R')

FEATURES_TO_USE = F.BORUTA.CONFIRMED
#FEATURES_TO_USE = c('AVG_FP', 'NBA_S_P_TRAD_GP', 'InjuryIndicator', 'NBA_S_P_ADV_PACE')

#================= Functions =================

createTeamPrediction = function(train, test, yName, xNames) {
  prediction = createPrediction(createModel(train, yName, xNames), test, xNames)
  floor = pmax(prediction - test$RG_deviation, 0)
  ceil = prediction + test$RG_deviation
  return(prediction)
}

#================= Main =================

data = setup(ALG, FEATURES_TO_USE, START_DATE, END_DATE, PROD_RUN, FILENAME)
hyperParams = findBestHyperParams(data, Y_NAME, FEATURES_TO_USE)
baseModel = createBaseModel(data, Y_NAME, FEATURES_TO_USE, createModel, createPrediction, computeError)
teamStats = if (MAKE_TEAMS) makeTeams(data, Y_NAME, FEATURES_TO_USE, MAX_COV, NUM_HILL_CLIMBING_TEAMS, createTeamPrediction, CONTESTS_TO_PLOT, STARTING_BALANCE, PLOT, PROD_RUN) else list()
makePlots(PLOT, data, Y_NAME, FEATURES_TO_USE, FILENAME, CONTESTS_TO_PLOT, teamStats, PROD_RUN)

cat('Done!\n')