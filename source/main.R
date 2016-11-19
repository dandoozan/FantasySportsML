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
#D-Add RG MarketWatch: 44_rgMW_xgb: 10/27-11/11, 202/218, 266, 102, 6.678373/7.69498, 3.826, 6.848475/6.951411/6.823288, Inf, 7.751412/18.46984, 0.9252272
#D-Fix MarketWatch Yahoo: 45_fixMW_xgb: 10/27-11/11, 202/218, 266, 102, 6.676079/7.70062, 3.817, 6.819313/6.928745/6.825204, Inf, 7.744314/19.18012, 0.9351234
#D-Add nba GP: 46_nbaGP_xgb: 10/27-11/11, 203/219, 266, 106, 6.653886/7.691137, 4.222, 6.794239/6.931079/6.805209, Inf, 7.748192/19.2912, 0.9092166
#D-Add NBA Defense: 47_nbaDef_xgb: 10/27-11/11, 212/228, 266, 97, 6.711039/7.705174, 4.089, 6.865964/6.928642/6.848675, Inf, 7.749246/17.77589, 0.9192925
#D-Add BackToBack: 48_b2b_xgb: 10/27-11/11, 214/230, 266, 95, 6.725143/7.702265, 3.953, 6.890779/6.930635/6.858175, Inf, 7.755357/17.19484, 0.9140041
#D-Use boruta confirmed features: 49_boruta_xgb: 10/27-11/11, 95/230, 266, 79, 6.90763/7.720568, 1.436, 7.084831/6.903145/7.027715, Inf, 7.728519/16.21745, 0.9611085
#D-Add boruta tentative: 50_borutaTntv_xgb: 10/27-11/11, 123/230, 266, 105, 6.719698/7.685369, 2.258, 6.867719/6.948294/6.86174, Inf, 7.771497/16.60619, 0.9041602
#D-Remove RG_MW_fd_current: 51_rmFdCurr_xgb: 10/27-11/11, 122/229, 266, 93, 6.789944/7.691975, 2.113, 6.929501/6.911408/6.903851, Inf, 7.756041/17.04462, 0.9323927
#D-Use auto-downloaded FD data: 52_autoFD_xgb: 10/27-11/11, 122/229, 266, 108, 6.703789/7.685564, 2.383, 6.832482/6.924322/6.824815, Inf, 7.784987/19.37958, 0.9208128
#D-add dates (up to 11/14): 53_nov14_xgb: 10/27-11/14, 122/229, 266, 99, 6.938578/7.729703, 2.596, 6.89587/7.901851/7.05387, Inf, 7.859666/17.93269, 0.921751
#D-make better plots: 54_plot_xgb: 10/27-11/14, 122/229, 266, 99, 6.938578/7.729703, 2.522, 6.89587/7.901851/7.05387, Inf, 7.859666/17.93269, 0.921751
#D-Tune like kaggler: 55_tunek_xgb: 10/27-11/14, 122/229, 266, 50, 7.050717/7.725374, 0.514, 7.009162/7.895815/7.180566, Inf, 7.803517/19.19325, 0.9434116 <-- new best with new dates
#D-Use new boruta confirmed and tentative: 56_boruta_xgb: 10/27-11/14, 129/229, 266, 54, 7.01587/7.726528, 3.345, 6.981771/7.893756/7.125948, Inf, 7.82811/17.04404, 0.9245518
#D-Use only boruta confirmed: 57_bconf_xgb: 10/27-11/14, 105/229, 266, 52, 7.051704/7.732884, 0.488, 7.011773/7.934879/7.161589, Inf, 7.844367/17.9021, 0.9388054
#D-Retune: 58_retune_xgb: 10/27-11/14, 105/229, 266, 53, 6.517612/7.722402, 0.589, 6.509602/7.962631/6.678165, Inf, 7.92412/16.70604, 0.9365133
#D-Add contest type: 59_contestType_xgb: 10/27-11/14, 105/229, 266, 53, 6.517612/7.722402, 0.592, 6.509602/7.962631/6.678165, Inf, 7.92412/16.70604, 0.9364618
#D-Plot only true tournaments: 60_tourneys_xgb: 10/27-11/14, 105/229, 266, 53, 6.517612/7.722402, 0.582, 6.509602/7.962631/6.678165, Inf, 7.92412/16.70604, 0.9320178
#D-Plot 10 hill climbing teams: 61_10teams_xgb: 10/27-11/14, 105/229, 266, 53, 6.517612/7.722402, 0.596, 6.509602/7.962631/6.678165, Inf, 7.92412/16.70604, 0.9320178
#D-Set MAX_COV to 0.5: 62_cov05_xgb: 10/27-11/14, 105/229, 266, 53, 6.517612/7.722402, 0.578, 6.509602/7.962631/6.678165, 0.5, 7.92412/17.74164, 0.9296532
#D-Use ceil: 63_cov05_ceil_xgb: 10/27-11/14, 105/229, 266, 53, 6.517612/7.722402, 0.59, 6.509602/7.962631/6.678165, 0.5, 10.46674/22.11585, 0.9450008
#D-Use floor: 64_cov05_floor_xgb: 10/27-11/14, 105/229, 266, 53, 6.517612/7.722402, 0.633, 6.509602/7.962631/6.678165, 0.5, 10.19702/15.93937, 0.8762993
#D-Use ceil, cov=Inf: 65_covInf_ceil_xgb: 10/27-11/14, 105/229, 266, 53, 6.517612/7.722402, 0.631, 6.509602/7.962631/6.678165, Inf, 10.46674/22.11585, 0.9450008
#D-Use floor, cov=Inf: 66_covInf_floor_xgb: 10/27-11/14, 105/229, 266, 53, 6.517612/7.722402, 0.617, 6.509602/7.962631/6.678165, Inf, 10.19702/16.56721, 0.9054912
#D-Remove projections: 67_noProj_xgb: 10/27-11/14, 211/229, 266, 39, 6.674566/7.760814, 11.824, 6.635393/7.992468/6.846707, Inf, 7.894667/17.21335, 0.918429
#D-Rerun boruta: 68_boruta_xgb: 10/27-11/14, 104/229, 266, 39, 6.813247/7.742457, 0.698, 6.749739/7.947403/6.938571, Inf, 7.844551/18.45305, 0.9623523
#D-Fix bug in greedy team: 69_greedy_xgb: 10/27-11/14, 104/230, 266, 39, 6.813247/7.742457, 1.102, 6.749739/7.947403/6.938571, Inf, 7.844551/17.59835, 0.9624888
#D-Retune xgb params: 70_retune_xgb: 10/27-11/14, 104/230, 266, 39, 6.631999/7.767962, 1.049, 6.588949/7.888081/6.763689, Inf, 7.902768/15.55635, 0.948499
#D-Add dates up to yesterday (11/18): 71_nov18_xgb:  10/27-11/18, 104/230, 266, 41, 6.707493/7.760857, 1.653, 6.719638/7.945174/6.88318, Inf, 7.879964/16.12162, 0.9473712

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
PROD_RUN = T
NUMBER = '71'
NAME = 'nov18'

PLOT = 'scores' #fi, scores, cv
PLOT_START_DATE = '2016-10-27'
END_DATE = '2016-11-18'
MAX_COV = Inf
NUM_HILL_CLIMBING_TEAMS = 10
ALG = 'xgb'
MAKE_TEAMS = PROD_RUN || T
FILENAME = paste0(NUMBER, '_', NAME, '_', ALG)
Y_NAME = 'FantasyPoints'

FEATURES_TO_USE = c(F.BORUTA.CONFIRMED)

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
teamStats = if (MAKE_TEAMS) makeTeams(data, Y_NAME, FEATURES_TO_USE, MAX_COV, NUM_HILL_CLIMBING_TEAMS, createTeamPrediction, PLOT, PROD_RUN) else list()
makePlots(PLOT, data, Y_NAME, FEATURES_TO_USE, FILENAME, teamStats, PROD_RUN)

cat('Done!\n')