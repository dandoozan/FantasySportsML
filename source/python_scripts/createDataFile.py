import os
from datetime import datetime, timedelta
import json
import scraper

SEASON = '2015'
DATA_DIR = 'data'
ROTOGURU_FILE = DATA_DIR + '/rawDataFromRotoGuru/fd_%s.txt' % SEASON
NBA_DIR = DATA_DIR + '/rawDataFromStatsNba'
Y_NAME = 'FantasyPoints'
X_NAMES = ['Date', 'Name', 'Salary', 'Position', 'Home', 'Team', 'Opponent', #rotoguru
        'AGE', 'GP', 'W', 'L', 'W_PCT', 'MIN', 'FGM', 'FGA', 'FG_PCT', #nba
        'FG3M', 'FG3A', 'FG3_PCT', 'FTM', 'FTA', 'FT_PCT', 'OREB', 'DREB', #nba
        'REB', 'AST', 'TOV', 'STL', 'BLK', 'BLKA', 'PF', 'PFD', 'PTS', #nba
        'PLUS_MINUS', 'DD2', 'TD3', #nba
        'AvgFantasyPoints', 'DaysPlayedPercent', 'Injured', #mine
]
DATE_FORMAT = '%Y%m%d'
ONE_DAY = timedelta(1)

FIRST_DATE_OF_SEASON = {
    '2014': datetime(2014, 10, 28),
    '2015': datetime(2015, 10, 27),
}

#rotoguru: nba
MISMATCHED_NAMES = {
    'Glenn Robinson III': 'Glenn Robinson',
    'Larry Nance': 'Larry Nance Jr.',
    'Joseph Young': 'Joe Young',
    'Nene Hilario': 'Nene',
    'Louis Williams': 'Lou Williams',
    'Jose Barea': 'Jose Juan Barea',
    'Amare Stoudemire': 'Amar\'e Stoudemire',
    'Louis Amundson': 'Lou Amundson',
    'Wes Matthews': 'Wesley Matthews',
    'Ishmael Smith': 'Ish Smith',
    'Walter Tavares': 'Edy Tavares',
    'Maurice Williams': 'Mo Williams',
    'Chuck Hayes': 'Charles Hayes',
}

#names that exist in rotoguru but are missing in nba for a given date
#you'll notice most of these are after the reg season ends, and it
#looks like the players only played in the post season, so they're legitimately missing
MISSING_NAMES = {
    '20151030': { 'Tibor Pleiss', 'James Ennis' },
    '20160307': { 'Rakeem Christmas' },
    '20160408': { 'Rakeem Christmas' },
    '20160420': { 'Dorell Wright' },
    '20160422': { 'John Holland' },
    '20160423': { 'Dorell Wright' },
    '20160424': { 'John Holland' },
    '20160425': { 'Dorell Wright' },
    '20160426': { 'John Holland' },
    '20160427': { 'Dorell Wright' },
    '20160429': { 'Dorell Wright' },
    '20160509': { 'Dorell Wright' },
    '20160503': { 'Dorell Wright' },
    '20160501': { 'Dorell Wright' },
    '20160507': { 'Dorell Wright' },
    '20160505': { 'Dorell Wright' },
    '20160515': { 'Dorell Wright' },
    '20160511': { 'Dorell Wright' },
    '20160513': { 'Dorell Wright' },
}

