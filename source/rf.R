#todo:
#D-Make initial prediction using salary: 01_rf_salary: numFeaturesUsed=1/1, Trn/CV Error=10.15385/10.16979, Train Error=10.15067
#D-Use 2014 data: NONE: 1/1, 8.888702/8.924981, 8.887228
#D-Use train/test data and keep NAs in data: rf_keepNAs: 1/2, 8.895979/8.880356, 8.887228
#D-Write script to create team: rf_createTeam: 1/3, 8.895979/8.880356, 8.887228
#D-Run for 20161025: 20161025: 1/3, 9.761371/9.643101, 9.733458
#D-Output test (tonight's predictions) error: 1/3, 9.761371/9.643101, 9.733458, testError=10.24964
#D-Use first 10 days of 2015 data: 20151106: 1/3, 8.769458/9.195576, 8.802408
#D-Remove rows with Salary NAs: 20151106_removeNAs: 1/3, 8.745434/9.390104, 8.802408
#D-Use all base features from rotoguru (Position, Salary, Home): 20151106_+PositionHome: 3/4, 9.614065/9.635446, 9.627315
#D-Add all features from nba: 20151208_allNba: 32/35, ntree=100, 4.068691/8.490935, 4.13253
  #-Features used: Salary, Position, Home, AGE, GP, W, L, W_PCT, MIN, FGM, FGA, FG_PCT, FG3M, FG3A, FG3_PCT, FTM, FTA, FT_PCT, OREB, DREB, REB, AST, TOV, STL, BLK, BLKA, PF, PFD, PTS, PLUS_MINUS, DD2, TD3
#D-Use as many features as possible that don't overfit (Salary, MIN): 20160619_SalaryMin: 2/35, 10, 8.709144/9.774915, 8.742757
#D-Add AvgFantasyPoints, DaysPlayedPercent features: 20151208_AvgFantasyPoints: 34/37, 100, 3.868784/8.450441, 3.837078
  #-Features used: Salary, Position, Home, AGE, GP, W, L, W_PCT, MIN, FGM, FGA, FG_PCT, FG3M, FG3A, FG3_PCT, FTM, FTA, FT_PCT, OREB, DREB, REB, AST, TOV, STL, BLK, BLKA, PF, PFD, PTS, PLUS_MINUS, DD2, TD3, AvgFantasyPoints, DaysPlayedPercent
#D-Use AvgFantasyPoints, Salary, MIN: 20160619_top3: 3/37, 10, 7.397566/9.545659, 7.284939
#D-Fix AvgFantasyPoints (AvgFantasyPoints, Salary, MIN): 20160619_fixAvgFP: 3/37, 10, 7.301757/9.625992, 7.293516
#D-Add Injured feature: 20160619_Injured: 4/38, 10, 8.910737/9.158973, 8.813595
#D-Add FantasyPoints_PrevGame: 20160619_FantasyPointsPrevGame: 5/39, 10, 8.363092/8.940201, 8.373344, "Mean of squared residuals"=83.92964, "% Var explained"=56.62
#D-Try AvgFantasyPointsPerMin (made it worse): 20160619, 6/40, 10, 4.983091/9.134001, 5.040836, 96.6889, 50.03
#D-Replace AvgFantasyPoints with AvgFantasyPointsPerMin: 20160619_AvgFPPerMin: 5/40, 10, 8.212136/8.850639, 8.213636, 81.12534, 58.07
#D-Add Minutes_PrevGame (it didn't help much, if at all; come back to it if i need to increase my results a tid bit)
#D-Remove the first X% of data so that winpct etc mean something (it didn't help)
#D-Try top X correlation features (with and without Injury, which majorly helps it not overfit for some reason):
  #-Top 1 (AvgFantasyPoints): 9.329334/9.399666, 10.48611
  #-Top 2 (+FantasyPoints_PrevGame): 8.801942/9.009306, 8.904963
  #-Top 3 (+Salary): 8.436485/8.855896, 8.889949
  #-Top 4 (+Minutes_PrevGame): 8.362315/8.876209, 8.154882
  #-Top 5 (+PTS): 4.974178/9.135287, 5.133405
  #-Top 10 (+FGM, FGA, MIN, PFD, AvgFantasyPointsPerMin): 4.456431/9.081288, 4.454354
