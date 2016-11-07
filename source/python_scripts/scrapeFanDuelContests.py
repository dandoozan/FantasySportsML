import re
from datetime import date, timedelta
import json
import scraper
import _util as util

TODAY_STR = date.today().strftime('%Y-%m-%d')
FULL_PATH_DIR_NAME = util.joinDirs('data', 'rawDataFromFanDuel', 'Contests')

def createFanduelApiUrl(fixtureList):
    return 'https://api.fanduel.com/contests?fixture_list=%s&include_restricted=true' % fixtureList

def createHeaders(xAuthToken):
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
        'Referer': 'https://www.fanduel.com/games',
        'X-Auth-Token': xAuthToken,
    }

#=============== Main ================

xAuthToken = raw_input('Enter X-Auth-Token: ')
fixtureList = raw_input('Enter Fixture List (eg. 16857): ')

print 'Downloading contest file for date: %s...' % TODAY_STR

#make dir
util.createDirIfNecessary(FULL_PATH_DIR_NAME)

jsonData = scraper.downloadJson(createFanduelApiUrl(fixtureList), createHeaders(xAuthToken))
util.writeJsonData(jsonData, util.createFullPathFilename(FULL_PATH_DIR_NAME, util.createJsonFilename(TODAY_STR)), prettyPrint=False)

print 'Done!'
