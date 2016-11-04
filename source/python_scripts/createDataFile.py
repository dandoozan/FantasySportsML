import os
from datetime import datetime, timedelta
import json
import scraper
import _util as util

SEASON = '2015'
DATA_DIR = 'data'
ROTOGURU_FILE = DATA_DIR + '/rawDataFromRotoGuru/fd_%s.txt' % SEASON
NBA_DIR = util.joinDirs(DATA_DIR, 'rawDataFromStatsNba')

ROTOGURU_FEATURES = ['Date', 'Name', 'Salary', 'Position', 'Home', 'Team', 'Opponent']
ADDITIONAL_FEATURES = ['AvgFantasyPoints', 'DaysPlayedPercent', 'Injured',
        'FantasyPoints_PrevGame', 'Minutes_PrevGame', 'StartedPercent',
        'Salary_PrevGame']
CATEGORIES_TO_USE = [
    {
        'dirName': 'Team_FourFactors',
        'features': [
            'TEAM_FTA_RATE', 'TEAM_OPP_EFG_PCT', 'TEAM_OPP_FTA_RATE',
            'TEAM_OPP_TOV_PCT', 'TEAM_OPP_OREB_PCT'],
        'prefix': 'TEAM_',
        'type': 'team',
    },
    {
        'dirName': 'Team_Advanced',
        'features': [
            'TEAM_OFF_RATING', 'TEAM_DEF_RATING', 'TEAM_NET_RATING', 'TEAM_AST_PCT',
            'TEAM_AST_TO', 'TEAM_AST_RATIO', 'TEAM_OREB_PCT', 'TEAM_DREB_PCT',
            'TEAM_REB_PCT', 'TEAM_TM_TOV_PCT', 'TEAM_EFG_PCT', 'TEAM_TS_PCT',
            'TEAM_PACE', 'TEAM_PIE'],
        'prefix': 'TEAM_',
        'type': 'team',
    },
    {
        'dirName': 'Team_Traditional',
        'features': [
            'TEAM_GP', 'TEAM_W', 'TEAM_L', 'TEAM_W_PCT', 'TEAM_MIN',
            'TEAM_FGM', 'TEAM_FGA', 'TEAM_FG_PCT', 'TEAM_FG3M', 'TEAM_FG3A',
            'TEAM_FG3_PCT', 'TEAM_FTM', 'TEAM_FTA', 'TEAM_FT_PCT', 'TEAM_OREB',
            'TEAM_DREB', 'TEAM_REB', 'TEAM_AST', 'TEAM_TOV', 'TEAM_STL',
            'TEAM_BLK', 'TEAM_BLKA', 'TEAM_PF', 'TEAM_PFD', 'TEAM_PTS',
            'TEAM_PLUS_MINUS'],
        'prefix': 'TEAM_',
        'type': 'team',
    },
    {
        'dirName': 'Traditional_Diff',
        'features': [
            'DIFF_FGM', 'DIFF_FGA', 'DIFF_FG_PCT', 'DIFF_FG3M',
            'DIFF_FG3A', 'DIFF_FG3_PCT', 'DIFF_FTM', 'DIFF_FTA',
            'DIFF_FT_PCT', 'DIFF_OREB', 'DIFF_DREB', 'DIFF_REB',
            'DIFF_AST', 'DIFF_TOV', 'DIFF_STL', 'DIFF_BLK',
            'DIFF_BLKA', 'DIFF_PF', 'DIFF_PFD'],
        'prefix': 'DIFF_',
    },
    {
        'dirName': 'Usage',
        'features': [
            'PCT_FGM', 'PCT_FGA', 'PCT_FG3M', 'PCT_FG3A', 'PCT_FTM',
            'PCT_FTA', 'PCT_OREB', 'PCT_REB', 'PCT_AST', 'PCT_TOV',
            'PCT_BLKA', 'PCT_PF', 'PCT_PFD', 'PCT_PTS'],
    },
    {
        'dirName': 'Scoring',
        'features': [
            'PCT_FGA_2PT', 'PCT_FGA_3PT', 'PCT_PTS_2PT', 'PCT_PTS_2PT_MR',
            'PCT_PTS_3PT', 'PCT_PTS_FB', 'PCT_PTS_FT', 'PCT_PTS_OFF_TOV',
            'PCT_PTS_PAINT', 'PCT_AST_2PM', 'PCT_UAST_2PM', 'PCT_AST_3PM',
            'PCT_UAST_3PM', 'PCT_AST_FGM', 'PCT_UAST_FGM'],
    },
    {
        'dirName': 'Defense',
        'features': [
            'PCT_DREB', 'PCT_STL', 'PCT_BLK', 'OPP_PTS_OFF_TOV',
            'OPP_PTS_2ND_CHANCE', 'OPP_PTS_FB', 'OPP_PTS_PAINT', 'DEF_WS'],
    },
    {
        'dirName': 'Opponent',
        'features': [
            'OPP_FGM', 'OPP_FGA', 'OPP_FG_PCT', 'OPP_FG3M', 'OPP_FG3A',
            'OPP_FG3_PCT', 'OPP_FTM', 'OPP_FTA', 'OPP_FT_PCT', 'OPP_OREB',
            'OPP_DREB', 'OPP_REB', 'OPP_AST', 'OPP_TOV', 'OPP_STL',
            'OPP_BLK', 'OPP_BLKA', 'OPP_PF', 'OPP_PFD', 'OPP_PTS'],
    },
    {
        'dirName': 'PlayerBios',
        'features': [
            'PLAYER_HEIGHT_INCHES','PLAYER_WEIGHT',
            'COLLEGE','COUNTRY','DRAFT_YEAR','DRAFT_ROUND','DRAFT_NUMBER'],
        'type': 'playerBios',
    },
    {
        'dirName': 'Advanced',
        'features': [
            'OFF_RATING', 'DEF_RATING', 'NET_RATING', 'AST_PCT', 'AST_TO',
            'AST_RATIO', 'OREB_PCT', 'DREB_PCT', 'REB_PCT', 'TM_TOV_PCT',
            'EFG_PCT', 'TS_PCT', 'USG_PCT', 'PACE', 'PIE'],
    },
    {
        'dirName': 'Traditional',
        'features': [
            'AGE', 'GP', 'W', 'L', 'W_PCT', 'MIN', 'FGM', 'FGA', 'FG_PCT',
            'FG3M', 'FG3A', 'FG3_PCT', 'FTM', 'FTA', 'FT_PCT', 'OREB', 'DREB',
            'REB', 'AST', 'TOV', 'STL', 'BLK', 'BLKA', 'PF', 'PFD', 'PTS',
            'PLUS_MINUS', 'DD2', 'TD3'],
    },
]

