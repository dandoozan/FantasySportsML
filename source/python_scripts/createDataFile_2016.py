from datetime import datetime, timedelta
import scraper
import _util as util

DATA_DIR = 'data'
OUTPUT_FILE = util.createFullPathFilename(DATA_DIR, 'data_2016.csv')
DATE_FORMAT = '%Y-%m-%d'
SEASON_START_DATE = datetime(2016, 10, 25)
ONE_DAY = timedelta(1)
END_DATE = datetime(2016, 11, 6)

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
def parseRotoGrinderRow(row, dateStr):
    #handle pownpct
    #remove the '%' from pownpct (eg. '25.00%' -> 25.00)
    #set to 0 if pownpct is null
    row['RG_pownpct'] = float(row['RG_pownpct'][:-1]) if (row['RG_pownpct'] and row['RG_pownpct'][-1] == '%') else 0.

    #handle deviation, ceil, and floor
    #first, set deviation to 0 if it is null
    if row['RG_deviation'] == None:
        #also verify that ceil and lower both equal null here
        if row['RG_ceil'] != None or row['RG_floor'] != None:
            util.stop('deviation is null, but ceil or floor are not.')
        row['RG_deviation'] = 0.
    else:
        row['RG_deviation'] = float(row['RG_deviation'])
    #now, for ceil and floor, set them to +/- devation if
    #they are null (there are more of these nulls than deviation nulls)
    row['RG_ceil'] = (float(row['RG_points']) + row['RG_deviation']) if row['RG_ceil'] == None else float(row['RG_ceil'])
    row['RG_floor'] = (float(row['RG_points']) - row['RG_deviation']) if row['RG_floor'] == None else float(row['RG_floor'])

    #handle saldiff and rankdiff
    #set salarydiff and rankdiff to 0 if they are null for now, but manually compute
    #it in the future when i get DK salary and rank
    row['RG_saldiff'] = 0 if row['RG_saldiff'] == None else int(row['RG_saldiff'])
    row['RG_rankdiff'] = 0 if row['RG_rankdiff'] == None else int(row['RG_rankdiff'])

    #parse everything else to int/float to make sure
    #they're all in the right format
    intCols = ['RG_line', 'RG_movement']
    floatCols = ['RG_overunder', 'RG_points', 'RG_ppdk',
        'RG_total', 'RG_contr', 'RG_minutes',
        'RG_2', 'RG_15', 'RG_19', 'RG_20', 'RG_28',
        'RG_43', 'RG_50', 'RG_51', 'RG_58']

    for col in intCols:
        try:
            row[col] = int(row[col])
        except Exception as e:
            print col
            util.printObj(row)
            raise(e)

    for col in floatCols:
        try:
            row[col] = float(row[col])
        except Exception as e:
            print col
            util.printObj(row)
            raise(e)

    return row['RG_player_name'].strip().lower(), row

def handleRotoGrinderDuplicates(oldMatch, newMatch):
    oldMatchPoints = float(oldMatch['RG_points'])
    newMatchPoints = float(newMatch['RG_points'])
    if oldMatchPoints > 0 and newMatchPoints == 0:
        return oldMatch
    if newMatchPoints > 0 and oldMatchPoints == 0:
        return newMatch
    util.stop('In handleDuplicates for RotoGrinder, and dont know which to return')

def loadJsonFile(fullPathFilename, keyRenameMap=None, prefix=''):
    jsonData = util.loadJsonFile(fullPathFilename)

    #append prefix to all keys
    for item in jsonData:
        #first, rename the keys
        if keyRenameMap:
            util.renameKeys(keyRenameMap, item)

        #then, add the prefix
        if prefix:
            util.addPrefixToObj(item, prefix)

    return jsonData

def loadDataFromFile(fullPathToDir, parseRowFunction, handleDuplicates, features, dateStr, isJson, keyRenameMap={}, delimiter=',', prefix=''):
    data = {}

    filename = util.createJsonFilename(dateStr) if isJson else util.createCsvFilename(dateStr)
    print '    Loading file: %s...' % filename

    fullPathFilename = util.createFullPathFilename(fullPathToDir, filename)
    if util.fileExists(fullPathFilename):
        rows = loadJsonFile(fullPathFilename, keyRenameMap, prefix) if isJson else util.loadCsvFile(fullPathFilename, keyRenameMap=keyRenameMap, delimiter=delimiter, prefix=prefix)
        for row in rows:
            playerName, playerData = parseRowFunction(row, dateStr)
            if playerName in data:
                if handleDuplicates:
                    util.headsUp('Found duplicate name: ' + playerName)
                    newPlayerData = handleDuplicates(data[playerName], playerData)
                    if newPlayerData:
                        data[playerName] = newPlayerData
                    else:
                        util.stop('Handle duplicates failed to give back new data')
                else:
                    util.stop('Got a duplicate name: ' + playerName)
            #if fullPathFilename == 'data/rawDataFromRotoGrinders/PlayerProjections/2016-10-26.json':
            #    print playerData
            data[playerName] = util.filterObj(features, playerData)
    else:
        util.headsUp('File not found: ' + fullPathFilename)

    return data

