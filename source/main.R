#todo:
#-Use rmse, logy (RG_points, NF_FP):
  #-rf: 0.3303115/42.00708, 5.427849/9.789181/5.56946, $0, 8/8, 9.702848/10.49211/9.877602, 0.9344018
  #-xgb: 0.521395/0.541843, 8.886824/9.610087/9.004735, $16, 12/4, 9.403513/10.75018/9.756688, 0.9792446


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
source('source/xgb_2016.R')
source('source/rf_2016.R')
source('source/glm_2016.R')

#Globals
PROD_RUN = F
NUMBER = '87'
NAME = 'retune'
ALGS = list(rf=rf(), xgb=xgb())

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