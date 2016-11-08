from datetime import datetime, timedelta
import scraper
import _util as util

DATA_DIR = 'data'
OUTPUT_FILE = util.createFullPathFilename(DATA_DIR, 'data_2016.csv')
DATE_FORMAT = '%Y-%m-%d'
SEASON_START_DATE = datetime(2016, 10, 25)
TODAY = datetime.today()
ONE_DAY = timedelta(1)
YESTERDAY = TODAY - ONE_DAY

Y_NAME = 'FantasyPoints'
X_NAMES = []

TBX_MISSING_PLAYERS = {}

def parseFanDuelRow(row, dateStr):
    #add Name, which is a join of firstname and lastname
    row['Name'] = ' '.join([row['First Name'], row['Last Name']])

    #add date to row
    row['Date'] = dateStr

    #add IsHome
    row['Home'] = 'Home' if (row['Game'].split('@')[1] == row['Team']) else 'Away'

    #set '' to 'None' in injury cols
    if row['InjuryIndicator'] == '':
        row['InjuryIndicator'] = 'None'
    if row['InjuryDetails'] == '':
        row['InjuryDetails'] = 'None'

    playerName = row['Name'].lower()
    return playerName, row
def parseRotoGuruRow(row, dateStr):
    #convert to float just to make sure all values can be parsed to floats
    row['FantasyPoints'] = float(row['FantasyPoints'])

    #reverse name bc it's in format: "lastname, firstname"
    playerName = row['Name'].split(', ')
    playerName.reverse()
    playerName = ' '.join(playerName).lower()

    return playerName, row
def parseNumberFireRow(row, dateStr):
    return row['NF_Name'].lower(), row
def loadDataFromFile(fullPathFilename, parseRowFunction, features, dateStr, keyRenameMap={}, delimiter=',', prefix=''):
    print '    Loading file: %s...' % fullPathFilename

    data = {}

    csvData = util.loadCsvFile(fullPathFilename, keyRenameMap=keyRenameMap, delimiter=delimiter, prefix=prefix)
    for row in csvData:
        playerName, playerData = parseRowFunction(row, dateStr)
        if playerName in data:
            util.stop('Got a duplicate name: ' + playerName)
        data[playerName] = util.filterObj(features, playerData)
    return data
def loadDataFromDir(fullPathToDir, parseRowFunction, features, keyRenameMap={}, delimiter=',', prefix=''):
    data = {}
    currDate = SEASON_START_DATE
    while currDate <= YESTERDAY:
        currDateStr = util.formatDate(currDate)
        fullPathFilename = util.createFullPathFilename(fullPathToDir, util.createCsvFilename(currDateStr))
        if util.fileExists(fullPathFilename):
            dateData = loadDataFromFile(fullPathFilename, parseRowFunction, features, currDateStr, keyRenameMap, delimiter, prefix)
            data[currDateStr] = dateData
        else:
            util.headsUp('File not found for date=' + currDateStr)
        currDate = currDate + ONE_DAY

    return data

def hasExactMatch(key, obj):
    return key in obj
def removePeriods(name):
    return name.replace('.', '')
def removeSuffix(name):
    validSuffices = { 'jr.', 'iv', 'iii' }
    nameSp = name.split(' ')
    if nameSp[-1] in validSuffices:
        return ' '.join(nameSp[:-1])
    return name
def findAllPlayersThatMatchFunction(name, newData, func):
    playerMatches = []

    newName = func(name)
    if newName and hasExactMatch(newName, newData):
        return [newName]

    for newDataName in newData:
        newName = func(newDataName)
        if newName == name:
            playerMatches.append(newName)

    return playerMatches
def findAllPlayerMatches(name, newData):
    playerMatches = []
    playerMatches.extend(findAllPlayersThatMatchFunction(name, newData, removePeriods))
    playerMatches.extend(findAllPlayersThatMatchFunction(name, newData, removeSuffix))
    return playerMatches
def findMatchingName(name, newData, nameMap={}):

    #first, check for exact match
    if hasExactMatch(name, newData):
        return name

    #then, check if it's a known mismatch name or its a reverse of a known mismatch name
    if name in nameMap:
        misMatchedName = nameMap[name]
        if hasExactMatch(misMatchedName, newData):
            return misMatchedName

    #then, check all permutations of the name and its reverse
    #print 'No match found for player=', name, ', searching for similar names...'
    playerMatches = findAllPlayerMatches(name, newData)
    numPlayerMatches = len(playerMatches)
    if numPlayerMatches > 1:
        util.stop('Multiple matches found for name=' + name + ', matches=' + ','.join(playerMatches))

    if numPlayerMatches == 1:
        newName = playerMatches[0]
        print '    Found different name: %s -> %s' % (name, newName)
        #add it to the known mismatches
        nameMap[name] = newName
        return newName
    return None