Y_NAME = 'FantasyPoints'
X_NAMES = []

DATE_FORMAT = '%Y%m%d'
ONE_DAY = timedelta(1)

FIRST_DATE_OF_SEASON = {
    '2014': datetime(2014, 10, 28),
    '2015': datetime(2015, 10, 27),
}
LAST_DATE_OF_SEASON = {
    '2014': datetime(2015, 4, 15),
    '2015': datetime(2016, 4, 13),
}

VALID_SUFFICES = {'iii', 'jr.'}

#rotoguru: nba
MISMATCHED_NAMES = {
    'glenn robinson iii': 'glenn robinson',
    'larry nance': 'larry nance jr.',
    'joseph young': 'joe young',
    'nene hilario': 'nene',
    'louis williams': 'lou williams',
    'jose barea': 'jose juan barea',
    'amare stoudemire': 'amar\'e stoudemire',
    'louis amundson': 'lou amundson',
    'wes matthews': 'wesley matthews',
    'ishmael smith': 'ish smith',
    'walter tavares': 'edy tavares',
    'maurice williams': 'mo williams',
    'chuck hayes': 'charles hayes',
}
MISMATCHED_NAMES_REVERSED = {
    'luc mbah a moute': 'mbah a moute, luc',
    'metta world peace': 'world peace, metta',
}

