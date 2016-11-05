#todo:
#D-Use all features: rf_all: start-2015-11-16, 43/44, 100, 5.479, 81.80186/55.09977, 3.609911/8.349023/3.541713
#D-Add nba advanced: rf_adv: start-2015-11-16, 60/61, 100, 7.071, 82.36119/54.79276, 3.557412/8.356418/3.491678
#D-Add nba PlayerBios: rf_playerbios: start-2015-11-16, 66/68, 100, 8.396, 81.48067/55.27606, 3.560697/8.388797/3.486949
#D-Add WasDrafted and AttendedTopCollege: rf_WasDrafted: start-2015-11-16, 71/73, 100, 8.189, 81.66209/55.17648, 3.518361/8.388745/3.449907
#D-Data file reordered (everything same as above): rf_Reorder: start-2015-11-16, 71/73, 100, 8.121, 82.86294/54.51735, 3.535505/8.343658/3.475144 <-- new best!
#D-Add nba opponent: rf_opponent: start-2015-11-16, 91/93, 100, 10.167, 82.27009/54.84276, 3.519526/8.310265/3.475451 <-- new best!
#D-Add defense: rf_defense: start-2015-11-16, 99/101, 100, 11.268, 82.89138/54.50174, 3.542588/8.280058/3.483619 <-- new best!
#D-Add scoring: rf_scoring: start-2015-11-16, 114/116, 100, 12.438, 82.65378/54.63216, 3.496146/8.324325/3.456758
#D-Fix mse/rsq output (everything same as above): start-2015-11-16, 114/116, 100, 12.419, 75.50643/58.55527, 3.496146/8.324325/3.456758
#D-Add usage: rf_usage: start-2015-11-16, 128/130, 100, 17.309, 75.31835/58.6585, 3.539682/8.300316/3.470495
#D-Add traditional-diff: rf_tradDiff: start-2015-11-16, 147/149, 100, 15.763, 75.14734/58.75237, 3.506969/8.345989/3.459044
#D-Add Starter: rf_starter: start-2015-11-16, 148/150, 100, 15.644, 76.20332/58.17275, 3.515676/8.349295/3.444033
#D-Add team traditional: rf_team: start-2015-11-16, 174/176, 100, 18.482, 75.41484/58.60554, 3.497111/8.261813/3.439535 <-- new best!
#D-Add team adv: rf_teamAdv: start-2015-11-16, 188/190, 100, 19.583, 75.46155/58.5799, 3.521843/8.281854/3.435679
#D-Add team 4factor: rf_4factor: start-2015-11-16, 193/195, 100, 19.747, 76.0708/58.24549, 3.481958/8.354231/3.469764
#D-Removing FGM_PG, FGA_PG: rf_rmFG_PG: start-2015-11-16, 191/193, 100, 18.931, 75.22574/58.70933, 3.48194/8.304678/3.449578
#D-Add opp team traditional: rf_oppTeamTraditional: start-2015-11-16, 217/238, 100, 23.322, 75.52434/58.54544, 3.472347/8.343084/3.461793
#D-Add opp team adv: rf_oppTeamAdvanced: start-2015-11-16, 231/238, 100, 23.449, 74.63901/59.03139, 3.476982/8.323181/3.418769
#D-Add opp team 4factor: rf_oppTeam4Factor: start-2015-11-16, 236/238, 100, 23.465, 75.26318/58.68878, 3.52854/8.220664/3.435185 <-- new best!
#D-Add prevgame traditional: rf_prevGame: start-2015-11-16, 265/267, 100, 26.645, 75.0749/58.79213, 3.50504/8.325245/3.432752
#D-Add prevgame advanced: rf_prevGameAdv: start-2015-11-16, 280/290, 100, 27.901, 75.84301/58.37052, 3.520104/8.34741/3.436957
#D-Add prevgame defense: rf_prevGameDef: start-2015-11-16, 288/290, 100, 28.606, 75.34841/58.642, 3.485228/8.311185/3.419689
#D-Remove Minutes_PrevGame: rf_rmMinPrevGame: start-2015-11-16, 287/289, 100, 28.244, 74.67363/59.01238, 3.448102/8.292937/3.438265
#D-Convert binary cols to factors: rf_binToFactor: start-2015-11-16, 287/289, 100, 33.157, 75.69991/58.44907, 3.470923/8.261393/3.456092
#-Convert Injured to factor

