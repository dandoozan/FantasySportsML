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

getTeam = function(players) {
  return(players[players$OnTeam == T,])
}
createFirstAvailableTeam = function(players) {
  players$OnTeam = F

  positions = levels(players$Position)
  for (position in positions) {
    numPlayersToChoose = ifelse(position == 'C', 1, 2)
    playersInPosition = players[players$Position == position,]

    #if there are not enough players in the position, return NA
    if (sum(!is.na(players[players$Position == position, 'Position'])) < numPlayersToChoose) {
      stop('Cannot create team because there are not enough ', position, 's\n')
      return(NULL)
    }

    players[players$Position == position,][1:numPlayersToChoose, 'OnTeam'] = T
  }

  return(players)
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
getWorseTeam = function(players, amountOverBudget, verbose=F) {
  cnt = 1
  while (amountOverBudget > 0) {
    if (verbose) print(paste('Iteration', cnt, ', amountOverBudget=', amountOverBudget))

    bestPpdg = Inf
    bestOldPlayerIndex = NULL
    bestNewPlayerIndex = NULL

    team = getTeam(players)

    for (i in 1:nrow(team)) {
      playerOnTeam = team[i,]
      potentiallyBetterPlayers = players[(players$OnTeam == F)
          & (players$Position == playerOnTeam$Position),]
      fpDiff = playerOnTeam$FantasyPoints - potentiallyBetterPlayers$FantasyPoints
      salaryDiff = pmin(playerOnTeam$Salary - potentiallyBetterPlayers$Salary, amountOverBudget)
      salaryDiff[salaryDiff <= 0] = NA
      if (sum(!is.na(salaryDiff)) > 0) {
        ppdg = computePPD(fpDiff, salaryDiff)
        minPpdg = min(ppdg, na.rm=T)
        if (minPpdg < bestPpdg) {
          bestPpdg = minPpdg
          bestOldPlayerIndex = rownames(playerOnTeam)
          bestNewPlayerIndex = rownames(potentiallyBetterPlayers[which.min(ppdg), ])
        }
      }
    }

    #i now have the next best player, replace him
    #if (verbose) cat('Replacing', oldPlayer$Name, '<-', newPlayer$Name, '\n')
    #team = replacePlayer(team, bestOldPlayerIndex, bestNewPlayerIndex)
    players[bestOldPlayerIndex, 'OnTeam'] = F
    players[bestNewPlayerIndex, 'OnTeam'] = T
    team = getTeam(players)

    amountOverBudget = computeAmountOverBudget(team)
    cnt = cnt + 1
  }
  return(team)
}
getBetterTeam = function(players, amountUnderBudget, verbose=F) {
  #while amountOverBudget < 0, look for a better match
  #compute the next highest ppdg for each position
  #select the matchup with the highest ppdg gained
  cnt = 1
  someoneWasReplaced = TRUE
  while (amountUnderBudget > 0 && someoneWasReplaced) {
    someoneWasReplaced = FALSE
    if (verbose) cat(paste('Iteration', cnt, ', amountUnderBudget=', amountUnderBudget), '\n')

    bestPpdg = -Inf
    bestOldPlayerIndex = NULL
    bestNewPlayerIndex = NULL

    team = getTeam(players)

    for (i in 1:nrow(team)) {
      playerOnTeam = team[i,]
      potentiallyBetterPlayers = players[(players$OnTeam == F)
          & (players$Position == playerOnTeam$Position),]
      fpDiff = potentiallyBetterPlayers$FantasyPoints - playerOnTeam$FantasyPoints
      salaryDiff = potentiallyBetterPlayers$Salary - playerOnTeam$Salary
      salaryDiff[salaryDiff > amountUnderBudget] = NA
      salaryDiff[salaryDiff < 0] = NA
      if (sum(!is.na(salaryDiff)) > 0) {
        ppdg = computePPD(fpDiff, salaryDiff)
        maxPpdg = max(ppdg, na.rm=T)
        if (maxPpdg > bestPpdg) {
          bestPpdg = maxPpdg
          bestOldPlayerIndex = rownames(playerOnTeam)
          bestNewPlayerIndex = rownames(potentiallyBetterPlayers[which.max(ppdg), ])
        }
      }
    }

    if (!is.null(bestOldPlayerIndex)) {
      #i now have the next best player, replace him
      someoneWasReplaced = TRUE
      players[bestOldPlayerIndex, 'OnTeam'] = F
      players[bestNewPlayerIndex, 'OnTeam'] = T
      team = getTeam(players)
    }

    amountUnderBudget = -computeAmountOverBudget(team)
    cnt = cnt + 1
  }
  return(team)
}
createTeam_Greedy = function(players, maxCov=Inf, verbose=F) {
  #remove players whose Coefficient of Variation is > cov
  players$cov = computeCov(players)
  players = removeRows(players, players[players$cov > maxCov,]) #todo: improve

  #add PPD coumn
  players$PPD = computePPD(players$FantasyPoints, players$Salary)

  #sort by ppd
  players = players[order(players$PPD, decreasing=TRUE),]

  #first, fill team with all the highest ppd players
  players = createFirstAvailableTeam(players)
  team = getTeam(players)
  if (is.null(team)) {
    return(NULL)
  }

  if (verbose) {
    cat('Initial team:\n')
    printTeam(team)
  }

  amountOverBudget = computeAmountOverBudget(team)
  if (amountOverBudget > 0) {
    team = getWorseTeam(players, amountOverBudget, verbose)
  } else if (amountOverBudget < 0) {
    team = getBetterTeam(players, -amountOverBudget, verbose)
  } else {
    #cat('Wow, I got a perfect team on the first try!\n')
  }

  if (verbose) {
    cat('Final team:\n')
    printTeam(team)
  }

  return(team)
}

climbHill = function(players, verbose=F) {
  #select a random player on the team, and swap him with an available player
  #if the fp is higher, keep the swapped player
  #repeat until i get to a team where every possible swap produces a lower score

  foundBetterTeam = T
  while (foundBetterTeam) {
    foundBetterTeam = F

    #shuffle the players
    players = shuffle(players)
    team = getTeam(players)

    amountUnderBudget = SALARY_CAP - computeAmountSpent(team)

    for (i in 1:nrow(team)) {
      playerOnTeam = team[i,]
      betterPlayers = players[(players$OnTeam == F)
          & (players$Position == playerOnTeam$Position)
          & (players$FantasyPoints > playerOnTeam$FantasyPoints)
          & (players$Salary - playerOnTeam$Salary <= amountUnderBudget),]
      if(nrow(betterPlayers) > 0) {
        #swap new and old
        newPlayer = betterPlayers[1,]
        players[players$Name == playerOnTeam$Name, 'OnTeam'] = F
        players[players$Name == newPlayer$Name, 'OnTeam'] = T
        foundBetterTeam = T
        if (verbose) cat('Replaced ', playerOnTeam$Name, ' (', as.character(playerOnTeam$Position), ') -> ', newPlayer$Name, ' (', as.character(newPlayer$Position), ') \n', sep='')
        break
      }
    }
  }
  return(players)
}
createTeam_HillClimbing = function(players, maxCov=Inf, maxNumTries=1, verbose=F) {
  #remove players whose Coefficient of Variation is > cov
  players$cov = computeCov(players)
  players = players[players$cov <= maxCov,]

  bestTeam = NULL
  bestTeamFP = -Inf

  numTriesWithoutFindingBetterTeam = 0
  while (numTriesWithoutFindingBetterTeam < maxNumTries) {
    set.seed(sample(1:1000, 1))
    players = shuffle(players)
    players = createFirstAvailableTeam(players)
    players = climbHill(players, verbose)
    team = getTeam(players)
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
