#todo:
#D-use all fanduel features: rf_01initial: 10/27-11/5, 9/12, 100, 1.846, 73.34114/61.859, 3.968405/8.834827/3.965828, 8.92789, 0.9321584
#D-set ntree=20: rf_02ntree20: 10/27-11/5, 9/12, 20, 0.375, 80.54763/58.11127, 4.207119/8.824238/4.083524, 9.068537, 0.9347183
#D-Remove first date: rf_03sansday1: 10/27-11/5, 9/12, 20, 0.341, 79.55694/58.34918, 4.049431/9.295638/4.167405, 8.991759, 0.9588696
#D-add numberfire features: rf_04numberfire: 10/27-11/5, 17/20, 20, 0.428, 74.71894/60.88204, 3.654075/8.507217/3.711897, 8.580198, 0.9484206
#D-fixed bad rotoguru data: rf_05fixrotoguru: 10/27-11/5, 17/20, 20, 0.417, 76.52583/59.93656, 3.609373/8.581317/3.778761, 8.573306, 0.9521481
#D-add 11/6: rf_06nov6: 10/27-11/5, 17/20, 20, 0.462, 77.185/59.41379, 3.735602/8.460795/3.687973, 8.555099, 0.9583455
#D-add rotogrinder points: rf_07RGpoints: 10/27-11/6, 18/21, 20, 0.496, 69.95476/63.21567, 3.4776/8.341828/3.509083, 8.280576, 0.9873654
#D-add more RG features: rf_08moreRG: 10/27-11/6, 34/37, 20, 0.653, 71.34992/62.48205, 3.530176/8.411089/3.506541, 8.114273, 0.9488803 <-- new best!
#D-add even more RG PlayerProjections: rf_09moreRG2: 10/27-11/6, 40/43, 20, 0.769, 73.0322/61.59746, 3.566091/8.167627/3.516046, 8.156932, 0.9746103
#D-add rest of RG PlayerProjections features: rf_10moreRG3: 10/27-11/6, 50/53, 20, 0.851, 70.92486/62.70556, 3.356778/8.357909/3.521121, 8.126946, 0.9400258
#D-add RG defense vs position: rf_11DvP: 10/27-11/6, 60/63, 20, 0.928, 72.85086/61.69281, 3.3672/8.387346/3.446881, 8.104879, 0.9684187 <-- new best!
#D-add def vs my position: rf_12mydvp: 10/27-11/6, 52/65, 20, 0.819, 70.92388/62.70608, 3.426565/8.297581/3.437354, 8.078652, 0.9607791 <-- new best!
#D-add nba player season-long features: rf_13nba: 10/27-11/6, 80/93, 20, 1.07, 49.71302/73.85939, 2.827531/6.956564/2.852913, 6.878917, 1.109224 <-- WRONG
#D-fix nba data (using prevday's data): rf_14fixnba: 10/27-11/6, 80/93, 20, 1.041, 72.91909/61.65693, 3.394206/8.340627/3.441368, 8.065771, 0.955393 <-- new best
#D-Curate features: rf_15curate: 10/27-11/6, 6/93, 100, 0.774, 66.01628/65.28664, 4.163789/8.088749/4.206491, 8.066922, 0.9791746
#D-add data up to 11/8: rf_16nov8: 10/27-11/8, 6/93, 100, 0.974, 65.82099/65.06195, 4.180437/7.846159/4.206441, 8.054633, 0.982619 <-- new best!

#-Compute FantasyPoints from nba.com rather than get it from rotoguru
#-Compute FPPD (FP/Salary*1000)
#-add first day back

#How to add dates (up to date before yesterday)
  #-download rotoguru (python source/python_scripts/scrapeRotoGuruDay.py)
  #-download nba data (python source/python_scripts/scrapeStatsNba.py)
  #-change END_DATE in createDataFile_2016.py
  #-create data_2016.csv (python source/python_scripts/createDataFile_2016.py)
  #-create data_contests_2016.csv (python source/python_scripts/createContestFile.py)
  #-change END_DATE to new date

#Remove all objects from the current workspace
rm(list = ls())
setwd('/Users/dan/Desktop/ML/df')