#-Add AttendedCollege feature

#-Somehow get top features
  #-use top features from correlation
  #-use top features from rf importances
  #-use boruta
  #-use lm pvalues

#-Build models on subset of data
  #-starter
  #-position
  #-injured
  #-salary level?
  #-at least 10? games played
  #-individual player?
  #-consistent players (based on stdev if i can compute it)

#-Try changing start date
#-Add prev X days stats
#-Create high level features (eg. whether good defenseive team)

#-Try boruta features from all of the above

#Remove all objects from the current workspace
rm(list = ls())
setwd('/Users/dan/Desktop/ML/df')

library(randomForest) #randomForest
library(hydroGOF) #rmse
library(ggplot2) #visualization
library(ggthemes) #visualization
source('../ml-common/plot.R')
source('../ml-common/util.R')
source('source/_getData.R')
source('source/_createTeam.R')

#Globals
F.ID = c('Date', 'Name', 'Team')
F.RG = c('Salary', 'Position', 'Home', 'Team', 'Opponent')
F.NBA.P.TRADITIONAL = c('SEASON_AGE', 'SEASON_GP', 'SEASON_W', 'SEASON_L', 'SEASON_W_PCT', 'SEASON_MIN', 'SEASON_FGM', 'SEASON_FGA', 'SEASON_FG_PCT', 'SEASON_FG3M', 'SEASON_FG3A', 'SEASON_FG3_PCT', 'SEASON_FTM', 'SEASON_FTA', 'SEASON_FT_PCT', 'SEASON_OREB', 'SEASON_DREB', 'SEASON_REB', 'SEASON_AST', 'SEASON_TOV', 'SEASON_STL', 'SEASON_BLK', 'SEASON_BLKA', 'SEASON_PF', 'SEASON_PFD', 'SEASON_PTS', 'SEASON_PLUS_MINUS', 'SEASON_DD2', 'SEASON_TD3')
F.NBA.P.ADVANCED = c('SEASON_OFF_RATING', 'SEASON_DEF_RATING', 'SEASON_NET_RATING', 'SEASON_AST_PCT', 'SEASON_AST_TO', 'SEASON_AST_RATIO', 'SEASON_OREB_PCT', 'SEASON_DREB_PCT', 'SEASON_REB_PCT', 'SEASON_TM_TOV_PCT', 'SEASON_EFG_PCT', 'SEASON_TS_PCT', 'SEASON_USG_PCT', 'SEASON_PACE', 'SEASON_PIE')
F.NBA.P.PLAYERBIOS = c('PLAYER_HEIGHT_INCHES','PLAYER_WEIGHT','COUNTRY','DRAFT_YEAR','DRAFT_ROUND','DRAFT_NUMBER')
F.NBA.P.OPPONENT = c('SEASON_OPP_FGM', 'SEASON_OPP_FGA', 'SEASON_OPP_FG_PCT', 'SEASON_OPP_FG3M', 'SEASON_OPP_FG3A', 'SEASON_OPP_FG3_PCT', 'SEASON_OPP_FTM', 'SEASON_OPP_FTA', 'SEASON_OPP_FT_PCT', 'SEASON_OPP_OREB', 'SEASON_OPP_DREB', 'SEASON_OPP_REB', 'SEASON_OPP_AST', 'SEASON_OPP_TOV', 'SEASON_OPP_STL', 'SEASON_OPP_BLK', 'SEASON_OPP_BLKA', 'SEASON_OPP_PF', 'SEASON_OPP_PFD', 'SEASON_OPP_PTS')
F.NBA.P.DEFENSE = c('SEASON_PCT_DREB', 'SEASON_PCT_STL', 'SEASON_PCT_BLK', 'SEASON_OPP_PTS_OFF_TOV', 'SEASON_OPP_PTS_2ND_CHANCE', 'SEASON_OPP_PTS_FB', 'SEASON_OPP_PTS_PAINT', 'SEASON_DEF_WS')
F.NBA.P.SCORING = c('SEASON_PCT_FGA_2PT', 'SEASON_PCT_FGA_3PT', 'SEASON_PCT_PTS_2PT', 'SEASON_PCT_PTS_2PT_MR', 'SEASON_PCT_PTS_3PT', 'SEASON_PCT_PTS_FB', 'SEASON_PCT_PTS_FT', 'SEASON_PCT_PTS_OFF_TOV', 'SEASON_PCT_PTS_PAINT', 'SEASON_PCT_AST_2PM', 'SEASON_PCT_UAST_2PM', 'SEASON_PCT_AST_3PM', 'SEASON_PCT_UAST_3PM', 'SEASON_PCT_AST_FGM', 'SEASON_PCT_UAST_FGM')
F.NBA.P.USAGE = c('SEASON_PCT_FGM', 'SEASON_PCT_FGA', 'SEASON_PCT_FG3M', 'SEASON_PCT_FG3A', 'SEASON_PCT_FTM', 'SEASON_PCT_FTA', 'SEASON_PCT_OREB', 'SEASON_PCT_REB', 'SEASON_PCT_AST', 'SEASON_PCT_TOV', 'SEASON_PCT_BLKA', 'SEASON_PCT_PF', 'SEASON_PCT_PFD', 'SEASON_PCT_PTS')
F.NBA.P.TRADITIONAL_DIFF = c('DIFF_SEASON_FGM', 'DIFF_SEASON_FGA', 'DIFF_SEASON_FG_PCT', 'DIFF_SEASON_FG3M', 'DIFF_SEASON_FG3A', 'DIFF_SEASON_FG3_PCT', 'DIFF_SEASON_FTM', 'DIFF_SEASON_FTA', 'DIFF_SEASON_FT_PCT', 'DIFF_SEASON_OREB', 'DIFF_SEASON_DREB', 'DIFF_SEASON_REB', 'DIFF_SEASON_AST', 'DIFF_SEASON_TOV', 'DIFF_SEASON_STL', 'DIFF_SEASON_BLK', 'DIFF_SEASON_BLKA', 'DIFF_SEASON_PF', 'DIFF_SEASON_PFD')
F.NBA.T.TRADITIONAL = c('TEAM_SEASON_GP', 'TEAM_SEASON_W', 'TEAM_SEASON_L', 'TEAM_SEASON_W_PCT', 'TEAM_SEASON_MIN', 'TEAM_SEASON_FGM', 'TEAM_SEASON_FGA', 'TEAM_SEASON_FG_PCT', 'TEAM_SEASON_FG3M', 'TEAM_SEASON_FG3A', 'TEAM_SEASON_FG3_PCT', 'TEAM_SEASON_FTM', 'TEAM_SEASON_FTA', 'TEAM_SEASON_FT_PCT', 'TEAM_SEASON_OREB', 'TEAM_SEASON_DREB', 'TEAM_SEASON_REB', 'TEAM_SEASON_AST', 'TEAM_SEASON_TOV', 'TEAM_SEASON_STL', 'TEAM_SEASON_BLK', 'TEAM_SEASON_BLKA', 'TEAM_SEASON_PF', 'TEAM_SEASON_PFD', 'TEAM_SEASON_PTS', 'TEAM_SEASON_PLUS_MINUS')
F.NBA.T.ADVANCED = c('TEAM_SEASON_OFF_RATING', 'TEAM_SEASON_DEF_RATING', 'TEAM_SEASON_NET_RATING', 'TEAM_SEASON_AST_PCT', 'TEAM_SEASON_AST_TO', 'TEAM_SEASON_AST_RATIO', 'TEAM_SEASON_OREB_PCT', 'TEAM_SEASON_DREB_PCT', 'TEAM_SEASON_REB_PCT', 'TEAM_SEASON_TM_TOV_PCT', 'TEAM_SEASON_EFG_PCT', 'TEAM_SEASON_TS_PCT', 'TEAM_SEASON_PACE', 'TEAM_SEASON_PIE')
F.NBA.T.FOURFACTORS = c('TEAM_SEASON_FTA_RATE', 'TEAM_SEASON_OPP_EFG_PCT', 'TEAM_SEASON_OPP_FTA_RATE', 'TEAM_SEASON_OPP_TOV_PCT', 'TEAM_SEASON_OPP_OREB_PCT')
F.NBA.T.OPP.TRADITIONAL = c('OPP_TEAM_SEASON_GP', 'OPP_TEAM_SEASON_W', 'OPP_TEAM_SEASON_L', 'OPP_TEAM_SEASON_W_PCT', 'OPP_TEAM_SEASON_MIN', 'OPP_TEAM_SEASON_FGM', 'OPP_TEAM_SEASON_FGA', 'OPP_TEAM_SEASON_FG_PCT', 'OPP_TEAM_SEASON_FG3M', 'OPP_TEAM_SEASON_FG3A', 'OPP_TEAM_SEASON_FG3_PCT', 'OPP_TEAM_SEASON_FTM', 'OPP_TEAM_SEASON_FTA', 'OPP_TEAM_SEASON_FT_PCT', 'OPP_TEAM_SEASON_OREB', 'OPP_TEAM_SEASON_DREB', 'OPP_TEAM_SEASON_REB', 'OPP_TEAM_SEASON_AST', 'OPP_TEAM_SEASON_TOV', 'OPP_TEAM_SEASON_STL', 'OPP_TEAM_SEASON_BLK', 'OPP_TEAM_SEASON_BLKA', 'OPP_TEAM_SEASON_PF', 'OPP_TEAM_SEASON_PFD', 'OPP_TEAM_SEASON_PTS', 'OPP_TEAM_SEASON_PLUS_MINUS')
F.NBA.T.OPP.ADVANCED = c('OPP_TEAM_SEASON_OFF_RATING', 'OPP_TEAM_SEASON_DEF_RATING', 'OPP_TEAM_SEASON_NET_RATING', 'OPP_TEAM_SEASON_AST_PCT', 'OPP_TEAM_SEASON_AST_TO', 'OPP_TEAM_SEASON_AST_RATIO', 'OPP_TEAM_SEASON_OREB_PCT', 'OPP_TEAM_SEASON_DREB_PCT', 'OPP_TEAM_SEASON_REB_PCT', 'OPP_TEAM_SEASON_TM_TOV_PCT', 'OPP_TEAM_SEASON_EFG_PCT', 'OPP_TEAM_SEASON_TS_PCT', 'OPP_TEAM_SEASON_PACE', 'OPP_TEAM_SEASON_PIE')
F.NBA.T.OPP.FOURFACTORS = c('OPP_TEAM_SEASON_FTA_RATE', 'OPP_TEAM_SEASON_OPP_EFG_PCT', 'OPP_TEAM_SEASON_OPP_FTA_RATE', 'OPP_TEAM_SEASON_OPP_TOV_PCT', 'OPP_TEAM_SEASON_OPP_OREB_PCT')
F.NBA.P.PREV1.TRADITIONAL = c('PREV_GAME_AGE', 'PREV_GAME_GP', 'PREV_GAME_W', 'PREV_GAME_L', 'PREV_GAME_W_PCT', 'PREV_GAME_MIN', 'PREV_GAME_FGM', 'PREV_GAME_FGA', 'PREV_GAME_FG_PCT', 'PREV_GAME_FG3M', 'PREV_GAME_FG3A', 'PREV_GAME_FG3_PCT', 'PREV_GAME_FTM', 'PREV_GAME_FTA', 'PREV_GAME_FT_PCT', 'PREV_GAME_OREB', 'PREV_GAME_DREB', 'PREV_GAME_REB', 'PREV_GAME_AST', 'PREV_GAME_TOV', 'PREV_GAME_STL', 'PREV_GAME_BLK', 'PREV_GAME_BLKA', 'PREV_GAME_PF', 'PREV_GAME_PFD', 'PREV_GAME_PTS', 'PREV_GAME_PLUS_MINUS', 'PREV_GAME_DD2', 'PREV_GAME_TD3')
F.NBA.P.PREV1.ADVANCED = c('PREV_GAME_OFF_RATING', 'PREV_GAME_DEF_RATING', 'PREV_GAME_NET_RATING', 'PREV_GAME_AST_PCT', 'PREV_GAME_AST_TO', 'PREV_GAME_AST_RATIO', 'PREV_GAME_OREB_PCT', 'PREV_GAME_DREB_PCT', 'PREV_GAME_REB_PCT', 'PREV_GAME_TM_TOV_PCT', 'PREV_GAME_EFG_PCT', 'PREV_GAME_TS_PCT', 'PREV_GAME_USG_PCT', 'PREV_GAME_PACE', 'PREV_GAME_PIE')
F.NBA.P.PREV1.DEFENSE = c('PREV_GAME_PCT_DREB', 'PREV_GAME_PCT_STL', 'PREV_GAME_PCT_BLK', 'PREV_GAME_OPP_PTS_OFF_TOV', 'PREV_GAME_OPP_PTS_2ND_CHANCE', 'PREV_GAME_OPP_PTS_FB', 'PREV_GAME_OPP_PTS_PAINT', 'PREV_GAME_DEF_WS')
F.MINE = c('Starter', 'WasDrafted', 'AttendedTop5PctCollege', 'AttendedTop10PctCollege', 'AttendedTop20PctCollege', 'AttendedTop50PctCollege', 'AvgFantasyPoints', 'DaysPlayedPercent', 'Injured', 'FantasyPoints_PrevGame', 'StartedPercent', 'Salary_PrevGame', 'AvgFantasyPointsPerMin', 'SalaryIncreased')
F.ALL = c(F.RG, F.NBA.P.TRADITIONAL, F.NBA.P.ADVANCED, F.NBA.P.PLAYERBIOS, F.NBA.P.OPPONENT,
          F.NBA.P.DEFENSE, F.NBA.P.SCORING, F.NBA.P.USAGE, F.NBA.P.TRADITIONAL_DIFF,
          F.NBA.T.TRADITIONAL, F.NBA.T.ADVANCED, F.NBA.T.FOURFACTORS,
          F.NBA.T.OPP.TRADITIONAL, F.NBA.T.OPP.ADVANCED, F.NBA.T.OPP.FOURFACTORS,
          F.NBA.P.PREV1.TRADITIONAL, F.NBA.P.PREV1.ADVANCED, F.NBA.P.PREV1.DEFENSE,
          F.MINE)

