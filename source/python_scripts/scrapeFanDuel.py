import os
from datetime import date, timedelta
import time
from bs4 import BeautifulSoup
import json
import scraper

TEST = False

TODAY = date.today()
YESTERDAY = TODAY - timedelta(1)
PARENT_DIR = 'data/rawDataFromFanDuel/Contests/' + YESTERDAY.strftime('%Y-%m-%d')
SLEEP = 10

def isFanduelUrl(url):
    #todo: imporove this by using a regex match of whole url
    return url.find('://www.fanduel.com/games/') > -1

def isNbaContest(contestName):
    return contestName.find('NBA') > -1

def getRotoGrinderContestLinksUrl():
    return raw_input('Enter RotoGrinder Contest Links Url: ')

def parseContestFromUrl(url):
    #https://www.fanduel.com/games/16754/contests/16754-202913340/scoring
    startIndex = url.find('/contests/') + 10
    endIndex = url.find('/', startIndex)
    return url[startIndex:endIndex]

def scrapeContestsFromRotoGrinder(url):
    print 'Scraping RotoGrinder...'

    #tbx
    print '    url=',url

    pageSource = open(PARENT_DIR + '/' + YESTERDAY.strftime('%Y-%m-%d') + '.html') if TEST else scraper.downloadPageSource(url)

    soup = BeautifulSoup(pageSource, 'html.parser')
    atags = soup.find('div', class_='content').find_all('a')

    contests = []

    for atag in atags:
        href = atag.get('href')
        text = atag.get_text().strip()
        if isFanduelUrl(href) and isNbaContest(text):
            print href
            contests.append(parseContestFromUrl(href))

    return contests

def createFanduelApiUrl(contest):
    return 'https://api.fanduel.com/contests/' + contest

def parseContestGroup(contest):
    return contest.split('-')[0]

def createHeaders(contest):
    contestGroup = parseContestGroup(contest)
    return {
        'Accept': 'application/json, text/plain, */*',
        #'Accept-Encoding': 'gzip, deflate, sdch, br',
        'Accept-Language': 'en-US,en;q=0.8',
        'Authorization': 'Basic N2U3ODNmMTE4OTIzYzE2NzVjNWZhYWFmZTYwYTc5ZmM6',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        'Host': 'api.fanduel.com',
        'Origin': 'https://www.fanduel.com',
        'Pragma': 'no-cache',
        'Referer': 'https://www.fanduel.com/games/%s/contests/%s/scoring' % (contestGroup, contest),
        'X-Auth-Token': '975a94dbf50089faf4156964a5d0b4c986966124c77587c2fb95d8b0758bbc7a',
    }


#=============== Main ================

#make dir
#comment this out until i figure out how to make dir
#if not os.path.isdir(PARENT_DIR):
#    os.makedirs(PARENT_DIR)

#fetch contests from RotoGrinder
rgUrl = getRotoGrinderContestLinksUrl()
contests = scrapeContestsFromRotoGrinder(rgUrl)

#for each contestId, download its results
cnt = 1
for contest in contests:
    print '\nScraping Contest %s (%d / %d) ...' % (contest, cnt, len(contests))

    url = createFanduelApiUrl(contest)
    headers = createHeaders(contest)

    #tbx
    print '    url=', url
    for h in headers:
        print '   ', h, ':', headers[h]

    jsonData = scraper.downloadJson(url, headers)

    baseFilename = contest
    scraper.writeJsonData(jsonData, scraper.createJsonFilename(PARENT_DIR, baseFilename))

    print '    Sleeping for %d seconds' % SLEEP
    time.sleep(SLEEP)

    cnt += 1

print 'Done!'
