#Download contests that are in Contests dir

import re
import scraper
import _util as util

CONTESTS_DIR = util.joinDirs('data', 'rawDataFromFanDuel', 'Contests')
CONTEST_RESULTS_DIR = util.joinDirs('data', 'rawDataFromFanDuel', 'ContestResults')
SLEEP = 10

def getContestId(contest):
    return contest['id']
def getContestUrl(contest):
    return contest['_url']

def parseDateStrFromFilename(filename):
    return filename[:filename.find('.')]
def parseContestGroup(contestId):
    return contestId[:contestId.find('-')]

def is5050Contest(contest):
    return not not re.match('50/50 Contest \(\$\d+ - Top 50% Win\)', contest['name'])
def isOneDollarContest(contest):
    return int(contest['entry_fee']) == 1
def createHeaders(contestId, xAuthToken):
    contestGroup = parseContestGroup(contestId)
    return {
        'Accept': 'application/json, text/plain, */*',
        #'Accept-Encoding': 'gzip, deflate, sdch, br',
        'Accept-Language': 'en-US,en;q=0.8',
        'Authorization': 'Basic N2U3ODNmMTE4OTIzYzE2NzVjNWZhYWFmZTYwYTc5ZmM6',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        'Host': 'api.fanduel.com',
        'Origin': 'https://www.fanduel.com',
        'Pragma': 'no-cache',
        'Referer': 'https://www.fanduel.com/games/%s/contests/%s/scoring' % (contestGroup, contestId),
        'X-Auth-Token': xAuthToken,
    }

def findContestsToDownload():
    print 'Finding contests to donwload...'
    contestsToDownload = []

    filenames = util.getFilesInDir(CONTESTS_DIR)
    for filename in filenames:
        numContests = 0
        jsonDataFromFile = util.loadJsonFile(util.createFullPathFilename(CONTESTS_DIR, filename))
        contests = jsonDataFromFile['contests']
        for contest in contests:
            if is5050Contest(contest) and isOneDollarContest(contest):
                contestsToDownload.append({
                    'contestId': getContestId(contest),
                    'url': getContestUrl(contest),
                    'dateStr': parseDateStrFromFilename(filename),
                })
                numContests += 1

        print '    Found %d contests in file: %s' % (numContests, filename)
    return contestsToDownload


#=============== main ==================

xAuthToken = raw_input('Enter X-Auth-Token: ')

#first, get contests to download
contestsToDownload = findContestsToDownload()
print 'Found %d contests to download' % len(contestsToDownload)

#then, download them
numContests = len(contestsToDownload)
cnt = 1
for contest in contestsToDownload:
    url = contest['url']
    contestId = contest['contestId']
    dateStr = contest['dateStr']

    print 'Downloading contest (%d / %d): %s' % (cnt, numContests, contestId)

    fullPathFilename = util.createFullPathFilename(util.joinDirs(CONTEST_RESULTS_DIR, dateStr), util.createJsonFilename(contestId))
    if util.fileExists(fullPathFilename):
        print('    Skipping contest because file exists: ' + fullPathFilename)
    else:
        jsonData = scraper.downloadJson(url, createHeaders(contestId, xAuthToken))
        util.writeJsonData(jsonData, fullPathFilename)
        scraper.sleep(SLEEP)
    cnt += 1