FEATURES_TO_USE = F.ALL

PROD_RUN = T
FILENAME = 'rf_binToFactor'
START_DATE = 'start'
SPLIT_DATE = '2015-11-16'
N_TREE = 100
PLOT = 'fi' #lc=learning curve, fi=feature importances

ID_NAME = 'Name'
Y_NAME = 'FantasyPoints'

#============== Functions ===============

createModel = function(data, yName, xNames) {
  set.seed(754)
  return(randomForest(x=data[, xNames],
                      y=data[[yName]],
                      ntree=N_TREE))
}
createPrediction = function(model, newData=NULL, xNames=NULL) {
  if (is.null(newData)) {
    return(predict(model))
  }
  return(predict(model, newData))
}
computeError = function(y, yhat) {
  return(rmse(y, yhat))
}
findBestSetOfFeatures = function(data, possibleFeatures) {
  cat('Finding best set of features to use...\n')

  #featuresToUse = c('Salary', 'MIN', 'Injured', 'FantasyPoints_PrevGame', 'AvgFantasyPointsPerMin')
  featuresToUse = FEATURES_TO_USE

  cat('    Number of features to use: ', length(featuresToUse), '/', length(possibleFeatures), '\n')
  #cat('    Features to use:', paste(featuresToUse, collapse=', '), '\n')
  return(featuresToUse)
}