#names that exist in rotoguru but are missing in nba for a given date
#you'll notice most of these are after the reg season ends, and it
#looks like the players only played in the post season, so they're legitimately missing
MISSING_KEYS = {
    '20151030': { 'tibor pleiss', 'james ennis' },
    '20160307': { 'rakeem christmas' },
    '20160408': { 'rakeem christmas' },
    '20160420': { 'dorell wright' },
    '20160422': { 'john holland' },
    '20160423': { 'dorell wright' },
    '20160424': { 'john holland' },
    '20160425': { 'dorell wright' },
    '20160426': { 'john holland' },
    '20160427': { 'dorell wright' },
    '20160429': { 'dorell wright' },
    '20160509': { 'dorell wright' },
    '20160503': { 'dorell wright' },
    '20160501': { 'dorell wright' },
    '20160507': { 'dorell wright' },
    '20160505': { 'dorell wright' },
    '20160515': { 'dorell wright' },
    '20160511': { 'dorell wright' },
    '20160513': { 'dorell wright' },
}

RG_TO_NBA_TEAM_MAP = {
    'atl': 'Atlanta Hawks',
    'chi': 'Chicago Bulls',
    'cle': 'Cleveland Cavaliers',
    'bos': 'Boston Celtics',
    'bkn': 'Brooklyn Nets',
    'cha': 'Charlotte Hornets',
    'dal': 'Dallas Mavericks',
    'den': 'Denver Nuggets',
    'det': 'Detroit Pistons',
    'gsw': 'Golden State Warriors',
    'hou': 'Houston Rockets',
    'ind': 'Indiana Pacers',
    'lac': 'LA Clippers',
    'lal': 'Los Angeles Lakers',
    'mem': 'Memphis Grizzlies',
    'mia': 'Miami Heat',
    'mil': 'Milwaukee Bucks',
    'min': 'Minnesota Timberwolves',
    'nor': 'New Orleans Pelicans',
    'nyk': 'New York Knicks',
    'okc': 'Oklahoma City Thunder',
    'orl': 'Orlando Magic',
    'phi': 'Philadelphia 76ers',
    'pho': 'Phoenix Suns',
    'por': 'Portland Trail Blazers',
    'sac': 'Sacramento Kings',
    'sas': 'San Antonio Spurs',
    'tor': 'Toronto Raptors',
    'uta': 'Utah Jazz',
    'was': 'Washington Wizards',
}

TBX_MISSING_PLAYERS = []
TBX_DUPLICATE_NAMES = {}

def createKey(name, team):
    return name.lower()
def parseKey(key):
    return key, ''
def loadDataFromRotoGuru(fullPathFilename):
    print 'Loading RotoGuru data...'

    #get data
    f = open(fullPathFilename)
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
        starter = sp[4].strip() #1 or ''
        starter = 0 if starter == '' else int(starter)
        fantasyPoints = float(sp[5])
        salary = sp[6].strip()
        salary = '' if salary == 'N/A' else str(int(salary[1:].replace(',', '')))
        team = sp[7].strip()
        home = sp[8].strip()
        opponent = sp[9].strip()
        minutes = sp[12].strip() #this could be 'DNP', 'NA' or a float

        if date not in data:
            data[date] = {}

        if name in data[date]:
            scraper.headsUp('Uh oh, got a duplicate name. Name=' + name + ', date=' + date)
            exit()

        data[date][createKey(name, team)] = {
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
            'Starter': starter,
        }

    f.close()

    return data

def createNbaFullPathFilename(fullPathToDir, baseFilename):
    return util.createFullPathFilename(fullPathToDir, baseFilename + '.json')

def getNameIndex(colNames, prefix=''):
    if (prefix + 'PLAYER_NAME') in colNames:
        return colNames.index(prefix + 'PLAYER_NAME')
    return colNames.index(prefix + 'VS_PLAYER_NAME')