library(randomForest) #randomForest
library(hydroGOF) #rmse
library(ggplot2) #visualization
library(ggthemes) #visualization
library(dplyr) #%>%
source('../ml-common/plot.R')
source('../ml-common/util.R')
source('source/_getData_2016.R')
source('source/_createTeam.R')

#Globals
PROD_RUN = T
FILENAME = 'rf_16nov8'
END_DATE = '2016-11-08'
N_TREE = 100
PLOT = 'scores' #fi, scores,
Y_NAME = 'FantasyPoints'

#features excluded: FantasyPoints, Date, Name
F.ID = c('Date', 'Name', 'Position', 'Team', 'Opponent')
F.FANDUEL = c('Position', 'FPPG', 'GamesPlayed', 'Salary',
              'Home', 'Team', 'Opponent', 'InjuryIndicator', 'InjuryDetails')
F.NUMBERFIRE = c('NF_Min', 'NF_Pts', 'NF_Reb', 'NF_Ast', 'NF_Stl', 'NF_Blk', 'NF_TO', 'NF_FP')
F.RG.PP = c('RG_ceil', 'RG_floor', 'RG_points', 'RG_ppdk',
            'RG_line',  'RG_movement', 'RG_overunder', 'RG_total',
            'RG_contr', 'RG_pownpct', 'RG_rank',
            'RG_rankdiff', 'RG_saldiff',
            'RG_deviation', 'RG_minutes',
            'RG_rank20', 'RG_diff20', 'RG_rank_diff20', 'RG_salary20',
            'RG_salary15', 'RG_salary19', 'RG_salary28', 'RG_salary43', 'RG_salary50', 'RG_salary58',
            'RG_points15', 'RG_points19', 'RG_points20', 'RG_points28', 'RG_points43', 'RG_points50', 'RG_points51', 'RG_points58')
#F.RG.DVP = c('RG_OPP_DVP_CFPPG', 'RG_OPP_DVP_CRK', 'RG_OPP_DVP_PFFPPG', 'RG_OPP_DVP_PFRK', 'RG_OPP_DVP_PGFPPG', 'RG_OPP_DVP_PGRK', 'RG_OPP_DVP_SFFPPG', 'RG_OPP_DVP_SFRK', 'RG_OPP_DVP_SGFPPG', 'RG_OPP_DVP_SGRK')
F.NBA = c('NBA_SEASON_AGE', 'NBA_SEASON_W', 'NBA_SEASON_L', 'NBA_SEASON_W_PCT', 'NBA_SEASON_MIN', 'NBA_SEASON_FGM', 'NBA_SEASON_FGA', 'NBA_SEASON_FG_PCT', 'NBA_SEASON_FG3M', 'NBA_SEASON_FG3A', 'NBA_SEASON_FG3_PCT', 'NBA_SEASON_FTM', 'NBA_SEASON_FTA', 'NBA_SEASON_FT_PCT', 'NBA_SEASON_OREB', 'NBA_SEASON_DREB', 'NBA_SEASON_REB', 'NBA_SEASON_AST', 'NBA_SEASON_TOV', 'NBA_SEASON_STL', 'NBA_SEASON_BLK', 'NBA_SEASON_BLKA', 'NBA_SEASON_PF', 'NBA_SEASON_PFD', 'NBA_SEASON_PTS', 'NBA_SEASON_PLUS_MINUS', 'NBA_SEASON_DD2', 'NBA_SEASON_TD3')
F.MINE = c('OPP_DVP_FPPG', 'OPP_DVP_RANK')

F.CURATED = c('FPPG', 'Salary', 'InjuryIndicator',
              'RG_points', 'RG_pownpct',
              'OPP_DVP_RANK')

FEATURES_TO_USE = F.CURATED# c(F.FANDUEL, F.NUMBERFIRE, F.RG.PP, F.NBA, F.MINE)


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

