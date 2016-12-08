#todo:
#D-Add dates up to yesterday (11/18): 71_nov18_xgb:  10/27-11/18, 104/230, 266, 41, 6.707493/7.760857, 1.653, 6.719638/7.945174/6.88318, Inf, 7.879964/16.12162, 0.9473712
#D-Use NBA FP as Y_NAME: 73_nbaFp_xgb: 10/27-11/18, 104/260, 266, 43, 6.69183/7.771218, 1.574, 6.653663/8.075014/6.870274, Inf, 7.942952/18.6436, 0.9284567
#D-Remove GTD and Out players: 74_rmGtdOut_xgbL: 10/27-11/18, 102/261, 266, 37, 6.938448/8.016219, 0.914, 6.930815/7.886743/7.095053, Inf, 8.103604/14.58009, 0.9388279
#D-Plot balance: 75_balance_xgb: 10/27-11/18, 102/261, 266, 37, 6.938448/8.016219, 0.921, 6.930815/7.886743/7.095053, Inf, Gain=$4, 8.103604/14.58009, 0.919391
#D-Fix bug in createDataFile: 76_dataBug_xgb: 10/27-11/18, 102/261, 266, 37, 6.938443/8.016218, 0.93, 6.930815/7.886737/7.095035, Inf, $4, 8.09966/14.42227, 0.9167998
#D-Compute cv rmse with same as RG data: 77_RGrmse_xgb: 10/27-11/18, 102/262, 266, 37, 6.938443/8.016218, 0.905, 7.557726/8.381168/7.727685, Inf, $4, 8.09966/14.42227, 0.9167998
#D-Add dates (up to 11/23): 78_nov23_xgb: 10/27-11/23, 102/262, 266, 38, 7.071784/8.028437, 1.448, 7.540131/8.983257/7.852722, Inf, 8.138115/14.33826, 0.9119179
#D-Use RG, NF data for trn/cv errors: 79_RGAndNF_xgb: 10/27-11/23, 102/264, 266, 38, 7.071784/8.028437, 1.155, 7.555149/9.139898/7.863341, Inf, 8.138115/14.33826, 0.9119179
#D-Plot team using RG points: 80_plotRG_xgb: 10/27-11/23, 102/264, 266, 38, 7.071784/8.028437, 1.268, 7.555149/9.139898/7.863341, Inf, 8.138115/14.33826, 0.9119179
#D-Make RG,NF error apples-to-apples: 81_RGNFerrors_xgb: 10/27-11/23, 102/264, 266, 38, 7.071784/8.028437, 1.132, 7.033946/8.14378/7.191407, RG/Mine=9.037832/9.032108, NF/Mine=8.849512/8.338964, Inf, 8.138115/14.33826, 0.9119179
#D-Rerun boruta: 82_boruta_xgb: 10/27-11/23, 121/264, 266, 45, 6.923147/8.007204, 4.332, 6.921224/8.103531/7.065831, Inf, 8.113962/16.7418, 0.9296685
#D-Retune: 83_retune_xgb: 10/27-11/23, 121/264, 266, 53, 7.701541/8.002063, 3.455, 7.694258/8.06044/7.756014, Inf, -$8, 8.081185/10.13511, 0.9107249
#D-Start plot from 11/7: 84_plotNov7_xgb: 10/27-11/23, 121/264, 266, 53, 7.701541/8.002063, 2.725, 7.694258/8.06044/7.756014, Inf, -$8, 8.094706/9.56801, 0.9151632
#D-Retune xgb params: 85_retune_xgb: 10/27-11/23, 121/264, 266, 55, 7.400829/7.981152, 3.778, 7.394017/8.098042/7.503997, Inf, $8, 8.085093/10.28753, 0.9251442
#D-Fix PlayerBios NA imputation: 86_fixPBNA_xgb: 10/27-11/23, 121/265, 266, 50, 7.455275/7.990815, 2.643, 7.42947/8.135216/7.523257, Inf, $0, 8/8, 8.076828/10.12836, 0.9109897
#D-Retune xgb params: 87_retune_xgb: 10/27-11/23, 121/265, 266, 48, 7.353933/7.986254, 4.16, 7.357119/8.094131/7.435808, Inf, -$4, 7/9, 8.071163/10.13492, 0.9291407

