from datetime import date, timedelta
import time
import json
import scraper
import _util as util

NBA_DIR = 'data/rawDataFromStatsNba'
DATE_FORMAT_FILENAME = '%Y-%m-%d'
ONE_DAY = util.getOneDay()
SLEEP = 10

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
    '2016': {
        'str': '2016-17',
        'startDate': date(2016, 10, 25),
        'endDate': util.getYesterdayAsDate() - ONE_DAY,
    },
}

PLAYER_CATEGORIES = {
    'Traditional': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerstats?',
        'params': {
            'College': '',
            'Country': '',
            'DraftPick': '',
            'DraftYear': '',
            'Height': '',
            'Weight': '',
        },
    },
    'Traditional_Diff': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerstats?',
        'params': {
            'College': '',
            'Country': '',
            'DraftPick': '',
            'DraftYear': '',
            'Height': '',
            'PlusMinus': 'Y',
            'Weight': '',
        },
    },
    'Advanced': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerstats?',
        'params': {
            'College': '',
            'Country': '',
            'DraftPick': '',
            'DraftYear': '',
            'Height': '',
            'MeasureType': 'Advanced',
            'PerMode': 'Totals',
            'Weight': '',
        },
    },
    'Opponent': {
        'baseUrl': 'http://stats.nba.com/stats/leagueplayerondetails?',
        'params': {
            'College': '',
            'Country': '',
            'DraftPick': '',
            'DraftYear': '',
            'Height': '',
            'MeasureType': 'Opponent',
            'PerMode': 'Per100Possessions',
            'Weight': '',
        },
    },
    'Defense': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerstats?',
        'params': {
            'College': '',
            'Country': '',
            'DraftPick': '',
            'DraftYear': '',
            'Height': '',
            'MeasureType': 'Defense',
            'Weight': '',
        },
    },
    'Scoring': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerstats?',
        'params': {
            'College': '',
            'Country': '',
            'DraftPick': '',
            'DraftYear': '',
            'Height': '',
            'MeasureType': 'Scoring',
            'Weight': '',
        },
    },
    'Usage': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerstats?',
        'params': {
            'College': '',
            'Country': '',
            'DraftPick': '',
            'DraftYear': '',
            'Height': '',
            'MeasureType': 'Usage',
            'PerMode': 'Totals',
            'Weight': '',
        },
    },
}
TEAM_CATEGORIES = {
    'Traditional': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashteamstats?',
        'headers': {
            'Referer': 'http://stats.nba.com/league/team/'
        },
    },
    'Advanced': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashteamstats?',
        'headers': {
            'Referer': 'http://stats.nba.com/league/team/'
        },
        'params': {
            'MeasureType': 'Advanced',
            'PerMode': 'Totals',
        },
    },
    'FourFactors': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashteamstats?',
        'headers': {
            'Referer': 'http://stats.nba.com/league/team/'
        },
        'params': {
            'MeasureType': 'Four Factors',
            'PerMode': 'Totals',
        },
    },
}


def createUrlParams(startDate, endDate, season, params):
    dateFormat = '%m/%d/%Y'
    urlParams = {
        'Conference': '',
        'DateFrom': startDate.strftime(dateFormat) if startDate else '', #eg.'10/27/2015',
        'DateTo': endDate.strftime(dateFormat),
        'Division': '',
        'GameScope': '',
        'GameSegment': '',
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
    }
    urlParams.update(params)
    return urlParams
def createHeaders(hdrs):
    headers = {
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
    headers.update(hdrs)
    return headers

def getDataValues(data):
    return data['resultSets'][0]['rowSet']

def getSummary(isDaily, isTeam, category, season):
    return '%s, %s, %s, %s' % ('Daily' if isDaily else 'Season', 'Team' if isTeam else 'Player', category, season)

#=============== Main ================

isDaily = raw_input('Daily (leave blank for no)? ').strip() == 'y'
isTeam = raw_input('Team (leave blank for no)? ').strip() == 'y'
categoryInput = raw_input('Enter Category (if other than Traditional): ').strip()
category = 'Traditional' if categoryInput == '' else categoryInput
seasonInput = raw_input('Enter season (if other than 2016): ').strip()
season = '2016' if seasonInput == '' else seasonInput

print 'Running ' + getSummary(isDaily, isTeam, category, season) + '...'

parentDir = util.joinDirs(NBA_DIR, 'Daily' if isDaily else 'Season', ('Team_' if isTeam else '') + category, season)
util.createDirIfNecessary(parentDir)

seasonObj = SEASONS[season]
seasonStartDate = seasonObj['startDate']
seasonEndDate = seasonObj['endDate']

categoryObj = TEAM_CATEGORIES[category] if isTeam else PLAYER_CATEGORIES[category]
baseUrl = categoryObj['baseUrl']
params = categoryObj['params'] if 'params' in categoryObj else {}
headers = categoryObj['headers'] if 'headers' in categoryObj else {}

currDate = seasonStartDate
prevDataValues = None
while currDate <= seasonEndDate:
    print '\nDownloading data for ' + str(currDate) + '...'
    fullPathFilename = util.createFullPathFilename(parentDir, util.createJsonFilename(util.formatDate(currDate)))
    if util.fileExists(fullPathFilename):
        print '    Skipping date because file exists: ' + fullPathFilename
    else:
        startDate = currDate if isDaily else None
        url = scraper.createUrl(baseUrl, createUrlParams(startDate, currDate, seasonObj['str'], params))

        jsonData = scraper.downloadJson(url, createHeaders(headers))
        #jsonData = json.load(open(PARENT_DIR + '/tbx_2015-10-27.json'))

        dataValues = getDataValues(jsonData)
        if len(dataValues) > 0 and dataValues != prevDataValues:
            scraper.writeJsonData(jsonData, fullPathFilename, prettyPrint=False)
        else:
            util.headsUp('NO DATA FOUND FOR=' + currDate.strftime(DATE_FORMAT_FILENAME))

        prevDataValues = dataValues

        print '    Sleeping for %d seconds...' % SLEEP
        time.sleep(SLEEP)

    currDate = currDate + ONE_DAY

print 'Done!  Finished ' + getSummary(isDaily, isTeam, category, season)
