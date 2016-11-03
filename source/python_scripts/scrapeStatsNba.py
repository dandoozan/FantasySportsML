from datetime import date, timedelta
import time
import json
import scraper
import _util as util

TYPE = 'Advanced'
MODE = 'Totals'
SEASONS = {
    '2014': {
        'str': '2014-15',
        'startDate': date(2014, 10, 28),
        'endDate': date(2015, 4, 16),
    },
    '2015': {
        'str': '2015-16',
        'startDate': date(2015, 10, 27),
        'endDate': date(2016, 4, 14),
    },
}
BASE_URL = 'http://stats.nba.com/stats/leaguedashplayerstats?'
DATE_FORMAT_FILENAME = '%Y%m%d'
ONE_DAY = timedelta(1)
SLEEP = 10

def createUrlParams(startDate, endDate, measureType, perMode, season):
    dateFormat = '%m/%d/%Y'
    return {
        'College': '',
        'Conference': '',
        'Country': '',
        'DateFrom': startDate.strftime(dateFormat), #eg.'10/27/2015',
        'DateTo': endDate.strftime(dateFormat), #eg.'10/27/2015',
        'Division': '',
        'DraftPick': '',
        'DraftYear': '',
        'GameScope': '',
        'GameSegment': '',
        'Height': '',
        'LastNGames': '0',
        'LeagueID': '00',
        'Location': '',
        'MeasureType': measureType, #'Advanced', 'Base',
        'Month': '0',
        'OpponentTeamID': '0',
        'Outcome': '',
        'PORound': '0',
        'PaceAdjust': 'N',
        'PerMode': perMode, #'Totals', 'PerGame',
        'Period': '0',
        'PlayerExperience': '',
        'PlayerPosition': '',
        'PlusMinus': 'N',
        'Rank': 'N',
        'Season': season,
        'SeasonSegment': '',
        'SeasonType': 'Regular Season',
        'ShotClockRange': '',
        'StarterBench': '',
        'TeamID': '0',
        'VsConference': '',
        'VsDivision': '',
        'Weight': '',
    }

def getDataValues(data):
    return data['resultSets'][0]['rowSet']

#=============== Main ================

print 'Scraping Type=%s, Mode=%s' % (TYPE, MODE)

season = raw_input('Enter season (eg. 2015): ').strip()
parentDir = 'data/rawDataFromStatsNba/' + TYPE + '_Season/' + season
util.createDirIfNecessary(parentDir)

seasonObj = SEASONS[season]
startDate = seasonObj['startDate']
endDate = seasonObj['endDate']

currDate = startDate
prevDataValues = None
while currDate <= endDate:
    print '\nScraping data for ' + str(currDate) + '...'

    url = scraper.createUrl(BASE_URL, createUrlParams(startDate, currDate, TYPE, MODE, seasonObj['str']))

    jsonData = scraper.downloadJson(url)
    #jsonData = json.load(open(PARENT_DIR + '/tbx_2015-10-27.json'))

    dataValues = getDataValues(jsonData)
    if len(dataValues) > 0 and dataValues != prevDataValues:
        baseFilename = currDate.strftime(DATE_FORMAT_FILENAME)
        scraper.writeJsonData(jsonData, scraper.createJsonFilename(parentDir, baseFilename), prettyPrint=False)
    else:
        util.headsUp('NO DATA FOUND FOR=' + currDate.strftime(DATE_FORMAT_FILENAME))

    prevDataValues = dataValues
    currDate = currDate + ONE_DAY

    print '    Sleeping for %d seconds...' % SLEEP
    time.sleep(SLEEP)


print 'Done!'