#D-Add StartedPercent (didn't help): 5.059432/9.125127, 5.153629
#D-Add Salary_PrevGame (it didn't immediately help)
#

#-Salary moved up or down since last game
#-back-to-back, 2-of-3, etc


#Remove all objects from the current workspace
rm(list = ls())
setwd('/Users/dan/Desktop/ML/df')

library(randomForest) #randomForest
library(hydroGOF) #rmse
library(ggplot2) #visualization
library(ggthemes) #visualization
source('source/_getData.R')
source('../ml-common/plot.R')
source('../ml-common/util.R')

#============== Functions ===============

createModel = function(data, yName, xNames) {
  set.seed(754)
  return(randomForest(getFormula(yName, xNames),
                      data=data,
                      ntree=N_TREE))
}
createPrediction = function(model, newData, xNames=NULL) {
  return(predict(model, newData))
}
computeError = function(y, yhat) {
  return(rmse(y, yhat))
}
findBestSetOfFeatures = function(data, possibleFeatures) {
  cat('Finding best set of features to use...\n')

  #possible features (everything except FantasyPoints and Name):
  #'Date', 'Salary', 'Position', 'Home', 'Team', 'Opponent',
  #'AGE', 'GP', 'W', 'L', 'W_PCT', 'MIN', 'FGM', 'FGA', 'FG_PCT', 'FG3M', 'FG3A',
  #'FG3_PCT', 'FTM', 'FTA', 'FT_PCT', 'OREB', 'DREB', 'REB', 'AST', 'TOV', 'STL',
  #'BLK', 'BLKA', 'PF', 'PFD', 'PTS', 'PLUS_MINUS', 'DD2', 'TD3'

  #use everything except Date, Team, and Opponent
  #featuresToUse = setdiff(possibleFeatures, c('Date', 'Team', 'Opponent'))
  #featuresToUse = setdiff(possibleFeatures,
  #    c('Date', 'Team', 'Opponent', 'TD3', 'Position', 'AGE', 'Home', 'FG3M',
  #      'DD2', 'BLKA', 'BLK', 'STL', 'FG3A', 'OREB', 'W', 'PF', 'FTM', 'FTA',
  #      'TOV', 'L', 'FG3_PCT', 'AST', 'REB', 'DREB', 'FT_PCT', 'W_PCT', 'GP',
  #      'PLUS_MINUS', 'FG_PCT', 'PFD', 'FGA', 'FGM', 'PTS'))
  featuresToUse = c('AvgFantasyPoints', 'FantasyPoints_PrevGame', 'Salary', 'Injured', 'Salary_PrevGame')

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

writeSolution = function(data, yName, idName, prediction, filename, extraColNames) {
  solution = data.frame(data[, idName], prediction, data[, extraColNames])
  colnames(solution) = c(idName, yName, extraColNames)
  cat('    Writing solution to file: ', filename, '...\n', sep='')
  write.csv(solution, file=filename, row.names=F, quote=F)
}

getInitialTeam = function(data) {
  #take the top 2 from each position (except C)
  team = rbind(
    data[data$Position == 'PG',][1:2,],
    data[data$Position == 'SG',][1:2,],
    data[data$Position == 'SF',][1:2,],
    data[data$Position == 'PF',][1:2,],
    data[data$Position == 'C',][1,]
  )
  return(team)
}
computePPD = function(fantasyPoints, salary) {
  return(fantasyPoints / salary * 1000)
}
printTeam = function(team) {
  print(team)
}
computeAmountOverBudget = function(team) {
  return(sum(team$Salary) - SALARY_CAP)
}
replacePlayer = function(team, oldPlayer, newPlayer) {
  #remove old player
  playersToKeep = setdiff(rownames(team), rownames(oldPlayer))
  team = team[playersToKeep,]

  #add new player
  team = rbind(team, newPlayer)

  return(team)
}
getWorseTeam = function(data, team, amountOverBudget, verbose=F) {
  cnt = 1
  while (amountOverBudget > 0) {
    if (verbose) print(paste('Iteration', cnt, ', amountOverBudget=', amountOverBudget))

    bestPpdg = Inf
    bestOldPlayer = NULL
    bestNewPlayer = NULL

    positions = c('PG', 'SG', 'SF', 'PF', 'C')

    #find next best player for each position
    for (position in positions) {
      numPlayers = ifelse(position == 'C', 1, 2)

      players = data[data$Position == position,]

      #remove players currently on the team
      playersOnTeam = team[team$Position == position,]
      players = players[setdiff(rownames(players), rownames(playersOnTeam)),]

      for (i in 1:numPlayers) {
        teamPlayer = team[team$Position == position,][i,]
        fpDiff = teamPlayer$FantasyPoints - players$FantasyPoints
        salaryDiff = pmin(teamPlayer$Salary - players$Salary, amountOverBudget)
        salaryDiff[salaryDiff <= 0] = NA
        ppdg = computePPD(fpDiff, salaryDiff)
        minPpdg = min(ppdg, na.rm=T)
        if (minPpdg < bestPpdg) {
          bestPpdg = minPpdg
          bestOldPlayer = teamPlayer
          bestNewPlayer = players[which.min(ppdg), ]
        }
      }
    }

    #i now have the next best player, replace him
    if (verbose) cat('Replacing', oldPlayer$Name, '<-', newPlayer$Name, '\n')
    team = replacePlayer(team, bestOldPlayer, bestNewPlayer)

    amountOverBudget = computeAmountOverBudget(team)
    cnt = cnt + 1
  }
  return(team)
}
getBetterTeam = function(data, team, amountOverBudget, verbose=F) {
  #todo
  return(team)
}
createTeam = function(data, verbose=F) {
  #add PPD coumn
  data$PPD = computePPD(data$FantasyPoints, data$Salary)

  #sort by ppd
  data = data[order(data$PPD, decreasing=TRUE),]

  #first, fill team with all the highest ppd players
  team = getInitialTeam(data)

  if (verbose) {
    print('Initial team')
    printTeam(team)
  }

  amountOverBudget = computeAmountOverBudget(team)
  if (amountOverBudget > 0) {
    team = getWorseTeam(data, team, amountOverBudget, verbose)
  } else if (amountOverBudget < 0) {
    team = getBetterTeam(data, team, amountOverBudget, verbose)
  } else {
    cat('Wow, I got a perfect team on the first try!\n')
  }

  if (verbose) {
    print('Final team')
    printTeam(team)
  }

  return(team)
}
printTeamResults = function(team, bestTeam, yName) {
  myTeamPredictedPoints = sum(myTeam[[yName]])
  myTeamActualPoints = sum(test[rownames(myTeam), yName])
  bestTeamPoints = sum(bestTeam[[yName]])

  cat('How did my team do?\n')
  cat('    I was expecting to get', myTeamPredictedPoints, 'points\n')
  cat('    I actually got:', myTeamActualPoints, 'points\n')
  cat('    Best team got:', bestTeamPoints, 'points\n')
  cat('    My score ratio is', (myTeamActualPoints/bestTeamPoints), '\n')
}

#============= Main ================

#Globals
ID_NAME = 'Name'
Y_NAME = 'FantasyPoints'

PROD_RUN = F
N_TREE = 10
FILENAME = 'AvgFPPerMin'
PLOT = '' #lc=learning curve, fi=feature importances

if (PROD_RUN) cat('PROD RUN: ', FILENAME, '\n', sep='')

data = getData()
train = data$train #train=all data leading up to tonight
test = data$test #test=tonight's team
possibleFeatures = setdiff(names(train), c(ID_NAME, Y_NAME))

#find best set of features to use based on cv error
featuresToUse = findBestSetOfFeatures(train, possibleFeatures)

cat('Creating Model (ntree=', N_TREE, ')...\n', sep='')
model = createModel(train, Y_NAME, featuresToUse)

#plots
if (PROD_RUN || PLOT=='lc') plotLearningCurve(train, Y_NAME, featuresToUse, createModel, createPrediction, computeError, ylim=c(0, 15), save=PROD_RUN)
if (PROD_RUN || PLOT=='fi') plotImportances(model, save=PROD_RUN)

#print trn/cv, train error
printTrnCvTrainErrors(model, train, Y_NAME, featuresToUse, createModel, createPrediction, computeError)

#comment this out because it doesnt mean anything
#print test error
# prediction = createPrediction(model, test, featuresToUse)
# testError = computeError(test[, Y_NAME], prediction)
# cat('    Tonight\'s error: ', testError, '\n', sep='')

#comment this out until i fix createTeam
# cat('Creating teams...\n')
# SALARY_CAP = 60000
# #create my team (using prediction)
# predictionDF = test
# predictionDF[[Y_NAME]] = prediction
# myTeam = createTeam(predictionDF)
#
# #create best team (using test)
# bestTeam = createTeam(test)
#
# #print myTeam / bestTeam ratio
# printTeamResults(team, bestTeam, Y_NAME)

#comment this out because i think i dont need it
# if (PROD_RUN) {
#   cat('Outputing solution...\n')
#
#   extraColNames = c('Salary', 'Position')
#
#   #write prediction
#   predictionFilename = paste0('prediction_', FILENAME, '.csv')
#   writeSolution(test, Y_NAME, ID_NAME, prediction, predictionFilename, extraColNames)
#
#   #write actual
#   actualFilename = paste0('actual_', FILENAME, '.csv')
#   writeSolution(test, Y_NAME, ID_NAME, test[[Y_NAME]], actualFilename, extraColNames)
# }

cat('Done!\n')

#================= extra TODOs================

#What to do next:
  #-Use 2016 data, which possibly has better features (eg. expected fantasy points)
  #-Try a different algorithm (eg. xgboost, lm)
  #-Try same prediction on a subset of data (either one player, or group of similar players)
  #-Read articles/blog posts to determine good features that I haven't thought of
  #-Try predicting something else, then using that to compute expected fantasy points
    #-FantasyPointsPerMin, MinutesWillPlay -> manually compute FantasyPoints
    #-Steals, Block, etc -> manually compute FantasyPoints
  #-Use more features:
    #-Vegas odds
    #-More from stats.nba.com
    #-Manually compute more features
    #-Opponent data
  #-Add 2014 data


#-Maybe build a separate model for each player (or type of player (eg. starters, bench players))
#-Use all features but only from the last 5 games (rather than season), and start from game 5
#-fill in getBetterTeam
#-make createTeam better (perhaps use genetic or hill-climbing or DP algorithm)
#-Maybe use log of y
#-Perhaps make Home a binary col rather than factor with 2 levels
#-Identify high-risk vs low-risk player, and perhaps only choose team from players who are low-risk

#Process to get team for day:
#1. Change DATE (eg. 20161025)
#2. Source this file (rf.R)
#-Prints RMSE for Trn/CV, Train, Test
#-Prints ratio of my team score/best team score

#========================================
#CV strategies:
  #-Option 1:
    #-num days in 2015: 210
    #-starting on day 2,
      #-split data into train (days before), and test (day of)
      #-build model using train
      #-predict using test
      #-plot train and test errors
      #-set day to next day
  #-Option 2:
    #-take the first 10 days of 2015
    #-split data randomly into 80/20 (shuffled) for train/cv
    #-plot learning curve
    #-increase num days to take if i need more data