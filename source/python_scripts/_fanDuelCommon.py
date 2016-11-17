import _util as util

CONTEST_TYPES = {
    '5050': 'FIFTY_FIFTY',
    'h2h': 'H2H',
    'muliplier': 'MULTIPLIER',
    'league': 'LEAGUE',
    'tournament': 'TOURNAMENT',
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
def is5050Contest(contest):
    import re
    return not not re.match('50/50 Contest \(\$\d+ - Top 50% Win\)', getContestName(contest))
def isH2HContest(contest):
    return contest['h2h'] != None
def isLeagueContest(contest):
    maxEntries = getContestMaxEntries(contest)
    return maxEntries >=3 and maxEntries <= 100
def isMultiplierContest(contest):
    import re
    #Search for:
    #-Double Up, Triple Up, Quadruple Up, Quintuple Up
    #-Triple Double
    return not not re.search(' ((Double|Triple|Quadruple|Quintuple) Up|Triple Double) ', getContestName(contest))
def isTournamentContest(contest):
    import re
    return getContestMaxEntries(contest) > 100 and getContestPot(contest) > 1000
def getContestType(contest):
    #Types: H2H, FIFTY_FIFTY, MULTIPLIER, LEAGUE, TOURNAMENT
    #First check for H2H,
    #then FIFTY_FIFTY,
    #then MULTIPLIER,
    #then LEAGUE (3-100 players)
    #then TOURNAMENT (>1000 players)
    #then throw error if there are any contests left
    if isH2HContest(contest):
        return CONTEST_TYPES['h2h']
    if is5050Contest(contest):
        return CONTEST_TYPES['5050']
    if isMultiplierContest(contest):
        return CONTEST_TYPES['muliplier']
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