#I do not understand any of this code, I borrowed it from a kaggler
plotImportances = function(model, max=20, save=FALSE) {
  cat('Plotting Feature Importances...\n')

  # Get importance
  importances = randomForest::importance(model)

  #DPD: take the top 20 if there are more than 20
  importances = importances[order(-importances[, 1]), , drop = FALSE][1:min(max, nrow(importances)),, drop=F]

  varImportance = data.frame(Variables = row.names(importances),
                             Importance = round(importances[, 1], 2))

  # Create a rank variable based on importance
  rankImportance = varImportance %>%
    mutate(Rank = paste0('#',dense_rank(desc(Importance))))

  if (save) png(paste0('Importances_', FILENAME, '.png'), width=500, height=350)
  print(ggplot(rankImportance, aes(x = reorder(Variables, Importance),
                                   y = Importance, fill = Importance)) +
          geom_bar(stat='identity') +
          geom_text(aes(x = Variables, y = 0.5, label = Rank),
                    hjust=0, vjust=0.55, size = 4, colour = 'red') +
          labs(title='Feature Importances', x='Features') +
          coord_flip() +
          theme_few())
  if (save) dev.off()
}

writeSolution = function(data, yName, idName, prediction, filename, extraColNames) {
  solution = data.frame(data[, idName], prediction, data[, extraColNames])
  colnames(solution) = c(idName, yName, extraColNames)
  cat('    Writing solution to file: ', filename, '...\n', sep='')
  write.csv(solution, file=filename, row.names=F, quote=F)
}

