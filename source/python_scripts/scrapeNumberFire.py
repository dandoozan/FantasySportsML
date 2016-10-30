from datetime import date
import time
from bs4 import BeautifulSoup
import scraper

PARENT_DIR = 'data/rawDataFromNumberFire'
URL = 'https://www.numberfire.com/nba/daily-fantasy/daily-basketball-projections'
FILENAME = date.today().strftime('%Y-%m-%d')
#FILENAME = '2016-10-25'

def parseData(data):
    print '    Parsing data...'

    rowData = []
    colNames = []

    soup = BeautifulSoup(data, 'html.parser')

    #first, scrape player name and position
    colNames.append('Name')
    colNames.append('Position')
    playerInfos = soup.find_all('span', class_='player-info')
    for node in playerInfos:
        name = scraper.getText(node.find('a', class_='full'))
        position = scraper.getText(node.find('span', class_='player-info--position'))

        #append data to rowData
        rowData.append([name, position])


    #then, scrape the stats, which are in a separate table
    numRows = len(rowData)
    cols = [
        { 'colName': 'Min', 'tdClass': 'min' },
        { 'colName': 'Pts', 'tdClass': 'pts' },
        { 'colName': 'Reb', 'tdClass': 'reb' },
        { 'colName': 'Ast', 'tdClass': 'ast' },
        { 'colName': 'Stl', 'tdClass': 'stl' },
        { 'colName': 'Blk', 'tdClass': 'blk' },
        { 'colName': 'TO', 'tdClass': 'to' },
        { 'colName': 'FP', 'tdClass': 'fp' },
        { 'colName': 'Cost', 'tdClass': 'cost' },
        { 'colName': 'Value', 'tdClass': 'value' },
    ]
    for col in cols:
        colName = col['colName']
        tdClass = col['tdClass']

        colData = soup.find_all('td', class_=tdClass)

        #verify that this col data has the same number of rows as the others
        if len(colData) != numRows:
            raise(Exception('DPD ERROR: I got the wrong number of rows in col=', colName))

        #add this col's data to rowData
        for i in xrange(numRows):
            rowData[i].append(scraper.getText(colData[i]))

        #add colName to colNames
        colNames.append(colName)

    return colNames, rowData

def createFilename(parentDir, baseFilename):
    return parentDir + '/' + baseFilename + '.csv'

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

print '\nScraping NumberFire...'

pageSource = scraper.downloadPageSource(URL)
#pageSource = open(PARENT_DIR + '/' + FILENAME + '.html')
colNames, rowData = parseData(pageSource)
writeData(colNames, rowData, createFilename(PARENT_DIR, FILENAME))

print 'Done!'
