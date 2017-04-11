import sys
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
        'endDate': util.getYesterdayAsDate(),
    },
}

PLAYER_CATEGORIES = {
    'Traditional': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerstats?',
        'urlParams': {
            'College': '',
            'Country': '',
            'DraftPick': '',
            'DraftYear': '',
            'Height': '',
            'MeasureType': 'Base',
            'PaceAdjust': 'N',
            'PlusMinus': 'N',
            'Rank': 'N',
            'Weight': '',
        },
    },
    'Traditional_Diff': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerstats?',
        'urlParams': {
            'College': '',
            'Country': '',
            'DraftPick': '',
            'DraftYear': '',
            'Height': '',
            'MeasureType': 'Base',
            'PaceAdjust': 'N',
            'PlusMinus': 'Y',
            'Rank': 'N',
            'Weight': '',
        },
    },
    'Advanced': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerstats?',
        'urlParams': {
            'College': '',
            'Country': '',
            'DraftPick': '',
            'DraftYear': '',
            'Height': '',
            'MeasureType': 'Advanced',
            'PaceAdjust': 'N',
            'PerMode': 'Totals',
            'PlusMinus': 'N',
            'Rank': 'N',
            'Weight': '',
        },
    },
    'Opponent': {
        'baseUrl': 'http://stats.nba.com/stats/leagueplayerondetails?',
        'urlParams': {
            'College': '',
            'Country': '',
            'DraftPick': '',
            'DraftYear': '',
            'Height': '',
            'MeasureType': 'Opponent',
            'PaceAdjust': 'N',
            'PerMode': 'Per100Possessions',
            'PlusMinus': 'N',
            'Rank': 'N',
            'Weight': '',
        },
    },
    'Defense': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerstats?',
        'urlParams': {
            'College': '',
            'Country': '',
            'DraftPick': '',
            'DraftYear': '',
            'Height': '',
            'MeasureType': 'Defense',
            'PaceAdjust': 'N',
            'PlusMinus': 'N',
            'Rank': 'N',
            'Weight': '',
        },
    },
    'Scoring': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerstats?',
        'urlParams': {
            'College': '',
            'Country': '',
            'DraftPick': '',
            'DraftYear': '',
            'Height': '',
            'MeasureType': 'Scoring',
            'PaceAdjust': 'N',
            'PlusMinus': 'N',
            'Rank': 'N',
            'Weight': '',
        },
    },
    'Usage': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerstats?',
        'urlParams': {
            'College': '',
            'Country': '',
            'DraftPick': '',
            'DraftYear': '',
            'Height': '',
            'MeasureType': 'Usage',
            'PaceAdjust': 'N',
            'PerMode': 'Totals',
            'PlusMinus': 'N',
            'Rank': 'N',
            'Weight': '',
        },
    },
    'PlayerBios': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashplayerbiostats?',
        'endDate': util.getTodayAsDate(),
        'urlParams': {
            'College': '',
            'Country': '',
            'DateFrom': '',
            'DateTo': '',
            'DraftPick': '',
            'DraftYear': '',
            'Height': '',
            'Weight': '',
        },
    }
}
TEAM_CATEGORIES = {
    'Traditional': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashteamstats?',
        'headers': {
            'Referer': 'http://stats.nba.com/league/team/'
        },
        'urlParams': {
            'MeasureType': 'Base',
            'PaceAdjust': 'N',
            'PlusMinus': 'N',
            'Rank': 'N',
        }
    },
    'Advanced': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashteamstats?',
        'headers': {
            'Referer': 'http://stats.nba.com/league/team/'
        },
        'urlParams': {
            'MeasureType': 'Advanced',
            'PaceAdjust': 'N',
            'PerMode': 'Totals',
            'PlusMinus': 'N',
            'Rank': 'N',
        },
    },
    'FourFactors': {
        'baseUrl': 'http://stats.nba.com/stats/leaguedashteamstats?',
        'headers': {
            'Referer': 'http://stats.nba.com/league/team/'
        },
        'urlParams': {
            'MeasureType': 'Four Factors',
            'PaceAdjust': 'N',
            'PerMode': 'Totals',
            'PlusMinus': 'N',
            'Rank': 'N',
        },
    },
}

def createUrlParams(startDate, endDate, season, extraParams):
    dateFormat = '%m/%d/%Y'
    urlParams = {
        'Conference': '',
        'DateFrom': startDate.strftime(dateFormat) if startDate else '', #eg.'10/27/2015',
        'DateTo': endDate.strftime(dateFormat) if endDate else '',
        'Division': '',
        'GameScope': '',
        'GameSegment': '',
        'LastNGames': '0',
        'LeagueID': '00',
        'Location': '',
        'Month': '0',
        'OpponentTeamID': '0',
        'Outcome': '',
        'PORound': '0',
        'PerMode': 'PerGame',
        'Period': '0',
        'PlayerExperience': '',
        'PlayerPosition': '',
        'Season': season,
        'SeasonSegment': '',
        'SeasonType': 'Regular Season',
        'ShotClockRange': '',
        'StarterBench': '',
        'TeamID': '0',
        'VsConference': '',
        'VsDivision': '',
    }
    urlParams.update(extraParams)
    return urlParams
