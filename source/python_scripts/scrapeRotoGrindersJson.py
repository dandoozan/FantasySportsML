from datetime import date
import time
import json
import scraper
import _util as util

ROTO_GRINDER_DIR = 'data/rawDataFromRotoGrinders'
FILENAME = date.today().strftime('%Y-%m-%d')
SLEEP = 10

PAGES_TO_SCRAPE = [
    {
        'dirName': 'AdvancedPlayerStats',
        'jsonPrefix': 'data = ',
        'url': 'https://rotogrinders.com/grids/nba-advanced-stats-1494397',
    },
    {
        'dirName': 'DefenseVsPositionCheatSheet',
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
TEAM_STATS_PAGES_TO_SCRAPE = [
    {
        'baseUrl': 'https://rotogrinders.com/team-stats/nba-earned?',
        'dirName': 'TeamStats',
        'jsonPrefix': 'data = ',
        'urlParams': {
            'site': 'fanduel',
        },
        'positions': [
            { 'name': 'C', 'urlParams': { 'position': 'C', 'sport': 'nba' } },
            { 'name': 'PF', 'urlParams': { 'position': 'PF', 'sport': 'nba' } },
            { 'name': 'PG', 'urlParams': { 'position': 'PG', 'sport': 'nba' } },
            { 'name': 'SF', 'urlParams': { 'position': 'SF', 'sport': 'nba' } },
            { 'name': 'SG', 'urlParams': { 'position': 'SG', 'sport': 'nba' } },
        ],
        'ranges': [
            { 'name': '4weeks', 'urlParams': { 'range': '4weeks' } },
            { 'name': 'LastWeek', 'urlParams': { 'range': '1week' } },
            { 'name': 'Season', 'urlParams': { 'range': 'season' } },
            { 'name': 'Yesterday', 'urlParams': { 'range': 'yesterday' } },
        ],
    },
    {
        'baseUrl': 'https://rotogrinders.com/team-stats/nba-allowed?',
        'dirName': 'DefenseVsPosition',
        'jsonPrefix': 'data = ',
        'urlParams': {
            'site': 'fanduel',
        },
        'positions': [
            { 'name': 'C', 'urlParams': { 'position': 'C', 'sport': 'nba' } },
            { 'name': 'PF', 'urlParams': { 'position': 'PF', 'sport': 'nba' } },
            { 'name': 'PG', 'urlParams': { 'position': 'PG', 'sport': 'nba' } },
            { 'name': 'SF', 'urlParams': { 'position': 'SF', 'sport': 'nba' } },
            { 'name': 'SG', 'urlParams': { 'position': 'SG', 'sport': 'nba' } },
        ],
        'ranges': [
            { 'name': '4weeks', 'urlParams': { 'range': '4weeks' } },
            { 'name': 'LastWeek', 'urlParams': { 'range': '1week' } },
            { 'name': 'Season', 'urlParams': { 'range': 'season' } },
            { 'name': 'Yesterday', 'urlParams': { 'range': 'yesterday' } },
        ],
    }
]

def parseData(data, jsonPrefix):
    print '    Parsing data...'

    for line in data:
        line = line.strip()
        if line.find(jsonPrefix) == 0:
            #chop off the prefix
            line = line[len(jsonPrefix):]
            if line[-1] == ',' or line[-1] == ';':
                line = line[:-1]
            return json.loads(line)

    #if i get here, i didnt find the data
    return None

def scrapePage(dirName, url, jsonPrefix):
    print '\nScraping %s...' % dirName

    fullPathDirName = util.joinDirs(ROTO_GRINDER_DIR, dirName)
    #util.createDirIfNecessary(fullPathDirName)

    pageSource = scraper.downloadPageSource(url).split('\n')
    data = parseData(pageSource, jsonPrefix)
    if data:
        scraper.writeJsonData(data, scraper.createJsonFilename(fullPathDirName, FILENAME))
    else:
        util.headsUp('NO DATA FOUND FOR' + dirName)

    print '    Sleeping for %d seconds' % SLEEP
    time.sleep(SLEEP)

#=============== Main ================
for page in PAGES_TO_SCRAPE:
    dirName = page['dirName']
    jsonPrefix = page['jsonPrefix']
    url = page['url']
    scrapePage(dirName, url, jsonPrefix)

#tbx
urls = {}

#scrape team stats
for page in TEAM_STATS_PAGES_TO_SCRAPE:
    baseUrl = page['baseUrl']
    dirName = page['dirName']
    jsonPrefix = page['jsonPrefix']
    baseUrlParams = page['urlParams']
    for rnge in page['ranges']:
        rangeName = rnge['name']
        rangeUrlParams = rnge['urlParams']

        rangeDirName = dirName + rangeName
        urlParams = dict(baseUrlParams)
        urlParams.update(rangeUrlParams)

        #first scrape with no position (to get stat totals)
        url = scraper.createUrl(baseUrl, urlParams)
        urls[rangeDirName] = url #tbx
        scrapePage(rangeDirName, url, jsonPrefix)

        #then scrape for each position
        for position in page['positions']:
            positionName = position['name']
            positionUrlParams = position['urlParams']

            positionDirName = rangeDirName + positionName
            urlParams.update(positionUrlParams)
            url = scraper.createUrl(baseUrl, urlParams)
            urls[positionDirName] = url #tbx
            scrapePage(positionDirName, url, jsonPrefix)


'''
#tbx
keys = urls.keys()
keys.sort()
for key in keys:
    print key

for key in keys:
    print urls[key]
'''

print 'Done!'
