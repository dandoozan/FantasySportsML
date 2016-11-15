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

END_DATE = '2016-11-11'
Y_NAME = 'FantasyPoints'

#features excluded: FantasyPoints, Date, Name
F.ID = c('Date', 'Name', 'Position', 'Team', 'Opponent')
F.FANDUEL = c('Position', 'FPPG', 'GamesPlayed', 'Salary', 'Home', 'Team', 'Opponent', 'InjuryIndicator', 'InjuryDetails')
F.NUMBERFIRE = c('NF_Min', 'NF_Pts', 'NF_Reb', 'NF_Ast', 'NF_Stl', 'NF_Blk', 'NF_TO', 'NF_FP')
F.RG.PP = c('RG_ceil', 'RG_floor', 'RG_points', 'RG_ppdk', 'RG_line',  'RG_movement', 'RG_overunder', 'RG_total', 'RG_contr', 'RG_pownpct', 'RG_rank', 'RG_rankdiff', 'RG_saldiff', 'RG_deviation', 'RG_minutes', 'RG_rank20', 'RG_diff20', 'RG_rank_diff20', 'RG_salary20', 'RG_salary15', 'RG_salary19', 'RG_salary28', 'RG_salary43', 'RG_salary50', 'RG_salary58', 'RG_points15', 'RG_points19', 'RG_points20', 'RG_points28', 'RG_points43', 'RG_points50', 'RG_points51', 'RG_points58')
#F.RG.DVP = c('RG_OPP_DVP_CFPPG', 'RG_OPP_DVP_CRK', 'RG_OPP_DVP_PFFPPG', 'RG_OPP_DVP_PFRK', 'RG_OPP_DVP_PGFPPG', 'RG_OPP_DVP_PGRK', 'RG_OPP_DVP_SFFPPG', 'RG_OPP_DVP_SFRK', 'RG_OPP_DVP_SGFPPG', 'RG_OPP_DVP_SGRK')
F.NBA = c('NBA_SEASON_W', 'NBA_SEASON_L', 'NBA_SEASON_W_PCT', 'NBA_SEASON_MIN', 'NBA_SEASON_FGM', 'NBA_SEASON_FGA', 'NBA_SEASON_FG_PCT', 'NBA_SEASON_FG3M', 'NBA_SEASON_FG3A', 'NBA_SEASON_FG3_PCT', 'NBA_SEASON_FTM', 'NBA_SEASON_FTA', 'NBA_SEASON_FT_PCT', 'NBA_SEASON_OREB', 'NBA_SEASON_DREB', 'NBA_SEASON_REB', 'NBA_SEASON_AST', 'NBA_SEASON_TOV', 'NBA_SEASON_STL', 'NBA_SEASON_BLK', 'NBA_SEASON_BLKA', 'NBA_SEASON_PF', 'NBA_SEASON_PFD', 'NBA_SEASON_PTS', 'NBA_SEASON_PLUS_MINUS', 'NBA_SEASON_DD2', 'NBA_SEASON_TD3')
F.MINE = c('OPP_DVP_FPPG', 'OPP_DVP_RANK', 'TEAM_RG_points', 'TEAMMATES_RG_points')

setup = function(algToUse, featuresToUse, endDate, prodRun, filename) {
  if (algToUse == 'xgb') {
    source('source/xgb_2016.R')
  } else if (algToUse == 'rf') {
    source('source/rf2_2016.R')
  }

  if (prodRun) cat('PROD RUN: ', filename, '\n', sep='')

  #load data
  data = getData(endDate)

  #print number of feature to use
  cat('Number of features to use: ', length(featuresToUse), '/', length(colnames(data)), '\n', sep='')

  return(data)
}

createBaseModel = function(data, yName, xNames, createModel, createPrediction, computeError) {

  #create model
  cat('Creating Model...\n', sep='')
  timeElapsed = system.time(baseModel <- createModel(data, yName, xNames))
  cat('    Time to compute model: ', timeElapsed[3], '\n', sep='')
  printModelResults(baseModel)

  #print trn/cv, train error
  printTrnCvTrainErrors(baseModel, data, yName, xNames, createModel, createPrediction, computeError)
  printRGTrnCVError(data, yName, xNames, createModel, computeError)

  return(baseModel)
}

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
  return(sum(getTeamIndividualActualFPs(team, test)))
}
getTeamIndividualActualFPs = function(team, test) {
  return(test[test$Name %in% team$Name, 'FantasyPoints'])
}

