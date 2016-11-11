import urllib2
from bs4 import BeautifulSoup
import datetime
import scraper
import _util as util

PARENT_DIR = util.joinDirs('data', 'rawDataFromRotoGuru')
DATE_FORMAT = '%Y-%m-%d'
SEASON_START_DATE = datetime.date(2016, 10, 25)
YESTERDAY = util.getYesterdayAsDate()
ONE_DAY = util.getOneDay()
SLEEP = 5

def downloadData(date):
    url = 'http://rotoguru1.com/cgi-bin/hyday.pl?game=fd&mon=%d&day=%d&year=%d&scsv=1' % (date.month, date.day, date.year)
    pageSource = scraper.downloadPageSource(url)

    soup = BeautifulSoup(pageSource, 'html.parser')
    #soup = BeautifulSoup(open('data/rawDataFromRotoGuru/tbx_2016-10-25.txt'), 'html.parser')

    data = soup.pre.string.strip().split('\n')

    #make sure i get a header as expected before i chop off the first line
    if data[0][:5] != 'Date;':
        print '    ERROR: I didn\'t get a header like expected. See if the website changed their data format. Stopping.'
        exit()

    return data

def writeData(data, fullPathFilename):
    print 'Writing %d lines of data to %s' %(len(data), fullPathFilename)

    f = open(fullPathFilename, 'w')
    for line in data:
        f.write(line + '\n')
    f.close()

#=============== Main ================

currDate = SEASON_START_DATE
while currDate < YESTERDAY:
    currDateStr = util.formatDate(currDate)
    fullPathFilename = util.createFullPathFilename(PARENT_DIR, util.createCsvFilename(currDateStr))
    if util.fileExists(fullPathFilename):
        print '    Skipping date because file exists: ' + fullPathFilename
    else:
        data = downloadData(currDate)
        writeData(data, fullPathFilename)
        scraper.sleep(SLEEP)
    currDate = currDate + ONE_DAY

print 'Done!'
