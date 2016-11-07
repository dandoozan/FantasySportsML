#todo:
#-use all fanduel features: rf_initial: 9/12, 100, 1.783, 73.34114/61.859, 3.968405/8.834827/3.965828, 8.92789, 0.8931035
#-verify that contest data is correct

#-Compute FantasyPoints from nba.com rather than get it from rotoguru
#-Remove all first date rows from data
#-change ntree to 500

#Remove all objects from the current workspace
rm(list = ls())
setwd('/Users/dan/Desktop/ML/df')

library(randomForest) #randomForest
library(hydroGOF) #rmse
library(ggplot2) #visualization
library(ggthemes) #visualization
source('../ml-common/plot.R')
source('../ml-common/util.R')
source('source/_getData_2016.R')
source('source/_createTeam.R')

#Globals
PROD_RUN = T
FILENAME = 'rf_initial'
N_TREE = 100
PLOT = 'Scores'
Y_NAME = 'FantasyPoints'

#features excluded: FantasyPoints, Date, Name
F.FANDUEL = c('Position', 'FPPG', 'GamesPlayed', 'Salary',
              'Home', 'Team', 'Opponent', 'InjuryIndicator', 'InjuryDetails')
FEATURES_TO_USE = c(F.FANDUEL)

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
getLowestWinningScore = function(contestData, dateStr) {
  #return the lowest lastWinningScore; essentially, this is what i need to have won anything in any contest
  return(min(contestData[contestData$Date == dateStr, 'LastWinningScore'], na.rm=T))
}

plotScores = function(dateStrs, y, yLow, yHigh, save=FALSE, name=NULL, ...) {
  if (save) png(paste0(name, '.png'), width=500, height=350)

  dates = as.Date(dateStrs)

  plot(dates, y, type='n', ylim=c(min(y, yLow, na.rm=T), max(y, yHigh, na.rm=T)),
       ylab='Fantasy Points', xlab='Date', xaxt='n', ...)
  lines(dates, yLow, col='blue')
  lines(dates, yHigh, col='blue')

  polygon(c(dates, rev(dates)), c(yHigh, rev(yLow)),
          col = "azure", border = NA)
  lines(dates, y, col='red')

  axis.Date(side=1, dates, format="%m/%d")

  if (save) dev.off()
}

#============= Main ================

if (PROD_RUN) cat('PROD RUN: ', FILENAME, '\n', sep='')

#load data
data = getData()
contestData = getContestData()

#print number of feature to use
cat('Number of features to use: ', length(FEATURES_TO_USE), '/', length(names(data)), '\n', sep='')

#create model
cat('Creating Model (ntree=', N_TREE, ')...\n', sep='')
timeElapsed = system.time(model <- createModel(data, Y_NAME, FEATURES_TO_USE))
cat('    Time to compute model: ', timeElapsed[3], '\n', sep='')
cat('    MeanOfSquaredResiduals / %VarExplained: ', model$mse[N_TREE], '/', model$rsq[N_TREE]*100, '\n', sep='')

#print trn/cv, train error
printTrnCvTrainErrors(model, data, Y_NAME, FEATURES_TO_USE, createModel, createPrediction, computeError)

cat('Now let\'s see how I would\'ve done each day...\n')

#these are arrays to plot later
percentVarExplaineds = c()
meanOfSquaredResidualss = c()
testErrors = c()
teamRatios = c()
myTeamActualFantasyPointss = c()
highestWinningScores = c()
lowestWinningScores = c()

dateStrs = sort(unique(data$Date))[-1] #-1 uses all but the first element
for (dateStr in dateStrs) {
  cat('    ', dateStr, ': ', sep='')

  #split data into train, test
  trainTest = splitDataIntoTrainTest(data, 'start', dateStr)
  train = trainTest$train
  test = trainTest$test

  #create model
  model = createModel(train, Y_NAME, FEATURES_TO_USE)
  meanOfSquaredResiduals = model$mse[N_TREE]
  percentVarExplained = model$rsq[N_TREE] * 100

  #create prediction
  prediction = createPrediction(model, test, FEATURES_TO_USE)
  testError = computeError(test[[Y_NAME]], prediction)

  #create my team for today
  myTeam = createTeams(test, prediction, Y_NAME)$myTeam

  #get actual fanduel winning score for currday
  highestWinningScore = getHighestWinningScore(contestData, dateStr)
  lowestWinningScore = getLowestWinningScore(contestData, dateStr)

  #print results
  cat('RMSE=', testError, sep='')
  cat(', expected=', round(myTeam$expectedFantasyPoints, 2), sep='')
  cat(', actual=', round(myTeam$fantasyPoints, 2), sep='')
  cat(', low=', round(lowestWinningScore, 2), sep='')
  cat(', high=', round(highestWinningScore, 2), sep='')
  cat('\n')

  #add data to arrays to plot
  meanOfSquaredResidualss = c(meanOfSquaredResidualss, model$mse[N_TREE])
  percentVarExplaineds = c(percentVarExplaineds, model$rsq[N_TREE])
  testErrors = c(testErrors, testError)
  myTeamActualFantasyPointss = c(myTeamActualFantasyPointss, myTeam$fantasyPoints)
  highestWinningScores = c(highestWinningScores, highestWinningScore)
  lowestWinningScores = c(lowestWinningScores, lowestWinningScore)
}

#print mean of rmses
cat('Mean of daily RMSEs: ', mean(testErrors), '\n', sep='')

#print myteam score / lowestWinningScore ratio, call it "scoreRatios"
scoreRatios = myTeamActualFantasyPointss/lowestWinningScores
cat('Mean myScore/lowestScore ratio: ', mean(scoreRatios), '\n', sep='')

#plots
if (PROD_RUN || PLOT == 'Scores') plotScores(dateStrs, myTeamActualFantasyPointss, lowestWinningScores, highestWinningScores, main='Fantasy Points Comparison', save=PROD_RUN, name=paste0('Scores_', FILENAME))
#if (PROD_RUN || PLOT == 'RMSE') plotByDate(dateStrs, testErrors, main='RMSE by Date', ylab='RMSE', save=PROD_RUN, name=paste0(PLOT, '_', FILENAME))
#if (PROD_RUN || PLOT == 'ScoreRatios') plotByDate(dateStrs, scoreRatios, ylim=c(0, 1.5), main='Score Ratio by Date', ylab='Score Ratio', save=PROD_RUN, name=paste0(PLOT, '_', FILENAME))
if (PROD_RUN || PLOT == 'RMSE_ScoreRatios') plotByDate2Axis(dateStrs, testErrors, ylab='RMSE', y2=scoreRatios, y2lim=c(0, 1.5), y2lab='Score Ratio', main='RMSEs and Score Ratios', save=PROD_RUN, name=paste0('RMSE_ScoreRatios_', FILENAME))

cat('Done!\n')
