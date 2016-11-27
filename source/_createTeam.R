#How to compare hillClimbing and greedy teams:
  #-d=getPredictionForDate('2016-11-20', Y_NAME)
  #-computeTeamFP(createTeam_HillClimbing(d, Y_NAME, maxNumTries=100, verbose=T), Y_NAME)
  #-computeTeamFP(createTeam_Greedy(d, Y_NAME), Y_NAME)
#Dates that HillClimbing did better than Greedy:
  #-2016-11-20: hillClimbing=277.6335, greedy=277.3362
  #-2016-11-14: 297.9614, 297.4812
  #-2016-11-13: 279.4533, 278.3486
  #-2016-11-06: 284.9245, 284.8462
  #-2016-11-03: 289.1288, 287.2326

SALARY_CAP = 60000

createFirstAvailableTeam = function(allPlayers) {
  team = data.frame()

  positions = levels(allPlayers$Position)
  for (position in positions) {
    numPlayersToChoose = ifelse(position == 'C', 1, 2)
    playersInPosition = allPlayers[allPlayers$Position == position,]

    #if there are not enough players in the position, return NA
    if (sum(!is.na(allPlayers[allPlayers$Position == position, 'Position'])) < numPlayersToChoose) {
      stop('Cannot create team because there are not enough ', position, 's\n')
      return(NULL)
    }

    team = rbind(team, playersInPosition[1:numPlayersToChoose,])
  }

  return(team)
}
computePPD = function(fantasyPoints, salary) {
  return(fantasyPoints / salary * 1000)
}
computeCov = function(players, yName) {
  #cov is the 'Coefficient of Variance', which is the stdev / mean
  cov = players$RG_deviation / players[[yName]]
  cov = ifelse(is.nan(cov), Inf, cov)
  return(cov)
}
printPlayer = function(player, yName, full=F) {
  if (full) {
    cat('    ', player$Name, sep='')
    cat(', ', as.character(player$Position), sep='')
    #cat(', ', as.character(player$Team), sep='')
    #cat(', ', as.character(player$Opponent), sep='')
    cat(', $', player$Salary, sep='')
    cat(', ', round(player[[yName]], 2), sep='')
  } else {
    cat('    ', as.character(player$Position), ', ', sep='')
    cat(paste(player[, c('Name', 'Salary')], collapse=', '), sep='')
    cat(', ', round(player[[yName]], 2), sep='')
    cat(' (', round(player$RG_deviation, 2), ')', sep='')
    #cat(', ', round(player$PPD, 2), sep='')
    cat(', ', round(player$cov, 2), sep='')
  }
  cat('\n')
}
printTeam = function(team, yName, full=F) {
  if (is.null(team)) {
    cat('No team\n')
  } else {
    if (!('cov' %in% colnames(team))) {
      team$cov = computeCov(team, yName)
    }

    positions = c('PG', 'SG', 'SF', 'PF', 'C')
    for (position in positions) {
      playersAtPosition = team[team$Position==position,]
      for (i in 1:nrow(playersAtPosition)) {
        printPlayer(playersAtPosition[i,], yName, full)
      }
    }
    cat('    Total Amount spent:', computeAmountSpent(team), '\n')
    cat('    Total Fantasy Points:', round(computeTeamFP(team, yName), 2), '\n')
  }
}
computeTeamFP = function(team, yName) {
  return(sum(team[[yName]]))
}
computeAmountSpent = function(team) {
  return(sum(team$Salary))
}
computeAmountOverBudget = function(team) {
  return(computeAmountSpent(team) - SALARY_CAP)
}
replacePlayer = function(team, oldPlayer, newPlayer) {
  #remove old player
  playersToKeep = setdiff(rownames(team), rownames(oldPlayer))
  team = team[playersToKeep,]

  #add new player
  team = rbind(team, newPlayer)

  return(team)
}
getWorseTeam = function(data, yName, team, amountOverBudget, verbose=F) {
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
        fpDiff = teamPlayer[[yName]] - players[[yName]]
        salaryDiff = pmin(teamPlayer$Salary - players$Salary, amountOverBudget)
        salaryDiff[salaryDiff <= 0] = NA
        if (sum(!is.na(salaryDiff)) > 0) {
          ppdg = computePPD(fpDiff, salaryDiff)
          minPpdg = min(ppdg, na.rm=T)
          if (minPpdg < bestPpdg) {
            bestPpdg = minPpdg
            bestOldPlayer = teamPlayer
            bestNewPlayer = players[which.min(ppdg), ]
          }
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
getBetterTeam = function(data, yName, team, amountUnderBudget, verbose=F) {
  #while amountOverBudget < 0, look for a better match
  #compute the next highest ppdg for each position
  #select the matchup with the highest ppdg gained
  cnt = 1
  someoneWasReplaced = TRUE
  while (amountUnderBudget > 0 && someoneWasReplaced) {
    someoneWasReplaced = FALSE
    if (verbose) cat(paste('Iteration', cnt, ', amountUnderBudget=', amountUnderBudget), '\n')

    bestPpdg = -Inf
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
        fpDiff = players[[yName]] - teamPlayer[[yName]]
        fpDiff[fpDiff <= 0] = NA #remove players who have a lower or equal FP
        salaryDiff = players$Salary - teamPlayer$Salary
        salaryDiff[salaryDiff > amountUnderBudget] = NA #remove players whose salary will take me over the limit
        salaryDiff[salaryDiff < 0] = NA #remove players who have a lower salary
        if (sum(!is.na(fpDiff) & !is.na(salaryDiff)) > 0) {
          ppdg = computePPD(fpDiff, salaryDiff)
          maxPpdg = max(ppdg, na.rm=T)
          if (maxPpdg > bestPpdg) {
            bestPpdg = maxPpdg
            bestOldPlayer = teamPlayer
            bestNewPlayer = players[which.max(ppdg), ]
          }
        }
      }
    }

    if (!is.null(bestOldPlayer)) {
      someoneWasReplaced = TRUE
      #i now have the next best player, replace him
      if (verbose) cat('Replacing', bestOldPlayer$Name, '<-', bestNewPlayer$Name, '\n')
      team = replacePlayer(team, bestOldPlayer, bestNewPlayer)
    }

    if (verbose) {
      printTeam(team, yName)
      cat('\n')
    }

    amountUnderBudget = -computeAmountOverBudget(team)
    cnt = cnt + 1
  }
  return(team)
}
createTeam_Greedy = function(allPlayers, yName, maxCov=Inf, verbose=F) {
  #remove players whose Coefficient of Variation is > cov
  allPlayers$cov = computeCov(allPlayers, yName)
  allPlayers = removeRows(allPlayers, allPlayers[allPlayers$cov > maxCov,])

  #add PPD coumn
  allPlayers$PPD = computePPD(allPlayers[[yName]], allPlayers$Salary)

  #sort by ppd
  allPlayers = allPlayers[order(allPlayers$PPD, decreasing=TRUE),]

  #first, fill team with all the highest ppd players
  team = createFirstAvailableTeam(allPlayers)
  if (is.null(team)) {
    return(NULL)
  }

  if (verbose) {
    cat('Initial team:\n')
    printTeam(team, yName)
  }

  amountOverBudget = computeAmountOverBudget(team)
  if (amountOverBudget > 0) {
    team = getWorseTeam(allPlayers, yName, team, amountOverBudget, verbose)
  } else if (amountOverBudget < 0) {
    team = getBetterTeam(allPlayers, yName, team, -amountOverBudget, verbose)
  } else {
    #cat('Wow, I got a perfect team on the first try!\n')
  }

  if (verbose) {
    cat('Final team:\n')
    printTeam(team, yName)
  }

  return(team)
}

