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
KNOWN_MISSING_DATES = { #these are the dates that i forgot to scrape
    '2016-11-20',
    '2017-02-05',
}

def getContestId(contest):
    return contest['id']
def getContestUrl(contest):
    return contest['_url']

def parseContestGroup(contestId):
    return contestId[:contestId.find('-')]

def createHeaders(contestId, xAuthToken):
    contestGroup = parseContestGroup(contestId)
    referer = 'https://www.fanduel.com/games/%s/contests/%s/scoring' % (contestGroup, contestId)
    return fd.getHeaders(referer, xAuthToken)

def contestAlreadyDownloaded(dateStr, contest):
    return util.fileExists(util.createFullPathFilename(util.joinDirs(CONTEST_RESULTS_DIR, dateStr), util.createJsonFilename(getContestId(contest))))

def findFilename(fullPathToDir, dateStr):
    filenames = util.getFilesInDir(fullPathToDir)
    filenames.reverse() #go in reverse direction so that I find the latest contest file when there are multiple for one day
    for filename in filenames:
        if util.parseBaseFilename(filename) == dateStr \
                or util.parseDateFromDateTimeFilename(filename) == dateStr:
            return filename

def dateKnownToBeMissing(currDateStr):
    return currDateStr in KNOWN_MISSING_DATES or currDateStr in fd.DATES_WITH_NO_CONTESTS

def findContestsToDownload():
    print 'Finding contests to download...'
    contestsToDownload = []

    currDate = START_DATE
    while currDate <= END_DATE:
        currDateStr = util.formatDate(currDate)
        if not dateKnownToBeMissing(currDateStr):
            fullPathFilename = util.createFullPathFilename(CONTESTS_DIR, findFilename(CONTESTS_DIR, currDateStr))
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
                if numContests > 0:
                    print '    Found %d contests in file: %s' % (numContests, fullPathFilename)
            else:
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

    fullPathToDir = util.joinDirs(CONTEST_RESULTS_DIR, dateStr)
    util.createDirIfNecessary(fullPathToDir)

    fullPathFilename = util.createFullPathFilename(fullPathToDir, util.createJsonFilename(contestId))
    if util.fileExists(fullPathFilename):
        print('    Skipping contest because file exists: ' + fullPathFilename)
    else:
        jsonData = scraper.downloadJson(url, createHeaders(contestId, xAuthToken))
        util.writeJsonData(jsonData, fullPathFilename)
        util.sleep(SLEEP)
    cnt += 1

print 'Done!'
