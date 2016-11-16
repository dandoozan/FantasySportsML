from datetime import datetime, timedelta
import scraper
import _util as util

DATA_DIR = 'data'
OUTPUT_FILE = util.createFullPathFilename(DATA_DIR, 'data_2016.csv')
DATE_FORMAT = '%Y-%m-%d'
SEASON_START_DATE = datetime(2016, 10, 25)
ONE_DAY = timedelta(1)
END_DATE = datetime(2016, 11, 11)

Y_NAME = 'FantasyPoints'
X_NAMES = []

KNOWN_ALIASES = {
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
    'patty mills': 'patrick mills',
    'j.j. barea': ['jose juan barea', 'jose barea'],
    'ish smith': 'ishmael smith',
    'luc richard mbah a moute': 'luc mbah a moute',
    'derrick jones jr.': 'derrick jones',
    'timothe luwawu-cabarrot': 'timothe luwawu',
    'maurice ndour': 'maurice n\'dour',
    'wesley matthews': 'wes matthews',
    'john lucas iii': 'john lucas',

    #nba
    'nene hilario': 'nene',
    'walter tavares': 'edy tavares',
    'guillermo hernangomez': 'willy hernangomez',
    'j.r. smith': 'jr smith',
    'c.j. mccollum': 'cj mccollum',
    'c.j. miles': 'cj miles',
    't.j. warren': 'tj warren',
    'p.j. tucker': 'pj tucker',
    'k.j. mcdaniels': 'kj mcdaniels',
    't.j. mcconnell': 'tj mcconnell',
    'j.j. redick': 'jj redick',
    'a.j. hammons': 'aj hammons',
    'c.j. wilcox': 'cj wilcox',
    'c.j. watson': 'cj watson',

    #RotoGrinderStartingLineups
    'tim hardaway jr.': 'tim hardaway',

    #from createDataFile.py, investigate these
    #'amare stoudemire': 'amar\'e stoudemire',
    #'louis amundson': 'lou amundson',
    #'maurice williams': 'mo williams',
    #'chuck hayes': 'charles hayes',
}
TEAM_KNOWN_ALIASES = {
    'ATL': ['atl', 'atlanta hawks'],
    'CHI': ['chi', 'chicago bulls'],
    'CLE': ['cle', 'cleveland cavaliers'],
    'BOS': ['bos', 'boston celtics'],
    'BKN': ['bkn', 'brooklyn nets'],
    'CHA': ['cha', 'charlotte hornets'],
    'DAL': ['dal', 'dallas mavericks'],
    'DEN': ['den', 'denver nuggets'],
    'DET': ['det', 'detroit pistons'],
    'GS': ['gsw', 'golden state warriors'],
    'HOU': ['hou', 'houston rockets'],
    'IND': ['ind', 'indiana pacers'],
    'LAC': ['lac', 'los angeles clippers', 'la clippers'],
    'LAL': ['lal', 'los angeles lakers'],
    'MEM': ['mem', 'memphis grizzlies'],
    'MIA': ['mia', 'miami heat'],
    'MIL': ['mil', 'milwaukee bucks'],
    'MIN': ['min', 'minnesota timberwolves'],
    'NO': ['nop', 'new orleans pelicans'],
    'NY': ['nyk', 'new york knicks'],
    'OKC': ['okc', 'oklahoma city thunder'],
    'ORL': ['orl', 'orlando magic'],
    'PHI': ['phi', 'philadelphia 76ers'],
    'PHO': ['pho', 'phoenix suns'],
    'POR': ['por', 'portland trail blazers'],
    'SAC': ['sac', 'sacramento kings'],
    'SA': ['sas', 'san antonio spurs'],
    'TOR': ['tor', 'toronto raptors'],
    'UTA': ['uta', 'utah jazz'],
    'WAS': ['was', 'washington wizards'],
}

