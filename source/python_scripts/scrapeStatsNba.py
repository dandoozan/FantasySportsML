from datetime import date, timedelta
import time
import json
import scraper


#Change these params to get stats for a different season
PARENT_DIR = 'data/rawDataFromStatsNba/2014'
SEASON = '2014-15' #'2015-16'
BASE_DATE = date(2014, 10, 28) #date(2015, 10, 27) #the first day of the season
START_DATE = date(2014, 10, 28)
END_DATE = date(2015, 5, 1)

BASE_URL = 'http://stats.nba.com/stats/leaguedashplayerstats?'
DATE_FORMAT_FILENAME = '%Y%m%d'
ONE_DAY = timedelta(1)
SLEEP = 10

def createUrlParams(startDate, endDate, season):
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
        'MeasureType': 'Base',
        'Month': '0',
        'OpponentTeamID': '0',
        'Outcome': '',
        'PORound': '0',
        'PaceAdjust': 'N',
        'PerMode': 'PerGame',
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

baseDateStr = BASE_DATE.strftime(DATE_FORMAT_FILENAME)
currDate = START_DATE
prevDataValues = None
while currDate <= END_DATE:
    print '\nScraping data for ' + str(currDate) + '...'

    url = scraper.createUrl(BASE_URL, createUrlParams(BASE_DATE, currDate, SEASON))

    jsonData = scraper.downloadJson(url)
    #jsonData = json.load(open(PARENT_DIR + '/tbx_2015-10-27.json'))

    dataValues = getDataValues(jsonData)
    if len(dataValues) > 0 and dataValues != prevDataValues:
        baseFilename = baseDateStr + '-' + currDate.strftime(DATE_FORMAT_FILENAME)
        scraper.writeJsonData(jsonData, scraper.createJsonFilename(PARENT_DIR, baseFilename))
    else:
        print '==========================================='
        print '***HEADS UP!  NO DATA FOUND FOR=', currDate
        print '==========================================='

    prevDataValues = dataValues
    currDate = currDate + ONE_DAY

    print '    Sleeping for %d seconds...' % SLEEP
    time.sleep(SLEEP)


print 'Done!'
