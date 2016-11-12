#TBX:
#Baseteam:
# C, A.J. Hammons, 3500, 0.92
# PF, Amir Johnson, 4400, 26.07
# PF, Anthony Tolliver, 3500, 0.61
# PG, Cory Joseph, 3500, 13.6
# PG, D'Angelo Russell, 6100, 29.2
# SF, Brandon Ingram, 3700, 16.36
# SF, Bruno Caboclo, 3500, 2.05
# SG, Arron Afflalo, 3600, 14.71
# SG, Avery Bradley, 6800, 26.54
# Total Amount spent: 38600
# Total Fantasy Points: 130.08

#Finalteam:
# SG, Giannis Antetokounmpo, 9900, 44.12
# SF, Harrison Barnes, 5100, 24.92
# PF, Dwight Powell, 4100, 24.98
# PG, Jameer Nelson, 4200, 22.3
# SF, Rudy Gay, 7300, 33.93
# PG, Isaiah Thomas, 8100, 39.9
# PF, Nikola Jokic, 5700, 27.78
# SG, Devin Booker, 5900, 30.15
# C, DeMarcus Cousins, 9700, 40.1
# Total Amount spent: 60000
# Total Fantasy Points: 288.18

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
computeCov = function(players) {
  #cov is the 'Coefficient of Variance', which is the stdev / mean
  cov = players$RG_deviation / players$FantasyPoints
  cov = ifelse(is.nan(cov), Inf, cov)
  return(cov)
}
printPlayer = function(player) {
  cat('    ', as.character(player$Position), ', ', sep='')
  cat(paste(player[, c('Name', 'Salary')], collapse=', '), sep='')
  cat(', ', round(player$FantasyPoints, 2), sep='')
  #cat(', ', round(player$PPD, 2), sep='')
  cat(', ', round(player$cov, 2), sep='')
  cat('\n')
}
printTeam = function(team) {
  if (is.null(team)) {
    cat('No team\n')
  } else {
    for (i in 1:nrow(team)) {
      printPlayer(team[i,])
    }
    cat('    Total Amount spent:', computeAmountSpent(team), '\n')
    cat('    Total Fantasy Points:', round(computeTeamFP(team), 2), '\n')
  }
}
computeTeamFP = function(team) {
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
createTeam_Greedy = function(allPlayers, maxCov=Inf, verbose=F) {
  #remove players whose Coefficient of Variation is > cov
  allPlayers$cov = computeCov(allPlayers)
  allPlayers = removeRows(allPlayers, allPlayers[allPlayers$cov > maxCov,])

  #add PPD coumn
  allPlayers$PPD = computePPD(allPlayers$FantasyPoints, allPlayers$Salary)

  #sort by ppd
  allPlayers = allPlayers[order(allPlayers$PPD, decreasing=TRUE),]

  #first, fill team with all the highest ppd players
  team = createFirstAvailableTeam(allPlayers)
  if (is.null(team)) {
    return(NULL)
  }

  if (verbose) {
    cat('Initial team:\n')
    printTeam(team)
  }

  amountOverBudget = computeAmountOverBudget(team)
  if (amountOverBudget > 0) {
    team = getWorseTeam(allPlayers, team, amountOverBudget, verbose)
  } else if (amountOverBudget < 0) {
    team = getBetterTeam(allPlayers, team, -amountOverBudget, verbose)
  } else {
    #cat('Wow, I got a perfect team on the first try!\n')
  }

  if (verbose) {
    cat('Final team:\n')
    printTeam(team)
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
climbHill = function(team, allPlayers, verbose=F) {
  #select a random player on the team, and swap him with an available player
  #if the fp is higher, keep the swapped player
  #repeat until i get to a team where every possible swap produces a lower score

  availablePlayers = removeRows(allPlayers, team)

  foundBetterTeam = T
  while (foundBetterTeam) {
    foundBetterTeam = F

    #shuffle the team and available players
    set.seed(48)
    team = shuffle(team)
    set.seed(48)
    availablePlayers = shuffle(availablePlayers)

    amountUnderBudget = SALARY_CAP - computeAmountSpent(team)

    for (i in 1:nrow(team)) {
      playerOnTeam = team[i,]
      betterPlayers = availablePlayers[(availablePlayers$Position == playerOnTeam$Position)
                       & (availablePlayers$FantasyPoints > playerOnTeam$FantasyPoints)
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
createTeam_HillClimbing = function(allPlayers, maxCov=Inf, maxNumTries=1, verbose=F) {
  #remove players whose Coefficient of Variation is > cov
  allPlayers$cov = computeCov(allPlayers)
  allPlayers = removeRows(allPlayers, allPlayers[allPlayers$cov > maxCov,])

  bestTeam = NULL
  bestTeamFP = -Inf

  numTriesWithoutFindingBetterTeam = 0
  while (numTriesWithoutFindingBetterTeam < maxNumTries) {
    set.seed(43)
    allPlayers = shuffle(allPlayers)
    initalTeam = createFirstAvailableTeam(allPlayers)
    team = climbHill(initalTeam, allPlayers, verbose)
    teamFP = computeTeamFP(team)
    #cat('numTriesWithoutFindingBetterTeam=', numTriesWithoutFindingBetterTeam, ', fp=', teamFP,'\n')
    if (teamFP > bestTeamFP) {
      bestTeam = team
      bestTeamFP = teamFP
      numTriesWithoutFindingBetterTeam = 0
      #cat('    Found new best team, fp=', bestTeamFP, '\n')
    } else {
      numTriesWithoutFindingBetterTeam = numTriesWithoutFindingBetterTeam + 1
    }
  }
  return(bestTeam)
}