PLAYERS_WHO_DID_NOT_PLAY_UP_TO = {
    '2016-10-26': {
        'aaron gordon',
        'al horford',
        'al jefferson',
        'alex abrines',
        'alex len',
        'alexis ajinca',
        'amir johnson',
        'andre drummond',
        'andre roberson',
        'andrew bogut',
        'andrew harrison',
        'andrew wiggins',
        'anthony davis',
        'anthony tolliver',
        'aron baynes',
        'arron afflalo',
        'avery bradley',
        'ben mclemore',
        'beno udrih',
        'boban marjanovic',
        'bojan bogdanovic',
        'brandon ingram',
        'brandon knight',
        'brandon rush',
        'brook lopez',
        'buddy hield',
        'c.j. miles',
        'chris mccullough',
        'clint capela',
        'cody zeller',
        'cole aldrich',
        'corey brewer',
        'cory joseph',
        'd\'angelo russell',
        'd.j. augustin',
        'danilo gallinari',
        'dante cunningham',
        'dario saric',
        'demar derozan',
        'demarcus cousins',
        'demarre carroll',
        'deron williams',
        'devin booker',
        'deyonta davis',
        'dion waiters',
        'dirk nowitzki',
        'domantas sabonis',
        'dorian finney-smith',
        'dragan bender',
        'dwight powell',
        'e\'twaun moore',
        'elfrid payton',
        'emmanuel mudiay',
        'enes kanter',
        'eric bledsoe',
        'eric gordon',
        'ersan ilyasova',
        'evan fournier',
        'garrett temple',
        'gerald green',
        'gerald henderson',
        'giannis antetokounmpo',
        'glenn robinson iii',
        'goran dragic',
        'gorgui dieng',
        'greg monroe',
        'greivis vasquez',
        'harrison barnes',
        'hassan whiteside',
        'henry ellenson',
        'hollis thompson',
        'isaiah thomas',
        'isaiah whitehead',
        'ish smith',
        'j.j. barea',
        'jabari parker',
        'jae crowder',
        'jahlil okafor',
        'jakob poeltl',
        'jamal murray',
        'jameer nelson',
        'james ennis',
        'james harden',
        'james johnson',
        'jamychal green',
        'jared dudley',
        'jason terry',
        'jaylen brown',
        'jeff green',
        'jeff teague',
        'jerami grant',
        'jeremy lamb',
        'jeremy lin',
        'joe harris',
        'joe young',
        'joel embiid',
        'john henson',
        'jon leuer',
        'jonas jerebko',
        'jonas valanciunas',
        'jordan clarkson',
        'juancho hernangomez',
        'julius randle',
        'justin anderson',
        'justin hamilton',
        'justise winslow',
        'jusuf nurkic',
        'k.j. mcdaniels',
        'karl-anthony towns',
        'kemba walker',
        'kenneth faried',
        'kentavious caldwell-pope',
        'kosta koufos',
        'kris dunn',
        'kyle lowry',
        'kyle singler',
        'lance stephenson',
        'langston galloway',
        'larry nance jr.',
        'lavoy allen',
        'leandro barbosa',
        'lou williams',
        'luis scola',
        'luke babbitt',
        'luol deng',
        'malachi richardson',
        'malcolm brogdon',
        'marc gasol',
        'marcelo huertas',
        'marco belinelli',
        'marcus morris',
        'mario hezonja',
        'marquese chriss',
        'marvin williams',
        'matt barnes',
        'matthew dellavedova',
        'metta world peace',
        'michael beasley',
        'michael gbinije',
        'michael kidd-gilchrist',
        'mike conley',
        'miles plumlee',
        'mirza teletovic',
        'monta ellis',
        'myles turner',
        'nemanja bjelica',
        'nene hilario',
        'nick young',
        'nicolas batum',
        'nicolas brussino',
        'nik stauskas',
        'nikola jokic',
        'nikola vucevic',
        'norman powell',
        'omer asik',
        'omri casspi',
        'p.j. tucker',
        'pascal siakam',
        'patrick patterson',
        'paul george',
        'quincy acy',
        'ramon sessions',
        'rashad vaughn',
        'richaun holmes',
        'ricky rubio',
        'robert covington',
        'rodney mcgruder',
        'rodney stuckey',
        'rondae hollis-jefferson',
        'roy hibbert',
        'rudy gay',
        'russell westbrook',
        'ryan anderson',
        'sam dekker',
        'sean kilpatrick',
        'semaj christon',
        'serge ibaka',
        'sergio rodriguez',
        'seth curry',
        'shabazz muhammad',
        'solomon hill',
        'spencer hawes',
        'stanley johnson',
        'steven adams',
        't.j. mcconnell',
        't.j. warren',
        'tarik black',
        'terrence jones',
        'terrence ross',
        'terry rozier',
        'thaddeus young',
        'tim frazier',
        'timofey mozgov',
        'timothe luwawu-cabarrot',
        'tobias harris',
        'trevor ariza',
        'trevor booker',
        'ty lawson',
        'tyler ennis',
        'tyler johnson',
        'tyler ulis',
        'tyler zeller',
        'tyson chandler',
        'victor oladipo',
        'vince carter',
        'wade baldwin iv',
        'wesley matthews',
        'will barton',
        'willie cauley-stein',
        'willie reed',
        'wilson chandler',
        'zach lavine',
        'zach randolph',
    },
    '2016-10-27': {
        'andrew nicholson',
        'austin rivers',
        'blake griffin',
        'bradley beal',
        'brandon bass',
        'chris paul',
        'cristiano felicio',
        'daniel ochefu',
        'deandre jordan',
        'deandre\' bembry',
        'dennis schroder',
        'diamond stone',
        'doug mcdermott',
        'dwight howard',
        'dwyane wade',
        'isaiah canaan',
        'j.j. redick',
        'jamal crawford',
        'jason smith',
        'jimmy butler',
        'john wall',
        'kelly oubre jr.',
        'kent bazemore',
        'kris humphries',
        'kyle korver',
        'luc richard mbah a moute',
        'malcolm delaney',
        'marcin gortat',
        'marcus thornton',
        'markieff morris',
        'marreese speights',
        'michael carter-williams',
        'mike muscala',
        'nikola mirotic',
        'otto porter',
        'paul millsap',
        'rajon rondo',
        'raymond felton',
        'robin lopez',
        'shabazz napier',
        'sheldon mcclellan',
        'taj gibson',
        'taurean prince',
        'thabo sefolosha',
        'tim hardaway jr.',
        'tomas satoransky',
        'trey burke',
        'walter tavares',
        'wesley johnson',
    },
    '2016-10-28': {
        'a.j. hammons',
        'bismack biyombo',
        'bobby brown',
        'c.j. watson',
        'c.j. wilcox',
        'darrun hilliard',
        'derrick favors',
        'georges niang',
        'joel bolomboy',
        'joffrey lauvergne',
        'kevin seraphin',
        'kyle wiltjer',
        'montrezl harrell',
        'raul neto',
        'salah mejri',
        'stephen zimmerman jr.',
        'thomas robinson',
    },
    '2016-10-29': {
        'anthony bennett',
        'bobby portis',
        'cheick diallo',
        'dejounte murray',
        'denzel valentine',
        'frank kaminsky',
        'jarell martin',
        'jordan mickey',
        'kay felder',
        'paul zipser',
        'rakeem christmas',
        'tony snell',
        'troy daniels',
        'troy williams',
    },
    '2016-10-30': {
        'anthony morrow',
        'jose calderon',
        'thon maker',
    },
    '2016-10-31': {
        'alan williams',
    },
    '2016-11-01': {
        'aaron brooks',
        'jake layman',
        'james michael mcadoo',
        'jordan hill',
        'maurice ndour',
        'pat connaughton',
        'tony allen',
        'tyus jones',
        'udonis haslem',
    },
    '2016-11-02': {
        'ivica zubac',
        'james young',
        'jerian grant',
        'marcus smart',
        'nick collison',
        'treveon graham',
    },
    '2016-11-03': {
        'darrell arthur',
    },
    '2016-11-04': {
        'alec burks',
        'brian roberts',
        'chandler parsons',
        'gordon hayward',
        'josh richardson',
    },
    '2016-11-05': {
        'adreian payne',
        'arinze onuaku',
        'gary harris',
        'georgios papagiannis',
        'john lucas iii',
        'jordan farmar',
        'malik beasley',
        'mike miller',
        'skal labissiere',
        'steve novak',
    },
    '2016-11-06': {
        'demetrius jackson',
        'lucas nogueira',
    },
    '2016-11-07': {
        'aaron harrison',
        'arinze onuaku',
        'brian roberts',
        'christian wood',
        'damjan rudez',
        'derrick williams',
    },
    '2016-11-08': {
        'darren collison',
        'jarnell stokes',
        'randy foye',
    },
    '2016-11-09': {
        'alan anderson',
        'danny green',
        'fred vanvleet',
        'kelly olynyk',
        'tim quarterman',
    },
    '2016-11-10': {
    },
    '2016-11-11': {
        'danuel house',
    },
    '2016-11-12': {
        'archie goodwin',
        'john jenkins',
        'josh mcroberts',
    },
    'never': {
        'alec burks', #no games
        'brandan wright',
        'brice johnson', #no games
        'bruno caboclo', #no games
        'cameron jones',
        'caris levert', #no games
        'chasson randle',
        'chinanu onuaku', #no games
        'chris johnson',
        'cory jefferson',
        'dahntay jones',
        'damian jones', #no games
        'damien inglis',
        'derrick jones jr.', #no games
        'devin harris', #no games
        'elliot williams',
        'festus ezeli', #no games
        'grant jerrett',
        'greg stiemsma',
        'henry sims',
        'j.p. tokoto',
        'joel anthony',
        'john holland',
        'jonathan holmes',
        'josh huestis', #no games
        'jrue holiday', #no games
        'livio jean-charles',
        'louis amundson',
        'markel brown',
        'marshall plumlee', #no games
        'mike scott', #no games
        'nerlens noel', #no games
        'patricio garino',
        'patrick beverley', #no games
        'paul pierce', #no games
        'phil pressey',
        'reggie bullock', #no games
        'r.j. hunter', #no games
        'tiago splitter', #no games
        'wayne ellington', #no games
    }
}

