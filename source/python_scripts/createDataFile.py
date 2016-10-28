
DATA_DIR = 'data/'
DATA_FILE = DATA_DIR + 'rawDataFromRotoGuru/fd_2015.txt'
Y_NAME = 'FantasyPoints'
X_NAMES = ['Date', 'Name', 'Salary', 'Position']

def loadData(filename):
    print 'Loading data from ' + filename + '...'
    #get data
    f = open(filename)
    f.readline()

    data = []
    for line in f:
        sp = line.strip().split(';')

        date = sp[0].strip()
        position = sp[2].strip()
        name = sp[3].strip().replace(',', '')
        fantasyPoints = float(sp[5])
        salary = sp[6].strip()
        salary = '' if salary == 'N/A' else str(int(salary[1:].replace(',', '')))

        data.append({
            'Date': date,
            'Position': position,
            'Name': name,
            'FantasyPoints': fantasyPoints,
            'Salary': salary
        })
    f.close()

    return data

def writeData(filename, data):
    print 'Writing data to:', filename
    f = open(filename, 'w')

    #print col names
    f.write(Y_NAME + ',')
    f.write(','.join(X_NAMES) + '\n')

    for datum in data:
        #write y
        f.write(str(datum[Y_NAME]) + ',')

        #write first x
        f.write(str(datum[X_NAMES[0]]))

        #write the rest
        for i in xrange(1, len(X_NAMES)):
            f.write(',' + str(datum[X_NAMES[i]]))
        f.write('\n')
    f.close()

def createFilename(baseFilename):
    return DATA_DIR + baseFilename + '.csv'

#============= MAIN =============

data = loadData(DATA_FILE)
writeData(createFilename('data'), data)
