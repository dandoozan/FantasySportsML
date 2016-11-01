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
#D-Add all features from nba: 20151208_allNba: 32/35, 4.068691/8.490935, 4.13253, ntree=100
  #-Features used: Salary, Position, Home, AGE, GP, W, L, W_PCT, MIN, FGM, FGA, FG_PCT, FG3M, FG3A, FG3_PCT, FTM, FTA, FT_PCT, OREB, DREB, REB, AST, TOV, STL, BLK, BLKA, PF, PFD, PTS, PLUS_MINUS, DD2, TD3
#-Include nba season-long "traditional" stats:
#-Include nbs "advanced" stats
#-Perhaps make Home a binary col rather than factor with 2 levels
#-fill in getBetterTeam
#-make createTeam better (perhaps use genetic or hill-climbing or DP algorithm)
#-Use log of y
#-Remove players who played less than 5 min or so to remove the many 0 scores
#-Use more features than salary
#-Use probability that a player will do much better/much worse than expected
#-Identify high-risk vs low-risk player, and perhaps only choose team from players who are low-risk
#-Maybe predict fp/min instead of fp

#Process to get team for day:
#1. Change DATE (eg. 20161025)
#2. Source this file (rf.R)
  #-Prints RMSE for Trn/CV, Train, Test
  #-Prints ratio of my team score/best team score

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
                      ntree=100))
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
  featuresToUse = setdiff(possibleFeatures, c('Date', 'Team', 'Opponent'))

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

#2015 season
  #begin (day 1): 20151027
  #use 10 days (day 11): 20151106 (2142 obs)
  #10% (day 21): 20151116
  #20% (day 42): 20151208
  #50% (day 105): 20160210
  #end (day 210): 20160619
#Globals
PROD_RUN = T
SEASON = '2015'
ID_NAME = 'Name'
Y_NAME = 'FantasyPoints'
SPLIT_DATE = '20151208'
FILENAME = paste0(SPLIT_DATE, '_allNba')
DATE_FORMAT = '%Y%m%d'
PLOT = 'lc' #lc=learning curve, fi=feature importances

if (PROD_RUN) cat('PROD RUN: ', FILENAME, '\n', sep='')

splitDate = as.Date(SPLIT_DATE, DATE_FORMAT)
data = getData(Y_NAME, SEASON, splitDate, DATE_FORMAT, oneHotEncode=F)
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