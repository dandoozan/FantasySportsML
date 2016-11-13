#todo:
#D-use all features: 20_all_xgb: Dates=10/27-11/8, NumFeatures=80/93, Seed=?, Nrounds=?, XgbTrain/CvError=4.878435/8.200007, TimeToComputeModel=0.845, Trn/CV/Train=4.879084/7.799062/5.216833, MaxCov=Inf, Mean RMSE (AllPlayers/MyTeam)=8.152958/36.76341, Ratio of MyScore to LowestScore=0.9877099
#D-tune hyperparams: 21_tune_xgb: 10/27-11/8, 80/93, 266, 83, 6.762798/7.723589, 1.232, 6.797523/7.527155/6.903303, Inf, 7.771552/34.14032, 0.9890346 <-- new best!
#D-Use MAX_COV=0.5: 22_cov_xgb: 10/27-11/8, 80/93, 266, 83, 6.762798/7.723589, 1.285, 6.797523/7.527155/6.903303, 0.5, 7.771552/29.82064, 1.021105
#D-Tune using gblinear: 23_gblinear_xgb: 10/27-11/8, 80/93, 266, 1368, 7.523755/7.787023, 1.581, 7.578275/7.510651/7.546615, Inf, 7.860481/41.00078, 0.9811104
#D-Revert back to gbtree, cov=Inf: 24_revert_xgb: 10/27-11/8, 80/93, 266, 83, 6.762798/7.723589, 1.249, 6.797523/7.527155/6.903303, Inf, 7.771552/34.14032, 0.9890346
#-Add more dates (up to 11/11): 25_nov11_xgb: 10/27-11/11, 80/93, 266, 83, 6.931508/7.714106, 1.582, 7.095388/6.890297/7.044084, Inf, 7.743002/29.56711, 0.9956685 <-- new best!
#-plot several teams:
#-plot $2 5050 contests

#-make createTeam faster

#-use curated features
#-tune again using xgbcv as metric to watch
#-gblinear might be slightly better but it takes longer and plotImportances doesn't work, so use gbtree for now

rm(list = ls())
setwd('/Users/dan/Desktop/ML/df')

library(xgboost) #xgb.train, xgb.cv
library(caret) #dummyVars
library(Ckmeans.1d.dp) #xgb.plot.importance
library(randomForest) #randomForest
library(hydroGOF) #rmse
library(ggplot2) #visualization
library(ggthemes) #visualization
library(dplyr) #%>%
source('../ml-common/plot.R')
source('../ml-common/util.R')
source('source/_getData_2016.R')
source('source/_createTeam.R')

#Globals
PROD_RUN = T
ALG = 'xgb'
NUMBER = 25
NAME = 'nov11'
FILENAME = paste0(NUMBER, '_', NAME, '_', ALG)
END_DATE = '2016-11-11'
PLOT = 'scores' #fi, scores, cv
MAX_COV = Inf
NUM_TEAMS = 5
Y_NAME = 'FantasyPoints'
MAKE_TEAMS = PROD_RUN || T

if (ALG == 'xgb') {
  source('source/xgb_2016.R')
} else if (ALG == 'rf') {
  source('source/rf2_2016.R')
}

#features excluded: FantasyPoints, Date, Name
F.ID = c('Date', 'Name', 'Position', 'Team', 'Opponent')
F.FANDUEL = c('Position', 'FPPG', 'GamesPlayed', 'Salary', 'Home', 'Team', 'Opponent', 'InjuryIndicator', 'InjuryDetails')
F.NUMBERFIRE = c('NF_Min', 'NF_Pts', 'NF_Reb', 'NF_Ast', 'NF_Stl', 'NF_Blk', 'NF_TO', 'NF_FP')
F.RG.PP = c('RG_ceil', 'RG_floor', 'RG_points', 'RG_ppdk', 'RG_line',  'RG_movement', 'RG_overunder', 'RG_total', 'RG_contr', 'RG_pownpct', 'RG_rank', 'RG_rankdiff', 'RG_saldiff', 'RG_deviation', 'RG_minutes', 'RG_rank20', 'RG_diff20', 'RG_rank_diff20', 'RG_salary20', 'RG_salary15', 'RG_salary19', 'RG_salary28', 'RG_salary43', 'RG_salary50', 'RG_salary58', 'RG_points15', 'RG_points19', 'RG_points20', 'RG_points28', 'RG_points43', 'RG_points50', 'RG_points51', 'RG_points58')
#F.RG.DVP = c('RG_OPP_DVP_CFPPG', 'RG_OPP_DVP_CRK', 'RG_OPP_DVP_PFFPPG', 'RG_OPP_DVP_PFRK', 'RG_OPP_DVP_PGFPPG', 'RG_OPP_DVP_PGRK', 'RG_OPP_DVP_SFFPPG', 'RG_OPP_DVP_SFRK', 'RG_OPP_DVP_SGFPPG', 'RG_OPP_DVP_SGRK')
F.NBA = c('NBA_SEASON_AGE', 'NBA_SEASON_W', 'NBA_SEASON_L', 'NBA_SEASON_W_PCT', 'NBA_SEASON_MIN', 'NBA_SEASON_FGM', 'NBA_SEASON_FGA', 'NBA_SEASON_FG_PCT', 'NBA_SEASON_FG3M', 'NBA_SEASON_FG3A', 'NBA_SEASON_FG3_PCT', 'NBA_SEASON_FTM', 'NBA_SEASON_FTA', 'NBA_SEASON_FT_PCT', 'NBA_SEASON_OREB', 'NBA_SEASON_DREB', 'NBA_SEASON_REB', 'NBA_SEASON_AST', 'NBA_SEASON_TOV', 'NBA_SEASON_STL', 'NBA_SEASON_BLK', 'NBA_SEASON_BLKA', 'NBA_SEASON_PF', 'NBA_SEASON_PFD', 'NBA_SEASON_PTS', 'NBA_SEASON_PLUS_MINUS', 'NBA_SEASON_DD2', 'NBA_SEASON_TD3')
F.MINE = c('OPP_DVP_FPPG', 'OPP_DVP_RANK')
F.CURATED = c('FPPG', 'Salary', 'InjuryIndicator', 'RG_points', 'RG_pownpct', 'OPP_DVP_RANK')

