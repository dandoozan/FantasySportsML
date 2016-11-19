#todo:
# setwd('/Users/dan/Desktop/ML/df')
#
# library(xgboost) #xgb.train, xgb.cv
# library(caret) #dummyVars
# library(Ckmeans.1d.dp) #xgb.plot.importance
# library(randomForest) #randomForest
# library(hydroGOF) #rmse
# library(ggplot2) #visualization
# library(ggthemes) #visualization
# library(dplyr) #%>%
# source('../ml-common/plot.R')
# source('../ml-common/util.R')
# source('source/_getData_2016.R')
# source('source/_createTeam.R')
#
# #Globals
# Y_NAME = 'FantasyPoints'

#================= Functions ===================

createModel = function(data, yName, xNames) {
  set.seed(hyperParams$seed)
  return(xgb.train(data=getDMatrix(data, yName, xNames),
                   params=getHyperParams(),
                   nrounds=hyperParams$nrounds,
                   verbose=0))
}
createPrediction = function(model, newData, xNames) {
  #return(predict(model, newData[, xNames]))
  return(predict(model, data.matrix(oneHotEncode(newData[, xNames]))))
}
computeError = function(y, yhat) {
  return(rmse(y, yhat))
}

#these are the params i used for gblinear
getHyperParams_gblinear = function() {
  return(list(
    #values=gbtree|gblinear|dart, default=gbtree, toTry=gbtree,gblinear
    booster = 'gblinear', #gbtree/dart=tree based, gblinear=linear function. Remove eta when using gblinear

    #range=[0,∞], default=0, toTry=0->1000 or more
    lambda = 100, #Larger value=less overfitting

    #range=[0,∞], default=0, toTry=0->1000 or more
    alpha = 70, #Larger value=less overfitting

    #range=[0,∞], default=0, toTry=0->100? or more
    lambda_bias = 3,

    objective = 'reg:linear'
  ))
}
getHyperParams = function() {
  return(list(
    #values=gbtree|gblinear|dart, default=gbtree, toTry=gbtree,gblinear
    booster = 'gbtree', #gbtree/dart=tree based, gblinear=linear function. Remove eta when using gblinear

    #range=[0,1], default=0.3, toTry=0.01,0.015,0.025,0.05,0.1
    #eta = 0.1,#0.1 #learning rate. Lower value=less overfitting, but increase nrounds when lowering eta

    #range=[0,∞], default=0, toTry=?
    #gamma = 0,#0 #Larger value=less overfitting

    #range=[1,∞], default=6, toTry=3,5,7,9,12,15,17,25
    #max_depth = 4,#10 #Lower value=less overfitting

    #range=(0,1], default=1, toTry=0.6,0.7,0.8,0.9,1.0
    #subsample = 0.9,#1 #ratio of sample of data to use for each instance (eg. 0.5=50% of data). Lower value=less overfitting

    #range=[0,∞], default=1, toTry=1,3,5,7
    #min_child_weight = 6,#5 #Larger value=less overfitting

    #range=(0,1], default=1, toTry=0.6,0.7,0.8,0.9,1.0
    #colsample_bytree = 0.6,#0.2 #ratio of cols (features) to use in each tree. Lower value=less overfitting

    #----Parameters for Linear Booster:-----
    #range=[0,∞], default=0, toTry=0->1000 or more
    #lambda = 0, #Larger value=less overfitting

    #range=[0,∞], default=0, toTry=0->1000 or more
    #alpha = 0, #Larger value=less overfitting

    #range=[0,∞], default=0, toTry=0->100? or more
    #lambda_bias = 0,

    objective = 'reg:linear'
  ))
}

plotCVErrorRates = function(data, yName, xNames, ylim=NULL, save=FALSE, filename='') {
  cat('    Plotting CV Error Rates...\n')

  dataAsDMatrix = getDMatrix(data, yName, xNames)

  set.seed(hyperParams$seed)
  cvRes = xgb.cv(data=dataAsDMatrix,
                 params=getHyperParams(),
                 nfold=5,
                 nrounds=(hyperParams$nrounds * 1.5), #times by 1.5 to plot a little extra
                 verbose=0)
  trainErrors = cvRes[[1]]
  cvErrors = cvRes[[3]]

  if (is.null(ylim)) {
    ylim = c(0, max(cvErrors, trainErrors))
  }

  if (save) startSavePlot('XGBErrorRates', filename)
  plot(trainErrors, type='l', col='blue', ylim=ylim, main='Train Error vs. CV Error', xlab='Num Rounds', ylab='Error')
  lines(cvErrors, col='red')
  addLegend(labels=c('train', 'cv'), colors=c('blue', 'red'))
  if (save) endSavePlot()
}
plotImportances = function(model, xNames, maxFeatures=50, save=FALSE, filename='') {
  cat('    Plotting Feature Importances...\n')

  featureNames = colnames(oneHotEncode(data[, xNames]))

  importances = xgb.importance(feature_names=featureNames, model=model)
  importances = importances[1:min(nrow(importances), maxFeatures), ]
  if (save) startSavePlot('Importances', filename, height=max(nrow(importances)*20, 700))
  print(xgb.plot.importance(importance_matrix=importances))
  if (save) endSavePlot()
}

