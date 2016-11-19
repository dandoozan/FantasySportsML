#todo:
#D-Add dates up to yesterday (11/18): 71_nov18_xgb:  10/27-11/18, 104/230, 266, 41, 6.707493/7.760857, 1.653, 6.719638/7.945174/6.88318, Inf, 7.879964/16.12162, 0.9473712
#-Use FPPG, GamesPlayed, NBA_S_P_TRAD_MIN: dates=11/05-11/18, train/cvErrors=7.229933/9.089477, Trn/CV/Train=7.360246/8.624631/7.322529
#-Add InjuryIndicator: 6.984573/8.280182, 7.008483/8.283887/7.121777
#-Add OPP_DVP_RANK:
  #-diff b/n prediction and FP increases as DVP rank decreases and vice versa



#-use combination of MAX_COV, floor, ceil, hillClimbing numTries to get good prediction
#-gblinear might be slightly better but it takes longer and plotImportances doesn't work, so use gbtree for now
#-remove 10/26 and add RG Offense Vs Defense Advanced
#-remove F.RG.ADVANCEDPLAYERSTATS bc there are too many NAs
#-increase numTries in createTeam_HillClimbing to get a better hill climbing team
#-rescrape all nba data to get updated stats

rm(list = ls())
setwd('/Users/dan/Desktop/ML/df')
source('source/_main_common.R')

#Globals
PROD_RUN = F
NUMBER = '72'
NAME = 'rgPoints'

PLOT = 'fi' #fi, scores, cv
START_DATE = '2016-11-05'
END_DATE = '2016-11-18'
PLOT_START_DATE = '2016-10-27'
MAX_COV = Inf
NUM_HILL_CLIMBING_TEAMS = 10
ALG = 'xgb'
MAKE_TEAMS = PROD_RUN || F
FILENAME = paste0(NUMBER, '_', NAME, '_', ALG)
Y_NAME = 'FantasyPoints'

FEATURES_TO_USE = c('FPPG', 'GamesPlayed', 'NBA_S_P_TRAD_MIN', 'InjuryIndicator')#, 'OPP_DVP_RANK')

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
teamStats = if (MAKE_TEAMS) makeTeams(data, Y_NAME, FEATURES_TO_USE, MAX_COV, NUM_HILL_CLIMBING_TEAMS, createTeamPrediction, PLOT, PROD_RUN) else list()
makePlots(PLOT, data, Y_NAME, FEATURES_TO_USE, FILENAME, teamStats, PROD_RUN)

cat('Done!\n')