swapRow = function(data1, rowName1, data2, rowName2) {
  tempRow = data1[rowName1,]
  data1[rowName1,] = data2[rowName2,]
  data2[rowName2,] = tempRow
  return(list(
    data1 = data1,
    data2 = data2
  ))
}
climbHill = function(team, allPlayers, yName, verbose=F) {
  #select a random player on the team, and swap him with an available player
  #if the fp is higher, keep the swapped player
  #repeat until i get to a team where every possible swap produces a lower score

  availablePlayers = removeRows(allPlayers, team)

  foundBetterTeam = T
  while (foundBetterTeam) {
    foundBetterTeam = F

    #shuffle the team and available players
    team = shuffle(team)
    availablePlayers = shuffle(availablePlayers)

    amountUnderBudget = SALARY_CAP - computeAmountSpent(team)

    for (i in 1:nrow(team)) {
      playerOnTeam = team[i,]
      betterPlayers = availablePlayers[(availablePlayers$Position == playerOnTeam$Position)
                                       & (availablePlayers[[yName]] > playerOnTeam[[yName]])
                                       & (availablePlayers$Salary - playerOnTeam$Salary <= amountUnderBudget),]
      if(nrow(betterPlayers) > 0) {
        #swap new and old
        newPlayer = betterPlayers[1,]
        spNewTeam = swapRow(team, rownames(playerOnTeam), availablePlayers, rownames(newPlayer))
        team = spNewTeam$data1
        availablePlayers = spNewTeam$data2
        foundBetterTeam = T
        if (verbose) cat('Replaced ', playerOnTeam$Name, ' (', as.character(playerOnTeam$Position), ') -> ', newPlayer$Name, ' (', as.character(newPlayer$Position), ') \n', sep='')
        break
      }
    }
  }
  return(team)
}
createTeam_HillClimbing = function(allPlayers, yName, maxCov=Inf, maxNumTries=1, verbose=F) {
  #remove players whose Coefficient of Variation is > cov
  allPlayers$cov = computeCov(allPlayers, yName)
  allPlayers = removeRows(allPlayers, allPlayers[allPlayers$cov > maxCov,])

  bestTeam = NULL
  bestTeamFP = -Inf

  numTriesWithoutFindingBetterTeam = 0
  while (numTriesWithoutFindingBetterTeam < maxNumTries) {
    set.seed(sample(1:1000, 1))
    allPlayers = shuffle(allPlayers)
    initialTeam = createFirstAvailableTeam(allPlayers)
    while (computeTeamFP(initialTeam, yName) > SALARY_CAP) {
      cat('Wow, I got a team that was > SALARY_CAP randomly\n')
      allPlayers = shuffle(allPlayers)
      initialTeam = createFirstAvailableTeam(allPlayers)
    }
    team = climbHill(initialTeam, allPlayers, yName, verbose=F)
    teamFP = computeTeamFP(team, yName)
    if (verbose) cat('numTriesWithoutFindingBetterTeam=', numTriesWithoutFindingBetterTeam, ', fp=', teamFP,'\n')
    if (teamFP > bestTeamFP) {
      bestTeam = team
      bestTeamFP = teamFP
      numTriesWithoutFindingBetterTeam = 0
      if (verbose) cat('    Found new best team, fp=', bestTeamFP, '\n')
    } else {
      numTriesWithoutFindingBetterTeam = numTriesWithoutFindingBetterTeam + 1
    }
  }
  return(bestTeam)
}