#I do not understand any of this code, I borrowed it from a kaggler
plotImportances = function(model, maxFeatures=50, save=FALSE) {
  cat('Plotting Feature Importances...\n')

  # Get importance
  importances = randomForest::importance(model)

  #DPD: take the top 20 if there are more than 20
  importances = importances[order(-importances[, 1]), , drop = FALSE][1:min(maxFeatures, nrow(importances)),, drop=F]

  varImportance = data.frame(Variables = row.names(importances),
                             Importance = round(importances[, 1], 2))

  # Create a rank variable based on importance
  rankImportance = varImportance %>%
    mutate(Rank = paste0('#',dense_rank(desc(Importance))))

  if (save) png(paste0('plots/Importances_', FILENAME, '.png'), width=500, height=max(nrow(importances)*10, 350))
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

plotScores = function(dateStrs, yLow, yHigh, linesToPlot=list(), save=FALSE, name=NULL, ...) {
  if (save) png(paste0('plots/', name, '.png'), width=500, height=350)

  numLinesToPlot = length(linesToPlot)

  dates = as.Date(dateStrs)

  #get ymin and ymax
  minValue = min(yLow)
  maxValue = max(yHigh)
  if (numLinesToPlot > 0) {
    for (i in 1:numLinesToPlot) {
      minValue = min(minValue, linesToPlot[[i]])
      maxValue = max(maxValue, linesToPlot[[i]])
    }
  }

  #draw band
  plot(dates, yLow, type='l', ylim=c(minValue, maxValue+50), ylab='Fantasy Points', xlab='Date', xaxt='n', ...)
  lines(dates, yHigh, col='blue')
  polygon(c(dates, rev(dates)), c(yHigh, rev(yLow)),
          col = "azure", border = NA)

  #draw lines
  labels = c('Expected', 'Actual', 'line3', 'line4')
  colors = c('purple', 'green', 'red', 'orange')
  if (numLinesToPlot > 0) {
    for (i in 1:numLinesToPlot) {
      lines(dates, linesToPlot[[i]], col=colors[i])
    }
    legend(x='topright', legend=labels[1:numLinesToPlot], fill=colors[1:numLinesToPlot], inset=0.02)
  }

  axis.Date(side=1, dates, format="%m/%d")

  if (save) dev.off()
}

computeActualFP = function(team, test) {
  #todo: perhaps improve this through vectorization
  actualFP = 0.0
  for (i in 1:nrow(team)) {
    actualFP = actualFP + test[test$Name == team[i,'Name'], 'FantasyPoints']
  }
  return(actualFP)
}

#============= Main ================

if (PROD_RUN) cat('PROD RUN: ', FILENAME, '\n', sep='')

#load data
data = getData(END_DATE)
contestData = getContestData()

#print number of feature to use
cat('Number of features to use: ', length(FEATURES_TO_USE), '/', length(names(data)), '\n', sep='')

#create model
cat('Creating Model (ntree=', N_TREE, ')...\n', sep='')
timeElapsed = system.time(baseModel <- createModel(data, Y_NAME, FEATURES_TO_USE))
cat('    Time to compute model: ', timeElapsed[3], '\n', sep='')
cat('    MeanOfSquaredResiduals / %VarExplained: ', baseModel$mse[N_TREE], '/', baseModel$rsq[N_TREE]*100, '\n', sep='')

#print trn/cv, train error
printTrnCvTrainErrors(baseModel, data, Y_NAME, FEATURES_TO_USE, createModel, createPrediction, computeError)

cat('Now let\'s see how I would\'ve done each day...\n')

#these are arrays to plot later
percentVarExplaineds = c()
meanOfSquaredResidualss = c()
testErrors = c()
teamRatios = c()
myTeamExpectedFPs = c()
myTeamActualFPs = c()
myTeamGreedyExpectedFPs = c()
myTeamHillClimbingExpectedFPs = c()
highestWinningScores = c()
lowestWinningScores = c()

dateStrs = sort(unique(data$Date))[-1] #-1 uses all but the first element
for (dateStr in dateStrs) {
  cat('    ', dateStr, ': ', sep='')

  #split data into train, test
  trainTest = splitDataIntoTrainTest(data, 'start', dateStr)
  train = trainTest$train
  test = trainTest$test

  #create model
  model = createModel(train, Y_NAME, FEATURES_TO_USE)
  meanOfSquaredResiduals = model$mse[N_TREE]
  percentVarExplained = model$rsq[N_TREE] * 100

  #create prediction
  prediction = createPrediction(model, test, FEATURES_TO_USE)
  testError = computeError(test[[Y_NAME]], prediction)

  #create my teams for today
  predictionDF = test
  predictionDF[[Y_NAME]] = prediction
  myTeamGreedy = createTeam_Greedy(predictionDF)
  myTeamGreedyExpectedFP = computeTeamFP(myTeamGreedy)
  myTeamHillClimbing = createTeam_HillClimbing(predictionDF)
  myTeamHillClimbingExpectedFP = computeTeamFP(myTeamHillClimbing)

  #set my team to whichever gave the best expected score from above
  if (myTeamGreedyExpectedFP > myTeamHillClimbingExpectedFP) {
    myTeam = myTeamGreedy
    whichTeamITook = 'Greedy'
  } else {
    myTeam = myTeamHillClimbing
    whichTeamITook = 'HillClimbing'
  }
  myTeamExpectedFP = computeTeamFP(myTeam)
  myTeamActualFP = computeActualFP(myTeam, test)

  #get actual fanduel winning score for currday
  highestWinningScore = getHighestWinningScore(contestData, dateStr)
  lowestWinningScore = getLowestWinningScore(contestData, dateStr)

  #print results
  cat('RMSE=', testError, sep='')
  cat(', expected=', round(myTeamExpectedFP, 2), sep='')
  cat(', actual=', round(myTeamActualFP, 2), sep='')
  cat(', low=', round(lowestWinningScore, 2), sep='')
  cat(', ', whichTeamITook, sep='')
  #cat(', high=', round(highestWinningScore, 2), sep='')
  cat('\n')

  #add data to arrays to plot
  meanOfSquaredResidualss = c(meanOfSquaredResidualss, model$mse[N_TREE])
  percentVarExplaineds = c(percentVarExplaineds, model$rsq[N_TREE])
  testErrors = c(testErrors, testError)
  myTeamExpectedFPs = c(myTeamExpectedFPs, myTeamExpectedFP)
  myTeamActualFPs = c(myTeamActualFPs, myTeamActualFP)
  myTeamGreedyExpectedFPs = c(myTeamGreedyExpectedFPs, myTeamGreedyExpectedFP)
  myTeamHillClimbingExpectedFPs = c(myTeamHillClimbingExpectedFPs, myTeamHillClimbingExpectedFP)
  highestWinningScores = c(highestWinningScores, highestWinningScore)
  lowestWinningScores = c(lowestWinningScores, lowestWinningScore)
}

#print mean of rmses
cat('Mean of daily RMSEs: ', mean(testErrors), '\n', sep='')

#print myteam score / lowestWinningScore ratio, call it "scoreRatios"
scoreRatios = myTeamActualFPs/lowestWinningScores
cat('Mean myScore/lowestScore ratio: ', mean(scoreRatios), '\n', sep='')

#plots
if (PROD_RUN || PLOT == 'fi') plotImportances(baseModel, save=PROD_RUN)
if (PROD_RUN || PLOT == 'scores') plotScores(dateStrs, lowestWinningScores, highestWinningScores, linesToPlot=list(myTeamExpectedFPs, myTeamActualFPs), main='Fantasy Points Comparison', save=PROD_RUN, name=paste0('Scores_', FILENAME))
#if (PROD_RUN || PLOT == 'rmse') plotByDate(dateStrs, testErrors, main='RMSE by Date', ylab='RMSE', save=PROD_RUN, name=paste0(PLOT, '_', FILENAME))
#if (PROD_RUN || PLOT == 'scoreratios') plotByDate(dateStrs, scoreRatios, ylim=c(0, 1.5), main='Score Ratio by Date', ylab='Score Ratio', save=PROD_RUN, name=paste0(PLOT, '_', FILENAME))
if (PROD_RUN || PLOT == 'rmse_scoreratios') plotByDate2Axis(dateStrs, testErrors, ylab='RMSE', ylim=c(5, 12), y2=scoreRatios, y2lim=c(0, 1.5), y2lab='Score Ratio', main='RMSEs and Score Ratios', save=PROD_RUN, name=paste0('RMSE_ScoreRatios_', FILENAME))

cat('Done!\n')
