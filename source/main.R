#todo:
#-Use rmse, y (RG_points, NF_FP):
  #-lm: 8.80294/0.5589454, 8.704673/9.173929/8.79985, Inf, -$8, 6/10, 8.830848/9.546116/10.05835, 0.9280507
  #-rf: 87.61809/50.11933, 5.025854/9.693496/5.134203, Inf, $8, 10/6, 9.410472/10.19983/9.351791, 0.9394312
  #-xgb: 8.502619/8.841369, 8.419662/9.240263/8.552652, Inf, $0, 8/8, 8.921783/9.705028/8.938733, 0.941946
#-Use rmse, logy (RG_points, NF_FP):
  #-lm: 0.5631245/0.4433804, 10.36607/10.85297/10.36518, Inf, -$8, 6/10, 10.40135/12.62814/18.09946, 0.9195618
  #-rf: 0.3303115/42.00708, 5.427849/9.789181/5.56946, Inf, $0, 8/8, 9.702848/10.49211/9.877602, 0.9344018
  #-xgb: 0.521395/0.541843, 8.886824/9.610087/9.004735, Inf, $16, 12/4, 9.403513/10.75018/9.756688, 0.9792446


#-use combination of MAX_COVS, floor, ceil, hillClimbing numTries, startDate to get good prediction
#-gblinear might be slightly better but it takes longer and plotImportances doesn't work, so use gbtree for now
#-remove 10/26 and add RG Offense Vs Defense Advanced
#-remove F.RG.ADVANCEDPLAYERSTATS bc there are too many NAs
#-increase numTries in createTeam_HillClimbing to get a better hill climbing team
#-rescrape all nba data to get updated stats
#-make sure 11/20 has all data for all players and teams that played that day since I scraped it late
#-maybe only use data from 11/5 onward or only the last X (2?) weeks
#-add back projected points features
#-run findBestSeedAndNrounds for every date rather than once at beginning on all data
#-use RG_points51 as a feature

rm(list = ls())
setwd('/Users/dan/Desktop/ML/df')
source('source/lm_2016.R')
source('source/rf_2016.R')
source('source/xgb_2016.R')

#Globals
PROD_RUN = F
NUMBER = '87'
NAME = 'retune'
ALGS = list(lm=lm(), rf=rf(), xgb=xgb())

PLOT = 'fi' #fi, bal, scores, cv, rmses
START_DATE = '2016-10-26' #'2016-11-05'
END_DATE = '2016-11-23'
PLOT_START_DATE = '2016-11-07'
.MAX_COV = Inf
MAX_COVS = list(C=.MAX_COV, SF=.MAX_COV, SG=.MAX_COV, PF=.MAX_COV, PG=.MAX_COV)
NUM_HILL_CLIMBING_TEAMS = 10
CONTESTS_TO_PLOT = list(
  #list(type='FIFTY_FIFTY', entryFee=2, maxEntries=100, maxEntriesPerUser=1, winAmount=1.8, label='50/50, $2, 100, Single-Entry', color='red' ),
  list(type='DOUBLE_UP', entryFee=2, maxEntries=568, maxEntriesPerUser=1, winAmount=2, label='DoubleUp, $2, 568, Single-Entry', color='blue' ))
MAKE_TEAMS = T#PROD_RUN || PLOT == 'scores' || PLOT == 'multiscores' || PLOT == 'bal'
FILENAME = paste0(NUMBER, '_', NAME)
STARTING_BALANCE = 25

source('source/_main_common.R')

#================= Functions =================

createTeamPrediction = function(obj, train, test, yName, xNames, hyperParams, amountToAddToY) {
  prediction = obj$createPrediction(obj$createModel(train, yName, xNames, hyperParams, amountToAddToY), test, xNames, amountToAddToY)
  floor = pmax(prediction - test$StDevFP, 0)
  ceil = prediction + test$StDevFP
  return(prediction)
}

#================= Main =================

data = setup(START_DATE, END_DATE, PROD_RUN, FILENAME)
amountToAddToY = computeAmountToAddToY(data, Y_NAME)
featuresToUse = getFeaturesToUse(data)
runAlgs(ALGS, data, amountToAddToY, featuresToUse)
cat('Done!\n')