findBestSeedAndNrounds = function(data, yName, xNames, earlyStopRound=10, numSeedsToTry=1) {
  cat('Finding best seed and nrounds.  Trying ', numSeedsToTry, ' seeds...\n', sep='')

  dataAsDMatrix = getDMatrix(data, yName, xNames)
  initialNrounds = 10000
  maximize = FALSE
  bestSeed = 1
  bestNrounds = 0
  bestTrainError = Inf
  bestCvError = Inf
  trainErrors = numeric(numSeedsToTry)
  cvErrors = numeric(numSeedsToTry)
  set.seed(1) #set seed at the start here so that we generate the same following seeds every time
  for (i in 1:numSeedsToTry) {
    seed = sample(1:1000, 1)
    if (numSeedsToTry > 1) cat('    ', i, '. Seed ', seed, ': ', sep='')
    set.seed(seed)
    output = capture.output(cvRes <- xgb.cv(data=dataAsDMatrix,
                                            params=getHyperParams(),
                                            nfold=5,
                                            nrounds=initialNrounds,
                                            early.stop.round=earlyStopRound,
                                            maximize=maximize,
                                            verbose=0))
    nrounds = if (length(output) > 0) strtoi(substr(output, 27, nchar(output))) else initialNrounds
    trainErrors[i] = cvRes[[1]][nrounds] #mean train error
    cvErrors[i] = cvRes[[3]][nrounds] #mean test error
    if (numSeedsToTry > 1) cat('nrounds=', nrounds, ', trainError=', trainErrors[i], ', cvError=', cvErrors[i], sep='')
    if (cvErrors[i] < bestCvError) {
      bestSeed = seed
      bestNrounds = nrounds
      bestTrainError = trainErrors[i]
      bestCvError = cvErrors[i]
      if (numSeedsToTry > 1) cat(' <- New best!')
    }
    if (numSeedsToTry > 1) cat('\n')
  }

  if (numSeedsToTry > 1) cat('    Average errors: train=', mean(trainErrors), ', cv=', mean(cvErrors), '\n', sep='')
  cat('    Best seed=', bestSeed, ', nrounds=', bestNrounds, ', train/cvErrors=', bestTrainError, '/', bestCvError, '\n', sep='')

  return(list(seed=bestSeed, nrounds=bestNrounds))
}

getDMatrix = function(data, yName, xNames) {
  set.seed(634)
  #return(xgb.DMatrix(data=data[, xNames], label=data[, yName]))
  return(xgb.DMatrix(data.matrix(oneHotEncode(data[, xNames])), label=data[, yName]))
}

oneHotEncode = function(data) {
  #data = data[, setdiff(colnames(data), c('Date', 'Name'))]
  dmy = caret::dummyVars('~.', data, fullRank=T)
  return(data.frame(predict(dmy, data)))
}

printModelResults = function(model) {
  return()
}
findBestHyperParams = function(data, yName, xNames) {
  #find best seed and nrounds
  return(findBestSeedAndNrounds(data, yName, xNames))
}

doPlots = function(toPlot, prodRun, data, yName, xNames, filename) {
  if (prodRun || toPlot=='cv') plotCVErrorRates(data, yName, xNames, ylim=c(0, 15), save=prodRun, filename=filename)
}
#============= Main ================

# train = data.matrix(oneHotEncode(getData(END_DATE)))
#
# FEATURES_TO_USE = setdiff(colnames(train), c('FantasyPoints', 'Date', 'Name'))
#
# #find best seed and nrounds
# hyperParams = findBestSeedAndNrounds(train, Y_NAME, FEATURES_TO_USE)
# SEED = sn$seed
# NROUNDS = sn$nrounds
#
# #create model
# cat('Creating Model...\n')
# model = createModel(train, Y_NAME, FEATURES_TO_USE)
#
# #print trn/cv, train error
# printTrnCvTrainErrors(model, train, Y_NAME, FEATURES_TO_USE, createModel, createPrediction, computeError)
#
# cat('Done!\n')