def loadDataFromRotoGuru(filename):
    print 'Loading data from ' + filename + '...'
    #get data
    f = open(filename)
    f.readline()

    #Upcoming game data:
    #-Date
    #-Position
    #-Name
    #-Salary
    #-Home
    #-Team
    #-Opponent

    #Future data:
    #-Starter
    #-FantasyPoints
    #-MyTeamScore
    #-OppTeamScore
    #-MinutesPlayed
    #-Points
    #-Rebounds
    #-Assists
    #-Turnovers
    #-3PointersMade
    #-FGMade
    #-FGAttempts
    #-FTMade
    #-FTAttempts
    #-Steals
    #-Blocks

    #Other:
    #-GID (i think this is player id)

    data = {}
    for line in f:
        sp = line.strip().split(';')

        date = sp[0].strip()
        rgPlayerId = sp[1].strip()
        position = sp[2].strip()
        name = sp[3].strip().split(', ')
        name.reverse()
        name = ' '.join(name)
        fantasyPoints = float(sp[5])
        salary = sp[6].strip()
        salary = '' if salary == 'N/A' else str(int(salary[1:].replace(',', '')))
        team = sp[7].strip()
        home = sp[8].strip()
        opponent = sp[9].strip()

        minutes = sp[12].strip()

        if date not in data:
            data[date] = {}

        if name in data[date]:
            scraper.headsUp('Uh oh, got a duplicate name. Name=' + name + ', date=' + date)
            exit()

        data[date][name] = {
            'Date': date,
            'FantasyPoints': fantasyPoints,
            'Home': home,
            'Name': name,
            'Opponent': opponent,
            'Position': position,
            'Salary': salary,
            'Team': team,
            'RGPlayerID': rgPlayerId,
            'Minutes': minutes,
        }

    f.close()

    return data

def createNbaDataFileName(date, season):
    year = date.year
    return NBA_DIR + '/' + season + '/' + FIRST_DATE_OF_SEASON[season].strftime(DATE_FORMAT) + '-' + date.strftime(DATE_FORMAT) + '.json'

def loadNbaDataForDate(date, season):
    #possible stats:
    #PLAYER_ID #N
    #PLAYER_NAME #N
    #TEAM_ID #N
    #TEAM_ABBREVIATION #N
    #AGE
    #GP
    #W
    #L
    #W_PCT
    #MIN
    #FGM
    #FGA
    #FG_PCT
    #FG3M
    #FG3A
    #FG3_PCT
    #FTM
    #FTA
    #FT_PCT
    #OREB
    #DREB
    #REB
    #AST
    #TOV
    #STL
    #BLK
    #BLKA #(Blocks Against)
    #PF
    #PFD #(Personal Fouls Drawn)
    #PTS
    #PLUS_MINUS
    #DD2
    #TD3
    #CFID #?
    #CFPARAMS #?

    data = {}

    #if i dont find a file for date, then check each previous day until i find it
    usedDiffFile = False
    currDate = date
    filename = createNbaDataFileName(date, season)
    while currDate >= FIRST_DATE_OF_SEASON[season] and not os.path.exists(filename):
        currDate = currDate - ONE_DAY
        filename = createNbaDataFileName(currDate, season)
        usedDiffFile = True

    if usedDiffFile:
        scraper.headsUp('Used different file. date=' + str(date) + ', file=' + filename)

    if os.path.exists(filename):
        f = open(filename)
        jsonData = json.load(f)
        f.close()

        colNames = jsonData['resultSets'][0]['headers']
        rowData = jsonData['resultSets'][0]['rowSet']
        nameIndex = colNames.index('PLAYER_NAME')

        for row in rowData:
            name = row[nameIndex]
            if name in data:
                scraper.headsUp('Uh oh, got a duplicate name. Name=' + name + ', date=' + str(date))
                exit()
            data[name] = zip(colNames, row)
    return data

def hasExactMatch(name, nbaData):
    return name in nbaData

def splitName(name):
    return name.split(' ')
def joinName(nameSp):
    return ' '.join(nameSp)

def removePeriods(name):
    return name.replace('.', '')
#Not used
def removeSuffix(name):
    #case 1: name has suffix, nba data name does not
        #eg. name='Glenn Robinson III' -> 'Glenn Robinson'
    #case 2: name does not have suffix, nba name does
        #eg. name='Larry Nance' -> 'Larry Nance Jr.'

    validSuffices = {'III', 'Jr.'}
    nameSp = splitName(name)
    if nameSp[-1] in validSuffices:
        return joinName(nameSp[:-1])
    return name
#Not used
def abbreviateFirstName(name):
    nameSp = splitName(name)
    nameSp[0] = nameSp[0][:3]
    return joinName(nameSp)
def findAllPlayersThatMatchFunction(name, nbaData, func):
    playerMatches = []

    newName = func(name)
    if hasExactMatch(newName, nbaData):
        return [newName]

    for nbaName in nbaData:
        newNbaName = func(nbaName)
        if newNbaName == name:
            playerMatches.append(nbaName)
    return playerMatches