def loadDataFromDir(fullPathToDir, parseRowFunction, handleDuplicates, features, isJson, keyRenameMap={}, delimiter=',', prefix=''):
    print '    Loading dir:', fullPathToDir
    data = {}
    currDate = SEASON_START_DATE
    while currDate <= END_DATE:
        currDateStr = util.formatDate(currDate)
        dateData = loadDataFromFile(fullPathToDir, parseRowFunction, handleDuplicates, features, currDateStr, isJson, keyRenameMap, delimiter, prefix)
        if dateData:
            data[currDateStr] = dateData
        else:
            util.headsUp('Data not found for date=' + currDateStr)
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

DATA_SOURCES = [
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
    {
        'name': 'RotoGrinder PlayerProjections',
        'handleDuplicates': handleRotoGrinderDuplicates,
        'features': [
            #Projection
            'RG_ceil',
            'RG_floor',
            'RG_points',
            'RG_ppdk',

            #Vegas Lines
            'RG_line', #chance that this player's team will win, lower number = higher chance
            'RG_movement', #diff between current 'total' and original 'total' when the vegas line opened (this changes by the minute/hour)
            'RG_overunder', #total points scored in the game
            'RG_total', #total points scored by player's team

            #Premium
            #'RG_rank', #rank at fanduel #always null
            'RG_contr', #contrarian rating (projected points / pown%)
            'RG_pownpct', #projected ownership percentage in large field tournaments

            #FD vs DK
            'RG_rankdiff', #diff between FD and DK rank (FD - DK)
            'RG_saldiff', #diff between FD and DK salaries (FD - DK)

            #Other
            'RG_deviation', #i suspect this is stdev of score, but im not sure
            'RG_minutes', #? im not sure if this is projected minutes or actual average or something else

            #inside player obj
            #'RG_hand',

            #inside schedule -> salaries obj
            #figure out what to do with these, they dont fit in the keyRenameMap structure
            #'RG_rank2', 'RG_diff2', 'RG_rank_diff2', 'RG_salary2',
            #'RG_rank20', 'RG_diff20', 'RG_rank_diff20', 'RG_salary20',
            #'RG_salary50',
            #'RG_salary58',
            #'RG_salary28',
            #'RG_salary15', #some
            #'RG_salary19', #some
            #'RG_salary43',
            #maybe other salary#s?

            #im not sure what these numbers are
            'RG_2', 'RG_15', 'RG_19', 'RG_20', 'RG_28', 'RG_43', 'RG_50', 'RG_51', 'RG_58',
        ],
        'fullPathToDir': util.joinDirs(DATA_DIR, 'rawDataFromRotoGrinders', 'PlayerProjections'),
        'isJson': True,
        'keyRenameMap': {
            'pown%': 'pownpct',
            'pt/$/k': 'ppdk',
            'o/u': 'overunder',
        },
        'knownMissingObj': {
            'cory jefferson',
            'louis amundson',
            'derrick favors',
            'kevon looney',
            'tim quarterman',
            'alec burks',
            'davis bertans',
            'nicolas laprovittola',
            'damien inglis',
            'guillermo hernangomez',
            'phil pressey',
            'damian jones',
            'raul neto',
            'livio jean-charles',
            'henry sims',
            'dahntay jones',
            'cameron jones',
            'pat connaughton',
            'chasson randle',
            'grant jerrett',
            'mindaugas kuzminskas',
            'bryn forbes',
            'joel bolomboy',
            'maurice ndour',
            'john holland',
            'jake layman', 'javale mcgee', 'j.p. tokoto', 'joel anthony', 'shabazz napier', 'danny green', 'dejounte murray', 'jonathan holmes', 'marshall plumlee', 'patricio garino', 'elliot williams', 'greg stiemsma', 'markel brown', 'kay felder', 'festus ezeli', 'chris johnson',
            'skal labissiere', 'brian roberts', 'adreian payne', 'tony allen', 'brandan wright', 'darrell arthur', 'nick collison', 'sam dekker', 'jarell martin', 'georges niang', 'tyus jones',
            'lucas nogueira', 'bismack biyombo', 'caris levert', 'thon maker', 'georgios papagiannis', 'josh huestis', 'christian wood', 'henry ellenson', 'udonis haslem', 'wayne ellington', 'mike miller', 'josh mcroberts', 'kevin seraphin', 'jose calderon',
            'nerlens noel', 'ivica zubac', 'a.j. hammons', 'timothe luwawu-cabarrot', 'isaiah whitehead', 'devin harris', 'derrick jones jr.', 'josh richardson', 'malachi richardson', 'steve novak', 'quincy acy', 'jordan mickey', 'patrick beverley', 'treveon graham', 'malik beasley', 'chinanu onuaku', 'arinze onuaku', 'demetrius jackson', 'jordan hill', 'james young', 'john jenkins', 'anthony bennett', 'john lucas iii', 'bruno caboclo', 'bobby brown', 'chandler parsons', 'marcus smart', 'kelly olynyk', 'gary harris', 'michael gbinije', 'alan williams', 'jrue holiday', 'randy foye', 'rakeem christmas', 'darrun hilliard', 'dragan bender', 'kyle wiltjer', 'jakob poeltl', 'frank kaminsky', 'fred vanvleet', 'boban marjanovic',
            'jarnell stokes',
            'dorian finney-smith', 'aaron harrison', 'tony snell', 'cheick diallo',
            'roy hibbert', 'james michael mcadoo', 'lance stephenson', 'paul zipser', 'jeremy lamb', 'sheldon mcclellan', 'damjan rudez', 'michael carter-williams', 'alan anderson', 'anderson varejao', 'brice johnson', 'paul pierce', 'reggie bullock', 'rodney stuckey', 'stephen zimmerman jr.', 'daniel ochefu', 'c.j. wilcox', 'patrick mccaw', 'george hill', 'diamond stone',
            'danuel house', 'derrick williams', 'r.j. hunter', 'boris diaw',
            'anthony tolliver', 'darren collison', 'metta world peace', 'will barton', 'deron williams', 'leandro barbosa', 'nicolas brussino', 'jae crowder', 'marcelo huertas', 'gerald green', 'al horford', 'miles plumlee', 'thomas robinson', 'dirk nowitzki', 'michael beasley',
            'tiago splitter', 'cole aldrich', 'ricky rubio', 'rudy gay', 'chris andersen', 'deandre\' bembry', 'jordan farmar', 'mike scott', 'tony parker', 'anthony morrow', 'john wall', 'jerian grant', 'walter tavares', 'taurean prince', 'james jones',
            'sasha vujacic', 'troy williams', 'chris mccullough', 'greivis vasquez', 'dante cunningham', 'tomas satoransky', 'jeremy lin', 'troy daniels', 'gordon hayward',
            'omri casspi', 'jordan mcrae', 'juancho hernangomez',
            'joel embiid', 'brandon bass', 'ron baker', 'jerami grant', 'timofey mozgov', 'nene hilario',
            'john henson', 'channing frye', 'c.j. watson', 'jeff withey', 'jahlil okafor', 'deyonta davis',
            'bobby portis',
            'jason terry', 'lamarcus aldridge', 'montrezl harrell', 'salah mejri',
            'denzel valentine', 'glenn robinson iii', 'brook lopez', 'rashad vaughn', 'cristiano felicio',
            'aaron brooks', 'joffrey lauvergne',
        },
        'nameMap': {
            'maurice harkless': 'moe harkless',
            'james michael mcadoo': 'james mcadoo',
            'lou williams': 'louis williams',
            'joe young': 'joseph young',
            'juancho hernangomez': 'juan hernangomez',
            'cristiano felicio': 'cristiano da silva felicio',
            'deandre\' bembry': 'deandre bembry',
            'wade baldwin iv': 'wade baldwin',
            'larry nance jr.': 'larry nance',
            'stephen zimmerman jr.': 'stephen zimmerman',
            'glenn robinson iii': 'glenn robinson',
            'kelly oubre jr.': 'kelly oubre',
        },
        'parseRowFunction': parseRotoGrinderRow,
        'prefix': 'RG_',
    },
]

