SALARY_CAP = 60000

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
printPlayer = function(player) {
  cat('    ', as.character(player$Position), ', ', sep='')
  cat(paste(player[, c('Name', 'Salary')], collapse=', '), sep='')
  cat(', ', round(player$FantasyPoints, 2), sep='')
  cat(', ', round(player$PPD, 2), sep='')
  cat('\n')
}
printTeam = function(team) {
  for (i in 1:nrow(team)) {
    printPlayer(team[i,])
  }
  cat('    Total Amount spent:', computeAmountSpent(team), '\n')
  cat('    Total Fantasy Points:', round(computeTotalFantasyPoints(team), 2), '\n')
}
computeTotalFantasyPoints = function(team) {
  return(sum(team$FantasyPoints))
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
getBetterTeam = function(data, team, amountUnderBudget, verbose=F) {
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
        fpDiff = players$FantasyPoints - teamPlayer$FantasyPoints
        salaryDiff = players$Salary - teamPlayer$Salary
        salaryDiff[salaryDiff > amountUnderBudget] = NA
        salaryDiff[salaryDiff < 0] = NA
        if (sum(!is.na(salaryDiff)) > 0) {
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
      printTeam(team)
      cat('\n')
    }

    amountUnderBudget = -computeAmountOverBudget(team)
    cnt = cnt + 1
  }
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
    cat('Initial team:\n')
    printTeam(team)
  }

  amountOverBudget = computeAmountOverBudget(team)
  if (amountOverBudget > 0) {
    team = getWorseTeam(data, team, amountOverBudget, verbose)
  } else if (amountOverBudget < 0) {
    team = getBetterTeam(data, team, -amountOverBudget, verbose)
  } else {
    #cat('Wow, I got a perfect team on the first try!\n')
  }

  if (verbose) {
    cat('Final team:\n')
    printTeam(team)
  }

  return(team)
}
printTeamResults = function(myTeam, bestTeam, yName) {
  myTeamPredictedPoints = computeTotalFantasyPoints(myTeam)
  myTeamActualPoints = computeTotalFantasyPoints(test[rownames(myTeam),])
  bestTeamPoints = computeTotalFantasyPoints(bestTeam)

  cat('How did my team do?\n')
  cat('    I was expecting to get', round(myTeamPredictedPoints, 2), 'points\n')
  cat('    I actually got:', round(myTeamActualPoints, 2), 'points\n')
  cat('    Best team got:', round(bestTeamPoints, 2), 'points\n')
  cat('    My score ratio is', round(myTeamActualPoints/bestTeamPoints, 4), '\n')
}

createTeams = function(testData, prediction, yName, verbose=F) {
  if (verbose) cat('Creating my team...\n')

  #create my team (using prediction)
  predictionDF = testData
  predictionDF[[yName]] = prediction
  myTeam = createTeam(predictionDF)
  if (verbose) {
    cat('My team:\n')
    printTeam(myTeam)
  }

  #create best team (using test)
  bestTeam = createTeam(testData)
  if (verbose) {
    cat('Best team:\n')
    printTeam(bestTeam)
  }

  if (verbose) printTeamResults(myTeam, bestTeam, yName)

  myTeamActualFantasyPoints = computeTotalFantasyPoints(testData[rownames(myTeam),])
  bestTeamFantasyPoints = computeTotalFantasyPoints(bestTeam)

  return(list(
    myTeam=list(
      expectedFantasyPoints=computeTotalFantasyPoints(myTeam),
      fantasyPoints=myTeamActualFantasyPoints
    ),
    bestTeam=list(
      fantasyPoints=bestTeamFantasyPoints
    ),
    ratio=myTeamActualFantasyPoints/bestTeamFantasyPoints
    ))
}
