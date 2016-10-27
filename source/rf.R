#todo:
#D-Make initial prediction using salary: 01_rf_salary: numFeaturesUsed=1/1, Trn/CV Error=10.15385/10.16979, Train Error=10.15067
#D-Use 2014 data: NONE: 1/1, 8.888702/8.924981, 8.887228
#D-Use train/test data and keep NAs in data: rf_keepNAs: 1/2, 8.895979/8.880356, 8.887228
#D-Write script to create team: rf_createTeam: 1/3, 8.895979/8.880356, 8.887228
#D-Run for 20161025: 20161025: 1/3, 9.761371/9.643101, 9.733458
#D-Output test (tonight's predictions) error: 1/3, 9.761371/9.643101, 9.733458, testError=10.24964
#-fix NAs in data
#-Use log of y
#-Remove players who played less than 5 min or so to remove the many 0 scores
#-Use more features than salary
#-Use probability that a player will do much better/much worse than expected
#-Identify high-risk vs low-risk player, and perhaps only choose team from players who are low-risk

#Process to get team for day:
#1. Change DATE (eg. 20161025)
#2. Source this file (rf.R)
  #-Prints RMSE for Trn/CV, Train, Test
  #-Prints ratio of my team score/best team score
  #-Outputs: prediction_[date].csv


#Remove all objects from the current workspace
rm(list = ls())
setwd('/Users/dan/Desktop/ML/df')

library(randomForest) #randomForest
library(hydroGOF) #rmse
library(ggplot2) #visualization
library(ggthemes) # visualization
source('source/_getData.R')
source('../ml-common/plot.R')
source('../ml-common/util.R')

#============== Functions ===============

createModel = function(data, yName, xNames) {
  set.seed(754)
  return(randomForest(getFormula(yName, xNames),
                      data=data,
                      na.action=na.omit,
                      ntree=500))
}
createPrediction = function(model, newData, xNames=NULL) {
  return(predict(model, newData))
}
computeError = function(y, yhat) {
  return(rmse(y, yhat))
}
findBestSetOfFeatures = function(data, possibleFeatures) {
  cat('Finding best set of features to use...\n')

  #use only salary for now
  featuresToUse = 'Salary'

  cat('    Number of features to use: ', length(featuresToUse), '/', length(possibleFeatures), '\n')
  cat('    Features to use:', paste(featuresToUse, collapse=', '), '\n')
  return(featuresToUse)
}

#I do not understand any of this code, I borrowed it from a kaggler
plotImportances = function(model, save=FALSE) {
  cat('Plotting Feature Importances...\n')

  # Get importance
  importances = randomForest::importance(model)
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

#============= Main ================

#Globals
PROD_RUN = F
ID_NAME = 'Name'
Y_NAME = 'FantasyPoints'
DATE = '20161025'
FILENAME = DATE
DATE_FORMAT = '%Y%m%d'
PLOT = '' #lc=learning curve, fi=feature importances

if (PROD_RUN) cat('PROD RUN: ', FILENAME, '\n', sep='')

date = as.Date(DATE, DATE_FORMAT)
data = getData(Y_NAME, date, DATE_FORMAT, oneHotEncode=F)
train = data$train #train=all data leading up to tonight
test = data$test #test=tonight's team
possibleFeatures = setdiff(names(train), c(ID_NAME, Y_NAME))

#find best set of features to use based on cv error
featuresToUse = findBestSetOfFeatures(train, possibleFeatures)

cat('Creating Model...\n')
model = createModel(train, Y_NAME, featuresToUse)

#plots
if (PROD_RUN || PLOT=='lc') plotLearningCurve(train, Y_NAME, featuresToUse, createModel, createPrediction, computeError, save=PROD_RUN)
if (PROD_RUN || PLOT=='fi') plotImportances(model, save=PROD_RUN)

#print trn/cv, train error
printTrnCvTrainErrors(model, train, Y_NAME, featuresToUse, createModel, createPrediction, computeError)

#print test error
testError = computeError(test[, Y_NAME], createPrediction(model, test, featuresToUse))
cat('    Tonight\'s error: ', testError, '\n', sep='')


# if (PROD_RUN) {
#   outputFilename = paste0('prediction_', FILENAME, '.csv')
#   extraColNames = c('Salary', 'Position')
#   outputSolution(createPrediction, model, test, ID_NAME, Y_NAME, featuresToUse, outputFilename, extraColNames)
# }

cat('Done!\n')
