#todo:
#-Make initial prediction using salary: 01_rf_salary: numFeaturesUsed=1/1, Trn/CV Error=10.15385/10.16979, Train Error=10.15067
#-Use log of y
#-Remove players who played less than 5 min or so to remove the many 0 scores
#-Use 2014 data


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

  featuresToUse = possibleFeatures

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
Y_NAME = 'FantasyPoints'
FILENAME = '01_rf_salary'
PROD_RUN = T
PLOT = 'lc' #lc=learning curve, fi=feature importances

data = getData(Y_NAME, oneHotEncode=F)
possibleFeatures = setdiff(names(data), Y_NAME)

#find best set of features to use based on cv error
featuresToUse = findBestSetOfFeatures(data, possibleFeatures)

cat('Creating Model...\n')
model = createModel(data, Y_NAME, featuresToUse)

#plots
if (PROD_RUN || PLOT=='lc') plotLearningCurve(data, Y_NAME, featuresToUse, createModel, createPrediction, computeError, save=PROD_RUN)
if (PROD_RUN || PLOT=='fi') plotImportances(model, save=PROD_RUN)

#print trn/cv, train error
printTrnCvTrainErrors(model, data, Y_NAME, featuresToUse, createModel, createPrediction, computeError)

cat('Done!\n')
