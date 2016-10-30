from datetime import date
import time
import json
import scraper

PARENT_DIR = 'data/rawDataFromRotoGrinders'
FILENAME = date.today().strftime('%Y-%m-%d')
SLEEP = 10

pagesToScrape = [
    {
        'dirName': 'AdvancedPlayerStats',
        'jsonPrefix': 'data = ',
        'url': 'https://rotogrinders.com/grids/nba-advanced-stats-1494397',
    },
    {
        'dirName': 'DefenseVsPosition',
        'jsonPrefix': 'data = ',
        'url': 'https://rotogrinders.com/grids/nba-defense-vs-position-cheat-sheet-1493632',
    },
    {
        'dirName': 'MarketWatch',
        'jsonPrefix': 'data = ',
        'url': 'https://rotogrinders.com/game-stats/nba/market-watch',
    },
    {
        'dirName': 'OffenseVsDefenseAdvanced',
        'jsonPrefix': 'data = ',
        'url': 'https://rotogrinders.com/grids/nba-offense-vs-defense-advanced-1493604',
    },
    {
        'dirName': 'OffenseVsDefenseBasic',
        'jsonPrefix': 'data = ',
        'url': 'https://rotogrinders.com/grids/nba-offense-vs-defense-1493592',
    },
    {
        'dirName': 'OffenseVsDefenseForwards',
        'jsonPrefix': 'data = ',
        'url': 'https://rotogrinders.com/grids/nba-offense-vs-defense-forwards-1493610',
    },
    {
        'dirName': 'OffenseVsDefenseGuards',
        'jsonPrefix': 'data = ',
        'url': 'https://rotogrinders.com/grids/nba-offense-vs-defense-guards-1493607',
    },
    {
        'dirName': 'PlayerProjections',
        'jsonPrefix': 'data = ',
        'url': 'https://rotogrinders.com/projected-stats/nba-player?site=fanduel',
    },
    {
        'dirName': 'StartingLineups',
        'jsonPrefix': 'schedules: ',
        'url': 'https://rotogrinders.com/lineups/nba?site=fanduel',
    },
    {
        'dirName': 'Touches',
        'jsonPrefix': 'data = ',
        'url': 'https://rotogrinders.com/grids/nba-touches-1494403',
    },
    {
        'dirName': 'VegasOdds',
        'jsonPrefix': 'schedules: ',
        'url': 'https://rotogrinders.com/schedules/nba',
    },
]

def parseData(data, jsonPrefix):
    print '    Parsing data...'

    for line in data:
        line = line.strip()
        if line.find(prefix) == 0:
            #chop off the prefix
            line = line[len(prefix):]
            if line[-1] == ',' or line[-1] == ';':
                line = line[:-1]
            return json.loads(line)

    #if i get here, i didnt find the data
    return None

def createFilename(parentDir, dirName, baseFilename):
    return parentDir + '/' + dirName + '/' + baseFilename + '.json'

#=============== Main ================

for page in pagesToScrape:
    dirName = page['dirName']
    jsonPrefix = page['jsonPrefix']
    url = page['url']

    print '\nScraping %s...' % dirName

    pageSource = scraper.downloadPageSource(url).split('\n')
    data = parseData(pageSource, jsonPrefix)
    if data:
        scraper.writeJsonData(data, createFilename(PARENT_DIR, dirName, FILENAME))
    else:
        print '========================================='
        print '***HEADS UP!  NO DATA FOUND FOR', dirName
        print '========================================='

    print '    Sleeping for %d seconds' % SLEEP
    time.sleep(SLEEP)


print 'Done!'