#-Use RG_points, NF_FP: train/cvErrors=7.799588/8.079554, Trn/CV/Train=7.794999/8.146878/7.841864, $8, 10/6, 8.107805/9.329115, 0.9542339
#-Remove players not in RG and NF: 8.502619/8.841369, 8.419662/9.240263/8.552652, $0, 8/8, 8.921783/8.938733, 0.941946
#-Use rmsle as error: 8.502619/8.841369, 0.5412207/0.5780044/0.5486122, RG=0.578914/0.5780044, NF=0.6198487/0.5780044, $0, 8/8, 0.5556841/0.5651253/0.335886, 0.941946
#-Use log(y) as y: 0.521395/0.541843, 0.5156722/0.566101/0.523897, Inf, $16, 12/4, 0.5387099/0.5651253/0.3190233, 0.9792446


library(xgboost) #xgb.train, xgb.cv

# setwd('/Users/dan/Desktop/ML/df')
#
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
xgb = function() {
  xgbObj = list(
    createModel = function(d, yName, xNames, amountToAddToY) {
      #compute dataAsDMatrix before setting the seed to get exact same result as findBestSeedAndNrounds
      dataAsDMatrix = xgbObj$getDMatrix(d, yName, xNames, amountToAddToY)
      hyperParams = xgbObj$findBestHyperParams(d, yName, xNames, amountToAddToY)
      set.seed(hyperParams$seed)
      return(xgb.train(data=dataAsDMatrix,
                       params=xgbObj$getHyperParams(),
                       nrounds=hyperParams$nrounds,
                       verbose=0))
    },
    createPrediction = function(model, newData, xNames, amountToAddToY) {
      return(predict(model, data.matrix(xgbObj$oneHotEncode(newData, xNames))))
      #return(exp(predict(model, data.matrix(xgbObj$oneHotEncode(newData, xNames)))) - amountToAddToY)
    },

    createCvModel = function(d, yName, xNames, amountToAddToY) {
      dataAsDMatrix = xgbObj$getDMatrix(d, yName, xNames, amountToAddToY)
      hyperParams = xgbObj$findBestHyperParams(d, yName, xNames, amountToAddToY)
      set.seed(hyperParams$seed)
      cvRes = xgb.cv(data=dataAsDMatrix,
                     params=xgbObj$getHyperParams(),
                     nfold=5,
                     nrounds=hyperParams$nrounds,
                     verbose=0)
      return(cvRes)
    },

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
    },
    getHyperParams = function() {
      return(list(
        #values=gbtree|gblinear|dart, default=gbtree, toTry=gbtree,gblinear
        booster = 'gbtree', #gbtree/dart=tree based, gblinear=linear function. Remove eta when using gblinear

        #range=[0,1], default=0.3, toTry=0.01,0.015,0.025,0.05,0.1
        eta = 0.1,#0.1 #learning rate. Lower value=less overfitting, but increase nrounds when lowering eta

        #range=[0,∞], default=0, toTry=?
        gamma = 0,#0 #Larger value=less overfitting

        #range=[1,∞], default=6, toTry=3,5,7,9,12,15,17,25
        max_depth = 3,#10 #Lower value=less overfitting

        #range=(0,1], default=1, toTry=0.6,0.7,0.8,0.9,1.0
        subsample = 1,#1 #ratio of sample of data to use for each instance (eg. 0.5=50% of data). Lower value=less overfitting

        #range=[0,∞], default=1, toTry=1,3,5,7
        min_child_weight = 1,#5 #Larger value=less overfitting

        #range=(0,1], default=1, toTry=0.6,0.7,0.8,0.9,1.0
        colsample_bytree = 1,#0.2 #ratio of cols (features) to use in each tree. Lower value=less overfitting

        #----Parameters for Linear Booster:-----
        #range=[0,∞], default=0, toTry=0->1000 or more
        #lambda = 0, #Larger value=less overfitting

        #range=[0,∞], default=0, toTry=0->1000 or more
        #alpha = 0, #Larger value=less overfitting

        #range=[0,∞], default=0, toTry=0->100? or more
        #lambda_bias = 0,

        objective = 'reg:linear'
      ))
    },


    plotCVErrorRates = function(d, yName, xNames, amountToAddToY, ylim=NULL, save=FALSE, filename='') {
      cat('    Plotting CV Error Rates...\n')

      dataAsDMatrix = xgbObj$getDMatrix(d, yName, xNames, amountToAddToY)
      hyperParams = xgbObj$findBestHyperParams(d, yName, xNames, amountToAddToY)
      set.seed(hyperParams$seed)
      cvRes = xgb.cv(data=dataAsDMatrix,
                     params=xgbObj$getHyperParams(),
                     nfold=5,
                     nrounds=(hyperParams$nrounds * 1.5), #times by 1.5 to plot a little extra
                     verbose=0)
      trainErrors = cvRes[[1]]
      cvErrors = cvRes[[3]]

      cvRes = createCvModel(d, yName, xNames, amountToAddToY)

      if (is.null(ylim)) {
        ylim = c(0, max(cvErrors, trainErrors))
      }

      if (save) startSavePlot('XGBErrorRates', filename)
      plot(trainErrors, type='l', col='blue', ylim=ylim, main='Train Error vs. CV Error', xlab='Num Rounds', ylab='Error')
      lines(cvErrors, col='red')
      addLegend(labels=c('train', 'cv'), colors=c('blue', 'red'))
      if (save) endSavePlot()
    },
    plotImportances = function(model, d, xNames, maxFeatures=50, save=FALSE, filename='') {
      cat('    Plotting Feature Importances...\n')

      featureNames = colnames(xgbObj$oneHotEncode(d, xNames))

      importances = xgb.importance(feature_names=featureNames, model=model)
      importances = importances[1:min(nrow(importances), maxFeatures), ]
      if (save) startSavePlot('Importances_xgb', filename, height=max(nrow(importances)*20, 700))
      print(xgb.plot.importance(importance_matrix=importances))
      if (save) endSavePlot()
    },

    findBestSeedAndNrounds = function(d, yName, xNames, amountToAddToY, earlyStopRound=10, numSeedsToTry=1) {
      #cat('Finding best seed and nrounds.  Trying ', numSeedsToTry, ' seeds...\n', sep='')

      dataAsDMatrix = xgbObj$getDMatrix(d, yName, xNames, amountToAddToY)
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
                                                params=xgbObj$getHyperParams(),
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

      #if (numSeedsToTry > 1) cat('    Average errors: train=', mean(trainErrors), ', cv=', mean(cvErrors), '\n', sep='')
      #cat('    Best seed=', bestSeed, ', nrounds=', bestNrounds, ', train/cvErrors=', bestTrainError, '/', bestCvError, '\n', sep='')

      return(list(seed=bestSeed, nrounds=bestNrounds))
    },

    getDMatrix = function(d, yName, xNames, amountToAddToY) {
      set.seed(634)
      #return(xgb.DMatrix(data=data[, xNames], label=data[, yName]))
      return(xgb.DMatrix(data=data.matrix(xgbObj$oneHotEncode(d, xNames)), label=d[, yName]))
      #return(xgb.DMatrix(data=data.matrix(xgbObj$oneHotEncode(d, xNames)), label=log(d[, yName] + amountToAddToY)))
    },
    oneHotEncode = function(d, xNames) {
      dataToUse = convertToDataFrame(d[, xNames], xNames)
      dmy = caret::dummyVars('~.', dataToUse, fullRank=T)
      return(data.frame(predict(dmy, dataToUse)))
    },

    printModelResults = function(d, yName, xNames, amountToAddToY, prefix='') {
      cvRes = xgbObj$createCvModel(d, yName, xNames, amountToAddToY)
      cat(prefix, 'Train/CV Errors=', cvRes[[1]][nrow(cvRes)], '/', cvRes[[3]][nrow(cvRes)], '\n', sep='')
    },
    findBestHyperParams = function(d, yName, xNames, amountToAddToY) {
      #find best seed and nrounds
      return(xgbObj$findBestSeedAndNrounds(d, yName, xNames, amountToAddToY))
    },

    doPlots = function(toPlot, prodRun, d, yName, xNames, amountToAddToY, filename) {
      if (prodRun || toPlot=='cv') xgbObj$plotCVErrorRates(d, yName, xNames, amountToAddToY, ylim=c(0, 15), save=prodRun, filename=filename)
      if (prodRun || toPlot == 'fi') xgbObj$plotImportances(xgbObj$createModel(d, yName, xNames, amountToAddToY), d, xNames, save=prodRun, filename=filename)
    }
  )
  return(xgbObj)
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
