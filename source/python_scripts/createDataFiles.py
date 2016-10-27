from datetime import datetime, timedelta

DATE_FORMAT = '%Y%m%d'
DATA_LOCATION = 'data/'
Y_NAME = 'FantasyPoints'
X_NAMES = ['Name', 'Date', 'Salary', 'Position']

def readInput():
    print 'Enter date (eg. 20161025):'
    return raw_input().strip()

def loadData():
    dataFilename = 'data/rawDataFromRotoGuru/fd_all.txt'
    print 'Loading data from', dataFilename, '...'
    #get data
    f = open(dataFilename)
    f.readline()

    yData = [] #vector
    XData = [] #matrix
    for line in f:
        sp = line.strip().split(';')

        #y
        fantasyPoints = float(sp[5])
        yData.append(fantasyPoints)

        #features
        date = sp[0].strip()
        position = sp[2].strip()
        name = sp[3].strip().replace(',', '')
        salary = sp[6].strip()
        salary = '' if salary == 'N/A' else str(int(salary[1:].replace(',', '')))
        XData.append((name, date, salary, position))
    f.close()

    return yData, XData

def getStartIndexOfDate(data, date):
    startDateIndex = len(data)
    for i in xrange(len(data)):
        datum = data[i]
        dte = datetime.strptime(datum[1], DATE_FORMAT)
        if dte >= date:
            if dte > date:
                print 'Did not find the date=', date
            startDateIndex = i
            break
    return startDateIndex

def getEndIndexOfDate(data, date):
    endDateIndex = len(data)
    for i in xrange(len(data)):
        datum = data[i]
        dte = datetime.strptime(datum[1], DATE_FORMAT)
        if dte > date:
            endDateIndex = i
            break
    return endDateIndex

def getTrainData(y, X, date):
    #get all data up to date
    index = getStartIndexOfDate(X, date)
    yTrain = y[:index]
    XTrain = X[:index]
    return yTrain, XTrain

def getTestData(X, date):
    #get all data at date
    startIndex = getStartIndexOfDate(X, date)
    endIndex = getEndIndexOfDate(X, date)
    return X[startIndex:endIndex]

def writeData(filename, XData, yData=None):
    print 'Writing data to:', filename
    f = open(filename, 'w')

    #print col names
    if yData:
        f.write(Y_NAME + ',')
    f.write(','.join(X_NAMES) + '\n')

    for i in xrange(len(XData)):
        if yData:
            f.write(str(yData[i]) + ',')
        f.write(','.join(map(str, XData[i])) + '\n')
    f.close()

def createFilename(baseFilename):
    return DATA_LOCATION + baseFilename + '.csv'

#============= MAIN =============


dateStr = readInput()

date = datetime.strptime(dateStr, DATE_FORMAT)

y, X = loadData()
train_y, train_X = getTrainData(y, X, date)
test = getTestData(X, date)
writeData(createFilename('train'), train_X, train_y)
writeData(createFilename('test'), test)
