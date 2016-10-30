from datetime import date
import time
import json
import scraper

TEST = True
TEST_FILENAME = '2016-10-26'

PARENT_DIR = 'data/rawDataFromRotoGrinders'
FILENAME = TEST_FILENAME if TEST else date.today().strftime('%Y-%m-%d')
SLEEP = 10

urlsToScrape = {
    'StartingLineups': 'https://rotogrinders.com/lineups/nba?site=fanduel'
    'VegasOdds': 'https://rotogrinders.com/schedules/nba',
}

def parseData(data):
    print '    Parsing data...'

    for line in data:
        line = line.strip()
        if line.find('schedules: {') == 0:
            #chop off the 'schedules: '
            line = line[11:]
            if line[-1] == ',':
                line = line[:-1]
            return json.loads(line)

    #if i get here, i didnt find the data
    raise(Exception('DPD ERROR: I didn\'t find the data'))

def createFilename(parentDir, dirName, baseFilename):
    return parentDir + '/' + dirName + '/' + baseFilename + '.json'

#=============== Main ================

for dirName in urlsToScrape:
    print '\nScraping %s...' % dirName

    url = urlsToScrape[dirName]

    pageSource = open(PARENT_DIR+'/'+dirName+'/'+FILENAME+'.html') if TEST else scraper.downloadPageSource(url).split('\n')
    data = parseData(pageSource)
    scraper.writeJsonData(data, createFilename(PARENT_DIR, dirName, FILENAME))

    print '    Sleeping for %d seconds' % SLEEP
    time.sleep(SLEEP)

print 'Done!'
