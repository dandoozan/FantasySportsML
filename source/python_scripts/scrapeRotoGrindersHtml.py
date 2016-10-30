from datetime import date
import time
from bs4 import BeautifulSoup
import scraper

PARENT_DIR = 'data/rawDataFromRotoGrinders'
FILENAME = date.today().strftime('%Y-%m-%d')
#FILENAME = '2016-10-26'
SLEEP = 10

pagesToScrape = [
    {
        'dirName': 'BackToBack',
        'tableClassName': 'data-table',
        'url': 'https://rotogrinders.com/pages/nba-back-to-back-tool-518716',
    },
]

def getText(node):
    #replace funny apostrophe with regular one
    return node.get_text().replace(u'\u2019', '\'').strip()

def getColNames(table):
    colNames = []
    ths = table.thead.tr.find_all('th')
    for th in ths:
        colNames.append(getText(th))
    return colNames

def getRowData(table):
    rowData = []
    trs = table.tbody.find_all('tr')
    for tr in trs:
        thisRowData = []
        tds = tr.find_all('td')
        for td in tds:
            thisRowData.append(getText(td))
        rowData.append(thisRowData)
    return rowData

def parseData(data, tableClassName):
    print '    Parsing data...'
    soup = BeautifulSoup(data, 'html.parser')
    table = soup.find('table', class_=tableClassName)
    colNames = getColNames(table)
    rowData = getRowData(table)
    return colNames, rowData

def createFilename(parentDir, dirName, baseFilename):
    return parentDir + '/' + dirName + '/' + baseFilename + '.csv'

def writeData(colNames, rowData, fullPathFilename):
    print '    Writing data to ' + fullPathFilename + '...'

    f = open(fullPathFilename, 'w')

    #write colnames
    f.write(','.join(colNames) + '\n')

    #write rows
    for row in rowData:
        f.write(','.join(row) + '\n')

    f.close()

#=============== Main ================


for page in pagesToScrape:
    dirName = page['dirName']
    url = page['url']
    tableClassName = page['tableClassName']

    print '\nScraping %s...' % dirName

    pageSource = scraper.downloadPageSource(url)
    #pageSource = open('data/rawDataFromRotoGrinders/' + dirName + '/' + FILENAME + '.html')
    colNames, rowData = parseData(pageSource, tableClassName)

    writeData(colNames, rowData, createFilename(PARENT_DIR, dirName, FILENAME))

    print '    Sleeping for %d seconds' % SLEEP
    time.sleep(SLEEP)

print 'Done!'