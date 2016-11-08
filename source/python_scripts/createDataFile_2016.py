from datetime import datetime, timedelta
import scraper
import _util as util

DATA_DIR = 'data'
ROTOGURU_FILE = util.createFullPathFilename(util.joinDirs(DATA_DIR, 'rawDataFromRotoGuru'), 'fd_2016.txt')
FANDUEL_DIR = util.joinDirs(DATA_DIR, 'rawDataFromFanDuel', 'Players_manuallyDownloaded')
NUMBERFIRE_DIR = util.joinDirs(DATA_DIR, 'rawDataFromNumberFire')
OUTPUT_FILE = util.createFullPathFilename(DATA_DIR, 'data_2016.csv')
DATE_FORMAT = '%Y-%m-%d'
SEASON_START_DATE = datetime(2016, 10, 25)
TODAY = datetime.today()
ONE_DAY = timedelta(1)
YESTERDAY = TODAY - ONE_DAY

FANDUEL_FEATURES = ['Date', 'Name','Position','FPPG','GamesPlayed',
        'Salary','Home','Team','Opponent','InjuryIndicator','InjuryDetails']
ROTOGURU_FEATURES = ['FantasyPoints']
NUMBERFIRE_FEATURES = ['NF_Min', 'NF_Pts', 'NF_Reb', 'NF_Ast', 'NF_Stl', 'NF_Blk', 'NF_TO', 'NF_FP']

Y_NAME = 'FantasyPoints'
X_NAMES = []

FANDUEL_TO_ROTOGURU_NAME_MAP = {
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
}
FANDUEL_TO_NUMBERFIRE_NAME_MAP = {
    'patty mills': 'patrick mills',
    'j.j. barea': 'jose juan barea',
    'lou williams': 'louis williams',
    'joe young': 'joseph young',
    'ish smith': 'ishmael smith',
    'juancho hernangomez': 'juan hernangomez',
    'luc richard mbah a moute': 'luc mbah a moute',
    'deandre\' bembry': 'deandre bembry',
    'kelly oubre jr.': 'kelly oubre',
}

PLAYERS_MISSING_FROM_ROTOGURU = {
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
}

PLAYERS_MISSING_FROM_NUMBERFIRE = {
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
}


TBX_MISSING_PLAYERS = {}

def loadFanDuelDataFromFile(fullPathFilename, dateStr, keyRenameMap):
    print '    Loading FanDuel file: ', fullPathFilename

    data = {}

    dataArr = util.loadCsvFile(fullPathFilename, keyRenameMap=keyRenameMap)
    for playerData in dataArr:
        #add Name
        #get player name as a join of firstname and lastname
        playerName = ' '.join([playerData['First Name'], playerData['Last Name']])
        playerData['Name'] = playerName

        #add date to playerData
        playerData['Date'] = dateStr

        #add IsHome
        playerData['Home'] = 'Home' if (playerData['Game'].split('@')[1] == playerData['Team']) else 'Away'

        #set '' to 'None' in injury cols
        if playerData['InjuryIndicator'] == '':
            playerData['InjuryIndicator'] = 'None'
        if playerData['InjuryDetails'] == '':
            playerData['InjuryDetails'] = 'None'

        playerName = playerData['Name'].lower()
        if playerName in data:
            util.stop('Got a duplicate name in fanduel data, name=' + playerName)

        data[playerName] = util.filterObj(FANDUEL_FEATURES, playerData)

    return data
def loadFanDuelData(fullPathToDir, startDate, endDate):
    print 'Loading FanDuel data...'

    keyRenameMap = {
        'Played': 'GamesPlayed',
        'Injury Indicator': 'InjuryIndicator',
        'Injury Details': 'InjuryDetails',
    }

    data = {}
    currDate = startDate
    while currDate <= endDate:
        currDateStr = currDate.strftime(DATE_FORMAT)
        fullPathFilename = util.createFullPathFilename(fullPathToDir, util.createCsvFilename(currDateStr))
        if util.fileExists(fullPathFilename):
            dateData = loadFanDuelDataFromFile(fullPathFilename, currDateStr, keyRenameMap)
            data[currDateStr] = dateData
        else:
            util.stop('File not found for date=' + currDateStr)
        currDate = currDate + ONE_DAY

    return data

