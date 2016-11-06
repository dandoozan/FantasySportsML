import urllib2
from bs4 import BeautifulSoup
from time import sleep
from datetime import datetime, date, timedelta

SITE = 'fd'
START_DATE = date(2016, 10, 25)
END_DATE = date(2016, 11, 5)
ONE_DAY = timedelta(1)
f = open('%s_%s.txt' % (SITE, START_DATE.strftime('%Y')), 'a')

currDate = START_DATE
while currDate <= END_DATE:
    year = currDate.year
    month = currDate.month
    day = currDate.day
    url = 'http://rotoguru1.com/cgi-bin/hyday.pl?game=%s&mon=%d&day=%d&year=%d&scsv=1' % (SITE, month, day, year)
    print '***URL=', url

    #f = open(currDate.strftime('%Y-%m-%d') + '.txt', 'w')
    #f.write(urllib2.urlopen(url).read())
    #f.close()
    soup = BeautifulSoup(urllib2.urlopen(url).read(), 'html.parser')
    #soup = BeautifulSoup(open('2014-10-24.txt'), 'html.parser')

    data = soup.pre.string.strip()

    #check if there is data for this date, if so store it
    if data.find('\n') > -1:
        #remove header line
        data = data[data.find('\n'):]

        print '***DATA=', data[:400], '\n'

        f.write(data)

    currDate = currDate + ONE_DAY
    sleep(1)
f.close()
