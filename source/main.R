#todo:
#D-Add dates up to yesterday (11/18): 71_nov18_xgb:  10/27-11/18, 104/230, 266, 41, 6.707493/7.760857, 1.653, 6.719638/7.945174/6.88318, Inf, 7.879964/16.12162, 0.9473712
#D-Use NBA FP as Y_NAME: 73_nbaFp_xgb: 10/27-11/18, 104/260, 266, 43, 6.69183/7.771218, 1.574, 6.653663/8.075014/6.870274, Inf, 7.942952/18.6436, 0.9284567
#D-Remove GTD and Out players: 74_rmGtdOut_xgbL: 10/27-11/18, 102/261, 266, 37, 6.938448/8.016219, 0.914, 6.930815/7.886743/7.095053, Inf, 8.103604/14.58009, 0.9388279
#D-Plot balance: 75_balance_xgb: 10/27-11/18, 102/261, 266, 37, 6.938448/8.016219, 0.921, 6.930815/7.886743/7.095053, Inf, Gain=$4, 8.103604/14.58009, 0.919391
#D-Fix bug in createDataFile: 76_dataBug_xgb: 10/27-11/18, 102/261, 266, 37, 6.938443/8.016218, 0.93, 6.930815/7.886737/7.095035, Inf, $4, 8.09966/14.42227, 0.9167998
#D-Compute cv rmse with same as RG data: 77_RGrmse_xgb: 10/27-11/18, 102/262, 266, 37, 6.938443/8.016218, 0.905, 7.557726/8.381168/7.727685, Inf, $4, 8.09966/14.42227, 0.9167998
#D-Add dates (up to 11/23): 78_nov23_xgb: 10/27-11/23, 102/262, 266, 38, 7.071784/8.028437, 1.448, 7.540131/8.983257/7.852722, Inf, 8.138115/14.33826, 0.9119179
#D-Use RG, NF data for trn/cv errors: 79_RGAndNF_xgb: 10/27-11/23, 102/264, 266, 38, 7.071784/8.028437, 1.155, 7.555149/9.139898/7.863341, Inf, 8.138115/14.33826, 0.9119179
#D-Plot team using RG points: 80_plotRG_xgb: 10/27-11/23, 102/264, 266, 38, 7.071784/8.028437, 1.268, 7.555149/9.139898/7.863341, Inf, 8.138115/14.33826, 0.9119179
#D-Make RG,NF error apples-to-apples: 81_RGNFerrors_xgb: 10/27-11/23, 102/264, 266, 38, 7.071784/8.028437, 1.132, 7.033946/8.14378/7.191407, RG/Mine=9.037832/9.032108, NF/Mine=8.849512/8.338964, Inf, 8.138115/14.33826, 0.9119179
#D-Rerun boruta: 82_boruta_xgb: 10/27-11/23, 121/264, 266, 45, 6.923147/8.007204, 4.332, 6.921224/8.103531/7.065831, Inf, 8.113962/16.7418, 0.9296685
#D-Retune: 83_retune_xgb: 10/27-11/23, 121/264, 266, 53, 7.701541/8.002063, 3.455, 7.694258/8.06044/7.756014, Inf, -$8, 8.081185/10.13511, 0.9107249
#D-Start plot from 11/7: 84_plotNov7_xgb: 10/27-11/23, 121/264, 266, 53, 7.701541/8.002063, 2.725, 7.694258/8.06044/7.756014, Inf, -$8, 8.094706/9.56801, 0.9151632
#D-Retune xgb params: 85_retune_xgb: 10/27-11/23, 121/264, 266, 55, 7.400829/7.981152, 3.778, 7.394017/8.098042/7.503997, Inf, $8, 8.085093/10.28753, 0.9251442
#D-Fix PlayerBios NA imputation: 86_fixPBNA_xgb: 10/27-11/23, 121/265, 266, 50, 7.455275/7.990815, 2.643, 7.42947/8.135216/7.523257, Inf, $0, 8/8, 8.076828/10.12836, 0.9109897

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
#-add back projected points features
#-run findBestSeedAndNrounds for every date rather than once at beginning on all data

rm(list = ls())
setwd('/Users/dan/Desktop/ML/df')

#Globals
PROD_RUN = T
NUMBER = '86'
NAME = 'fixPBNA'

PLOT = 'balance' #fi, scores, cv, rmses
START_DATE = '2016-10-26' #'2016-11-05'
END_DATE = '2016-11-23'
PLOT_START_DATE = '2016-11-07'
MAX_COV = Inf
NUM_HILL_CLIMBING_TEAMS = 10
CONTESTS_TO_PLOT = list(
  #list(type='FIFTY_FIFTY', entryFee=2, maxEntries=100, maxEntriesPerUser=1, winAmount=1.8, label='50/50, $2, 100, Single-Entry', color='red' ),
  list(type='DOUBLE_UP', entryFee=2, maxEntries=568, maxEntriesPerUser=1, winAmount=2, label='DoubleUp, $2, 568, Single-Entry', color='blue' ))
ALG = 'xgb'
MAKE_TEAMS = PROD_RUN || PLOT == 'scores' || PLOT == 'multiscores' || PLOT == 'balance'
FILENAME = paste0(NUMBER, '_', NAME, '_', ALG)
STARTING_BALANCE = 25

source('source/_main_common.R')

#================= Functions =================

createTeamPrediction = function(train, test, yName, xNames) {
  prediction = createPrediction(createModel(train, yName, xNames), test, xNames)
  floor = pmax(prediction - test$RG_deviation, 0)
  ceil = prediction + test$RG_deviation
  return(prediction)
}

#================= Main =================

data = setup(ALG, START_DATE, END_DATE, PROD_RUN, FILENAME)
featuresToUse = getFeaturesToUse(data)
hyperParams = findBestHyperParams(data, Y_NAME, featuresToUse)
baseModel = createBaseModel(data, Y_NAME, featuresToUse, createModel, createPrediction, computeError)
printErrors(baseModel, data, Y_NAME, featuresToUse, createModel, createPrediction, computeError)
teamStats = if (MAKE_TEAMS) makeTeams(data, Y_NAME, featuresToUse, PREDICTION_NAME, MAX_COV, NUM_HILL_CLIMBING_TEAMS, createTeamPrediction, CONTESTS_TO_PLOT, STARTING_BALANCE, PLOT, PROD_RUN) else list()
makePlots(PLOT, data, Y_NAME, featuresToUse, FILENAME, CONTESTS_TO_PLOT, teamStats, PROD_RUN)

cat('Done!\n')