printRGTrnCVError = function(data, yName, xNames, createModel, computeError) {
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

plotScores = function(dateStrs, yLow, yHigh, lowest5050s=list(), labels5050=c(), greedyTeamExpected=c(), greedyTeamActual=c(), hillClimbingTeams=list(), medianActualFPs=c(), name='Scores', save=FALSE, main='Title') {
  cat('    Plotting Scores...\n')

  if (save) png(createPlotFilename(name, FILENAME), width=500, height=350)

  labels = c()
  colors = c()

  dates = as.Date(dateStrs)

  numHillClimbing = length(hillClimbingTeams)
  numLowest5050s = length(lowest5050s)

  #get ymin and ymax
  minValue = min(yLow, greedyTeamExpected, greedyTeamActual, medianActualFPs, na.rm=T)
  maxValue = max(yHigh, greedyTeamExpected, greedyTeamActual, medianActualFPs, na.rm=T)
  if (numLowest5050s > 0) {
    for (i in 1:numLowest5050s) {
      minValue = min(minValue, lowest5050s[[i]], na.rm=T)
      maxValue = max(maxValue, lowest5050s[[i]], na.rm=T)
    }
  }
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
  labels = c(labels, 'Contest Results')
  colors = c(colors, 'blue')

  #draw lowest5050
  if (numLowest5050s > 0) {
    colors5050 = c('red', 'orange')
    for (i in 1:numLowest5050s) {
      lines(dates, lowest5050s[[i]], col=colors5050[i])
      labels = c(labels, labels5050[i])
      colors = c(colors, colors5050[i])
    }
  }

  #draw greedy expected
  if (length(greedyTeamExpected) > 0) {
    lines(dates, greedyTeamExpected, col='purple')
    labels = c(labels, 'My Team Expected')
    colors = c(colors, 'purple')
  }

  #draw hill climbing
  if (numHillClimbing > 0) {
    for (i in 1:numHillClimbing) {
      lines(dates, hillClimbingTeams[[i]], col='grey', lty=2)
    }
    #draw greedy as gray
    if (length(greedyTeamActual) > 0) {
      lines(dates, greedyTeamActual, col='grey')
    }
    labels = c(labels, 'My Teams')
    colors = c(colors, 'grey')

    #draw median
    if (length(medianActualFPs) > 0) {
      lines(dates, medianActualFPs, col='black')
      labels = c(labels, 'My Teams Median')
      colors = c(colors, 'black')
    }
  } else {
    if (length(greedyTeamActual) > 0) {
      #draw greedy as green
      lines(dates, greedyTeamActual, col='green')
      labels = c(labels, 'My Team Actual')
      colors = c(colors, 'green')
    }
  }

  legend(x='topright', legend=labels, fill=colors, inset=0.02)

  #add date axis
  axis.Date(side=1, dates, format="%m/%d")

  #add grid
  grid()

  if (save) dev.off()
}

makeTeams = function(data, yName, xNames, maxCov, numHillClimbingTeams, createTeamPrediction, toPlot, prodRun) {
  cat('Now let\'s see how I would\'ve done each day...\n')

  contestData = getContestData()

  cat('    Creating teams with max cov:', maxCov, '\n')
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
  lowestWinningScores_5050_2 = c()
  myTeamHillClimbingActualFPs = vector('list', numHillClimbingTeams)
  for (i in 1:numHillClimbingTeams) myTeamHillClimbingActualFPs[[i]] = numeric()
  medianActualFPs = c()

  dateStrs = getUniqueDates(data)[-1] #-1 uses all but the first element
  for (dateStr in dateStrs) {
    cat('    ', dateStr, ': ', sep='')

    #split data into train, test
    trainTest = splitDataIntoTrainTest(data, 'start', dateStr)
    train = trainTest$train
    test = trainTest$test

    prediction = createTeamPrediction(train, test, yName, xNames)

    myRmse = computeError(test[[yName]], prediction)
    nfRmse = computeError(test[[yName]], test$NF_FP)
    rgRmse = computeError(test[[yName]], test$RG_points)
    fdRmse = computeError(test[[yName]], test$FPPG)

    #create my teams for today
    predictionDF = test
    predictionDF[[yName]] = prediction
    myTeamGreedy = createTeam_Greedy(predictionDF, maxCov=maxCov)
    myTeamExpectedFP = computeTeamFP(myTeamGreedy)
    myTeamActualFP = computeActualFP(myTeamGreedy, test)
    myTeamRmse = computeError(getTeamIndividualActualFPs(myTeamGreedy, test), myTeamGreedy$FantasyPoints)
    allMyTeamActualFPs = c(myTeamActualFP)
    if (prodRun || toPlot == 'multiscores') {
      for (i in 1:numHillClimbingTeams) {
        hillClimbingActualFP = computeActualFP(createTeam_HillClimbing(predictionDF, maxCov=maxCov), test)
        myTeamHillClimbingActualFPs[[i]] = c(myTeamHillClimbingActualFPs[[i]], hillClimbingActualFP)
        allMyTeamActualFPs = c(allMyTeamActualFPs, hillClimbingActualFP)
      }
    }
    medianActualFP = median(allMyTeamActualFPs)
    medianActualFPs = c(medianActualFPs, medianActualFP)

    #get actual fanduel winning score for currday
    highestWinningScore = getHighestWinningScore(contestData, dateStr)
    lowestWinningScore = getLowestWinningScore(contestData, dateStr, type='non5050')
    lowestWinningScore_5050_1 = getLowestWinningScore(contestData, dateStr, type='5050', entryFee=1)
    lowestWinningScore_5050_2 = getLowestWinningScore(contestData, dateStr, type='5050', entryFee=2)

    #print results
    cat('allRmse=', round(myRmse, 2), sep='')
    cat(', teamRmse=', round(myTeamRmse, 2), sep='')
    #cat(', expected=', round(myTeamExpectedFP, 2), sep='')
    #cat(', actual=', round(myTeamActualFP, 2), sep='')
    cat(', medianActual=', round(medianActualFP, 2), sep='')
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
    lowestWinningScores_5050_2 = c(lowestWinningScores_5050_2, lowestWinningScore_5050_2)
  }

  #print mean of rmses
  cat('Mean RMSE of all players/team: ', mean(myRmses), '/', mean(myTeamRmses), '\n', sep='')

  #print myteam score / lowestWinningScore ratio, call it "scoreRatios"
  scoreRatios = myTeamActualFPs/lowestWinningScores
  cat('Mean myScore/lowestScore ratio: ', mean(scoreRatios), '\n', sep='')

  return(list(
    dateStrs=dateStrs,
    myRmses=myRmses,
    fdRmses=fdRmses,
    nfRmses=nfRmses,
    rgRmses=rgRmses,
    myTeamExpectedFPs=myTeamExpectedFPs,
    myTeamActualFPs=myTeamActualFPs,
    myTeamHillClimbingActualFPs=myTeamHillClimbingActualFPs,
    medianActualFPs=medianActualFPs,
    myTeamRmses=myTeamRmses,
    scoreRatios=scoreRatios,
    highestWinningScores=highestWinningScores,
    lowestWinningScores=lowestWinningScores,
    lowestWinningScores_5050_1=lowestWinningScores_5050_1,
    lowestWinningScores_5050_2=lowestWinningScores_5050_2
  ))
}

makePlots = function(toPlot, data, yName, xNames, filename, teamStats=list(), prodRun) {
  cat('Creating plots...\n')
  doPlots(toPlot, prodRun, data, yName, xNames, filename)
  if (prodRun || toPlot == 'fi') plotImportances(baseModel, xNames, save=prodRun)
  if (length(teamStats) > 0) {
    if (prodRun || toPlot == 'scores') plotScores(teamStats$dateStrs, teamStats$lowestWinningScores, teamStats$highestWinningScores, lowest5050s=list(teamStats$lowestWinningScores_5050_1, teamStats$lowestWinningScores_5050_2), labels5050=c('50/50 $1 Contests', '50/50 $2 Contests'), greedyTeamExpected=teamStats$myTeamExpectedFPs, greedyTeamActual=teamStats$myTeamActualFPs, main='My Team Vs. Actual Contests', name='Scores', save=prodRun)
    if (prodRun || toPlot == 'multiscores') plotScores(teamStats$dateStrs, teamStats$lowestWinningScores, teamStats$highestWinningScores, lowest5050s=list(teamStats$lowestWinningScores_5050_1, teamStats$lowestWinningScores_5050_2), labels5050=c('50/50 $1 Contests', '50/50 $2 Contests'), greedyTeamActual=teamStats$myTeamActualFPs, hillClimbingTeams=teamStats$myTeamHillClimbingActualFPs, medianActualFPs=teamStats$medianActualFPs, main='My Teams Vs. Actual Contests', name='Multiscores', save=prodRun)
    if (prodRun || toPlot == 'rmse_scoreratios') plotByDate2Axis(teamStats$dateStrs, teamStats$myRmses, ylab='RMSE', ylim=c(5, 12), y2=teamStats$scoreRatios, y2lim=c(0, 1.5), y2lab='Score Ratio', main='RMSEs and Score Ratios', save=prodRun, name='RMSE_ScoreRatios', filename=filename)
    if (prodRun || toPlot == 'rmses') plotLinesByDate(teamStats$dateStrs, list(teamStats$myRmses, teamStats$fdRmses, teamStats$nfRmses, teamStats$rgRmses), ylab='RMSEs', labels=c('Me', 'FanDuel', 'NumberFire', 'RotoGrinder'), main='My Prediction Vs Other Sites', save=prodRun, name='RMSEs', filename=filename)
  }
}