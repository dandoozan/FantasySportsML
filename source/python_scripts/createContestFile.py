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
        'LastWinningRank', 'LastWinningScore', 'Type']

def loadDataFromTxtFile(fullPathFilename):
    print '    Loading file: ' + fullPathFilename + '...'
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

    #set type to tournament
    data['Type'] = fd.CONTEST_TYPES['tournament']

    return data

def loadDataFromJsonFile(fullPathFilename):
    print '    Loading file: ' + fullPathFilename + '...'
    jsonData = util.loadJsonFile(fullPathFilename)

    #convert values to int, float, etc just to catch errors
    contest = jsonData['contests'][0]

    if fd.contestIsCancelled(contest):
        print '        Bummer,contest was cancelled'
        return None

    return {
        'Title': contest['name'].strip().replace(',', ''),
        'Entries': int(contest['entries']['count']),
        'MaxEntries': int(contest['size']['max']),
        'EntryFee': int(contest['entry_fee']),
        'H2H': contest['h2h'],
        'MaxEntriesPerUser': int(contest['max_entries_per_user']),
        'Pot': float(contest['prizes']['total']),
        'HighestScore': float(contest['scoring']['highest_score']),
        'LastWinningIndex': int(contest['scoring']['last_winning_index']),
        'LastWinningRank': int(contest['scoring']['last_winning_rank']),
        'LastWinningScore': float(contest['scoring']['last_winning_score']),
        'Type': fd.getContestType(contest),
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
            if fileData:
                fileData['Date'] = currDateStr
                data.append(fileData)

    else:
        util.headsUp('No dir found for date=' + currDateStr)
    currDate = currDate + ONE_DAY

util.writeCsvFile(COL_NAMES, data, OUTPUT_FILE)


