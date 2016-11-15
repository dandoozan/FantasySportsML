#todo:
#D-use all features: 20_all_xgb: Dates=10/27-11/8, NumFeatures=80/93, Seed=?, Nrounds=?, XgbTrain/CvError=4.878435/8.200007, TimeToComputeModel=0.845, Trn/CV/Train=4.879084/7.799062/5.216833, MaxCov=Inf, Mean RMSE (AllPlayers/MyTeam)=8.152958/36.76341, Ratio of MyScore to LowestScore=0.9877099
#D-tune hyperparams: 21_tune_xgb: 10/27-11/8, 80/93, 266, 83, 6.762798/7.723589, 1.232, 6.797523/7.527155/6.903303, Inf, 7.771552/34.14032, 0.9890346 <-- new best!
#D-Use MAX_COV=0.5: 22_cov_xgb: 10/27-11/8, 80/93, 266, 83, 6.762798/7.723589, 1.285, 6.797523/7.527155/6.903303, 0.5, 7.771552/29.82064, 1.021105
#D-Tune using gblinear: 23_gblinear_xgb: 10/27-11/8, 80/93, 266, 1368, 7.523755/7.787023, 1.581, 7.578275/7.510651/7.546615, Inf, 7.860481/41.00078, 0.9811104
#D-Revert back to gbtree, cov=Inf: 24_revert_xgb: 10/27-11/8, 80/93, 266, 83, 6.762798/7.723589, 1.249, 6.797523/7.527155/6.903303, Inf, 7.771552/34.14032, 0.9890346
#D-Add more dates (up to 11/11): 25_nov11_xgb: 10/27-11/11, 80/93, 266, 83, 6.931508/7.714106, 1.582, 7.095388/6.890297/7.044084, Inf, 7.743002/29.56711, 0.9956685 <-- new best!
#D-Remove NBA_SEASON_AGE: 26_removeAge_xgb: 10/27-11/11, 79/92, 266, 77, 6.976525/7.717935, 1.486, 7.132318/6.901998/7.085736, Inf, 7.736499/28.44422, 0.9860664 <-- new best!
#D-plot multiple teams: 27_multiteams_xgb: 10/27-11/11, 79/92, 266, 77, 6.976525/7.717935, 1.507, 7.132318/6.901998/7.085736, Inf, 7.736499/28.44422, 0.9860664
#D-Make create teams more efficient: 28_efficientteams_xgb: 10/27-11/11, 79/92, 266, 77, 6.976525/7.717935, 1.696, 7.132318/6.901998/7.085736, Inf, 7.736499/28.44422, 0.9860664
#D-Revert create teams: 29_revertTeams_xgb: 10/27-11/11, 79/92, 266, 77, 6.976525/7.717935, 1.509, 7.132318/6.901998/7.085736, Inf, 7.736499/28.44422, 0.9860664
#D-Compute teamRmse correctly: 30_teamrmse_xgb: 10/27-11/11, 79/92, 266, 77, 6.976525/7.717935, 1.779, 7.132318/6.901998/7.085736, Inf, 7.736499/17.48905, 0.9860664
#D-Add teammates expected RG points: 31_teammates_xgb: 10/27-11/11, 81/94, 266, 81, 6.925018/7.701815, 1.997, 7.084283/6.873463/7.040948, Inf, 7.724325/18.74159, 0.9985387 <-- new best!
#D-plot median of lowest contest results: 32_mediancontest_xgb: 10/27-11/11, 81/94, 266, 81, 6.925018/7.701815, 1.599, 7.084283/6.873463/7.040948, Inf, 7.724325/18.74159, 0.9440826
#D-Add NBA PlayerBios: 33_playerbios_xgb: 10/27-11/11, 89/102, 266, 107, 6.772287/7.697509, 9.504, 6.904363/6.904882/6.893519, Inf, 7.750878/18.79264, 0.9617669
#D-Add RG StartingLineups: 34_starter_xgb: 10/27-11/11, 92/105, 266, 101, 6.777758/7.680179, 10.026, 6.907689/6.935779/6.879808, Inf, 7.73361/18.6916, 0.9273415 <-- new best!
#-Set numeric NAs to 1000: 35_numNA_xgb: 10/27-11/11, 92/105, 266, 85, 6.872778/7.686423, 9.691, 7.016102/6.916518/6.974054, Inf, 7.703383/17.91926, 0.9147303 <-- new best!

#-add back-to-back (RG BackToBack)
#-team wpct (NBA Team_Traditional)
#-offense/defense rating (RG OffenseVsDefense)
#-whether in RG optimal lineup (RG OptimalLineup)
#-salary/rank change (RG MarketWatch)
#-touches (RG Touches)
#-vegas odds (RG VegasOdds)
#-season-long advanced
#-season-long defense

#-use combination of MAX_COV, floor or ceil to get good prediction
#-use curated features
#-adjust MAX_COV
#-tune again using xgbcv as metric to watch
#-gblinear might be slightly better but it takes longer and plotImportances doesn't work, so use gbtree for now

rm(list = ls())
setwd('/Users/dan/Desktop/ML/df')
source('source/_main_common.R')

#Globals
PROD_RUN = T
NUMBER = '35'
NAME = 'numNA'

PLOT = 'multiscores' #fi, scores, cv
MAX_COV = Inf
NUM_HILL_CLIMBING_TEAMS = 4
ALG = 'xgb'
MAKE_TEAMS = PROD_RUN || T
FILENAME = paste0(NUMBER, '_', NAME, '_', ALG)

FEATURES_TO_USE = c(F.FANDUEL, F.NUMBERFIRE, F.RG.PP, F.NBA.TRADITIONAL, F.NBA.PLAYERBIOS, F.RG.START, F.MINE)

#================= Functions =================

createTeamPrediction = function(train, test, yName, xNames) {
  prediction = createPrediction(createModel(train, yName, xNames), test, xNames)
  floor = pmax(prediction - test$RG_deviation, 0)
  ceil = prediction + test$RG_deviation
  return(prediction)
}

#================= Main =================

data = setup(ALG, FEATURES_TO_USE, END_DATE, PROD_RUN, FILENAME)
hyperParams = findBestHyperParams(data, Y_NAME, FEATURES_TO_USE)
baseModel = createBaseModel(data, Y_NAME, FEATURES_TO_USE, createModel, createPrediction, computeError)
teamStats = if(MAKE_TEAMS) makeTeams(data, Y_NAME, FEATURES_TO_USE, MAX_COV, NUM_HILL_CLIMBING_TEAMS, createTeamPrediction, PLOT, PROD_RUN) else list()
makePlots(PLOT, data, Y_NAME, FEATURES_TO_USE, FILENAME, teamStats, PROD_RUN)

cat('Done!\n')