TBX_MISSING_PLAYERS = {}

#------------ Find File ------------
def findCsvFile(fullPathToDir, dateStr):
    return util.createFullPathFilename(fullPathToDir, util.createCsvFilename(dateStr))
def findJsonFile(fullPathToDir, dateStr):
    return util.createFullPathFilename(fullPathToDir, util.createJsonFilename(dateStr))
def findNbaFile(fullPathToDir, dateStr):
    #get previous day's file
    usedDiffFile = False
    currDate = util.parseDate(dateStr)
    while currDate > SEASON_START_DATE:
        currDate = currDate - ONE_DAY
        fullPathFilename = util.createFullPathFilename(fullPathToDir, util.createJsonFilename(util.formatDate(currDate)))
        if util.fileExists(fullPathFilename):
            if usedDiffFile:
                scraper.headsUp('Used different file for date=' + dateStr + ', file used=' + fullPathFilename)
            return fullPathFilename
        usedDiffFile = True
    return None
def findYearJsonFile(fullPathToDir, dateStr):
    return util.createFullPathFilename(fullPathToDir, util.createJsonFilename(str(util.parseDate(dateStr).year)))

#------------ Parse Row ------------
def parseFanDuelRow(row, dateStr, prefix):
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
def parseRotoGuruRow(row, dateStr, prefix):
    #convert to float just to make sure all values can be parsed to floats
    row['FantasyPoints'] = float(row['FantasyPoints'].strip())

    #reverse name bc it's in format: 'lastname, firstname'
    playerName = row['Name'].strip().split(', ')
    playerName.reverse()
    playerName = ' '.join(playerName).lower()

    return playerName, row
def parseNumberFireRow(row, dateStr, prefix):
    return row['NF_Name'].strip().lower(), row
def parseRotoGrinderPlayerProjectionsRow(row, dateStr, prefix):
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
        'RG_points15', 'RG_points19', 'RG_points20',
        'RG_points28', 'RG_points43',
        'RG_points50', 'RG_points51', 'RG_points58']
    util.mapSome(int, row, intCols)
    util.mapSome(float, row, floatCols)

    #now, add the extra data under salaries obj (which is other sites' salary, rank info)
    salaries = row['RG_schedule']['data']['salaries']['collection']
    for salaryObj in salaries:
        dataObj = salaryObj['data']
        siteId = str(int(dataObj['site_id']))

        if siteId == '2': #fanduel
            row['RG_rank'] = int(dataObj['rank'])
        elif siteId == '20': #draftkings i think
            row['RG_rank20'] = int(dataObj['rank'])
            row['RG_rank_diff20'] = int(dataObj['rank_diff'])
            row['RG_salary20'] = float(dataObj['salary'])
            row['RG_diff20'] = int(dataObj['diff'])
        else:
            row['RG_salary' + siteId] = float(dataObj['salary'])
    return row['RG_player_name'].strip().lower(), row
