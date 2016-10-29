#scrape rotogrinders

import urllib2
import json
from datetime import date
import time

USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36'
PARENT_DIR = 'data/rawDataFromRotoGrinders'
FILENAME = date.today().strftime('%Y-%m-%d')
SLEEP = 10

urlsToScrape = {
    'AdvancedPlayerStats': 'https://rotogrinders.com/grids/nba-advanced-stats-1494397',
    'DefenseVsPosition': 'https://rotogrinders.com/grids/nba-defense-vs-position-cheat-sheet-1493632',
    'MarketWatch': 'https://rotogrinders.com/game-stats/nba/market-watch',
    'OffenseVsDefenseAdvanced': 'https://rotogrinders.com/grids/nba-offense-vs-defense-advanced-1493604',
    'OffenseVsDefenseBasic': 'https://rotogrinders.com/grids/nba-offense-vs-defense-1493592',
    'OffenseVsDefenseForwards': 'https://rotogrinders.com/grids/nba-offense-vs-defense-forwards-1493610',
    'OffenseVsDefenseGuards': 'https://rotogrinders.com/grids/nba-offense-vs-defense-guards-1493607',
    'PlayerProjections': 'https://rotogrinders.com/projected-stats/nba-player?site=fanduel',
    'Touches': 'https://rotogrinders.com/grids/nba-touches-1494403'
    #'VegasOdds': 'https://rotogrinders.com/schedules/nba',
}

def downloadData(url, userAgent):
    print '    Downloading data...'
    print '        url:', url

    req = urllib2.Request(url, headers={ 'User-Agent': userAgent })
    pageSource = urllib2.urlopen(req).read().split('\n')
    #pageSource = open('data/rawDataFromRotoGrinders/2016-10-28_PlayerProjections.html')
    return pageSource

def parseData(data):
    print '    Parsing data...'

    for line in data:
        line = line.strip()
        if line.find('data = [') == 0 or line.find('data = {') == 0:
            #chop off the 'data = ' and ending semicolon'
            return json.loads(line[7:-1])

    #if i get here, i didnt find the data
    raise(Exception('DPD ERROR: I didn\'t find the data'))

def writeData(jsonData, filename):
    print '    Writing data to ' + filename + '...'
    f = open(filename, 'w')
    f.write(json.dumps(jsonData, indent=4))
    f.close()

def createFilename(parentDir, dirName, baseFilename):
    return parentDir + '/' + dirName + '/' + baseFilename + '.json'

#=============== Main ================

for key in urlsToScrape:
    dirName = key
    url = urlsToScrape[key]

    print 'Scraping %s data...' % dirName

    rawData = downloadData(url, USER_AGENT)
    data = parseData(rawData)
    writeData(data, createFilename(PARENT_DIR, dirName, FILENAME))

    print 'Sleeping for %d seconds' % SLEEP
    time.sleep(SLEEP)


print 'Done!'