createTeams = function(testData, prediction, yName) {
  cat('Creating teams...\n')

  #create my team (using prediction)
  predictionDF = testData
  predictionDF[[yName]] = prediction
  myTeam = createTeam(predictionDF)
  cat('My team:\n')
  printTeam(myTeam)

  #create best team (using test)
  bestTeam = createTeam(testData)
  cat('Best team:\n')
  printTeam(bestTeam)

  #print myTeam / bestTeam ratio
  printTeamResults(myTeam, bestTeam, yName)
}

#============= Main ================

if (PROD_RUN) cat('PROD RUN: ', FILENAME, '\n', sep='')

data = getData(START_DATE, SPLIT_DATE)
train = data$train #train=all data leading up to tonight
test = data$test #test=tonight's team
possibleFeatures = setdiff(names(train), c(ID_NAME, Y_NAME))

#find best set of features to use based on cv error
featuresToUse = findBestSetOfFeatures(train, possibleFeatures)

cat('Creating Model (ntree=', N_TREE, ')...\n', sep='')
timeElapsed = system.time(model <- createModel(train, Y_NAME, featuresToUse))
cat('    Time to compute model: ', timeElapsed[3], '\n', sep='')
cat('    MeanOfSquaredResiduals / %VarExplained: ', model$mse[N_TREE], '/', model$rsq[N_TREE]*100, '\n', sep='')

