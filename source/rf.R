#todo:
#D-Use all features: rf_all: start-2015-11-16, 43/44, 100, 5.479, 81.80186/55.09977, 3.609911/8.349023/3.541713
#D-Add nba advanced: rf_adv: start-2015-11-16, 60/61, 100, 7.071, 82.36119/54.79276, 3.557412/8.356418/3.491678
#D-Add nba PlayerBios: rf_playerbios: start-2015-11-16, 66/68, 100, 8.396, 81.48067/55.27606, 3.560697/8.388797/3.486949
#D-Add WasDrafted and AttendedTopCollege: rf_WasDrafted: start-2015-11-16, 71/73, 100, 8.189, 81.66209/55.17648, 3.518361/8.388745/3.449907
#D-Data file reordered: rf_Reorder: start-2015-11-16, 71/73, 100, 8.121, 82.86294/54.51735, 3.535505/8.343658/3.475144
#-Add nba opponent: rf_opponent: start-2015-11-16, 91/93, 100, 10.167, 82.27009/54.84276, 3.519526/8.310265/3.475451
#-Add defense

#NBA data to download:
  #D-traditional
  #D-gamelogs
  #D-player bios
  #D-traditional (per game)
  #D-advanced
  #D-opponent
  #D-defense
  #-team stats (not sure how to get)
  #-opp team stats (ditto)
  #-traditional, differentials on
  #-scoring
  #-usage

  #-misc?
#-Try boruta features from all of the above

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

#Globals
FEATURES.ID = c('Date', 'Name')
FEATURES.RG = c('Salary', 'Position', 'Home', 'Team', 'Opponent')
FEATURES.NBA = c('AGE', 'GP', 'W', 'L', 'W_PCT', 'MIN', 'FGM', 'FGA', 'FG_PCT', 'FG3M', 'FG3A', 'FG3_PCT', 'FTM', 'FTA', 'FT_PCT', 'OREB', 'DREB', 'REB', 'AST', 'TOV', 'STL', 'BLK', 'BLKA', 'PF', 'PFD', 'PTS', 'PLUS_MINUS', 'DD2', 'TD3')
FEATURES.NBA_ADV = c('OFF_RATING', 'DEF_RATING', 'NET_RATING', 'AST_PCT', 'AST_TO', 'AST_RATIO', 'OREB_PCT', 'DREB_PCT', 'REB_PCT', 'TM_TOV_PCT', 'EFG_PCT', 'TS_PCT', 'USG_PCT', 'PACE', 'PIE', 'FGM_PG', 'FGA_PG')
FEATURES.NBA_PLAYERBIOS = c('PLAYER_HEIGHT_INCHES','PLAYER_WEIGHT','COUNTRY','DRAFT_YEAR','DRAFT_ROUND','DRAFT_NUMBER')
FEATURES.NBA_OPPONENT = c('OPP_FGM', 'OPP_FGA', 'OPP_FG_PCT', 'OPP_FG3M', 'OPP_FG3A', 'OPP_FG3_PCT', 'OPP_FTM', 'OPP_FTA', 'OPP_FT_PCT', 'OPP_OREB', 'OPP_DREB', 'OPP_REB', 'OPP_AST', 'OPP_TOV', 'OPP_STL', 'OPP_BLK', 'OPP_BLKA', 'OPP_PF', 'OPP_PFD', 'OPP_PTS')
FEATURES.MINE = c('WasDrafted', 'AttendedTop5PctCollege', 'AttendedTop10PctCollege', 'AttendedTop20PctCollege', 'AttendedTop50PctCollege', 'AvgFantasyPoints', 'DaysPlayedPercent', 'Injured', 'FantasyPoints_PrevGame', 'Minutes_PrevGame', 'StartedPercent', 'Salary_PrevGame', 'AvgFantasyPointsPerMin', 'SalaryIncreased')
FEATURES.ALL = c(FEATURES.RG, FEATURES.NBA, FEATURES.NBA_ADV, FEATURES.NBA_PLAYERBIOS, FEATURES.NBA_OPPONENT, FEATURES.MINE)

FEATURES_TO_USE = FEATURES.ALL

PROD_RUN = T
N_TREE = 100
FILENAME = 'rf_opponent'
PLOT = 'fi' #lc=learning curve, fi=feature importances

