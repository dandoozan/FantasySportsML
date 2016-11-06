#todo:
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

plotRMSEs = function(dateStrs, rmseValues, y2=NULL, y2lab='', y2lim=NULL) {
  dates = as.Date(dateStrs)

  #make the margin wider on side 4 (right side) if there is a second y
  if (is.null(y2)) {
    par(mar=c(5, 4, 4, 2) + 0.1)
  } else {
    par(mar=c(5, 4, 4, 5) + 0.1)
  }

  plot(dates, rmseValues, type='l', col='red', main='RMSE by Date', xlab='Date', ylab='RMSE', xaxt="n")
  axis.Date(side=1, dates, format="%m/%d")

  if (!is.null(percentVarExplaineds)) {
    par(new=TRUE)
    plot(dates, y2, ylim=y2lim, type='l', col='blue', xaxt='n', yaxt='n', xlab='', ylab='')
    axis(side=4)
    mtext(y2lab, side=4, line=3)
  }
}
#============= Main ================

Y_NAME = 'FantasyPoints'

if (PROD_RUN) cat('PROD RUN: ', FILENAME, '\n', sep='')

data = getData()
possibleFeatures = setdiff(names(data), c('Name', 'Date', Y_NAME))
featuresToUse = findBestSetOfFeatures(train, possibleFeatures)

cat('Making predictions...\n')

percentVarExplaineds = c()
testErrors = c()
teamRatios = c()

dateStrs = sort(unique(data$Date))[-1]
for (dateStr in dateStrs) {
  cat('    ', dateStr, ': ', sep='')
  splitData = splitDataIntoTrainTest(data, 'start', dateStr)
  train = splitData$train
  test = splitData$test

  #cat('    Creating Model (ntree=', N_TREE, ')...\n', sep='')
  timeElapsed = system.time(model <- createModel(train, Y_NAME, featuresToUse))
  meanOfSquaredResiduals = model$mse[N_TREE]
  percentVarExplained = model$rsq[N_TREE]*100
  #cat('        Time to compute model: ', timeElapsed[3], '\n', sep='')
  #cat('    MeanOfSquaredResiduals / %VarExplained: ', meanOfSquaredResiduals, '/', percentVarExplained, '\n', sep='')

  #print test error
  prediction = createPrediction(model, test, featuresToUse)
  testError = computeError(test[[Y_NAME]], prediction)
  cat('MSR, %VarExplained, RMSE: ', meanOfSquaredResiduals, ', ', percentVarExplained, ', ', testError, sep='')

  teams = createTeams(test, prediction, Y_NAME)
  myTeam = teams$myTeam
  bestTeam = teams$bestTeam
  teamRatio = teams$ratio
  #cat('    My team expected score=', round(myTeam$expectedFantasyPoints, 2), sep='')
  #cat(', actual=', round(myTeam$fantasyPoints, 2), sep='')
  #cat(', best=', round(bestTeam$fantasyPoints, 2), sep='')
  cat(', TeamRatio=', round(teamRatio*100, 2), '%', sep='')
  cat('\n')

  percentVarExplaineds = c(percentVarExplaineds, percentVarExplained)
  testErrors = c(testErrors, testError)
  teamRatios = c(teamRatios, teamRatio)
}

plotRMSEs(dateStrs, testErrors, y2=teamRatios, y2lab='Team Ratios', y2lim=c(0, 1))

cat('Done!\n')