def playerIsKnownToBeMissing(dateStr, name, knownMissingObj):
    return (dateStr in knownMissingObj and name in knownMissingObj[dateStr]) or name in knownMissingObj
def mergeData(obj1, obj2, nameMap, knownMissingObj, containsY):
    print 'Merging data...'
    dateStrs = obj1.keys()
    dateStrs.sort()
    for dateStr in dateStrs:
        if dateStr in obj2:
            for name in obj1[dateStr]:
                obj2Name = findMatchingName(name, obj2[dateStr], nameMap)
                if obj2Name and obj2Name in obj2[dateStr]:
                    obj1[dateStr][name].update(obj2[dateStr][obj2Name])
                else:
                    if not playerIsKnownToBeMissing(dateStr, name, knownMissingObj):
                        #tbx
                        if dateStr in TBX_MISSING_PLAYERS:
                            TBX_MISSING_PLAYERS[dateStr].append(name)
                        else:
                            TBX_MISSING_PLAYERS[dateStr] = [name]

                        util.headsUp('Name not found in obj2, date=' + dateStr + ', name=' + name)
                    else:
                        #util.headsUp('Found known missing player, date=' + dateStr + ', name=' + name)
                        if containsY:
                            #set FantasyPoints to 0 for these people who are known to be missing
                            obj1[dateStr][name].update({ 'FantasyPoints': 0 })

        else:
            util.headsUp('Date not found in obj2, date=' + dateStr)

def writeData(fullPathFilename, data):
    colNames = [Y_NAME]
    colNames.extend(filter(lambda x: x != Y_NAME, X_NAMES))
    dataArr = []

    dateStrs = data.keys()
    dateStrs.sort() #sort by date
    for dateStr in dateStrs:
        names = data[dateStr].keys()
        names.sort() #sort by name
        for name in names:
            dataArr.append(data[dateStr][name])

    util.writeCsvFile(colNames, dataArr, fullPathFilename)

#============= MAIN =============