FEATURES_TO_USE = c(F.FANDUEL, F.NUMBERFIRE, F.RG.PP, F.NBA, F.MINE)

#================= Functions ===================

findFirstIndexOfDate = function(data, date) {
  index = which(data$Date == date)
  if (length(index) > 0) {
    return(which(data$Date == date)[1])
  }
  return(-1)
}
findLastIndexOfDate = function(data, date) {
  dateIndices = which(data$Date == date)
  if (length(dateIndices) > 0) {
    return(dateIndices[length(dateIndices)])
  }
  return(-1)
}
splitDataIntoTrainTest = function(data, startDate, splitDate) {
  startIndex = ifelse(startDate == 'start', 1, findFirstIndexOfDate(data, startDate))
  if (splitDate == 'end') {
    train = data[startIndex:nrow(data),]
    test = NULL
  } else {
    splitIndex = findFirstIndexOfDate(data, splitDate)
    endIndex = findLastIndexOfDate(data, splitDate)
    train = data[startIndex:(splitIndex-1),]
    test = data[splitIndex:endIndex,]
  }
  return(list(train=train, test=test))
}

getHighestWinningScore = function(contestData, dateStr) {
  #return the highest winnning score for this date
  return(max(contestData[contestData$Date == dateStr, 'HighestScore'], na.rm=T))
}
getLowestWinningScore = function(contests, dateStr, type='all', entryFee=-1) {
  #return the lowest lastWinningScore; essentially, this is what i need to have won anything in any contest
  contests = contests[contests$Date == dateStr,]
  if (type != 'all') {
    if (type == '5050') {
      contests = contests[contests$Is5050 == 1,]
    } else if (type == 'non5050') {
      contests = contests[contests$Is5050 == 0,]
    }
  }
  if (entryFee > -1) {
    contests = contests[contests$EntryFee == entryFee,]
  }

  if (sum(!is.na(contests$LastWinningScore)) > 0) {
    return(min(contests$LastWinningScore, na.rm=T))
  }
  return(NA)
}

computeActualFP = function(team, test) {
  #todo: perhaps improve this through vectorization
  actualFP = 0.0
  for (i in 1:nrow(team)) {
    actualFP = actualFP + test[test$Name == team[i,'Name'], 'FantasyPoints']
  }
  return(actualFP)
}

printRGTrnCVError = function(data, yName, xNames) {
  #split data into train, cv
  split = splitData(data, yName)
  train = split$train
  cv = split$cv

  #compute train and cv errors
  model = createModel(train, yName, xNames)
  trnError = computeError(train[, yName], train$RG_points)
  cvError = computeError(cv[, yName], cv$RG_points)
  trainError = computeError(data[, yName], data$RG_points)
  cat('    RG Trn/CV/Train: ', trnError, '/', cvError, '/', trainError, '\n', sep='')
}

