
#D-Use RG_points, NF_FP: Trn/CV/Train=8.704967/9.173133/8.800143, RG=9.21892/9.173133, NF=9.654601/9.173133, -$4, 7/9, 8.833883/8.953031/10.05593, 0.9343918
#D-Use log(y): 0.5597699/0.5754786/0.5629384, 0.578914/0.5754786, 0.6198487/0.5754786, -$8, 6/10, 0.5606038/0.5651253/0.4276129, 0.9191064

#================= Functions ===================
createModel = function(d, yName, xNames, hyperParams, amountToAddToY) {
  set.seed(754)
  #return(cv.glmnet(x=as.matrix(d[, xNames]), y=d[[yName]]))
  return(cv.glmnet(x=as.matrix(d[, xNames]), y=log(d[[yName]] + amountToAddToY)))
}
createPrediction = function(model, newData, xNames, amountToAddToY) {
  #return(predict(model, as.matrix(newData[, xNames]), s='lambda.min')[,1])
  return(exp(predict(model, as.matrix(newData[, xNames]), s='lambda.min')[,1]) - amountToAddToY)
}
computeError = function(y, yhat, amountToAddToY) {
  #return(rmse(y, yhat))
  return(rmse(log(y + amountToAddToY), log(yhat + amountToAddToY)))
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