def parseRotoGrinderDefenseVsPositionCheatSheetRow(row, dateStr, prefix):
    #convert each to int/float
    util.mapSome(int, row, util.addPrefixToArray([ 'CRK', 'SFRK', 'SGRK', 'PFRK', 'PGRK'], prefix))
    util.mapSome(float, row, util.addPrefixToArray(['CFPPG', 'SFFPPG', 'SGFPPG', 'PFFPPG', 'PGFPPG'], prefix))
    return row[prefix + 'TEAM'].strip().lower(), row
def parseNbaRow(row, dateStr, prefix):
    return row[prefix + 'PLAYER_NAME'].strip().lower(), row
def parseNbaTeamRow(row, dateStr, prefix):
    return row[prefix + 'TEAM_NAME'].strip().lower(), row
def parseRotoGrinderStartingLineupsRow(row, dateStr, prefix):
    name = row['data']['text'].strip()
    order = int(row['data']['order'].strip())
    isStarter = 1 if order <= 5 else 0

    #Im not sure what status is, but it might be important
    #I've seen it equal 'B' and 'C'
    #I think these are B=Best Guess and C=Confirmed
    status = row['data']['status'].strip()

    row = { 'Order': order, 'Starter': isStarter, 'Status': status, }

    return name.lower(), util.addPrefixToObj(row, prefix)
def parseRotoGrinderOffenseVsDefenseBasicRow(row, dateStr, prefix):
    #remove the '%' from FGPCT
    fgPct = row[prefix + 'FGPCT'].strip()
    row[prefix + 'FGPCT'] = fgPct[:-1] if fgPct[-1] == '%' else fgPct

    #make sure all values are floats
    util.mapSome(float, row, util.addPrefixToArray(['AST', 'STL', 'FGM', 'TO', '3PM', 'BLK', 'FGPCT', 'REB', 'PTS', 'FGA'], prefix))
    return row[prefix + 'OFFENSE'].strip().lower(), row
#def parseRotoGrinderOffenseVsDefenseAdvancedRow(row, dateStr, prefix):
#    #make sure all values are floats
#    util.mapSome(float, row, util.addPrefixToArray(['OFFRTG', 'PPG', 'PPG-A', 'AVGRTG', 'DEFRTG', 'PACE', 'PTS'], prefix))
#    return row[prefix + 'OFFENSE'].strip().lower(), row

#------------ Handle Duplicates ------------
def handleRotoGrinderDuplicates(oldMatch, newMatch):
    oldMatchPoints = float(oldMatch['RG_points'])
    newMatchPoints = float(newMatch['RG_points'])
    if oldMatchPoints > 0 and newMatchPoints == 0:
        return oldMatch
    if newMatchPoints > 0 and oldMatchPoints == 0:
        return newMatch
    util.stop('In handleDuplicates for RotoGrinder, and dont know which to return')

#------------ Load File ------------
def loadCsvFile(fullPathFilename, keyRenameMap, prefix, delimiter):
    return util.loadCsvFile(fullPathFilename, keyRenameMap=keyRenameMap, delimiter=delimiter, prefix=prefix)
def loadJsonFile(fullPathFilename, keyRenameMap, prefix, delimiter):
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
def loadNbaJsonFile(fullPathFilename, keyRenameMap, prefix, delimiter):
    rows = []
    jsonData = util.loadJsonFile(fullPathFilename)
    colNames = util.addPrefixToArray(jsonData['resultSets'][0]['headers'], prefix)
    rowData = jsonData['resultSets'][0]['rowSet']
    for row in rowData:
        rows.append(dict(zip(colNames, row)))
    return rows
def loadRotoGrinderStartingLineupsFile(fullPathFilename, keyRenameMap, prefix, delimiter):
    rows = []
    jsonData = util.loadJsonFile(fullPathFilename)
    matchups = jsonData.values()
    for matchup in matchups:
        teamHomePlayers = matchup['data']['team_home']['data']['lineups']['collection'].values()
        teamAwayPlayers = matchup['data']['team_away']['data']['lineups']['collection'].values()
        rows.extend(teamHomePlayers)
        rows.extend(teamAwayPlayers)
    return rows

#------------ Common ------------
def loadDataFromFile(fullPathToDir, findFileFunction, loadFileFunction, parseRowFunction, handleDuplicates, features, dateStr, keyRenameMap={}, delimiter=',', prefix=''):
    data = {}

    #filename = util.createJsonFilename(dateStr) if isJson else util.createCsvFilename(dateStr)
    fullPathFilename = findFileFunction(fullPathToDir, dateStr)

    print '    Loading file: %s...' % fullPathFilename

    if fullPathFilename and util.fileExists(fullPathFilename):
        rows = loadFileFunction(fullPathFilename, keyRenameMap, prefix, delimiter)
        for row in rows:
            playerName, playerData = parseRowFunction(row, dateStr, prefix)
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
        util.headsUp('File not found for date=' + dateStr)
        pass

    return data
