import _util as util

PRIVATE_DATA = util.loadJsonFile(util.createFullPathFilename('private', 'fanduel.json'))
CONTEST_TYPES = {
    '5050': 'FIFTY_FIFTY',
    'doubleUp': 'DOUBLE_UP',
    'h2h': 'H2H',
    'league': 'LEAGUE',
    'quadrupleUp': 'QUADRUPLE_UP',
    'quintupleUp': 'QUINTUPLE_UP',
    'tournament': 'TOURNAMENT',
    'tripleUp': 'TRIPLE_UP',
    'tripleDouble': 'TRIPLE_DOUBLE',
}
DATES_WITH_NO_CONTESTS = { #these are dates with no fanduel contests (likely dates with no NBA games too, except 4/3 had a NBA game but no contest for some reason)
    '2016-11-24',
    '2016-12-24',
    '2017-02-17',
    '2017-02-18',
    '2017-02-19',
    '2017-02-20',
    '2017-02-21',
    '2017-02-22',
    '2017-04-03',
}

def getHeaders(referer, xAuthToken):
    return {
        'Accept': 'application/json, text/plain, */*',
        #'Accept-Encoding': 'gzip, deflate, sdch, br',
        'Accept-Language': 'en-US,en;q=0.8',
        'Authorization': PRIVATE_DATA['Authorization'],
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        'Host': 'api.fanduel.com',
        'Origin': 'https://www.fanduel.com',
        'Pragma': 'no-cache',
        'Referer': referer,
        'X-Auth-Token': xAuthToken,
    }

#------------ Getters ------------
def getEntryFee(contest):
    return int(contest['entry_fee'])
def getContestId(contest):
    return contest['id'].strip()
def getContestMaxEntries(contest):
    return int(contest['size']['max'])
def getContestName(contest):
    return contest['name'].strip()
def getContestPot(contest):
    return float(contest['prizes']['total'])

#------------ Contest types ------------
def searchContestName(string, contest):
    import re
    return not not re.search(string, getContestName(contest))
def matchContestName(string, contest):
    import re
    return not not re.match(string, getContestName(contest))
def is5050Contest(contest):
    return matchContestName('50/50 Contest \(\$\d+ - Top 50% Win\)', contest)
def isH2HContest(contest):
    return contest['h2h'] != None
def isLeagueContest(contest):
    maxEntries = getContestMaxEntries(contest)
    return (not is5050Contest(contest)) \
        and (not isH2HContest(contest)) \
        and (not isMultiplierContest(contest)) \
        and maxEntries >=3 and maxEntries <= 100
def _isXupleUp(upleStr, contest):
    #Note upleStr is expected to be 'Double', 'Triple', etc
    return searchContestName((' %s Up ' % upleStr), contest)
def isDoubleUp(contest):
    return _isXupleUp('Double', contest)
def isTripleUp(contest):
    return _isXupleUp('Triple', contest)
def isQuadrupleUp(contest):
    return _isXupleUp('Quadruple', contest)
def isQuintupleUp(contest):
    return _isXupleUp('Quintuple', contest)
def isTripleDouble(contest):
    return searchContestName(' Triple Double ', contest)
def isMultiplierContest(contest):
    return isDoubleUp(contest) or isTripleUp(contest) or isQuadrupleUp(contest) or isQuintupleUp(contest) or isTripleDouble(contest)
def isTournamentContest(contest):
    return (not is5050Contest(contest)) \
        and (not isH2HContest(contest)) \
        and (not isMultiplierContest(contest)) \
        and (not isLeagueContest(contest)) \
        and getContestMaxEntries(contest) > 100 and getContestPot(contest) > 1000
def getContestType(contest):
    if isH2HContest(contest):
        return CONTEST_TYPES['h2h']
    if is5050Contest(contest):
        return CONTEST_TYPES['5050']
    if isDoubleUp(contest):
        return CONTEST_TYPES['doubleUp']
    if isTripleUp(contest):
        return CONTEST_TYPES['tripleUp']
    if isQuadrupleUp(contest):
        return CONTEST_TYPES['quadrupleUp']
    if isQuintupleUp(contest):
        return CONTEST_TYPES['quintupleUp']
    if isTripleDouble(contest):
        return CONTEST_TYPES['tripleDouble']
    if isLeagueContest(contest):
        return CONTEST_TYPES['league']
    if isTournamentContest(contest):
        return CONTEST_TYPES['tournament']
    #should never get here
    util.stop('Found an unknown contest=' + getContestName(contest))

#------------ Other ------------
def contestIsCancelled(contest):
    return contest['cancellation'] != None
def isValidContestId(contestId):
    import re
    return len(contestId) == 15 and re.match('\d{5}-\d{9}', contestId)