plotScores = function(dateStrs, yLow, yHigh, lowest5050=c(), greedyTeamExpected=c(), greedyTeamActual=c(), hillClimbingTeams=list(), meanFPs=c(), save=FALSE, main='Title') {
  cat('    Plotting Scores...\n')

  if (save) png(createPlotFilename('Scores', FILENAME), width=500, height=350)

  numHillClimbing = length(hillClimbingTeams)

  dates = as.Date(dateStrs)

  #get ymin and ymax
  minValue = min(yLow, lowest5050, greedyTeamExpected, greedyTeamActual, meanFPs, na.rm=T)
  maxValue = max(yHigh, lowest5050, greedyTeamExpected, greedyTeamActual, meanFPs, na.rm=T)
  if (numHillClimbing > 0) {
    for (i in 1:numHillClimbing) {
      minValue = min(minValue, hillClimbingTeams[[i]], na.rm=T)
      maxValue = max(maxValue, hillClimbingTeams[[i]], na.rm=T)
    }
  }

  #draw band
  plot(dates, yLow, type='l', col='blue', ylim=c(minValue, maxValue+50), ylab='Fantasy Points', xlab='Date', xaxt='n', main=main)
  lines(dates, yHigh, col='blue')
  polygon(c(dates, rev(dates)), c(yHigh, rev(yLow)),
          col = "azure", border = NA)

  #draw lowest5050
  lines(dates, lowest5050, col='red')

  #draw hill climbing
  colors = c('purple', 'green', 'red', 'orange')
  if (numHillClimbing > 0) {
    for (i in 1:numHillClimbing) {
      lines(dates, hillClimbingTeams[[i]], col='grey', lty=2)
    }
  }

  #draw greedy expected
  lines(dates, greedyTeamExpected, col='purple')

  #draw greedy actual
  lines(dates, greedyTeamActual, col='green')

  #draw mean
  lines(dates, meanFPs, col='black')

  legend(x='topright', legend=c('Contest Results', 'My Team Expected', 'My Team Actual', '50/50 $1 Contests'), fill=c('blue', 'purple', 'green', 'red'), inset=0.02)

  #add date axis
  axis.Date(side=1, dates, format="%m/%d")

  #add grid
  grid()

  if (save) dev.off()
}

#============= Main ================

if (PROD_RUN) cat('PROD RUN: ', FILENAME, '\n', sep='')

#load data
data = getData(END_DATE)

#print number of feature to use
cat('Number of features to use: ', length(FEATURES_TO_USE), '/', length(colnames(data)), '\n', sep='')

hyperParams = findBestHyperParams(data, Y_NAME, FEATURES_TO_USE)

#create model
cat('Creating Model...\n', sep='')
timeElapsed = system.time(baseModel <- createModel(data, Y_NAME, FEATURES_TO_USE))
cat('    Time to compute model: ', timeElapsed[3], '\n', sep='')

printModelResults(baseModel)
#cat('    MeanOfSquaredResiduals / %VarExplained: ', baseModel$mse[N_TREE], '/', baseModel$rsq[N_TREE]*100, '\n', sep='')

#print trn/cv, train error
printTrnCvTrainErrors(baseModel, data, Y_NAME, FEATURES_TO_USE, createModel, createPrediction, computeError)
printRGTrnCVError(data, Y_NAME, FEATURES_TO_USE)

