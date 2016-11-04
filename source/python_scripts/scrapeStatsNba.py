from datetime import date, timedelta
import time
import json
import scraper
import _util as util

CATEGORIES = {
    'Traditional': {
        'measureType': 'Base',
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerstats?',
        'perMode': 'PerGame',
    },
    'Advanced': {
        'measureType': 'Advanced',
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerstats?',
        'perMode': 'Totals',
    },
    'Opponent': {
        'measureType': 'Opponent',
        'baseUrl': 'http://stats.nba.com/stats/leagueplayerondetails?',
        'perMode': 'Per100Possessions',
    },
    'Defense': {
        'measureType': 'Defense',
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerstats?',
        'perMode': 'PerGame',
    },
    'Scoring': {
        'measureType': 'Scoring',
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerstats?',
        'perMode': 'PerGame',
    },
    'Usage': {
        'measureType': 'Usage',
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerstats?',
        'perMode': 'Totals',
    },

}

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
def createHeaders():
    return {
        'Accept': 'application/json, text/plain, */*',
        #'Accept-Encoding': 'gzip, deflate, sdch',
        'Accept-Language': 'en-US,en;q=0.8',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        #'Cookie': '__gads=ID=b3da99dc26c5cfd0:T=1477690842:S=ALNI_MbtFle3YGgA0oDc1DThDwtcxDAorw; crtg_trnr=; AMCVS_7FF852E2556756057F000101%40AdobeOrg=1; ug=57ed5ed1075a9d0a3c745d01dd006f88; ugs=1; AMCV_7FF852E2556756057F000101%40AdobeOrg=817868104%7CMCAID%7C2BF6AF6A051D0177-60000133C0016969%7CMCIDTS%7C17109%7CMCMID%7C14125603868183326573139779677214302359%7CMCAAMLH-1478561842%7C7%7CMCAAMB-1478757451%7CNRX38WO0n5BH8Th-nqAG_A%7CMCOPTOUT-1478159851s%7CNONE; _ga=GA1.2.475993216.1475174256; _gat=1; s_cc=true; s_fid=5F2F8D4AD9297E14-3D79A4301B91CFBF; s_sq=%5B%5BB%5D%5D; s_vi=[CS]v1|2BF6AF6A051D0177-60000133C0016969[CE]',
        'Host':'stats.nba.com',
        'Pragma': 'no-cache',
        'Referer': 'http://stats.nba.com/league/player/',
    }

def getDataValues(data):
    return data['resultSets'][0]['rowSet']

#=============== Main ================

category = raw_input('Enter Category (eg. Traditional): ').strip()
season = raw_input('Enter season (eg. 2015): ').strip()

parentDir = 'data/rawDataFromStatsNba/' + category + '/' + season
util.createDirIfNecessary(parentDir)

seasonObj = SEASONS[season]
startDate = seasonObj['startDate']
endDate = seasonObj['endDate']

categoryObj = CATEGORIES[category]
baseUrl = categoryObj['baseUrl']
measureType = categoryObj['measureType']
perMode = categoryObj['perMode']

currDate = startDate
prevDataValues = None
while currDate <= endDate:
    print '\nScraping data for ' + str(currDate) + '...'

    url = scraper.createUrl(baseUrl, createUrlParams(startDate, currDate, measureType, perMode, seasonObj['str']))

    jsonData = scraper.downloadJson(url, createHeaders())
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
