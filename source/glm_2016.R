#================= Functions ===================
createModel = function(d, yName, xNames, amountToAddToY) {
  set.seed(754)
  return(cv.glmnet(x=as.matrix(d[, xNames]), y=d[[yName]]))
}
createPrediction = function(model, newData, xNames, amountToAddToY) {
  return(predict(model, as.matrix(newData[, xNames]), s='lambda.min')[,1])
}
computeError = function(y, yhat, amountToAddToY) {
  return(rmse(y, yhat))
}
printModelResults = function(model) {
  return()
}
findBestHyperParams = function(d, yName, xNames, amountToAddToY) {
  return(NULL)
}
doPlots = function(toPlot, prodRun, data, yName, xNames, amountToAddToY, filename) {
  return()
}
#============= Main ================

# setwd('/Users/dan/Desktop/ML/df')
# library(glmnet)
# library(hydroGOF) #rmse
# source('../ml-common/plot.R')
# source('../ml-common/util.R')
# source('source/_getData_2016.R')
# source('source/_createTeam.R')
# Y_NAME = 'FP'
# d = getData()
# featuresToUse = c('RG_points', 'NF_FP')
# hyperParams = NULL
# model = createModel(d, Y_NAME, featuresToUse)
# printTrnCvTrainErrors(model, d, Y_NAME, featuresToUse, createModel, createPrediction, computeError)
# cat('Done!\n')