#plots
if (PROD_RUN || PLOT=='lc') plotLearningCurve(train, Y_NAME, featuresToUse, createModel, createPrediction, computeError, ylim=c(0, 15), save=PROD_RUN)
if (PROD_RUN || PLOT=='fi') plotImportances(model, save=PROD_RUN)

#print trn/cv, train error
printTrnCvTrainErrors(model, train, Y_NAME, featuresToUse, createModel, createPrediction, computeError)

tbx_commentsToCollapse = function() {
#comment this out because it doesnt mean anything
#print test error
# prediction = createPrediction(model, test, featuresToUse)
# testError = computeError(test[, Y_NAME], prediction)
# cat('    Tonight\'s error: ', testError, '\n', sep='')
#
# createTeams(test, prediction, Y_NAME)

#comment this out because i think i dont need it
#if (PROD_RUN) {
  # cat('Outputing solution...\n')
  #
  # extraColNames = c('Salary', 'Position')
  #
  # #write prediction
  # predictionFilename = paste0('prediction_', FILENAME, '.csv')
  # writeSolution(test, Y_NAME, ID_NAME, prediction, predictionFilename, extraColNames)
  #
  # #write actual
  # actualFilename = paste0('actual_', FILENAME, '.csv')
  # writeSolution(test, Y_NAME, ID_NAME, test[[Y_NAME]], actualFilename, extraColNames)
#}
}