def findAllPlayerMatches(name, nbaData):
    #Note: I'm only using remove periods, but I'm keepng the others in case i need them for other data sources

    #find all combinations of name permutations:
        #-remove/add suffix
        #-remove periods
        #-use first 3 letters of first name
    playerMatches = []
    playerMatches.extend(findAllPlayersThatMatchFunction(name, nbaData, removePeriods))
    #playerMatches.extend(findAllPlayersThatMatchFunction(name, nbaData, removeSuffix))
    #playerMatches.extend(findAllPlayersThatMatchFunction(name, nbaData, abbreviateFirstName))
    return playerMatches

def isPlayerInjured(playerData):
    minutes = playerData['Minutes']
    return minutes == 'NA'
def playerDidPlay(playerData):
    minutes = playerData['Minutes']
    return minutes != 'DNP' and minutes != 'NA' and float(minutes) > 0
def playerPlayedAnyGameUpToDate(data, playerName, date, season):
    currDate = FIRST_DATE_OF_SEASON[season]
    while currDate < date:
        currDateStr = currDate.strftime(DATE_FORMAT)
        if currDateStr in data:
            if playerName in data[currDateStr]:
                if playerDidPlay(data[currDateStr][playerName]):
                    return True
        currDate = currDate + ONE_DAY
    return False

def appendDataFromNba(data, season):
    cnt = 1
    dateStrs = data.keys()
    dateStrs.sort()
    numDates = len(dateStrs)
    for dateStr in dateStrs:
        print 'On date=%s (%d / %d)' % (dateStr, cnt, numDates)

        #load previous day's nba season-long data
        date = datetime.strptime(dateStr, DATE_FORMAT)
        prevDate = date - ONE_DAY
        nbaData = loadNbaDataForDate(prevDate, season)
        if len(nbaData) > 0:

            #iterate through each player and merge nba data into player data
            for name in data[dateStr]:

                #ignore players that are missing from data
                if dateStr in MISSING_NAMES and name in MISSING_NAMES[dateStr]:
                    continue

                #first, check for exact match
                if hasExactMatch(name, nbaData):
                    data[dateStr][name].update(nbaData[name])
                #then, check if it's a known mismatch name
                elif name in MISMATCHED_NAMES and MISMATCHED_NAMES[name] in nbaData:
                    data[dateStr][name].update(nbaData[MISMATCHED_NAMES[name]])
                #then, check all permutations of the name
                else:
                    #print 'No match found for player=', name, ', searching for similar names...'
                    playerMatches = findAllPlayerMatches(name, nbaData)
                    numPlayerMatches = len(playerMatches)
                    if numPlayerMatches == 1:
                        nbaName = playerMatches[0]
                        print '    Found different name: %s -> %s' % (name, nbaName)
                        #add it to the known mismatches
                        MISMATCHED_NAMES[name] = nbaName
                        data[dateStr][name].update(nbaData[nbaName])
                    elif numPlayerMatches == 0:
                        #print '    Didn\'t find player, checking that player actually played any games leading up to', dateStr

                        #verify that the player played any games leading up to date
                        if playerPlayedAnyGameUpToDate(data, name, date, season):
                            TBX_MISSING_PLAYERS.append((dateStr, name))
                            scraper.headsUp('Player played and was not found. player=' + name + ', date(rg)=' + dateStr + ', prevDate(nba)=' + prevDate.strftime(DATE_FORMAT))
                            exit()
                        else:
                            pass
                            #print '    Didn\'t find %s, but he didn\'t play any games' % name
                    else:
                        print 'Multiple matches found, matches=', playerMatches
                        exit()

        else:
            scraper.headsUp('No nba file found for date=' + dateStr + ', so not appending data')
            #exit()
        cnt += 1

def getValue(obj, key):
    return obj[key] if key in obj else ''

def writeData(filename, data):
    print 'Writing data to: ' + filename + '...'

    f = open(filename, 'w')

    #print col names
    f.write(Y_NAME + ',')
    f.write(','.join(X_NAMES) + '\n')

    dates = data.keys()
    dates.sort() #sort by date
    for date in dates:
        names = data[date].keys()
        names.sort() #sort by name
        for name in names:
            #write y
            f.write(str(getValue(data[date][name], Y_NAME)) + ',')

            #write first x
            f.write(str(getValue(data[date][name], X_NAMES[0])))

            #write the rest
            for i in xrange(1, len(X_NAMES)):
                f.write(',' + str(getValue(data[date][name], X_NAMES[i])))
            f.write('\n')
    f.close()

