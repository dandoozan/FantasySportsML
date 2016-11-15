#todo:
#D-Use all features: byplyr_01_all_xgb: 10/27-11/11, 79/92, 266, 77, 6.976525/7.717935, 1.681, 7.132318/6.901998/7.085736, Inf, 10.01754/18.61355, 0.9680755
#-make faster: create sparseMatrix before looping through the individual players
#-tune hyperparams for each player

rm(list = ls())
setwd('/Users/dan/Desktop/ML/df')
source('source/_main_common.R')

#Globals
PROD_RUN = T
NUMBER = '01'
NAME = 'all'

PLOT = 'multiscores' #fi, scores, cv
MAX_COV = Inf
NUM_HILL_CLIMBING_TEAMS = 2
ALG = 'xgb'
MAKE_TEAMS = PROD_RUN || T
FILENAME = paste0('byplyr_', NUMBER, '_', NAME, '_', ALG)

FEATURES_TO_USE = c(F.FANDUEL, F.NUMBERFIRE, F.RG.PP, F.NBA, F.MINE)

#================= Functions ===================

createTeamPrediction = function(train, test, yName, xNames) {
  teamPrediction = c()
  for (name in test$Name) {
    trainDataForPlayer = train[train$Name == name,]
    if (nrow(trainDataForPlayer) > 0) {
      testDataForPlayer = test[test$Name == name,]
      modelForPlayer = createModel(trainDataForPlayer, yName, xNames)
      predictionForPlayer = createPrediction(modelForPlayer, testDataForPlayer, xNames)
    } else {
      #maybe set prediction to RG_points rather than 0
      predictionForPlayer = 0
    }
    teamPrediction = c(teamPrediction, predictionForPlayer)
  }
  return(teamPrediction)
}

#============= Main ================

data = setup(ALG, FEATURES_TO_USE, END_DATE, PROD_RUN, FILENAME)
hyperParams = findBestHyperParams(data, Y_NAME, FEATURES_TO_USE)
baseModel = createBaseModel(data, Y_NAME, FEATURES_TO_USE, createModel, createPrediction, computeError)
teamStats = if(MAKE_TEAMS) makeTeams(data, Y_NAME, FEATURES_TO_USE, MAX_COV, NUM_HILL_CLIMBING_TEAMS, createTeamPrediction, PLOT, PROD_RUN) else list()
makePlots(PLOT, data, Y_NAME, FEATURES_TO_USE, FILENAME, teamStats, PROD_RUN)

cat('Done!\n')