cat('Done!\n')

tbx_moreCommentsToCollapse = function() {

#=====From above=======
#D-Make initial prediction using salary: 01_rf_salary: numFeaturesUsed=1/1, Trn/CV Error=10.15385/10.16979, Train Error=10.15067
#D-Use 2014 data: NONE: 1/1, 8.888702/8.924981, 8.887228
#D-Use train/test data and keep NAs in data: rf_keepNAs: 1/2, 8.895979/8.880356, 8.887228
#D-Write script to create team: rf_createTeam: 1/3, 8.895979/8.880356, 8.887228
#D-Run for 20161025: 20161025: 1/3, 9.761371/9.643101, 9.733458
#D-Output test (tonight's predictions) error: 1/3, 9.761371/9.643101, 9.733458, testError=10.24964
#D-Use first 10 days of 2015 data: 20151106: 1/3, 8.769458/9.195576, 8.802408
#D-Remove rows with Salary NAs: 20151106_removeNAs: 1/3, 8.745434/9.390104, 8.802408
#D-Use all base features from rotoguru (Position, Salary, Home): 20151106_+PositionHome: 3/4, 9.614065/9.635446, 9.627315
#D-Add all features from nba: 20151208_allNba: 32/35, ntree=100, 4.068691/8.490935, 4.13253
#-Features used: Salary, Position, Home, AGE, GP, W, L, W_PCT, MIN, FGM, FGA, FG_PCT, FG3M, FG3A, FG3_PCT, FTM, FTA, FT_PCT, OREB, DREB, REB, AST, TOV, STL, BLK, BLKA, PF, PFD, PTS, PLUS_MINUS, DD2, TD3
#D-Use as many features as possible that don't overfit (Salary, MIN): 20160619_SalaryMin: 2/35, 10, 8.709144/9.774915, 8.742757
#D-Add AvgFantasyPoints, DaysPlayedPercent features: 20151208_AvgFantasyPoints: 34/37, 100, 3.868784/8.450441, 3.837078
#-Features used: Salary, Position, Home, AGE, GP, W, L, W_PCT, MIN, FGM, FGA, FG_PCT, FG3M, FG3A, FG3_PCT, FTM, FTA, FT_PCT, OREB, DREB, REB, AST, TOV, STL, BLK, BLKA, PF, PFD, PTS, PLUS_MINUS, DD2, TD3, AvgFantasyPoints, DaysPlayedPercent
#D-Use AvgFantasyPoints, Salary, MIN: 20160619_top3: 3/37, 10, 7.397566/9.545659, 7.284939
#D-Fix AvgFantasyPoints (AvgFantasyPoints, Salary, MIN): 20160619_fixAvgFP: 3/37, 10, 7.301757/9.625992, 7.293516
#D-Add Injured feature: 20160619_Injured: 4/38, 10, 8.910737/9.158973, 8.813595
#D-Add FantasyPoints_PrevGame: 20160619_FantasyPointsPrevGame: 5/39, 10, 8.363092/8.940201, 8.373344, "Mean of squared residuals"=83.92964, "% Var explained"=56.62
#D-Try AvgFantasyPointsPerMin (made it worse): 20160619, 6/40, 10, 4.983091/9.134001, 5.040836, 96.6889, 50.03
#D-Replace AvgFantasyPoints with AvgFantasyPointsPerMin: 20160619_AvgFPPerMin: 5/40, 10, 8.212136/8.850639, 8.213636, 81.12534, 58.07
#D-Add Minutes_PrevGame (it didn't help much, if at all; come back to it if i need to increase my results a tid bit)
#D-Remove the first X% of data so that winpct etc mean something (it didn't help)
#D-Try top X correlation features (with and without Injury, which majorly helps it not overfit for some reason):
#-Top 1 (AvgFantasyPoints): 9.329334/9.399666, 10.48611
#-Top 2 (+FantasyPoints_PrevGame): 8.801942/9.009306, 8.904963
#-Top 3 (+Salary): 8.436485/8.855896, 8.889949
#-Top 4 (+Minutes_PrevGame): 8.362315/8.876209, 8.154882
#-Top 5 (+PTS): 4.974178/9.135287, 5.133405
#-Top 10 (+FGM, FGA, MIN, PFD, AvgFantasyPointsPerMin): 4.456431/9.081288, 4.454354
#D-Add StartedPercent (didn't help): 5.059432/9.125127, 5.153629
#D-Add Salary_PrevGame (it didn't immediately help)
#D-Add SalaryIncreased (nope): 6.195253/9.04208, 6.192414
#D-Use predict(model) for train: rf_predict: start-end, 5/44, 10, 8.9856/8.850639, 9.006961, 81.12534, 58.07 <-- use this for baseline
#-Features used: Salary, MIN, Injured, FantasyPoints_PrevGame, AvgFantasyPointsPerMin

#-Try all features, ignoring test/train overifitting
  #-Try all rg + nba + mine
    #-ntree=10, splitDate=2015-11-06: time=0.146, trn/cv=3.867389/9.298347, train=3.939142, MeanOfSquaredResiduals=91.22056, %VarExplained=47.48 (108.4268, 37.56809)
    #-10, 2015-11-16: 0.57, 4.088721/8.889591, 4.003655, 96.57905, 46.99 (112.8018, 38.0842)
    #-10, 2015-12-08: 2.325, 3.953117/8.453994, 3.894827, 89.84784, 51.55 (110.3565, 40.48488)
    #-10, 2016-02-10: 23.851, 3.959874/8.817836, 3.930304, 89.95064, 52.35 (108.2765, 42.64644) <-- take too long

    #-100, 2015-11-06: 1.29, 3.443206/8.770879, 3.425491, 71.39885, 58.89 (77.78406, 55.21211)
    #-100, 2015-11-16: 5.617, 3.609911/8.349023, 3.541713, 75.32584, 58.65 (81.80186, 55.09977) <--Use this one
    #-100, 2015-12-08: 23.954, 3.449412/8.140572, 3.418292, 70.74516, 61.85 (76.98727, 58.48087) <-- take too long

    #-500, 2015-11-06: 6.384, 3.396569/8.733787, 3.39772, 70.60391, 59.35 (72.19504, 58.43026)
    #-500, 2015-11-16: 27.869, 3.549393/8.354271, 3.487071, 74.28095, 59.23 (75.97834, 58.29624) <-- take too long


#================= extra TODOs================

#What to do next:
  #-Use more features:
    #-Vegas odds
    #-More from stats.nba.com
    #-Opponent data
  #-Try same prediction on a subset of data (either one player, or group of similar players)
  #-Try a different algorithm (eg. xgboost, lm)
  #-Read articles/blog posts to determine good features that I haven't thought of
  #-Try predicting something else, then using that to compute expected fantasy points
    #-FantasyPointsPerMin, MinutesWillPlay -> manually compute FantasyPoints
    #-Steals, Block, etc -> manually compute FantasyPoints
  #-Add 2014 data
  #-Use 2016 data, which possibly has better features (eg. expected fantasy points)


#-Maybe build a separate model for each player (or type of player (eg. starters, bench players))
#-Use all features but only from the last 5 games (rather than season), and start from game 5
#-Maybe use log of y
#-Perhaps make Home a binary col rather than factor with 2 levels
#-Identify high-risk vs low-risk player, and perhaps only choose team from players who are low-risk

#Process to get team for day:
#1. Change DATE (eg. 20161025)
#2. Source this file (rf.R)
#-Prints RMSE for Trn/CV, Train, Test
#-Prints ratio of my team score/best team score

#========================================
#CV strategies:
  #-Option 1:
    #-num days in 2015: 210
    #-starting on day 2,
      #-split data into train (days before), and test (day of)
      #-build model using train
      #-predict using test
      #-plot train and test errors
      #-set day to next day
  #-Option 2:
    #-take the first 10 days of 2015
    #-split data randomly into 80/20 (shuffled) for train/cv
    #-plot learning curve
    #-increase num days to take if i need more data
}