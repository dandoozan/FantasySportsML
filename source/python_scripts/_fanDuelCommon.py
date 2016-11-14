def is5050Contest(contest):
    import re
    return not not re.match('50/50 Contest \(\$\d+ - Top 50% Win\)', contest['name'].strip())
def getEntryFee(contest):
    return int(contest['entry_fee'])
def getContestId(contest):
    return contest['id']

def isValidContestId(contestId):
    import re
    return len(contestId) == 15 and re.match('\d{5}-\d{9}', contestId)