def loadDataFromDir(fullPathToDir, findFileFunction, loadFileFunction, parseRowFunction, handleDuplicates, features, keyRenameMap={}, delimiter=',', prefix=''):
    print '    Loading dir:', fullPathToDir
    data = {}
    currDate = SEASON_START_DATE
    while currDate <= END_DATE:
        currDateStr = util.formatDate(currDate)
        dateData = loadDataFromFile(fullPathToDir, findFileFunction, loadFileFunction, parseRowFunction, handleDuplicates, features, currDateStr, keyRenameMap, delimiter, prefix)
        if dateData:
            data[currDateStr] = dateData
        else:
            #util.headsUp('Data not found for date=' + currDateStr)
            pass
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
def findMatchingName(name, newData, isTeam):

    #first, check for exact match
    if hasExactMatch(name, newData):
        return name

    #then, check if it's a known mismatch name
    nameMap = TEAM_KNOWN_ALIASES if isTeam else KNOWN_ALIASES
    if name in nameMap:
        misMatchedName = nameMap[name]
        if isinstance(misMatchedName, list):
            for mmName in misMatchedName:
                if hasExactMatch(mmName, newData):
                    return mmName
        else:
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

    #if all fails return name, and let the parent handle it
    return name

def playerIsKnownToBeMissing(dateStr, name, knownMissingObj):
    return name in knownMissingObj or (dateStr in knownMissingObj and name in knownMissingObj[dateStr])
def playerDidNotPlayOnOrUpToDate(date, name):
    #first, check if they're in 'never'
    if name in PLAYERS_WHO_DID_NOT_PLAY_UP_TO['never']:
        return True

    #then, check each date starting with tomorrow up to the end
    currDate = date + ONE_DAY
    currDateStr = util.formatDate(currDate)
    while currDateStr in PLAYERS_WHO_DID_NOT_PLAY_UP_TO:
        if name in PLAYERS_WHO_DID_NOT_PLAY_UP_TO[currDateStr]:
            return True
        currDate = currDate + ONE_DAY
        currDateStr = util.formatDate(currDate)
    return False
def getTeam(playerData):
    return playerData['Team']
def getOppTeam(playerData):
    return playerData['Opponent']
def playerIsInData(data, name, isTeam):
    for dateStr in data:
        for nme in data[dateStr]:
            if nme == findMatchingName(name, data[dateStr], isTeam):
                return True
    return False

