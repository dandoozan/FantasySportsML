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
# PROD_RUN = F
# FILENAME = 'rf_19cov'
# END_DATE = '2016-11-08'
# N_TREE = 100
# PLOT = 'scores' #fi, scores,
# MAX_COV = Inf
# Y_NAME = 'FantasyPoints'
#
# #features excluded: FantasyPoints, Date, Name
# F.ID = c('Date', 'Name', 'Position', 'Team', 'Opponent')
# F.FANDUEL = c('Position', 'FPPG', 'GamesPlayed', 'Salary',
#               'Home', 'Team', 'Opponent', 'InjuryIndicator', 'InjuryDetails')
# F.NUMBERFIRE = c('NF_Min', 'NF_Pts', 'NF_Reb', 'NF_Ast', 'NF_Stl', 'NF_Blk', 'NF_TO', 'NF_FP')
# F.RG.PP = c('RG_ceil', 'RG_floor', 'RG_points', 'RG_ppdk',
#             'RG_line',  'RG_movement', 'RG_overunder', 'RG_total',
#             'RG_contr', 'RG_pownpct', 'RG_rank',
#             'RG_rankdiff', 'RG_saldiff',
#             'RG_deviation', 'RG_minutes',
#             'RG_rank20', 'RG_diff20', 'RG_rank_diff20', 'RG_salary20',
#             'RG_salary15', 'RG_salary19', 'RG_salary28', 'RG_salary43', 'RG_salary50', 'RG_salary58',
#             'RG_points15', 'RG_points19', 'RG_points20', 'RG_points28', 'RG_points43', 'RG_points50', 'RG_points51', 'RG_points58')
# #F.RG.DVP = c('RG_OPP_DVP_CFPPG', 'RG_OPP_DVP_CRK', 'RG_OPP_DVP_PFFPPG', 'RG_OPP_DVP_PFRK', 'RG_OPP_DVP_PGFPPG', 'RG_OPP_DVP_PGRK', 'RG_OPP_DVP_SFFPPG', 'RG_OPP_DVP_SFRK', 'RG_OPP_DVP_SGFPPG', 'RG_OPP_DVP_SGRK')
# F.NBA = c('NBA_SEASON_AGE', 'NBA_SEASON_W', 'NBA_SEASON_L', 'NBA_SEASON_W_PCT', 'NBA_SEASON_MIN', 'NBA_SEASON_FGM', 'NBA_SEASON_FGA', 'NBA_SEASON_FG_PCT', 'NBA_SEASON_FG3M', 'NBA_SEASON_FG3A', 'NBA_SEASON_FG3_PCT', 'NBA_SEASON_FTM', 'NBA_SEASON_FTA', 'NBA_SEASON_FT_PCT', 'NBA_SEASON_OREB', 'NBA_SEASON_DREB', 'NBA_SEASON_REB', 'NBA_SEASON_AST', 'NBA_SEASON_TOV', 'NBA_SEASON_STL', 'NBA_SEASON_BLK', 'NBA_SEASON_BLKA', 'NBA_SEASON_PF', 'NBA_SEASON_PFD', 'NBA_SEASON_PTS', 'NBA_SEASON_PLUS_MINUS', 'NBA_SEASON_DD2', 'NBA_SEASON_TD3')
# F.MINE = c('OPP_DVP_FPPG', 'OPP_DVP_RANK')
#
# FEATURES_TO_USE = c('FPPG', 'GamesPlayed', 'Salary')

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
getHyperParams = function() {
  return(list(
    #values=gbtree|gblinear|dart, default=gbtree, toTry=gbtree,gblinear
    booster = 'gbtree', #gbtree/dart=tree based, gblinear=linear function. Remove eta when using gblinear

    #range=(0,1], default=1, toTry=0.6,0.7,0.8,0.9,1.0
    colsample_bytree = 1, #ratio of cols (features) to use in each tree. Lower value=less overfitting

    #range=[0,1], default=0.3, toTry=0.01,0.015,0.025,0.05,0.1
    eta = 0.3, #learning rate. Lower value=less overfitting, but increase nrounds when lowering eta

    #range=[0,∞], default=0, toTry=?
    gamma = 0, #Larger value=less overfitting

    #range=[1,∞], default=6, toTry=3,5,7,9,12,15,17,25
    max_depth = 6, #Lower value=less overfitting

    #range=[0,∞], default=1, toTry=1,3,5,7
    min_child_weight = 1, #Larger value=less overfitting

    #range=(0,1], default=1, toTry=0.6,0.7,0.8,0.9,1.0
    subsample = 1, #ratio of sample of data to use for each instance (eg. 0.5=50% of data). Lower value=less overfitting

    objective = 'reg:linear'
  ))
}