def createHeaders(hdrs):
    headers = {
        'Accept': 'application/json, text/plain, */*',
        #'Accept-Encoding': 'gzip, deflate, sdch',
        'Accept-Language': 'en-US,en;q=0.8',
        'Cache-Control': 'no-cache',
        'Cookie': 'ug=58d86b960c26f00a3c8f7873980084c7; ugs=1; _ga=GA1.2.624056311.1491942990; s_cc=true; s_sq=%5B%5BB%5D%5D; s_vi=[CS]v1|2C769F260519410C-600006056003B198[CE]; s_fid=657B70FBDE2E63B6-0634C28D0F3D7667',
        'Connection': 'keep-alive',
        'Host':'stats.nba.com',
        'Pragma': 'no-cache',
        'Referer': 'http://stats.nba.com/players/traditional/',
        'x-nba-stats-origin': 'stats',
        'x-nba-stats-token': 'true',
    }
    headers.update(hdrs)
    return headers

def getDataValues(data):
    return data['resultSets'][0]['rowSet']

def getSummary(isDaily, isTeam, category, season):
    return '%s, %s, %s, %s' % ('Daily' if isDaily else 'Season', 'Team' if isTeam else 'Player', category, season)

#=============== Main ================

cmdLineArgs = util.getCommandLineArguments(4)

#verify command line args
if cmdLineArgs[0] != 'Daily' and cmdLineArgs[0] != 'Season' \
        and cmdLineArgs[1] != 'Team' and cmdLineArgs[1] != 'Player' \
        and cmdLineArgs[1] == 'Player' and cmdLineArgs[2] not in PLAYER_CATEGORIES \
        and cmdLineArgs[1] == 'Team' and cmdLineArgs[2] not in TEAM_CATEGORIES \
        and cmdLineArgs[3] not in SEASONS:
    exit('***Got an unexpected command line argument')

isDaily = cmdLineArgs[0] == 'Daily'
isTeam = cmdLineArgs[1] == 'Team'
category = cmdLineArgs[2]
season = cmdLineArgs[3]

print 'Running ' + getSummary(isDaily, isTeam, category, season) + '...'

parentDir = util.joinDirs(NBA_DIR, 'Daily' if isDaily else 'Season', ('Team_' if isTeam else '') + category, season)
util.createDirIfNecessary(parentDir)

seasonObj = SEASONS[season]
seasonStartDate = seasonObj['startDate']
seasonEndDate = seasonObj['endDate']

categoryObj = TEAM_CATEGORIES[category] if isTeam else PLAYER_CATEGORIES[category]
baseUrl = categoryObj['baseUrl']
endDate = util.getObjValue(categoryObj, 'endDate', seasonEndDate) if season == '2016' else seasonEndDate
urlParams = categoryObj['urlParams'] if 'urlParams' in categoryObj else {}
headers = categoryObj['headers'] if 'headers' in categoryObj else {}

lastFileInDir = util.getLastFileInDir(parentDir)
currDate = util.parseAsDate(util.parseBaseFilename(lastFileInDir)) + ONE_DAY if lastFileInDir else seasonStartDate
while currDate <= endDate:
    currDateStr = util.formatDate(currDate)
    fullPathFilename = util.createFullPathFilename(parentDir, util.createJsonFilename(currDateStr))
    print '\n%s data for %s...' % ('Overwriting' if util.fileExists(fullPathFilename) else 'Downloading', currDateStr)

    startDate = currDate if isDaily else None
    url = scraper.createUrl(baseUrl, createUrlParams(startDate, currDate, seasonObj['str'], urlParams))

    jsonData = scraper.downloadJson(url, createHeaders(headers))
    #jsonData = json.load(open(PARENT_DIR + '/tbx_2015-10-27.json'))

    dataValues = getDataValues(jsonData)
    if len(dataValues) > 0:
        util.writeJsonData(jsonData, fullPathFilename, prettyPrint=True)
    else:
        util.headsUp('NO DATA FOUND FOR=' + currDate.strftime(DATE_FORMAT_FILENAME))

    currDate = currDate + ONE_DAY
    if currDate <= seasonEndDate:
        util.sleep(SLEEP)

print 'Done!  Finished ' + getSummary(isDaily, isTeam, category, season)