def createFilename(season):
    return DATA_DIR + ('/data_%s.csv' % season)

def computeAvgFantasyPoints(data):
    #iterate through the dates in order
    #keep a total of fp for each player
        #if i encounter a new player, set his avgfp to 0, add him to the obj
        #if player already there, then compute avgfp BEFORE adding curr days fp (so that i get avgfp thru yesterday)
        #add fp to the players obj

    print '    Computing AvgFantasyPoints...'
    players = {}
    dateStrs = data.keys()
    dateStrs.sort()
    for dateStr in dateStrs:
        for playerName in data[dateStr]:
            playerData = data[dateStr][playerName]
            if playerName in players:
                playerData['AvgFantasyPoints'] = players[playerName]['totalFantasyPoints'] / players[playerName]['numDays']
                if not isPlayerInjured(playerData):
                    players[playerName]['totalFantasyPoints'] += playerData['FantasyPoints']
                    players[playerName]['numDays'] += 1
            else:
                playerData['AvgFantasyPoints'] = 0.
                if not isPlayerInjured(playerData):
                    players[playerName] = {
                        'totalFantasyPoints': playerData['FantasyPoints'],
                        'numDays': 1
                    }

def computeDaysPlayedPercent(data):
    print '    Computing DaysPlayedPercent...'
    players = {}
    dateStrs = data.keys()
    dateStrs.sort()
    for dateStr in dateStrs:
        for playerName in data[dateStr]:
            playerData = data[dateStr][playerName]
            if playerName in players:
                playerData['DaysPlayedPercent'] = float(players[playerName]['numDaysPlayed']) / players[playerName]['numDaysEligibleToPlay']
                if not isPlayerInjured(playerData):
                    if playerDidPlay(playerData):
                        players[playerName]['numDaysPlayed'] += 1
                    players[playerName]['numDaysEligibleToPlay'] += 1
            else:
                playerData['DaysPlayedPercent'] = 0.
                if not isPlayerInjured(playerData):
                    players[playerName] = {
                        'numDaysPlayed': 1 if playerDidPlay(playerData) else 0,
                        'numDaysEligibleToPlay': 1,
                    }

def computeInjured(data):
    print '    Computing Injured...'
    for dateStr in data:
        for playerName in data[dateStr]:
            playerData = data[dateStr][playerName]
            playerData['Injured'] = int(isPlayerInjured(playerData))

def addAdditionalFeatures(data):
    print 'Adding additional features...'
    computeAvgFantasyPoints(data)
    computeDaysPlayedPercent(data)
    computeInjured(data)

#============= MAIN =============


#1.load data from rotoguru. Data format is:
#   data={
#       '20151027': {
#           'Stephen Curry': {
#               'Date': '20151027',
#               'FantasyPoints': 59.7,
#               'Home': 'H',
#               'Name': 'Stephen Curry',
#               'Opponent': 'nor',
#               'Position': 'PG',
#               'Salary': 10400,
#               'Team': 'gsw',
#           },
#           ...
#       },
#       ...
#   }
    #-Make sure i dont have any duplicate names
#2.for each day
    #find the nba day file
    #load the data from the file into obj.  Format is:
        #data = {
        #   'Stephen Curry': {
        #       'PLAYER_ID': 201939,
        #       'PLAYER_NAME': 'Stephen Curry',
        #       'TEAM_ID': 1610612744,
        #       'TEAM_ABBREVIATION': 'GSW',
        #       'AGE': 28.0,
        #       ...
        #   }
        #}
    #for each player in rg data
        #find the player in the nba data
        #merge the nba player data into rg player data
#3.Print the data in tabular format (perhaps sort by day if i want the data in chronological order)

data = loadDataFromRotoGuru(ROTOGURU_FILE)
appendDataFromNba(data, SEASON)
addAdditionalFeatures(data)
writeData(createFilename(SEASON), data)
