import os
import re
from datetime import date, timedelta
from bs4 import BeautifulSoup
import json
import scraper

#This file does the following:
#1. scrape 'Daily Fantasy Tournament Links - [Date]' url from https://rotogrinders.com/threads/category/main
#2. scrape contest urls from 'Daily Fantasy Tournament Links - [Date]' page
#3. for each contest
    #-download its results from api.fanduel.com

TEST = False

RG_FORUM_URL = 'https://rotogrinders.com/threads/category/main'
TODAY = date.today()
YESTERDAY = TODAY - timedelta(1)
PARENT_DIR = 'data/rawDataFromFanDuel/Contests/' + YESTERDAY.strftime('%Y-%m-%d')
SLEEP = 10

def isContestLinksUrl(url, date):
    #https://rotogrinders.com/threads/daily-fantasy-tournament-links-saturday-october-29th-1512252
    dateStr = date.strftime('%A-%B-%d').lower()
    regexPattern = 'https://rotogrinders.com/threads/daily-fantasy-tournament-links-%s(st|nd|rd|th)-\d+' % dateStr
    return not not re.match(regexPattern, url)

def scrapeRotoGrinderForum(url, date):
    print 'Scraping RotoGrinder Forum...'

    pageSource = scraper.downloadPageSource(url)

    soup = BeautifulSoup(pageSource, 'html.parser')
    table = soup.find('table', class_='forum')
    if table:
        tds = table.find_all('td', class_='topic')
        for td in tds:
            atag = td.find_all('a', recursive=False)[0]
            href = atag.get('href')
            if isContestLinksUrl(href, date):
                return href

def isFanduelUrl(url):
    #https://www.fanduel.com/games/16754/contests/16754-202913340/scoring
    regexPattern = 'https://www.fanduel.com/games/\d+/contests/\d+-\d+/scoring'
    return not not re.match(regexPattern, url)

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
    print 'Scraping RotoGrinder Tournaments Page...'

    contests = []

    pageSource = open(PARENT_DIR + '/' + YESTERDAY.strftime('%Y-%m-%d') + '.html') if TEST else scraper.downloadPageSource(url)
    soup = BeautifulSoup(pageSource, 'html.parser')
    div = soup.find('div', class_='content')
    if div:
        atags = div.find_all('a')
        for atag in atags:
            href = atag.get('href')
            text = atag.get_text().strip()
            if isFanduelUrl(href) and isNbaContest(text):
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

print 'Scraping contest results for yesterday: ', YESTERDAY

#make dir
if not os.path.isdir(PARENT_DIR):
    os.makedirs(PARENT_DIR)

#1. scrape 'Daily Fantasy Tournament Links - [Date]' url from https://rotogrinders.com/threads/category/main
rgTournamentLinksUrl = scrapeRotoGrinderForum(RG_FORUM_URL, YESTERDAY)
if rgTournamentLinksUrl:
    scraper.sleep(SLEEP)

    #2. scrape contest urls from 'Daily Fantasy Tournament Links - [Date]' page
    contests = scrapeContestsFromRotoGrinder(rgTournamentLinksUrl)
    if len(contests) > 0:
        scraper.sleep(SLEEP)

        #3. for each contest, download its results from api.fanduel.com
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

            scraper.sleep(SLEEP)

            cnt += 1
    else:
        scraper.headsUp('No contests found on RotoGrinder Contest Page')
else:
    scraper.headsUp('No contest link found on forum')

print 'Done!'
