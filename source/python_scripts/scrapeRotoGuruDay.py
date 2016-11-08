import urllib2
from bs4 import BeautifulSoup
from datetime import datetime
import scraper
import _util as util

PARENT_DIR = util.joinDirs('data', 'rawDataFromRotoGuru')
DATE_FORMAT = '%Y-%m-%d'
ONE_DAY = util.getOneDay()
YESTERDAY = util.getYesterdayAsDate()
SLEEP = 2

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

dateInput = raw_input('Enter start date if different than yesterday (eg. 2016-10-25): ').strip()
startDate = YESTERDAY if dateInput == '' else util.parseDate(dateInput)

currDate = startDate
while currDate <= YESTERDAY:
    currDateStr = util.formatDate(currDate)
    data = downloadData(currDate)
    writeData(data, util.createFullPathFilename(PARENT_DIR, util.createTxtFilename(currDateStr)))
    currDate = currDate + ONE_DAY
    scraper.sleep(SLEEP)

print 'Done!'
