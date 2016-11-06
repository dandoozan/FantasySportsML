#todo:
#-try fanduel features (salary, injury, ?)

#for each day in day 2 - now
  #load all data from beginning up to currday (call it train)
  #load data for currday (as test)
  #build model on train
  #predict on test
  #add rmse of prediction to rmses
#plot all rmses

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
  cat('    Splitting data into train/test...\n')

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

ID_NAME = 'Name'
Y_NAME = 'FantasyPoints'

if (PROD_RUN) cat('PROD RUN: ', FILENAME, '\n', sep='')

data = getData()
possibleFeatures = setdiff(names(data), c(ID_NAME, Y_NAME))

testErrors = c()

dates = unique(data$Date)
for (i in 2:length(dates)) {
  cat('Predicting fantasy scrore for date: ', dates[i], '\n')
  splitData = splitDataIntoTrainTest(data, 'start', dates[i])
  train = splitData$train
  test = splitData$test

  #find best set of features to use
  featuresToUse = findBestSetOfFeatures(train, possibleFeatures)

  cat('Creating Model (ntree=', N_TREE, ')...\n', sep='')
  timeElapsed = system.time(model <- createModel(train, Y_NAME, featuresToUse))
  cat('    Time to compute model: ', timeElapsed[3], '\n', sep='')
  cat('    MeanOfSquaredResiduals / %VarExplained: ', model$mse[N_TREE], '/', model$rsq[N_TREE]*100, '\n', sep='')

  #print test error
  prediction = createPrediction(model, test, featuresToUse)
  testError = computeError(test[[Y_NAME]], prediction)
  cat('    Tonight\'s error: ', testError, '\n', sep='')
  testErrors = c(testErrors, testError)
}

plot(testErrors)

cat('Done!\n')
