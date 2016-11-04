#Usage: python createTeam.py [filename]
#Eg. python source/python_scripts/createTeam.py prediction_rf_createTeam.csv

SALARY_CAP = 60000
PREDICTION_LOCATION = ''
PREDICTION_PREFIX = 'prediction_'
ACTUAL_PREFIX = 'actual_'

def readInput():
    return raw_input('Enter filename suffix (eg. rf_usage): ').strip()

def loadPredictions(filename):
    f = open(filename)
    f.readline()
    players = {
        'PG': [],
        'SG': [],
        'SF': [],
        'PF': [],
        'C': []
    }
    for line in f:
        sp = line.strip().split(',')
        name = sp[0].strip()
        fantasyPoints = sp[1].strip()
        if fantasyPoints == 'NA':
            continue
        fantasyPoints = float(fantasyPoints)
        salary = int(sp[2].strip())
        position = sp[3].strip()
        players[position].append({
            'name': name,
            'ppd': fantasyPoints/salary*1000,
            'fantasyPoints': fantasyPoints,
            'salary': salary,
            'position': position
        })
    f.close()

    for position in players:
        players[position].sort(reverse=True, key=lambda x: x['ppd'])

    return players

def printPlayer(player):
    print '%s, %s, %.2f, %.2f, %d' % (player['position'], player['name'], player['ppd'], player['fantasyPoints'], player['salary'])

def printPlayers(players):
    for position in players:
        for player in players[position]:
            printPlayer(player)

def computePpg(fantasyPoints, salary):
    return float(fantasyPoints) / salary * 1000

def printTeamStats(team):
    totalPoints = computePoints(team)
    totalSalary = computeCost(team)
    print 'Total salary:', totalSalary
    print 'Total points: %.2f' % totalPoints
    print 'Ppg: %.4f' % computePpg(totalPoints, totalSalary)

def printTeam(team):
    for position in team:
        for player in team[position]:
            printPlayer(player)
    printTeamStats(team)

def getInitialTeam(players):
    team = {
        'PG': [None, None],
        'SG': [None, None],
        'SF': [None, None],
        'PF': [None, None],
        'C': [None]
    }

    for position in players:
        numPlayers = 1 if position == 'C' else 2
        for i in xrange(numPlayers):
            player = players[position][i]
            team[position][i] = player

    return team

def playerInTeam(player, team, position):
    for playr in team[position]:
        if playr == player:
            return True
    return False

def computePpdg(player1, player2, amountOverBudget):
    fpDiff = player2['fantasyPoints'] - player1['fantasyPoints']
    salaryDiff = player2['salary'] - player1['salary']

    #this essentially renders dollars that are unused as 0
    adjustedSalaryDiff = min(salaryDiff, amountOverBudget)

    return computePpg(fpDiff, adjustedSalaryDiff)

def findNextBestPlayerAtPosition(players, position, team, amountOverBudget):
    bestPpdg = None
    bestOldPlayer = None
    bestOldPlayerIndex = None
    bestNewPlayer = None
    for player in players[position]:
        if not playerInTeam(player, team, position):
            #compare this player to the existing ones
            for i in xrange(len(team[position])):
                teamPlayer = team[position][i]
                if player['salary'] < teamPlayer['salary']:
                    ppdg = computePpdg(player, teamPlayer, amountOverBudget)
                    if bestPpdg == None or ppdg < bestPpdg:
                        bestPpdg = ppdg
                        bestOldPlayer = teamPlayer
                        bestOldPlayerIndex = i
                        bestNewPlayer = player

    return bestPpdg, bestOldPlayer, bestOldPlayerIndex, bestNewPlayer

def computeCost(team):
    cost = 0
    for position in team:
        for player in team[position]:
            cost += player['salary']
    return cost

def computePoints(team):
    points = 0
    for position in team:
        for player in team[position]:
            points += player['fantasyPoints']
    return points


def computeAmountOverBudget(team):
    return computeCost(team) - SALARY_CAP

def createFilename(prefix, suffix):
    return PREDICTION_LOCATION + prefix + suffix + '.csv'

def getWorseTeam(team, amountOverBudget):
    #while amountOverBudget > 0
    #find the next lowest ppd player for each position
    #compute the ppd of the scoreDiff and salaryDiff for each of those players and the players that they might replace
    #replace the players that have the lowest ppd from above
    #repeat
    cnt = 1
    while amountOverBudget > 0:
        print ' '
        print 'Iteration', cnt, ', amountOverBudget=', amountOverBudget

        #find player to replace based on ppdg
        bestPpdg = None
        bestOldPlayer = None
        bestOldPlayerIndex = None
        bestNewPlayer = None
        bestPosition = None
        for position in team:
            ppdg, oldPlayer, oldPlayerIndex, newPlayer = findNextBestPlayerAtPosition(players, position, team, amountOverBudget)
            if bestPpdg == None or ppdg < bestPpdg:
                bestPpdg = ppdg
                bestOldPlayer = oldPlayer
                bestOldPlayerIndex = oldPlayerIndex
                bestNewPlayer = newPlayer
                bestPosition = position

        #replace player in team
        print 'Replacing', bestOldPlayer['name'], '<-', bestNewPlayer['name']
        #printPlayer(bestOldPlayer)
        #print 'with'
        #printPlayer(bestNewPlayer)

        team[bestPosition][bestOldPlayerIndex] = bestNewPlayer

        #todo: imporove this, it should just be -= diff b/n new player and old player i think
        amountOverBudget = computeAmountOverBudget(team)
        printTeamStats(team)
        cnt += 1

def getBetterTeam(team, amountOverBudget):
    #todo: fill this in
    return

def getTeam(prefix, suffix):
    #get players
    players = loadPredictions(createFilename(prefix, suffix))

    #first, fill team with all the highest ppd players
    team = getInitialTeam(players)

    amountOverBudget = computeAmountOverBudget(team)
    if amountOverBudget > 0:
        getWorseTeam(team, amountOverBudget)
    elif amountOverBudget < 0:
        getBetterTeam(team, amountOverBudget)
    else:
        print 'Wow, I got a perfect team on the first try!'

    return team

#================ MAIN ===============

suffix = readInput()

myTeam = getTeam(PREDICTION_PREFIX, suffix)
bestTeam = getTeam(ACTUAL_PREFIX, suffix)


print 'My Team:'
printTeam(myTeam)

print ' '
print 'Best Team:'
printTeam(bestTeam)