#load fanduel data
data = None

for dataSource in DATA_SOURCES:
    print 'Loading data for %s...' % dataSource['name']

    containsY = util.getObjValue(dataSource, 'containsY', False)
    delimiter = util.getObjValue(dataSource, 'delimiter', ',')
    features = dataSource['features']
    fullPathToDir = dataSource['fullPathToDir']
    handleDuplicates = util.getObjValue(dataSource, 'handleDuplicates', None)
    isJson = util.getObjValue(dataSource, 'isJson', False)
    keyRenameMap = util.getObjValue(dataSource, 'keyRenameMap', {})
    knownMissingObj = util.getObjValue(dataSource, 'knownMissingObj', {})
    nameMap = util.getObjValue(dataSource, 'nameMap', {})
    parseRowFunction = dataSource['parseRowFunction']
    prefix = util.getObjValue(dataSource, 'prefix', '')

    newData = loadDataFromDir(fullPathToDir, parseRowFunction, handleDuplicates, features, isJson, keyRenameMap, delimiter, prefix)
    X_NAMES.extend(features)

    if data == None:
        data = newData
    else:
        mergeData(data, newData, nameMap, knownMissingObj, containsY)

writeData(OUTPUT_FILE, data)

print 'Missing players:'
util.printObj(TBX_MISSING_PLAYERS)