def loadNbaDataFromJsonFile(fullPathFilename, prefix=''):
    data = {}

    f = open(fullPathFilename)
    jsonData = json.load(f)
    f.close()

    colNames = map(lambda x: prefix + x, jsonData['resultSets'][0]['headers'])
    rowData = jsonData['resultSets'][0]['rowSet']
    nameIndex = getNameIndex(colNames, prefix)
    teamIndex = colNames.index(prefix + 'TEAM_ABBREVIATION')
    gpIndex = colNames.index(prefix + 'GP')

    for row in rowData:
        key = createKey(row[nameIndex], row[teamIndex])
        if key in data:
            #TBX_DUPLICATE_NAMES[name] = fullPathFilename
            #scraper.headsUp('Got a duplicate name, name=' + name + ', filename=' + fullPathFilename)

            #Got a duplicate name. This only happens right now in Opponent
            #Replace it if the new GP is greater than the old GP
            if row[gpIndex] > data[key][prefix + 'GP']:
                data[key] = dict(zip(colNames, row))
        data[key] = dict(zip(colNames, row))
    return data
def loadNbaTeamDataFromJsonFile(fullPathFilename, prefix=''):
    #load data into an obj with the teamNames as keys (rather than playerNames)

    data = {}

    f = open(fullPathFilename)
    jsonData = json.load(f)
    f.close()

    colNames = map(lambda x: prefix + x, jsonData['resultSets'][0]['headers'])
    rowData = jsonData['resultSets'][0]['rowSet']
    teamNameIndex = colNames.index(prefix + 'TEAM_NAME')

    for row in rowData:
        key = row[teamNameIndex] #just use the team name for the key
        if key in data:
            scraper.stop('Got a duplicate team, team=' + key + ', filename=' + fullPathFilename)
        data[key] = dict(zip(colNames, row))
    return data
def findApplicableFile(fullPathToDir, date, season):
    #if i dont find a file for date, then check each previous day until i find it
    usedDiffFile = False
    currDate = date
    fullPathFilename = createNbaFullPathFilename(fullPathToDir, date.strftime(DATE_FORMAT))
    while currDate >= FIRST_DATE_OF_SEASON[season] and not os.path.exists(fullPathFilename):
        currDate = currDate - ONE_DAY
        fullPathFilename = createNbaFullPathFilename(fullPathToDir, currDate.strftime(DATE_FORMAT))
        usedDiffFile = True

    #if usedDiffFile:
        #scraper.headsUp('Used different file. date=' + str(date) + ', file=' + filename)
    if os.path.exists(fullPathFilename):
        return fullPathFilename
    return None
def loadNbaDataForDate(fullPathToDir, date, season, prefix=''):
    data = {}
    fullPathFilename = findApplicableFile(fullPathToDir, date, season)
    if fullPathFilename:
        data = loadNbaDataFromJsonFile(fullPathFilename, prefix)
    return data
def loadNbaTeamDataForDate(fullPathToDir, date, season, prefix=''):
    data = {}
    fullPathFilename = findApplicableFile(fullPathToDir, date, season)
    if fullPathFilename:
        data = loadNbaTeamDataFromJsonFile(fullPathFilename, prefix)
    return data

def hasExactMatch(key, nbaData):
    return key in nbaData

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

    nameSp = splitName(name)
    if nameSp[-1] in VALID_SUFFICES:
        return joinName(nameSp[:-1])
    return name
#Not used
def abbreviateFirstName(name):
    nameSp = splitName(name)
    nameSp[0] = nameSp[0][:3]
    return joinName(nameSp)
def findAllPlayersThatMatchFunction(name, team, newData, func):
    playerMatches = []

    newName = func(name)
    if newName and hasExactMatch(createKey(newName, team), newData):
        return [newName]

    for key in newData:
        nbaName, nbaTeam = parseKey(key)
        newNbaName = func(nbaName)
        if newNbaName and createKey(newNbaName, nbaTeam) == createKey(name, team):
            playerMatches.append(nbaName)

    return playerMatches