testClimbHill = function(yName=Y_NAME) {
  data = getData()
  playersForDate = data[data$Date == '2016-11-11',]

  for (i in 1:1) {
    cat('Run ', i, '... ', sep='')
    set.seed(i)
    shuffledPlayers = shuffle(playersForDate)
    initialTeam = createFirstAvailableTeam(shuffledPlayers)

    #cat('    Initial team: salary=', computeAmountSpent(initialTeam), ', fp=', computeTeamFP(initialTeam, yName),'\n', sep='')

    set.seed(i)
    oldTimeElapsed = system.time(oldFinalTeam <- climbHillOld(initialTeam, shuffledPlayers))
    set.seed(i)
    newTimeElapsed = system.time(newFinalTeam <- climbHill(initialTeam, shuffledPlayers))

    cat('Old team: ', computeAmountSpent(oldFinalTeam), ', ', computeTeamFP(oldFinalTeam, yName), ', time=', oldTimeElapsed[3], sep='')
    printTeam(oldFinalTeam, yName)
    cat(', New team: ', computeAmountSpent(newFinalTeam), ', ', computeTeamFP(newFinalTeam, yName), ', time=', newTimeElapsed[3], sep='')
    printTeam(newFinalTeam, yName)
    if (identical(oldFinalTeam, newFinalTeam)) {
      cat(', Match\n')
    } else {
      stop('Teams don\'t match')
    }
  }
}