plotCVErrorRates = function(data, yName, xNames, ylim=NULL, save=FALSE) {
  cat('Plotting CV error rates...\n')

  dataAsDMatrix = getDMatrix(data, yName, xNames)

  set.seed(SEED)
  cvRes = xgb.cv(data=dataAsDMatrix,
                 params=getHyperParams(),
                 nfold=5,
                 nrounds=(NROUNDS * 1.5), #times by 1.5 to plot a little extra
                 verbose=0)
  trainErrors = cvRes[[1]]
  cvErrors = cvRes[[3]]

  if (is.null(ylim)) {
    ylim = c(0, max(cvErrors, trainErrors))
  }

  if (save) png(paste0('ErrorRates_', FILENAME, '.png'), width=500, height=350)
  plot(trainErrors, type='l', col='blue', ylim=ylim, main='Train Error vs. CV Error', xlab='Num Rounds', ylab='Error')
  lines(cvErrors, col='red')
  legend(x='topright', legend=c('train', 'cv'), fill=c('blue', 'red'), inset=0.02, text.width=15)
  if (save) dev.off()
}

plotImportances = function(model, xNames, maxFeatures=50, save=FALSE) {
  cat('Plotting feature importances...\n')

  featureNames = colnames(oneHotEncode(data[, xNames]))

  importances = xgb.importance(feature_names=featureNames, model=model)
  importances = importances[1:min(nrow(importances), maxFeatures), ]
  if (save) png(paste0('plots/Importances_', FILENAME, '.png'), width=500, height=max(nrow(importances)*10, 350))
  print(xgb.plot.importance(importance_matrix=importances))
  if (save) dev.off()
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
    cat('    ', i, '. Seed ', seed, ': ', sep='')
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
    cat('nrounds=', nrounds, ', trainError=', trainErrors[i], ', cvError=', cvErrors[i], sep='')
    if (cvErrors[i] < bestCvError) {
      bestSeed = seed
      bestNrounds = nrounds
      bestTrainError = trainErrors[i]
      bestCvError = cvErrors[i]
      cat(' <- New best!')
    }
    cat('\n')
  }

  cat('    Average errors: train=', mean(trainErrors), ', cv=', mean(cvErrors), '\n', sep='')
  cat('    Best seed=', bestSeed, ', nrounds=', bestNrounds, ', trainError=', bestTrainError, ', cvError=', bestCvError, '\n', sep='')

  return(list(seed=bestSeed, nrounds=bestNrounds))
}

getDMatrix = function(data, yName, xNames) {
  set.seed(634)
  return(xgb.DMatrix(data.matrix(oneHotEncode(data[, xNames])), label=data[, yName]))
}

oneHotEncode = function(data) {
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

#============= Main ================

# train = data.matrix(oneHotEncode(getData(END_DATE)))
#
# #find best set of features to use based on cv error
# featuresToUse = setdiff(colnames(train), c('FantasyPoints', 'Date', 'Name'))
#
# #find best seed and nrounds
# sn = findBestSeedAndNrounds(train, Y_NAME, featuresToUse)
# SEED = sn$seed
# NROUNDS = sn$nrounds
#
# #create model
# cat('Creating Model...\n')
# model = createModel(train, Y_NAME, featuresToUse)
#
# #plots
# if (PROD_RUN || PLOT=='cv') plotCVErrorRates(train, Y_NAME, featuresToUse, ylim=c(0, 0.2), save=PROD_RUN)
# if (PROD_RUN || PLOT=='lc') plotLearningCurve(train, Y_NAME, featuresToUse, createModel, createPrediction, computeError, increment=50, ylim=c(0, 0.3), save=PROD_RUN)
# if (PROD_RUN || PLOT=='fi') plotFeatureImportances(model, featuresToUse, save=PROD_RUN)
#
# #print trn/cv, train error
# printTrnCvTrainErrors(model, train, Y_NAME, featuresToUse, createModel, createPrediction, computeError)
#
# if (PROD_RUN) outputSolution(createPrediction, model, test, ID_NAME, Y_NAME, featuresToUse, paste0(FILENAME, '.csv'))
#
# cat('Done!\n')