def findAllPlayerMatches(name, team, nbaData):
    #Note: I'm only using remove periods, but I'm keepng the others in case i need them for other data sources

    #find all combinations of name permutations:
        #-remove/add suffix
        #-remove periods
        #-use first 3 letters of first name
    playerMatches = []

    #frist check name
    playerMatches.extend(findAllPlayersThatMatchFunction(name, team, nbaData, removePeriods))

    #then check reversed name
    reversedName = reverseName(name)
    playerMatches.extend(findAllPlayersThatMatchFunction(reversedName, team, nbaData, removePeriods))

    return playerMatches

def isPlayerInjured(playerData):
    minutes = playerData['Minutes']
    return minutes == 'NA'
def playerDidPlay(playerData):
    minutes = playerData['Minutes']
    return minutes != 'DNP' and minutes != 'NA' and float(minutes) > 0
def playerDidStart(playerData):
    return playerData['Starter'] == 1
def playerPlayedAnyGameUpToDate(data, key, date, season):
    currDate = FIRST_DATE_OF_SEASON[season]
    while currDate < date:
        currDateStr = currDate.strftime(DATE_FORMAT)
        if currDateStr in data:
            if key in data[currDateStr]:
                if playerDidPlay(data[currDateStr][key]):
                    return True
        currDate = currDate + ONE_DAY
    return False
def playerPlayedAnyGameInSeason(data, key, season):
    endDate = LAST_DATE_OF_SEASON[season] + ONE_DAY
    return playerPlayedAnyGameUpToDate(data, key, endDate, season)
def teamPlayedAnyGameUpToDate(data, team, date, season):
    currDate = FIRST_DATE_OF_SEASON[season]
    while currDate < date:
        currDateStr = currDate.strftime(DATE_FORMAT)
        if currDateStr in data:
            for key in data[currDateStr]:
                playerData = data[currDateStr][key]
                playerTeam = getTeam(playerData)
                if playerTeam == team:
                    return True
        currDate = currDate + ONE_DAY
    return False

def reverseName(name):
    #first check if name is in special cases
    if name in MISMATCHED_NAMES_REVERSED:
        return MISMATCHED_NAMES_REVERSED[name]

    nameSp = name.split(' ')
    if nameSp[-1] in VALID_SUFFICES:
        return ' '.join(nameSp[1:]) + ', ' + nameSp[0]
    return nameSp[-1] + ', ' + ' '.join(nameSp[:-1])
def findMatchingKey(key, newData):

    #first, check for exact match
    if hasExactMatch(key, newData):
        return key

    name, team = parseKey(key)

    #then, check for exact match of reverse of the name
    reversedNameKey = createKey(reverseName(name), team)
    if hasExactMatch(reversedNameKey, newData):
        return reversedNameKey

    #then, check if it's a known mismatch name or its a reverse of a known mismatch name
    if name in MISMATCHED_NAMES:
        misMatchedName = MISMATCHED_NAMES[name]
        misMatchedNameKey = createKey(misMatchedName, team)
        if hasExactMatch(misMatchedNameKey, newData):
            return misMatchedNameKey
        reversedMisMatchedNameKey = createKey(reverseName(misMatchedName), team)
        if hasExactMatch(reversedMisMatchedNameKey, newData):
            return reversedMisMatchedNameKey

    #then, check all permutations of the name and its reverse
    #print 'No match found for player=', name, ', searching for similar names...'
    playerMatches = findAllPlayerMatches(name, team, newData)
    numPlayerMatches = len(playerMatches)
    if numPlayerMatches > 1:
        util.stop('Multiple matches found for name=' + name + ', matches=' + ','.join(playerMatches))

    if numPlayerMatches == 1:
        newName = playerMatches[0]
        print '    Found different name: %s -> %s' % (name, newName)
        #add it to the known mismatches
        MISMATCHED_NAMES[name] = newName
        return createKey(newName, team)
    return None
