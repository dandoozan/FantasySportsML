import urllib2
from bs4 import BeautifulSoup
from datetime import datetime

DATE_FORMAT = '%Y%m%d'
SITE = 'fd'
FILENAME = 'data/rawDataFromRotoGuru/fd_all.txt'

def getInput():
    print 'Enter date (eg. 20161025):'
    return raw_input().strip()

def downloadData(site, year, month, day):
    print 'Downloading data...'
    url = 'http://rotoguru1.com/cgi-bin/hyday.pl?game=%s&mon=%d&day=%d&year=%d&scsv=1' % (site, month, day, year)
    print '    url:', url

    soup = BeautifulSoup(urllib2.urlopen(url).read(), 'html.parser')
    #soup = BeautifulSoup(open('data/rawDataFromRotoGuru/tbx_2016-10-25.txt'), 'html.parser')

    data = soup.pre.string.strip().split('\n')

    #make sure i get a header as expected before i chop off the first line
    if data[0][:5] != 'Date;':
        print '    ERROR: I didn\'t get a header like expected. See if the website changed their data format. Stopping.'
        exit()

    #Remove header
    data = data[1:]

    return data

def appendData(data, filename):
    print 'Appending %d lines of data to %s' %(len(data), filename)
    f = open(filename, 'a')
    for line in data:
        f.write(line + '\n')
    f.close()

#=============== Main ================

dateStr = getInput()
date = datetime.strptime(dateStr, DATE_FORMAT)
data = downloadData(SITE, date.year, date.month, date.day)
appendData(data, FILENAME)

print 'Done!'