if (MAKE_TEAMS) {
  cat('Now let\'s see how I would\'ve done each day...\n')

  contestData = getContestData()

  cat('    Creating teams with max cov:', MAX_COV, '\n')
  #these are arrays to plot later
  myRmses = c()
  nfRmses = c()
  rgRmses = c()
  fdRmses = c()
  teamRatios = c()
  myTeamExpectedFPs = c()
  myTeamActualFPs = c()
  myTeamRmses = c()
  myTeamGreedyExpectedFPs = c()
  myTeamHillClimbingExpectedFPs = c()
  highestWinningScores = c()
  lowestWinningScores = c()
  lowestWinningScores_5050_1 = c()
  myTeamHillClimbingActualFPs = vector('list', NUM_TEAMS)
  for (i in 1:NUM_TEAMS) myTeamHillClimbingActualFPs[[i]] = numeric()
  meanActualFPs = c()

  dateStrs = sort(unique(data$Date))[-1] #-1 uses all but the first element
  for (dateStr in dateStrs) {
    cat('    ', dateStr, ': ', sep='')

    #split data into train, test
    trainTest = splitDataIntoTrainTest(data, 'start', dateStr)
    train = trainTest$train
    test = trainTest$test

    #create model
    model = createModel(train, Y_NAME, FEATURES_TO_USE)

    #create prediction
    #prediction = test$RG_points
    prediction = createPrediction(model, test, FEATURES_TO_USE)
    myRmse = computeError(test[[Y_NAME]], prediction)
    nfRmse = computeError(test[[Y_NAME]], test$NF_FP)
    rgRmse = computeError(test[[Y_NAME]], test$RG_points)
    fdRmse = computeError(test[[Y_NAME]], test$FPPG)

    #create my teams for today
    predictionDF = test
    predictionDF[[Y_NAME]] = prediction
    myTeamGreedy = createTeam_Greedy(predictionDF, maxCov=MAX_COV)
    myTeamExpectedFP = computeTeamFP(myTeamGreedy)
    myTeamActualFP = computeActualFP(myTeamGreedy, test)
    myTeamRmse = computeError(myTeamActualFP, myTeamExpectedFP)
    tempFPs = c(myTeamActualFP)
    for (i in 1:NUM_TEAMS) {
      hillClimbingActualFP = computeActualFP(createTeam_HillClimbing(predictionDF, maxCov=MAX_COV), test)
      myTeamHillClimbingActualFPs[[i]] = c(myTeamHillClimbingActualFPs[[i]], hillClimbingActualFP)
      tempFPs = c(tempFPs, hillClimbingActualFP)
    }
    meanActualFPs = c(meanActualFPs, mean(tempFPs))

    #get actual fanduel winning score for currday
    highestWinningScore = getHighestWinningScore(contestData, dateStr)
    lowestWinningScore = getLowestWinningScore(contestData, dateStr, type='non5050')
    lowestWinningScore_5050_1 = getLowestWinningScore(contestData, dateStr, type='5050', entryFee=1)

    #print results
    cat('allRmse=', round(myRmse, 2), sep='')
    cat(', teamRmse=', round(myTeamRmse, 2), sep='')
    cat(', expected=', round(myTeamExpectedFP, 2), sep='')
    cat(', actual=', round(myTeamActualFP, 2), sep='')
    cat(', low=', round(lowestWinningScore, 2), sep='')
    #cat(', ', whichTeamITook, sep='')
    #cat(', high=', round(highestWinningScore, 2), sep='')
    cat('\n')

    #add data to arrays to plot
    myRmses = c(myRmses, myRmse)
    fdRmses = c(fdRmses, fdRmse)
    nfRmses = c(nfRmses, nfRmse)
    rgRmses = c(rgRmses, rgRmse)
    myTeamExpectedFPs = c(myTeamExpectedFPs, myTeamExpectedFP)
    myTeamActualFPs = c(myTeamActualFPs, myTeamActualFP)
    myTeamRmses = c(myTeamRmses, myTeamRmse)
    highestWinningScores = c(highestWinningScores, highestWinningScore)
    lowestWinningScores = c(lowestWinningScores, lowestWinningScore)
    lowestWinningScores_5050_1 = c(lowestWinningScores_5050_1, lowestWinningScore_5050_1)
  }

  #print mean of rmses
  cat('Mean RMSE of all players/team: ', mean(myRmses), '/', mean(myTeamRmses), '\n', sep='')

  #print myteam score / lowestWinningScore ratio, call it "scoreRatios"
  scoreRatios = myTeamActualFPs/lowestWinningScores
  cat('Mean myScore/lowestScore ratio: ', mean(scoreRatios), '\n', sep='')
}

#plots
cat('Creating plots...\n')
doPlots(PLOT, PROD_RUN, data, Y_NAME, FEATURES_TO_USE, FILENAME)
if (PROD_RUN || PLOT == 'fi') plotImportances(baseModel, FEATURES_TO_USE, save=PROD_RUN)
if (MAKE_TEAMS) {
  #if (PROD_RUN || PLOT == 'scores') plotScores(dateStrs, lowestWinningScores, highestWinningScores, lowest5050=lowestWinningScores_5050_1, greedyTeam=myTeamActualFPs, hillClimbingTeams=myTeamHillClimbingActualFPs, meanFPs=meanActualFPs, main='My Team Vs. Actual Contests', save=PROD_RUN)
  if (PROD_RUN || PLOT == 'scores') plotScores(dateStrs, lowestWinningScores, highestWinningScores, lowest5050=lowestWinningScores_5050_1, greedyTeamExpected=myTeamExpectedFPs, greedyTeamActual=myTeamActualFPs, main='My Team Vs. Actual Contests', save=PROD_RUN)
  if (PROD_RUN || PLOT == 'rmse_scoreratios') plotByDate2Axis(dateStrs, myRmses, ylab='RMSE', ylim=c(5, 12), y2=scoreRatios, y2lim=c(0, 1.5), y2lab='Score Ratio', main='RMSEs and Score Ratios', save=PROD_RUN, name='RMSE_ScoreRatios', filename=FILENAME)
  if (PROD_RUN || PLOT == 'rmses') plotLinesByDate(dateStrs, list(myRmses, fdRmses, nfRmses, rgRmses), ylab='RMSEs', labels=c('Me', 'FanDuel', 'NumberFire', 'RotoGrinder'), main='My Prediction Vs Other Sites', save=PROD_RUN, name='RMSEs', filename=FILENAME)
}


cat('Done!\n')