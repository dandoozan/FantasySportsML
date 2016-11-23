#Download contests that are in Contests dir

import re
import scraper
import _util as util
import _fanDuelCommon as fd

CONTESTS_DIR = util.joinDirs('data', 'rawDataFromFanDuel', 'Contests')
CONTEST_RESULTS_DIR = util.joinDirs('data', 'rawDataFromFanDuel', 'ContestResults')
SLEEP = 30
ONE_DAY = util.getOneDay()
START_DATE = util.getDate(2016, 11, 7)
END_DATE = util.getYesterdayAsDate()

def getContestId(contest):
    return contest['id']
def getContestUrl(contest):
    return contest['_url']

def parseContestGroup(contestId):
    return contestId[:contestId.find('-')]

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

def contestAlreadyDownloaded(dateStr, contest):
    return util.fileExists(util.createFullPathFilename(util.joinDirs(CONTEST_RESULTS_DIR, dateStr), util.createJsonFilename(getContestId(contest))))

def findContestsToDownload():
    print 'Finding contests to donwload...'
    contestsToDownload = []

    currDate = START_DATE
    while currDate <= END_DATE:
        currDateStr = util.formatDate(currDate)
        fullPathFilename = util.createFullPathFilename(CONTESTS_DIR, util.createJsonFilename(currDateStr))
        if util.fileExists(fullPathFilename):
            jsonDataFromFile = util.loadJsonFile(fullPathFilename)
            numContests = 0
            contests = jsonDataFromFile['contests']
            for contest in contests:
                if ((fd.is5050Contest(contest) and fd.getEntryFee(contest) <= 2) \
                    or (fd.isDoubleUp(contest) and fd.getEntryFee(contest) <= 2 and fd.getContestMaxEntries(contest) > 200) \
                    or (fd.isTripleUp(contest) and fd.getEntryFee(contest) <= 2)) \
                    and not contestAlreadyDownloaded(currDateStr, contest):
                    contestsToDownload.append({
                        'contestId': getContestId(contest),
                        'url': getContestUrl(contest),
                        'dateStr': currDateStr,
                    })
                    numContests += 1
            print '    Found %d contests in file: %s' % (numContests, fullPathFilename)
        else:
            if currDateStr != '2016-11-20': #dont alert on this date since i know its missing
                util.headsUp('File doesn\'t exist: ' + fullPathFilename)
        currDate = currDate + ONE_DAY

    return contestsToDownload


#=============== main ==================

xAuthToken = util.getCommandLineArgument()

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

print 'Done!'