def keyIsKnownToBeMissing(key, dateStr):
    return dateStr in MISSING_KEYS and key in MISSING_KEYS[dateStr]
def createNbaFullPathToParentDir(parentDirName, season=None):
    if season:
        return util.joinDirs(NBA_DIR, parentDirName, season)
    return util.joinDirs(NBA_DIR, parentDirName)
def appendNbaData(parentDirName, data, season, prefix=''):
    print 'Adding NBA Data: %s...' % parentDirName

    fullPathToDir = createNbaFullPathToParentDir(parentDirName, season)

    cnt = 1
    dateStrs = data.keys()
    dateStrs.sort()
    numDates = len(dateStrs)
    for dateStr in dateStrs:
        #print 'On date=%s (%d / %d)' % (dateStr, cnt, numDates)

        #load previous day's nba season-long data
        date = datetime.strptime(dateStr, DATE_FORMAT)
        prevDate = date - ONE_DAY
        nbaData = loadNbaDataForDate(fullPathToDir, prevDate, season, prefix)
        if len(nbaData) > 0:
            #iterate through each player and merge nba data into player data
            for key in data[dateStr]:
                if not keyIsKnownToBeMissing(key, dateStr):
                    newKey = findMatchingKey(key, nbaData)
                    if newKey:
                        data[dateStr][key].update(nbaData[newKey])
                    else:
                        if playerPlayedAnyGameUpToDate(data, key, date, season):
                            TBX_MISSING_PLAYERS.append((dateStr, key))
                            util.stop('Player played and was not found. player=' + key + ', date(rg)=' + dateStr + ', prevDate(nba)=' + prevDate.strftime(DATE_FORMAT))
        cnt += 1
def appendNbaPlayerBios(parentDirName, data, season, prefix=''):
    print 'Adding NBA Player Bios...'

    fullPathToDir = createNbaFullPathToParentDir(parentDirName)

    cnt = 1
    dateStrs = data.keys()
    dateStrs.sort()
    numDates = len(dateStrs)

    fullPathFilename = createNbaFullPathFilename(fullPathToDir, season)
    nbaData = loadNbaDataFromJsonFile(fullPathFilename)

    for dateStr in dateStrs:
        #print 'On date=%s (%d / %d)' % (dateStr, cnt, numDates)

        #iterate through each player and merge nba data into player data
        for key in data[dateStr]:
            if not keyIsKnownToBeMissing(key, dateStr):
                newKey = findMatchingKey(key, nbaData)
                if newKey:
                    data[dateStr][key].update(nbaData[newKey])
                else:
                    if playerPlayedAnyGameInSeason(data, key, season):
                        TBX_MISSING_PLAYERS.append((dateStr, key))
                        util.stop('Player not found. player=' + key + ', date=' + dateStr)
        cnt += 1
def getTeam(playerData):
    return playerData['Team']
def appendNbaTeamData(parentDirName, data, season, prefix=''):
    print 'Adding NBA Team Data: %s...' % parentDirName

    fullPathToDir = createNbaFullPathToParentDir(parentDirName, season)

    cnt = 1
    dateStrs = data.keys()
    dateStrs.sort()
    numDates = len(dateStrs)
    for dateStr in dateStrs:
        #print 'On date=%s (%d / %d)' % (dateStr, cnt, numDates)

        #load previous day's nba season-long data
        date = datetime.strptime(dateStr, DATE_FORMAT)
        prevDate = date - ONE_DAY
        nbaData = loadNbaTeamDataForDate(fullPathToDir, prevDate, season, prefix)
        if len(nbaData) > 0:
            #iterate through each player and merge nba data into player data
            for key in data[dateStr]:
                playerData = data[dateStr][key]
                team = getTeam(playerData)

                nbaTeam = RG_TO_NBA_TEAM_MAP[team]
                if nbaTeam in nbaData:
                    playerData.update(nbaData[nbaTeam])
                else:
                    if teamPlayedAnyGameUpToDate(data, team, date, season):
                        #TBX_MISSING_PLAYERS.append((dateStr, key))
                        util.stop('Team played and was not found. team=' + team + ', date(rg)=' + dateStr + ', prevDate(nba)=' + prevDate.strftime(DATE_FORMAT))
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
                if not isPlayerInjured(playerData):
                    players[playerName] = {
                        'numDaysPlayed': 1 if playerDidPlay(playerData) else 0,
                        'numDaysEligibleToPlay': 1,
                    }