def mergeData(obj1, obj2, dataSourceName, isTeam, isOpp, knownMissingObj, containsY, usePrevDay):
    print 'Merging data...'
    dateStrs = obj1.keys()
    dateStrs.sort()
    for dateStr in dateStrs:
        if dateStr in obj2:
            for name in obj1[dateStr]:
                playerData = obj1[dateStr][name]
                if isTeam:
                    name = getOppTeam(playerData) if isOpp else getTeam(playerData)
                obj2Name = findMatchingName(name, obj2[dateStr], isTeam)
                if obj2Name in obj2[dateStr]:
                    playerData.update(obj2[dateStr][obj2Name])
                else:
                    date = util.parseDate(dateStr)
                    if playerIsKnownToBeMissing(dateStr, name, knownMissingObj) \
                            or playerDidNotPlayOnOrUpToDate(date - ONE_DAY if usePrevDay else date, name) \
                            or playerIsInData(obj2, name, isTeam): #it's oh well in this case; at least i know it's not a name mismatch
                        #util.headsUp('Found known missing player, date=' + dateStr + ', name=' + name)
                        if containsY:
                            #set FantasyPoints to 0 for these people who are known to be missing
                            playerData.update({ 'FantasyPoints': 0 })
                    else:
                        #tbx
                        if dataSourceName not in TBX_MISSING_PLAYERS:
                            TBX_MISSING_PLAYERS[dataSourceName] = {}

                        if dateStr in TBX_MISSING_PLAYERS[dataSourceName]:
                            TBX_MISSING_PLAYERS[dataSourceName][dateStr].append(name)
                        else:
                            TBX_MISSING_PLAYERS[dataSourceName][dateStr] = [name]

                        util.headsUp('Name not found in obj2, date=' + dateStr + ', name=' + name)
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
            '2016-11-07': {
                'lance stephenson',
            },
            '2016-11-08': {
                'jordan farmar',
                'lance stephenson',
                'walter tavares',
            },
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

            #2016-11-08
            'a.j. hammons',
            'jordan farmar',
            'lance stephenson',
        },
        'parseRowFunction': parseNumberFireRow,
        'prefix': 'NF_',
    },
    {
        'name': 'RotoGrinderPlayerProjections',
        'handleDuplicates': handleRotoGrinderDuplicates,
        'features': [
            #15=DD
            #19=?
            #20=DK
            #28=fa
            #43=FDraft (fdft)
            #50=Y!
            #58=rstr

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

            #inside schedule -> salaries obj
            'RG_rank', #fanduel
            'RG_salary15',
            'RG_salary19',
            'RG_rank20', 'RG_diff20', 'RG_rank_diff20', 'RG_salary20',
            'RG_salary28',
            'RG_salary43',
            'RG_salary50',
            #'RG_salary51', #no salary51 for some reason
            'RG_salary58',

            #projected points from other sites
            #'RG_points2', #fanduel (same as 'points')
            'RG_points15',
            'RG_points19',
            'RG_points20', #draftkings?
            'RG_points28',
            'RG_points43',
            'RG_points50',
            'RG_points51',
            'RG_points58',
        ],
        'findFileFunction': findJsonFile,
        'fullPathToDir': util.joinDirs(DATA_DIR, 'rawDataFromRotoGrinders', 'PlayerProjections'),
        'keyRenameMap': {
            'pown%': 'pownpct',
            'pt/$/k': 'ppdk',
            'o/u': 'overunder',
            '15': 'points15',
            '19': 'points19',
            '20': 'points20',
            '28': 'points28',
            '43': 'points43',
            '50': 'points50',
            '51': 'points51',
            '58': 'points58',
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

            #2016-11-08
            'kyle korver',
            'larry nance jr.',
        },
        'loadFileFunction': loadJsonFile,
        'parseRowFunction': parseRotoGrinderPlayerProjectionsRow,
        'prefix': 'RG_',
    },
    {
        'name': 'RotoGrinderDefenseVsPositionCheatSheet',
        'features': [
            'RG_OPP_DVP_CFPPG',
            'RG_OPP_DVP_CRK',
            'RG_OPP_DVP_PFFPPG',
            'RG_OPP_DVP_PFRK',
            'RG_OPP_DVP_PGFPPG',
            'RG_OPP_DVP_PGRK',
            'RG_OPP_DVP_SFFPPG',
            'RG_OPP_DVP_SFRK',
            'RG_OPP_DVP_SGFPPG',
            'RG_OPP_DVP_SGRK',
        ],
        'findFileFunction': findJsonFile,
        'fullPathToDir': util.joinDirs(DATA_DIR, 'rawDataFromRotoGrinders', 'DefenseVsPositionCheatSheet'),
        'isOpp': True,
        'isTeam': True,
        'keyRenameMap': {
            'C FPPG': 'CFPPG',
            'C RK': 'CRK',
            'PF FPPG': 'PFFPPG',
            'PF RK': 'PFRK',
            'PG FPPG': 'PGFPPG',
            'PG RK': 'PGRK',
            'SF FPPG': 'SFFPPG',
            'SF RK': 'SFRK',
            'SG FPPG': 'SGFPPG',
            'SG RK': 'SGRK'
        },
        'loadFileFunction': loadJsonFile,
        'parseRowFunction': parseRotoGrinderDefenseVsPositionCheatSheetRow,
        'prefix': 'RG_OPP_DVP_',
    },
    {
        'name': 'NBASeasonPlayerTraditional',
        'features': [
            'NBA_S_P_TRAD_W',
            'NBA_S_P_TRAD_L',
            'NBA_S_P_TRAD_W_PCT',
            'NBA_S_P_TRAD_MIN',
            'NBA_S_P_TRAD_FGM',
            'NBA_S_P_TRAD_FGA',
            'NBA_S_P_TRAD_FG_PCT',
            'NBA_S_P_TRAD_FG3M',
            'NBA_S_P_TRAD_FG3A',
            'NBA_S_P_TRAD_FG3_PCT',
            'NBA_S_P_TRAD_FTM',
            'NBA_S_P_TRAD_FTA',
            'NBA_S_P_TRAD_FT_PCT',
            'NBA_S_P_TRAD_OREB',
            'NBA_S_P_TRAD_DREB',
            'NBA_S_P_TRAD_REB',
            'NBA_S_P_TRAD_AST',
            'NBA_S_P_TRAD_TOV',
            'NBA_S_P_TRAD_STL',
            'NBA_S_P_TRAD_BLK',
            'NBA_S_P_TRAD_BLKA',
            'NBA_S_P_TRAD_PF',
            'NBA_S_P_TRAD_PFD',
            'NBA_S_P_TRAD_PTS',
            'NBA_S_P_TRAD_PLUS_MINUS',
            'NBA_S_P_TRAD_DD2',
            'NBA_S_P_TRAD_TD3',
        ],
        'findFileFunction': findNbaFile,
        'fullPathToDir': util.joinDirs(DATA_DIR, 'rawDataFromStatsNba', 'Season', 'Traditional', '2016'),
        'loadFileFunction': loadNbaJsonFile,
        'parseRowFunction': parseNbaRow,
        'prefix': 'NBA_S_P_TRAD_',
        'usePrevDay': True,
    },
    {
        'name': 'NBAPlayerBios',
        'features': [
            'NBA_PB_AGE',
            'NBA_PB_PLAYER_HEIGHT_INCHES',
            'NBA_PB_PLAYER_WEIGHT',
            'NBA_PB_COLLEGE',
            'NBA_PB_COUNTRY',
            'NBA_PB_DRAFT_YEAR',
            'NBA_PB_DRAFT_ROUND',
            'NBA_PB_DRAFT_NUMBER',
        ],
        'findFileFunction': findYearJsonFile,
        'fullPathToDir': util.joinDirs(DATA_DIR, 'rawDataFromStatsNba', 'Season', 'PlayerBios'),
        'loadFileFunction': loadNbaJsonFile,
        'parseRowFunction': parseNbaRow,
        'prefix': 'NBA_PB_',
    },
    {
        'name': 'RotoGrinderStartingLineups',
        'features': [
            'RG_START_Order',
            'RG_START_Starter',
            'RG_START_Status',
        ],
        'findFileFunction': findJsonFile,
        'fullPathToDir': util.joinDirs(DATA_DIR, 'rawDataFromRotoGrinders', 'StartingLineups'),
        'knownMissingObj': {
            '2016-10-29': { 'rakeem christmas' },
            '2016-11-01': { 'rakeem christmas' },
            '2016-11-03': { 'rakeem christmas' },
            '2016-11-05': { 'rakeem christmas', 'georgios papagiannis' },
            '2016-11-06': { 'georgios papagiannis' },
            '2016-11-07': { 'rakeem christmas' },
            '2016-11-08': { 'georgios papagiannis' },
            '2016-11-09': { 'rakeem christmas' },
            '2016-11-10': { 'georgios papagiannis' },
            '2016-11-11': { 'rakeem christmas', 'georgios papagiannis' },
        },
        'loadFileFunction': loadRotoGrinderStartingLineupsFile,
        'parseRowFunction': parseRotoGrinderStartingLineupsRow,
        'prefix': 'RG_START_',
    },
    {
        'name': 'NBASeasonTeamTraditional',
        'features': [
            'NBA_S_T_TRAD_GP',
            'NBA_S_T_TRAD_W',
            'NBA_S_T_TRAD_L',
            'NBA_S_T_TRAD_W_PCT',
            'NBA_S_T_TRAD_MIN',
            'NBA_S_T_TRAD_FGM',
            'NBA_S_T_TRAD_FGA',
            'NBA_S_T_TRAD_FG_PCT',
            'NBA_S_T_TRAD_FG3M',
            'NBA_S_T_TRAD_FG3A',
            'NBA_S_T_TRAD_FG3_PCT',
            'NBA_S_T_TRAD_FTM',
            'NBA_S_T_TRAD_FTA',
            'NBA_S_T_TRAD_FT_PCT',
            'NBA_S_T_TRAD_OREB',
            'NBA_S_T_TRAD_DREB',
            'NBA_S_T_TRAD_REB',
            'NBA_S_T_TRAD_AST',
            'NBA_S_T_TRAD_TOV',
            'NBA_S_T_TRAD_STL',
            'NBA_S_T_TRAD_BLK',
            'NBA_S_T_TRAD_BLKA',
            'NBA_S_T_TRAD_PF',
            'NBA_S_T_TRAD_PFD',
            'NBA_S_T_TRAD_PTS',
            'NBA_S_T_TRAD_PLUS_MINUS',
        ],
        'findFileFunction': findNbaFile,
        'fullPathToDir': util.joinDirs(DATA_DIR, 'rawDataFromStatsNba', 'Season', 'Team_Traditional', '2016'),
        'isTeam': True,
        'loadFileFunction': loadNbaJsonFile,
        'parseRowFunction': parseNbaTeamRow,
        'prefix': 'NBA_S_T_TRAD_',
        'usePrevDay': True,
    },
    {
        'name': 'NBASeasonTeamOpponentTraditional',
        'features': [
            'NBA_S_OPPT_TRAD_GP',
            'NBA_S_OPPT_TRAD_W',
            'NBA_S_OPPT_TRAD_L',
            'NBA_S_OPPT_TRAD_W_PCT',
            'NBA_S_OPPT_TRAD_MIN',
            'NBA_S_OPPT_TRAD_FGM',
            'NBA_S_OPPT_TRAD_FGA',
            'NBA_S_OPPT_TRAD_FG_PCT',
            'NBA_S_OPPT_TRAD_FG3M',
            'NBA_S_OPPT_TRAD_FG3A',
            'NBA_S_OPPT_TRAD_FG3_PCT',
            'NBA_S_OPPT_TRAD_FTM',
            'NBA_S_OPPT_TRAD_FTA',
            'NBA_S_OPPT_TRAD_FT_PCT',
            'NBA_S_OPPT_TRAD_OREB',
            'NBA_S_OPPT_TRAD_DREB',
            'NBA_S_OPPT_TRAD_REB',
            'NBA_S_OPPT_TRAD_AST',
            'NBA_S_OPPT_TRAD_TOV',
            'NBA_S_OPPT_TRAD_STL',
            'NBA_S_OPPT_TRAD_BLK',
            'NBA_S_OPPT_TRAD_BLKA',
            'NBA_S_OPPT_TRAD_PF',
            'NBA_S_OPPT_TRAD_PFD',
            'NBA_S_OPPT_TRAD_PTS',
            'NBA_S_OPPT_TRAD_PLUS_MINUS',
        ],
        'findFileFunction': findNbaFile,
        'fullPathToDir': util.joinDirs(DATA_DIR, 'rawDataFromStatsNba', 'Season', 'Team_Traditional', '2016'),
        'isOpp': True,
        'isTeam': True,
        'loadFileFunction': loadNbaJsonFile,
        'parseRowFunction': parseNbaTeamRow,
        'prefix': 'NBA_S_OPPT_TRAD_',
        'usePrevDay': True,
    },
    {
        'name': 'NBASeasonPlayerAdvanced',
        'features': [
            'NBA_S_P_ADV_OFF_RATING',
            'NBA_S_P_ADV_DEF_RATING',
            'NBA_S_P_ADV_NET_RATING',
            'NBA_S_P_ADV_AST_PCT',
            'NBA_S_P_ADV_AST_TO',
            'NBA_S_P_ADV_AST_RATIO',
            'NBA_S_P_ADV_OREB_PCT',
            'NBA_S_P_ADV_DREB_PCT',
            'NBA_S_P_ADV_REB_PCT',
            'NBA_S_P_ADV_TM_TOV_PCT',
            'NBA_S_P_ADV_EFG_PCT',
            'NBA_S_P_ADV_TS_PCT',
            'NBA_S_P_ADV_USG_PCT',
            'NBA_S_P_ADV_PACE',
            'NBA_S_P_ADV_PIE',
            'NBA_S_P_ADV_FGM_PG',
            'NBA_S_P_ADV_FGA_PG',
        ],
        'findFileFunction': findNbaFile,
        'fullPathToDir': util.joinDirs(DATA_DIR, 'rawDataFromStatsNba', 'Season', 'Advanced', '2016'),
        'loadFileFunction': loadNbaJsonFile,
        'parseRowFunction': parseNbaRow,
        'prefix': 'NBA_S_P_ADV_',
        'usePrevDay': True,
    },
    {
        'name': 'RotoGrinderOffenseVsDefenseBasic',
        'features': [
            'RG_OVD_AST',
            'RG_OVD_STL',
            'RG_OVD_FGM',
            'RG_OVD_TO',
            'RG_OVD_3PM',
            'RG_OVD_BLK',
            'RG_OVD_FGPCT',
            'RG_OVD_REB',
            'RG_OVD_PTS',
            'RG_OVD_FGA',
        ],
        'findFileFunction': findJsonFile,
        'fullPathToDir': util.joinDirs(DATA_DIR, 'rawDataFromRotoGrinders', 'OffenseVsDefenseBasic'),
        'isTeam': True,
        'keyRenameMap': {
            'FG%': 'FGPCT',
        },
        'loadFileFunction': loadJsonFile,
        'parseRowFunction': parseRotoGrinderOffenseVsDefenseBasicRow,
        'prefix': 'RG_OVD_',
    },
    {
        'name': 'RotoGrinderOffenseVsDefenseBasicOpponent',
        'features': [
            'RG_OVD_OPP_AST',
            'RG_OVD_OPP_STL',
            'RG_OVD_OPP_FGM',
            'RG_OVD_OPP_TO',
            'RG_OVD_OPP_3PM',
            'RG_OVD_OPP_BLK',
            'RG_OVD_OPP_FGPCT',
            'RG_OVD_OPP_REB',
            'RG_OVD_OPP_PTS',
            'RG_OVD_OPP_FGA',
        ],
        'findFileFunction': findJsonFile,
        'fullPathToDir': util.joinDirs(DATA_DIR, 'rawDataFromRotoGrinders', 'OffenseVsDefenseBasic'),
        'isOpp': True,
        'isTeam': True,
        'keyRenameMap': {
            'FG%': 'FGPCT',
        },
        'loadFileFunction': loadJsonFile,
        'parseRowFunction': parseRotoGrinderOffenseVsDefenseBasicRow,
        'prefix': 'RG_OVD_OPP_',
    },
    #{
    #    'name': 'RotoGrinderOffenseVsDefenseAdvanced',
    #    'features': [
    #        'RG_OVD_ADV_OFFRTG',
    #        'RG_OVD_ADV_PPG',
    #        'RG_OVD_ADV_PPG-A',
    #        'RG_OVD_ADV_AVGRTG',
    #        'RG_OVD_ADV_DEFRTG',
    #        'RG_OVD_ADV_PACE',
    #        'RG_OVD_ADV_PTS',
    #    ],
    #    'findFileFunction': findJsonFile,
    #    'fullPathToDir': util.joinDirs(DATA_DIR, 'rawDataFromRotoGrinders', 'OffenseVsDefenseAdvanced'),
    #    'isTeam': True,
    #    'loadFileFunction': loadJsonFile,
    #    'parseRowFunction': parseRotoGrinderOffenseVsDefenseAdvancedRow,
    #    'prefix': 'RG_OVD_ADV_',
    #},


    #{
    #    'name': '',
    #    'features': [],
    #    'fullPathToDir': util.joinDirs(DATA_DIR, ''),
    #    'parseRowFunction': ,
    #},
]

