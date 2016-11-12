def is5050Contest(contest):
    import re
    return not not re.match('50/50 Contest \(\$\d+ - Top 50% Win\)', contest['name'].strip())
def getEntryFee(contest):
    return int(contest['entry_fee'])