def computeStartedPercent(data):
    print '    Computing StartedPercent...'
    players = {}
    dateStrs = data.keys()
    dateStrs.sort()
    for dateStr in dateStrs:
        for playerName in data[dateStr]:
            playerData = data[dateStr][playerName]
            if playerName in players:
                playerData['StartedPercent'] = float(players[playerName]['numDaysStarted']) / players[playerName]['numDaysEligibleToStart']
                if not isPlayerInjured(playerData):
                    if playerDidStart(playerData):
                        players[playerName]['numDaysStarted'] += 1
                    players[playerName]['numDaysEligibleToStart'] += 1
            else:
                if not isPlayerInjured(playerData):
                    players[playerName] = {
                        'numDaysStarted': 1 if playerDidStart(playerData) else 0,
                        'numDaysEligibleToStart': 1,
                    }
def computeInjured(data):
    print '    Computing Injured...'
    for dateStr in data:
        for playerName in data[dateStr]:
            playerData = data[dateStr][playerName]
            playerData['Injured'] = int(isPlayerInjured(playerData))
def computePrevGameStats(data):
    #todo: improve the below by using an obj to hold the items that i am computing
    print '    Computing PrevGameStats...'
    players = {}
    dateStrs = data.keys()
    dateStrs.sort()
    for dateStr in dateStrs:
        for playerName in data[dateStr]:
            playerData = data[dateStr][playerName]
            if playerName in players:
                playerData['Salary_PrevGame'] = players[playerName]['salary']
                playerData['FantasyPoints_PrevGame'] = players[playerName]['fantasyPoints']
                playerData['Minutes_PrevGame'] = players[playerName]['minutes']
                if not isPlayerInjured(playerData):
                    players[playerName]['fantasyPoints'] = playerData['FantasyPoints']
                    players[playerName]['minutes'] = float(playerData['Minutes']) if playerDidPlay(playerData) else 0.
                    players[playerName]['salary'] = playerData['Salary']
            else:
                if not isPlayerInjured(playerData):
                    players[playerName] = {
                        'salary': playerData['Salary'],
                        'fantasyPoints': playerData['FantasyPoints'],
                        'minutes': float(playerData['Minutes']) if playerDidPlay(playerData) else 0.,
                    }

def addAdditionalFeatures(data):
    print 'Adding additional features...'
    computeAvgFantasyPoints(data)
    computeDaysPlayedPercent(data)
    computeInjured(data)
    computeStartedPercent(data)
    computePrevGameStats(data)

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
X_NAMES.extend(ROTOGURU_FEATURES)

categoryFeatures = []
for category in CATEGORIES_TO_USE:
    dirName = category['dirName']
    features = category['features']
    typee = category['type'] if 'type' in category else None
    prefix = category['prefix'] if 'prefix' in category else ''
    if typee == 'playerBios':
        appendNbaPlayerBios(dirName, data, SEASON, prefix)
    elif typee == 'team':
        appendNbaTeamData(dirName, data, SEASON, prefix)
    else:
        appendNbaData(dirName, data, SEASON, prefix)
    #add features to the front
    categoryFeatures = features + categoryFeatures
X_NAMES.extend(categoryFeatures)

addAdditionalFeatures(data)
X_NAMES.extend(ADDITIONAL_FEATURES)

writeData(createFilename(SEASON), data)

#for a in TBX_DUPLICATE_NAMES:
#    print a, ':', TBX_DUPLICATE_NAMES[a]