def loadDataFromRotoGuru(fullPathFilename):
    print 'Loading RotoGuru data...'

    keyRenameMap = {
        'FD Pts': 'FantasyPoints',
    }

    data = {}

    dataArr = util.loadCsvFile(fullPathFilename, keyRenameMap=keyRenameMap, delimiter=';')
    for playerData in dataArr:

        #reverse name bc it's in format: "lastname, firstname"
        playerName = playerData['Name'].split(', ')
        playerName.reverse()
        playerData['Name'] = ' '.join(playerName)

        #convert date to right format ("20161025" -> "2016-10-25")
        playerData['Date'] = datetime.strptime(playerData['Date'], '%Y%m%d').strftime(DATE_FORMAT)

        #convert to float just to make sure all values can be parsed to floats
        playerData['FantasyPoints'] = float(playerData['FantasyPoints'])

        #add playerData to data
        dateStr = playerData['Date']
        playerName = playerData['Name'].lower()

        if dateStr not in data:
            data[dateStr] = {}

        if playerName in data[dateStr]:
            util.stop('Got a duplicate name in rotoguru data, name=' + playerName)
        data[dateStr][playerName] = util.filterObj(ROTOGURU_FEATURES, playerData)

    return data

def loadNumberFireDataFromFile(fullPathFilename, dateStr, prefix):
    print '    Loading NumberFire file: ', fullPathFilename

    data = {}

    dataArr = util.loadCsvFile(fullPathFilename, prefix=prefix)
    for playerData in dataArr:
        playerName = playerData[prefix + 'Name'].lower()
        if playerName in data:
            util.stop('Got a duplicate name in numberfire data, name=' + playerName)

        data[playerName] = util.filterObj(NUMBERFIRE_FEATURES, playerData)

    return data
def loadNumberFireData(fullPathToDir, startDate, endDate, prefix):
    print 'Loading NumberFire data...'

    data = {}
    currDate = startDate
    while currDate <= endDate:
        currDateStr = currDate.strftime(DATE_FORMAT)
        fullPathFilename = util.createFullPathFilename(fullPathToDir, util.createCsvFilename(currDateStr))
        if util.fileExists(fullPathFilename):
            dateData = loadNumberFireDataFromFile(fullPathFilename, currDateStr, prefix)
            data[currDateStr] = dateData
        else:
            util.stop('NumberFire file not found for date=' + currDateStr)
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
def mergeData(obj1, obj2, nameMap={}, knownMissingObj={}, setFP=False):
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
                        if setFP:
                            #set FantasyPoints to 0 for these people who are known to be missing
                            obj1[dateStr][name].update({ 'FantasyPoints': 0 })

        else:
            util.headsUp('Date not found in obj2, date=' + dateStr)

def writeData(filename, data):
    print 'Writing data to: ' + filename + '...'

    f = open(filename, 'w')

    #print col names
    f.write(Y_NAME + ',')
    f.write(','.join(filter(lambda x: x != Y_NAME, X_NAMES)) + '\n')

    dates = data.keys()
    dates.sort() #sort by date
    for date in dates:
        names = data[date].keys()
        names.sort() #sort by name
        for name in names:
            #write y
            f.write(str(util.getObjValue(data[date][name], Y_NAME, '')) + ',')

            #write first x

            #write the rest
            for i in xrange(0, len(X_NAMES)):
                colName = X_NAMES[i]
                if colName != Y_NAME:
                    if i > 0:
                        f.write(',')
                    f.write(str(util.getObjValue(data[date][name], colName, '')))

            f.write('\n')
    f.close()

#============= MAIN =============

#load fanduel data
data = loadFanDuelData(FANDUEL_DIR, SEASON_START_DATE, YESTERDAY)
X_NAMES.extend(FANDUEL_FEATURES)

#load rotoguru data
rgData = loadDataFromRotoGuru(ROTOGURU_FILE)
mergeData(data, rgData, nameMap=FANDUEL_TO_ROTOGURU_NAME_MAP, knownMissingObj=PLAYERS_MISSING_FROM_ROTOGURU, setFP=True)
X_NAMES.extend(ROTOGURU_FEATURES)

#load numberfire data
nfData = loadNumberFireData(NUMBERFIRE_DIR, SEASON_START_DATE, YESTERDAY, 'NF_')
mergeData(data, nfData, nameMap=FANDUEL_TO_NUMBERFIRE_NAME_MAP, knownMissingObj=PLAYERS_MISSING_FROM_NUMBERFIRE)
X_NAMES.extend(NUMBERFIRE_FEATURES)

writeData(OUTPUT_FILE, data)

print 'Missing players:'
util.printObj(TBX_MISSING_PLAYERS)
