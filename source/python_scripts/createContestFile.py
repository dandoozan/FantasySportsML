import datetime
import re
import json
import _util as util
import _fanDuelCommon as fd

DATA_DIR = 'data'
CONTESTS_DIR = util.joinDirs(DATA_DIR, 'rawDataFromFanDuel', 'ContestResults')
OUTPUT_FILE = util.createFullPathFilename(DATA_DIR, 'data_contests_2016.csv')
SEASON_START_DATE = datetime.date(2016, 10, 25)
TODAY = datetime.date.today()
ONE_DAY = datetime.timedelta(1)
DATE_FORMAT = '%Y-%m-%d'

COL_NAMES = ['Date', 'Title', 'Entries', 'MaxEntries', 'MaxEntriesPerUser',
        'H2H', 'EntryFee', 'Pot', 'HighestScore', 'LastWinningIndex',
        'LastWinningRank', 'LastWinningScore', 'Is5050']

def loadDataFromTxtFile(fullPathFilename):
    data = {}

    f = open(fullPathFilename)
    lines  = f.readlines()
    f.close()

    #set title
    data['Title'] = lines[0].strip().replace(',', '')

    #set MaxEntriesPerUser if I find it in the title
    if data['Title'].find('(Single Entry)') > -1:
        data['MaxEntriesPerUser'] = 1
    else:
        match = re.search('\(\d+ Entries Max\)', data['Title'])
        if match:
            data['MaxEntriesPerUser'] = int(match.group(0).split(' ')[0].replace('(', ''))

    #set pot and entryFee
    if lines[2].strip() == 'TYPE':
        potIndex = 3
        entryIndex = 5
    else:
        potIndex = 2
        entryIndex = 3
    data['Pot'] = int(lines[potIndex].strip().replace(',', '').replace('$', ''))
    data['EntryFee'] = int(lines[entryIndex].strip().split(' ')[0].strip().replace('$', '').replace(',', ''))

    #set the highestScore and lastWinningScore
    #find start of lines with scores
    startIndex = 0
    while lines[startIndex][:3] != '1st':
        startIndex += 1

    prevSp = None
    for i in xrange(startIndex, len(lines)):
        line  = lines[i].strip()
        spSpaces = filter(None, line.split(' '))
        spCommas = line.split(',')

        if line == '...':
            continue

        sp = spSpaces if len(spSpaces) == 5 else spCommas

        #find the first '1st'
        if sp[0] == '1st':
            if 'HighestScore' not in data:
                data['HighestScore'] = float(sp[-1].strip())

        #find last winning rank and score
        elif sp[2].split(' ')[0] == '$0':
            break
        prevSp = sp

    #set last winning rank and score
    data['LastWinningRank'] = int(re.sub(r'(st|nd|rd|th)', '', prevSp[0].strip()))
    data['LastWinningScore'] = float(prevSp[-1].strip())

    #set 5050 to always be 0
    data['Is5050'] = 0

    return data

def loadDataFromJsonFile(fullPathFilename):
    jsonData = util.loadJsonFile(fullPathFilename)

    #convert values to int, float, etc just to catch errors
    contestData = jsonData['contests'][0]
    return {
        'Title': contestData['name'].strip().replace(',', ''),
        'Entries': int(contestData['entries']['count']),
        'MaxEntries': int(contestData['size']['max']),
        'EntryFee': int(contestData['entry_fee']),
        'H2H': contestData['h2h'],
        'MaxEntriesPerUser': int(contestData['max_entries_per_user']),
        'Pot': float(contestData['prizes']['total']),
        'HighestScore': float(contestData['scoring']['highest_score']),
        'LastWinningIndex': int(contestData['scoring']['last_winning_index']),
        'LastWinningRank': int(contestData['scoring']['last_winning_rank']),
        'LastWinningScore': float(contestData['scoring']['last_winning_score']),
        'Is5050': (1 if fd.is5050Contest(contestData['name']) else 0),
    }

#============= main =============

data = []

currDate = SEASON_START_DATE
while currDate < TODAY:
    currDateStr = currDate.strftime(DATE_FORMAT)
    print 'Loading contest files for date=', currDateStr
    fullPathDirName = util.joinDirs(CONTESTS_DIR, currDateStr)
    if util.dirExists(fullPathDirName):
        filenames = util.getFilesInDir(fullPathDirName)
        for filename in filenames:
            fullPathFilename = util.createFullPathFilename(fullPathDirName, filename)
            fileData = loadDataFromTxtFile(fullPathFilename) if util.isTxtFile(filename) else loadDataFromJsonFile(fullPathFilename)
            fileData['Date'] = currDateStr
            data.append(fileData)
    else:
        util.headsUp('No dir found for date=' + currDateStr)
    currDate = currDate + ONE_DAY

util.writeCsvFile(COL_NAMES, data, OUTPUT_FILE)