EXTRA_DATA_SOURCES = [
    {
        'name': 'FanDuel',
        'features': ['Date', 'Name','Position','FPPG','GamesPlayed','Salary','Home','Team','Opponent','InjuryIndicator','InjuryDetails'],
        'fullPathToDir': util.joinDirs(DATA_DIR, 'rawDataFromFanDuel', 'Players_manuallyDownloaded'),
        'keyRenameMap': {
            'Played': 'GamesPlayed',
            'Injury Indicator': 'InjuryIndicator',
            'Injury Details': 'InjuryDetails',
        },
        'parseRowFunction': parseFanDuelRow,
    },
    {
        'name': 'RotoGuru',
        'containsY': True,
        'delimiter': ';',
        'features': ['FantasyPoints'],
        'fullPathToDir': util.joinDirs(DATA_DIR, 'rawDataFromRotoGuru'),
        'keyRenameMap': { 'FD Pts': 'FantasyPoints' },
        'knownMissingObj': {
            '2016-10-25': {
                'cory jefferson', #he didn't play according to stats.nba.com
                'louis amundson', #he didn't play according to stats.nba.com
                'damien inglis', #he didn't play according to stats.nba.com
                'phil pressey', #he didn't play according to stats.nba.com
                'greg stiemsma', #he didn't play according to stats.nba.com
                'patricio garino', #this guy isn't even on nba.com
                'chasson randle', #this guy isn't even on nba.com
                'j.p. tokoto', #this guy isn't even on nba.com
                'livio jean-charles', #this guy isn't even on nba.com
                'markel brown', #he didn't play according to stats.nba.com
                'joel anthony', #he didn't play according to stats.nba.com
                'grant jerrett', #he didn't play according to stats.nba.com
                'henry sims', #he didn't play according to stats.nba.com
                'chris johnson', #he didn't play according to stats.nba.com
                'dahntay jones', #he didn't play according to stats.nba.com
                'elliot williams', #he didn't play according to stats.nba.com
                'john holland', #he didn't play according to stats.nba.com
                'cameron jones', #this guy isn't even on nba.com
                'jonathan holmes', #this guy isn't even on nba.com
            },'2016-10-31': {
                'taurean prince', #he didn't play according to stats.nba.com
                'walter tavares', #he didn't play according to stats.nba.com
            },
            '2016-11-01': {
                'jerami grant', #he didn't play according to stats.nba.com
            },
            '2016-11-02': {
                'taurean prince', #he actually did play, but only for 2 min and didn't accumulate any stats
                'walter tavares', #he didn't play according to stats.nba.com
            },
            '2016-11-04': {
                'taurean prince', #he didn't play according to stats.nba.com
                'walter tavares', #he didn't play according to stats.nba.com
                'joel bolomboy', #he didn't play according to stats.nba.com
            },
            '2016-11-05': {
                'taurean prince', #he actually did play, but only for 2 min and didn't accumulate any stats
                'walter tavares', #he didn't play according to stats.nba.com
            },
        },
        'nameMap': {
            'luc richard mbah a moute': 'luc mbah a moute',
            'derrick jones jr.': 'derrick jones',
            'deandre\' bembry': 'deandre bembry',
            'juancho hernangomez': 'juan hernangomez',
            'lou williams': 'louis williams',
            'timothe luwawu-cabarrot': 'timothe luwawu',
            'ish smith': 'ishmael smith',
            'joe young': 'joseph young',
            'maurice ndour': 'maurice n\'dour',
            'j.j. barea': 'jose barea',
            'wesley matthews': 'wes matthews',
            'kelly oubre jr.': 'kelly oubre',
            'wade baldwin iv': 'wade baldwin',
            'larry nance jr.': 'larry nance',
            'stephen zimmerman jr.': 'stephen zimmerman',
            'john lucas iii': 'john lucas',
        },
        'parseRowFunction': parseRotoGuruRow,
    },
    {
        'name': 'NumberFire',
        'features': ['NF_Min', 'NF_Pts', 'NF_Reb', 'NF_Ast', 'NF_Stl', 'NF_Blk', 'NF_TO', 'NF_FP'],
        'fullPathToDir': util.joinDirs(DATA_DIR, 'rawDataFromNumberFire'),
        'knownMissingObj': {
            'cory jefferson', #he didn't play according to stats.nba.com
            'tim quarterman', #he didn't play according to stats.nba.com
            'davis bertans',
            'nicolas laprovittola',
            'damien inglis',
            'phil pressey',
            'deandre liggins',
            'cameron jones',
            'chasson randle',
            'grant jerrett',
            'ron baker',
            'mindaugas kuzminskas',
            'bryn forbes',
            'john holland',
            'j.p. tokoto',
            'jonathan holmes',
            'marshall plumlee',
            'patricio garino',
            'greg stiemsma',
            'rodney mcgruder',
            'metta world peace',
            'georgios papagiannis',
            'josh huestis',
            'kevin seraphin',
            'nerlens noel',
            'nicolas brussino',
            'timothe luwawu-cabarrot',
            'derrick jones jr.',
            'chris mccullough',
            'treveon graham',
            'chinanu onuaku',
            'demetrius jackson',
            'troy williams',
            'john jenkins',
            'john lucas iii',
            'bobby brown',
            'michael gbinije',
            'rakeem christmas',
            'beno udrih',
            'kyle wiltjer',
            'fred vanvleet',
            'dorian finney-smith',
            'sheldon mcclellan',
            'daniel ochefu',
            'walter tavares',
            'paul zipser',
            'dejounte murray',
            'danuel house',
            'darren collison',
            'r.j. hunter',
            'alec burks',
            'jeremy lamb',
            'mike scott',
            'bismack biyombo',
            'frank kaminsky',
            'michael carter-williams',
        },
        'nameMap': {
            'patty mills': 'patrick mills',
            'j.j. barea': 'jose juan barea',
            'lou williams': 'louis williams',
            'joe young': 'joseph young',
            'ish smith': 'ishmael smith',
            'juancho hernangomez': 'juan hernangomez',
            'luc richard mbah a moute': 'luc mbah a moute',
            'deandre\' bembry': 'deandre bembry',
            'kelly oubre jr.': 'kelly oubre',
        },
        'parseRowFunction': parseNumberFireRow,
        'prefix': 'NF_',
    },
]

#load fanduel data
data = None

for dataSource in EXTRA_DATA_SOURCES:
    print 'Loading data for %s...' % dataSource['name']

    containsY = util.getObjValue(dataSource, 'containsY', False)
    delimiter = util.getObjValue(dataSource, 'delimiter', ',')
    features = dataSource['features']
    fullPathToDir = dataSource['fullPathToDir']
    keyRenameMap = util.getObjValue(dataSource, 'keyRenameMap', {})
    knownMissingObj = util.getObjValue(dataSource, 'knownMissingObj', {})
    nameMap = util.getObjValue(dataSource, 'nameMap', {})
    parseRowFunction = dataSource['parseRowFunction']
    prefix = util.getObjValue(dataSource, 'prefix', '')

    newData = loadDataFromDir(fullPathToDir, parseRowFunction, features, keyRenameMap, delimiter, prefix)
    X_NAMES.extend(features)

    if data == None:
        data = newData
    else:
        mergeData(data, newData, nameMap, knownMissingObj, containsY)

writeData(OUTPUT_FILE, data)

print 'Missing players:'
util.printObj(TBX_MISSING_PLAYERS)
