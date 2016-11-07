#todo:
#-verify that contest data is correct
#-try fanduel features (salary, injury, ?)
#-Compute FantasyPoints from nba.com rather than get it from rotoguru

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

PROD_RUN = F
FILENAME = 'rf_initial'
START_DATE = 'start'
SPLIT_DATE = 'end'
N_TREE = 100
PLOT = 'fi' #lc=learning curve, fi=feature importances

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

  featuresToUse = possibleFeatures

  cat('    Number of features to use: ', length(featuresToUse), '/', length(possibleFeatures), '\n', sep='')
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

plotScores = function(dateStrs, y, yLow, yHigh, ...) {
  dates = as.Date(dateStrs)

  plot(dates, y, type='n', ylim=c(min(y, yLow, na.rm=T), max(y, yHigh, na.rm=T)),
       ylab='Fantasy Points', xlab='Date', xaxt='n', ...)
  lines(dates, yLow, col='blue')
  lines(dates, yHigh, col='blue')

  polygon(c(dates, rev(dates)), c(yHigh, rev(yLow)),
          col = "azure", border = NA)
  lines(dates, y, col='red')

  axis.Date(side=1, dates, format="%m/%d")
}

#============= Main ================

Y_NAME = 'FantasyPoints'
PLOT = 'Scores'

if (PROD_RUN) cat('PROD RUN: ', FILENAME, '\n', sep='')

#load data
data = getData()
possibleFeatures = setdiff(names(data), c('Name', 'Date', Y_NAME))
featuresToUse = findBestSetOfFeatures(train, possibleFeatures)

#load contest data
contestData = getContestData()

cat('Making predictions...\n')

#these are arrays to plot later
percentVarExplaineds = c()
testErrors = c()
teamRatios = c()
myTeamActualFantasyPointss = c()
highestWinningScores = c()
lowestWinningScores = c()

dateStrs = sort(unique(data$Date))[-1]
for (dateStr in dateStrs) {
  cat('    ', dateStr, ': ', sep='')

  #split data into train, test
  splitData = splitDataIntoTrainTest(data, 'start', dateStr)
  train = splitData$train
  test = splitData$test

  #create model
  #cat('    Creating Model (ntree=', N_TREE, ')...\n', sep='')
  timeElapsed = system.time(model <- createModel(train, Y_NAME, featuresToUse))
  meanOfSquaredResiduals = model$mse[N_TREE]
  percentVarExplained = model$rsq[N_TREE]*100
  #cat('        Time to compute model: ', timeElapsed[3], '\n', sep='')
  #cat('    MeanOfSquaredResiduals / %VarExplained: ', meanOfSquaredResiduals, '/', percentVarExplained, '\n', sep='')

  #create prediction
  prediction = createPrediction(model, test, featuresToUse)
  testError = computeError(test[[Y_NAME]], prediction)
  #cat('MSR, %VarExplained, RMSE: ', meanOfSquaredResiduals, ', ', percentVarExplained, ', ', testError, sep='')

  #create teams for today
  teams = createTeams(test, prediction, Y_NAME)
  myTeam = teams$myTeam
  bestTeam = teams$bestTeam
  teamRatio = teams$ratio

  #get actual fanduel winning score for currday
  highestWinningScore = getHighestWinningScore(contestData, dateStr)
  lowestWinningScore = getLowestWinningScore(contestData, dateStr)

  #print results
  cat(' Expected score=', round(myTeam$expectedFantasyPoints, 2), sep='')
  cat(', actual=', round(myTeam$fantasyPoints, 2), sep='')
  #cat(', best=', round(bestTeam$fantasyPoints, 2), sep='')
  cat(', low=', round(lowestWinningScore, 2), sep='')
  cat(', high=', round(highestWinningScore, 2), sep='')
  #cat(', TeamRatio=', round(teamRatio*100, 2), '%', sep='')
  cat('\n')

  #add data to arrays to plot
  percentVarExplaineds = c(percentVarExplaineds, percentVarExplained)
  testErrors = c(testErrors, testError)
  teamRatios = c(teamRatios, teamRatio)
  myTeamActualFantasyPointss = c(myTeamActualFantasyPointss, myTeam$fantasyPoints)
  highestWinningScores = c(highestWinningScores, highestWinningScore)
  lowestWinningScores = c(lowestWinningScores, lowestWinningScore)
}

if (PLOT == 'Scores') plotScores(dateStrs, myTeamActualFantasyPointss, lowestWinningScores, highestWinningScores, main='Fantasy Points Comparison')
if (PLOT == 'Mine&Lowest') plotByDate(dateStrs, myTeamActualFantasyPointss, y2=lowestWinningScores, main='Fantasy Point Comparison', ylab='Fantasy Points', y2lab='Lowest Winning Score')
if (PLOT == 'RMSE') plotByDate(dateStrs, testErrors, main='RMSE by Date', ylab='RMSE')
if (PLOT == 'RMSE&TeamRatios') plotByDate2Axis(dateStrs, testErrors, y2=teamRatios, y2lab='Team Ratios', y2lim=c(0, 1), main='RMSE and Team Ratios', ylab='RMSE')

cat('Done!\n')
