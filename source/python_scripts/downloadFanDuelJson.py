import re
from datetime import date
import json
import scraper
import _util as util
import _fanDuelCommon as fd

TEST = False

TODAY_STR = date.today().strftime('%Y-%m-%d')
PARENT_DIR = util.joinDirs('data', 'rawDataFromFanDuel')
SLEEP = 10

def createHeaders(xAuthToken, referer, customHeaders={}):
    headers = {
        'Accept': 'application/json, text/plain, */*',
        #'Accept-Encoding': 'gzip, deflate, sdch, br',
        'Accept-Language': 'en-US,en;q=0.8',
        'Authorization': 'Basic N2U3ODNmMTE4OTIzYzE2NzVjNWZhYWFmZTYwYTc5ZmM6',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        'Host': 'api.fanduel.com',
        'Origin': 'https://www.fanduel.com',
        'Pragma': 'no-cache',
        'Referer': referer,
        'X-Auth-Token': xAuthToken,
    }
    headers.update(customHeaders)
    return headers
def downloadData(url, xAuthToken, referer, customHeaders={}):
    #print 'Not downloading data, but here\'s:'
    #print 'url=', url
    #print 'headers:'
    #util.printObj(createHeaders(xAuthToken, referer, customHeaders))
    return scraper.downloadJson(url, createHeaders(xAuthToken, referer, customHeaders))
def createFullPathFilename(dirName, prefix=''):
    return util.createFullPathFilename(util.joinDirs(PARENT_DIR, dirName), prefix + util.createJsonFilename(TODAY_STR))
def writeData(data, dirName):
    util.writeJsonData(data, createFullPathFilename(dirName))

def parseFixtureList(jsonData):
    fixtureListObjs = jsonData['fixture_lists']
    for obj in fixtureListObjs:
        if obj['sport'] == 'NBA' and obj['label'] == 'Main':
            return obj['id']
    util.stop('No fixture list found')
def downloadFixtureList(xAuthToken):
    dirName = 'FixtureLists'
    referer = 'https://www.fanduel.com/games'
    url = 'https://api.fanduel.com/fixture-lists'
    jsonData = json.load(open(createFullPathFilename(dirName, 'tbx_'))) if TEST else downloadData(url, xAuthToken, referer)
    #writeData(jsonData, 'tbx_FixtureLists')
    return parseFixtureList(jsonData)

def findContestId(jsonData):
    #find the first contest whose id fits the expected format
    contests = jsonData['contests']
    for contest in contests:
        contestId = fd.getContestId(contest)
        if fd.isValidContestId(contestId):
            return contestId
    util.stop('Contest Id was not found or was a different format than expected')
def downloadContests(xAuthToken, fixtureList):
    dirName = 'Contests'
    referer = 'https://www.fanduel.com/games'
    url = 'https://api.fanduel.com/contests?fixture_list=%s&include_restricted=true' % fixtureList
    jsonData = json.load(open(createFullPathFilename(dirName, 'tbx_'))) if TEST else downloadData(url, xAuthToken, referer)
    if not TEST:
        writeData(jsonData, dirName)
    return findContestId(jsonData)

def downloadPlayers(xAuthToken, fixtureList, contestId):
    dirName = 'Players'
    customHeaders = {
        'Accept': 'application/json',
    }
    referer = 'https://www.fanduel.com/games/%s/contests/%s/enter' % (fixtureList, contestId)
    url = 'https://api.fanduel.com/fixture-lists/%s/players' % fixtureList
    jsonData = downloadData(url, xAuthToken, referer, customHeaders)
    writeData(jsonData, dirName)


#=============== Main ================

#first, download x-auth-token, and save as xAuthToken
#then, download fixture lists using xAuthToken, and save NBAs fixture as fixtureList
#then, download contests using xAuthToken and fixtureList, and save top contest id as contestId
#then, download player list using xAuthToken, fixtureList and contestId

xAuthToken = raw_input('Enter X-Auth-Token: ') #'d6d05fe2f3047e6126e3b0df7c70d62f238a26f1bdeaaf915cb83054368757fc'# raw_input('Enter X-Auth-Token: ')

print 'Downloading Fixture Lists...'
#16997=11/20 nba early only
#16998=11/20 nba main
#16999=11/20 nba late night
fixtureList = downloadFixtureList(xAuthToken)
print 'Got fixture list:', fixtureList
scraper.sleep(SLEEP)

print '\nDownloading Contests...'
contestId = downloadContests(xAuthToken, fixtureList)
print 'Got contest id:', contestId
scraper.sleep(SLEEP)

print '\nDownloading Players...'
downloadPlayers(xAuthToken, fixtureList, contestId)

print 'Done!'