ID_NAME = 'Name'
Y_NAME = 'FantasyPoints'

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
findBestSetOfFeatures = function(data, possibleFeatures) {
  cat('Finding best set of features to use...\n')

  #featuresToUse = c('Salary', 'MIN', 'Injured', 'FantasyPoints_PrevGame', 'AvgFantasyPointsPerMin')
  featuresToUse = FEATURES_TO_USE

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

if (PROD_RUN) cat('PROD RUN: ', FILENAME, '\n', sep='')

data = getData()
train = data$train #train=all data leading up to tonight
test = data$test #test=tonight's team
possibleFeatures = setdiff(names(train), c(ID_NAME, Y_NAME))

#find best set of features to use based on cv error
featuresToUse = findBestSetOfFeatures(train, possibleFeatures)

cat('Creating Model (ntree=', N_TREE, ')...\n', sep='')
timeElapsed = system.time(model <- createModel(train, Y_NAME, featuresToUse))
cat('    Time to compute model: ', timeElapsed[3], '\n', sep='')
cat('    MeanOfSquaredResiduals / %VarExplained: ', mean(model$mse), '/', mean(model$rsq*100), '\n', sep='')

#plots
if (PROD_RUN || PLOT=='lc') plotLearningCurve(train, Y_NAME, featuresToUse, createModel, createPrediction, computeError, ylim=c(0, 15), save=PROD_RUN)
if (PROD_RUN || PLOT=='fi') plotImportances(model, save=PROD_RUN)

#print trn/cv, train error
printTrnCvTrainErrors(model, train, Y_NAME, featuresToUse, createModel, createPrediction, computeError)

tbx_commentsToCollapse = function() {
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
}

cat('Done!\n')

tbx_moreCommentsToCollapse = function() {

#=====From above=======
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
#D-Add SalaryIncreased (nope): 6.195253/9.04208, 6.192414
#D-Use predict(model) for train: rf_predict: start-end, 5/44, 10, 8.9856/8.850639, 9.006961, 81.12534, 58.07 <-- use this for baseline
#-Features used: Salary, MIN, Injured, FantasyPoints_PrevGame, AvgFantasyPointsPerMin

#-Try all features, ignoring test/train overifitting
  #-Try all rg + nba + mine
    #-ntree=10, splitDate=2015-11-06: time=0.146, trn/cv=3.867389/9.298347, train=3.939142, MeanOfSquaredResiduals=91.22056, %VarExplained=47.48 (108.4268, 37.56809)
    #-10, 2015-11-16: 0.57, 4.088721/8.889591, 4.003655, 96.57905, 46.99 (112.8018, 38.0842)
    #-10, 2015-12-08: 2.325, 3.953117/8.453994, 3.894827, 89.84784, 51.55 (110.3565, 40.48488)
    #-10, 2016-02-10: 23.851, 3.959874/8.817836, 3.930304, 89.95064, 52.35 (108.2765, 42.64644) <-- take too long

    #-100, 2015-11-06: 1.29, 3.443206/8.770879, 3.425491, 71.39885, 58.89 (77.78406, 55.21211)
    #-100, 2015-11-16: 5.617, 3.609911/8.349023, 3.541713, 75.32584, 58.65 (81.80186, 55.09977) <--Use this one
    #-100, 2015-12-08: 23.954, 3.449412/8.140572, 3.418292, 70.74516, 61.85 (76.98727, 58.48087) <-- take too long

    #-500, 2015-11-06: 6.384, 3.396569/8.733787, 3.39772, 70.60391, 59.35 (72.19504, 58.43026)
    #-500, 2015-11-16: 27.869, 3.549393/8.354271, 3.487071, 74.28095, 59.23 (75.97834, 58.29624) <-- take too long


#================= extra TODOs================

#What to do next:
  #-Use more features:
    #-Vegas odds
    #-More from stats.nba.com
    #-Opponent data
  #-Try same prediction on a subset of data (either one player, or group of similar players)
  #-Try a different algorithm (eg. xgboost, lm)
  #-Read articles/blog posts to determine good features that I haven't thought of
  #-Try predicting something else, then using that to compute expected fantasy points
    #-FantasyPointsPerMin, MinutesWillPlay -> manually compute FantasyPoints
    #-Steals, Block, etc -> manually compute FantasyPoints
  #-Add 2014 data
  #-Use 2016 data, which possibly has better features (eg. expected fantasy points)


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
}