import urllib2
from bs4 import BeautifulSoup
from datetime import datetime
import scraper
import _util as util

PARENT_DIR = util.joinDirs('data', 'rawDataFromRotoGuru')
DATE_FORMAT = '%Y-%m-%d'

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

date = util.getYesterdayAsDate()
dateStr = util.formatDate(date, DATE_FORMAT)
shouldScrapeYesterday = raw_input(('Scrape yesterday (%s)? ' % dateStr)).strip() == 'y'
if not shouldScrapeYesterday:
    dateStr = raw_input('Enter date (eg. 2016-11-06): ').strip()
    date = util.parseDate(dateStr, DATE_FORMAT)

data = downloadData(date)
writeData(data, util.createFullPathFilename(PARENT_DIR, util.createTxtFilename(dateStr)))

print 'Done!'