#tbx
'''
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
            '2016-11-07': {
                'lance stephenson',
            },
            '2016-11-08': {
                'jordan farmar',
                'lance stephenson',
                'walter tavares',
            },
        },
        'parseRowFunction': parseRotoGuruRow,
    },
]
'''

#load fanduel data
data = None

for dataSource in DATA_SOURCES:
    name = dataSource['name']
    print 'Loading data for %s...' % dataSource['name']

    containsY = util.getObjValue(dataSource, 'containsY', False)
    delimiter = util.getObjValue(dataSource, 'delimiter', ',')
    features = dataSource['features']
    findFileFunction = util.getObjValue(dataSource, 'findFileFunction', findCsvFile)
    fullPathToDir = dataSource['fullPathToDir']
    handleDuplicates = util.getObjValue(dataSource, 'handleDuplicates', None)
    isOpp = util.getObjValue(dataSource, 'isOpp', False)
    isTeam = util.getObjValue(dataSource, 'isTeam', False)
    keyRenameMap = util.getObjValue(dataSource, 'keyRenameMap', {})
    knownMissingObj = util.getObjValue(dataSource, 'knownMissingObj', {})
    loadFileFunction = util.getObjValue(dataSource, 'loadFileFunction', loadCsvFile)
    parseRowFunction = dataSource['parseRowFunction']
    prefix = util.getObjValue(dataSource, 'prefix', '')
    usePrevDay = util.getObjValue(dataSource, 'usePrevDay', False)

    newData = loadDataFromDir(fullPathToDir, findFileFunction, loadFileFunction, parseRowFunction, handleDuplicates, features, keyRenameMap, delimiter, prefix)
    X_NAMES.extend(features)

    if data == None:
        data = newData
    else:
        mergeData(data, newData, name, isTeam, isOpp, knownMissingObj, containsY, usePrevDay)

writeData(OUTPUT_FILE, data)

if len(TBX_MISSING_PLAYERS) > 0:
    print 'Missing players:'
    dataSourceNames = TBX_MISSING_PLAYERS.keys()
    dataSourceNames.sort()
    for dataSourceName in dataSourceNames:
        print ' '
        print dataSourceName
        dateStrs = TBX_MISSING_PLAYERS[dataSourceName].keys()
        dateStrs.sort()
        for dateStr in dateStrs:
            print dateStr
            TBX_MISSING_PLAYERS[dataSourceName][dateStr].sort()
            for name in TBX_MISSING_PLAYERS[dataSourceName][dateStr]:
                print '\'' + name + '\','
