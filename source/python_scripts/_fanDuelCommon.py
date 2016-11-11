def is5050Contest(contestName):
    import re
    return not not re.match('50/50 Contest \(\$\d+ - Top 50% Win\)', contestName)
