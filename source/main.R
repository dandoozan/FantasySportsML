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
#D-Set numeric NAs to 1000: 35_numNA_xgb: 10/27-11/11, 92/105, 266, 85, 6.872778/7.686423, 9.691, 7.016102/6.916518/6.974054, Inf, 7.703383/17.91926, 0.9147303 <-- new best!
#D-Add NBA Team features: 36_team_xgb: 10/27-11/11, 118/131, 266, 102, 6.750822/7.664908, 6.363, 6.870544/6.913532/6.871711, Inf, 7.716599/17.70431, 0.9262162
#D-Add NBA Opp team features: 37_opp_xgb: 10/27-11/11, 144/157, 266, 101, 6.729758/7.671829, 7.292, 6.862323/6.924714/6.826556, Inf, 7.717891/18.05657, 0.9195285
#D-Add nba advanced: 38_nbaAdv_xgb: 10/27-11/11, 161/174, 266, 113, 6.664812/7.671916, 8.479, 6.804168/6.889426/6.781096, Inf, 7.738682/18.0611, 0.924935
#D-Add RG OffVsDef: 39_rgOvD_xgb: 10/27-11/11, 171/184, 266, 119, 6.635796/7.662486, 12.482, 6.752482/6.958521/6.746832, Inf, 7.760703/17.182, 0.9426347
#D-Add RG Opponent OffVsDef: 40_rgOppOvD_xgb: 10/27-11/11, 181/194, 266, 118, 6.634613/7.672941, 12.594, 6.741939/6.945327/6.745809, Inf, 7.731329/16.75071, 0.9421539
#D-Remove country and college: 41_rmCollegeCountry_xgb: 10/27-11/11, 179/194, 266, 111, 6.675282/7.675929, 3.941, 6.802302/6.927807/6.779758, Inf, 7.758061/17.7694, 0.90549
#D-Remove InjuryDetails: 42_rmInjuryDetails_xgb: 10/27-11/11, 178/194, 266, 111, 6.675282/7.675929, 3.683, 6.802302/6.927807/6.779758, Inf, 7.759193/16.98893, 0.9154588
#D-Add RG AdvancedPlayerStats: 43_rgAdv_xgb: 10/27-11/11, 188/204, 266, 81, 6.846089/7.690408, 3.323, 6.998297/6.902806/6.969302, Inf, 7.708973/17.87509, 0.9420913
#-Add RG MarketWatch: 44_rgMW_xgb: 10/27-11/11, 202/218, 266, 102, 6.678373/7.69498, 3.826, 6.848475/6.951411/6.823288, Inf, 7.751412/18.46984, 0.9252272

#-verify marketwatch

#-salary/rank change (RG MarketWatch)
#-touches (RG Touches)
#-vegas odds (RG VegasOdds)
#-nba GP
#-nba defense
#-add back-to-back (RG BackToBack)

#-use combination of MAX_COV, floor or ceil to get good prediction
#-use curated features
#-adjust MAX_COV
#-tune again using xgbcv as metric to watch
#-gblinear might be slightly better but it takes longer and plotImportances doesn't work, so use gbtree for now
#-tune earlystopround in findBestSeedAndNrounds
#-remove 10/26 and add RG Offense Vs Defense Advanced
#-remove NBA Opp features
#-use nba GP instead of FD GamesPlayed
#-add back college, country, InjuryDetails
#-remove F.RG.ADVANCEDPLAYERSTATS bc there are too many NAs
#-remove some of the RG_Salary_X features now that I have the MarketWatch features


rm(list = ls())
setwd('/Users/dan/Desktop/ML/df')
source('source/_main_common.R')

#Globals
PROD_RUN = T
NUMBER = '44'
NAME = 'rgMW'

PLOT = 'scores' #fi, scores, cv
MAX_COV = Inf
NUM_HILL_CLIMBING_TEAMS = 4
ALG = 'xgb'
MAKE_TEAMS = PROD_RUN || T
FILENAME = paste0(NUMBER, '_', NAME, '_', ALG)

FEATURES_TO_USE = c(F.FANDUEL_FAST, F.NUMBERFIRE,
                    F.RG.PP, F.RG.ADVANCEDPLAYERSTATS, F.RG.MARKETWATCH, F.RG.START, F.RG.OVD.BASIC, F.RG.OVD.OPP.BASIC,
                    F.NBA.SEASON.PLAYER.TRADITIONAL, F.NBA.SEASON.PLAYER.ADVANCED, F.NBA.PLAYERBIOS_NUM, F.NBA.SEASON.TEAM.TRADITIONAL, F.NBA.SEASON.OPPTEAM.TRADITIONAL,
                    F.MINE)

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

timeElapsed = system.time(teamStats <- if(MAKE_TEAMS) makeTeams(data, Y_NAME, FEATURES_TO_USE, MAX_COV, NUM_HILL_CLIMBING_TEAMS, createTeamPrediction, PLOT, PROD_RUN) else list())
cat('Time taken to make teams: ', timeElapsed[3], '\n', sep='')

makePlots(PLOT, data, Y_NAME, FEATURES_TO_USE, FILENAME, teamStats, PROD_RUN)

cat('Done!\n')