
#================= file stuff ===================
def createDirIfNecessary(fullPathToDir):
    import os
    if not os.path.isdir(fullPathToDir):
        print 'Creating dir: ' + fullPathToDir + '...'
        os.makedirs(fullPathToDir)
def getFilesInDir(fullPathToDir):
    import os
    return [f for f in os.listdir(fullPathToDir) if (os.path.isfile(os.path.join(fullPathToDir, f)) and f[:1] != '.')]
def getLastFileInDir(fullPathToDir):
    filenames = getFilesInDir(fullPathToDir)
    filenames.sort()
    return filenames[-1]
def createFullPathFilename(fullPathToParentDir, filename):
    import os
    return os.path.join(fullPathToParentDir, filename)
def joinDirs(*dirNames):
    import os
    return os.path.join(*dirNames)
def fileExists(fullPathFilename):
    import os
    return os.path.exists(fullPathFilename)
def dirExists(fullPathToDir):
    import os
    return os.path.exists(fullPathToDir)
def createCsvFilename(baseFilename):
    return baseFilename + '.csv'
def createJsonFilename(baseFilename):
    return baseFilename + '.json'
def createTxtFilename(baseFilename):
    return baseFilename + '.txt'
def parseBaseFilename(filename):
    return filename[:filename.find('.')]
def loadCsvFile(fullPathFilename, keyRenameMap=None, delimiter=',', prefix=''):
    import csv
    data = []
    with open(fullPathFilename) as f:
        reader = csv.DictReader(f, delimiter=delimiter)
        for rowAsObj in reader:
            #Map keys to the ones I want to use
            if keyRenameMap:
                renameKeys(keyRenameMap, rowAsObj)

            #add prefix to each key
            if prefix:
                addPrefixToObj(rowAsObj, prefix)

            #strip whitespace from each value
            for key in rowAsObj:
                rowAsObj[key] = rowAsObj[key].strip()

            data.append(rowAsObj)
    return data
def loadJsonFile(fullPathFilename):
    import json
    with open(fullPathFilename) as f:
        return json.load(f)
def isJsonFile(filename):
    return len(filename) > 5 and filename[-5:] == '.json'
def isTxtFile(filename):
    return len(filename) > 4 and filename[-4:] == '.txt'
def writeCsvFile(colNames, dataArr, fullPathFilename):
    print 'Writing Csv File: ' + fullPathFilename + '...'
    import csv
    with open(fullPathFilename, 'w') as f:
        writer = csv.DictWriter(f, fieldnames=colNames)
        writer.writeheader()
        writer.writerows(dataArr)
def writeJsonData(jsonData, fullPathFilename, prettyPrint=True):
    import json
    print '    Writing data to ' + fullPathFilename + '...'
    f = open(fullPathFilename, 'w')
    if prettyPrint:
        json.dump(jsonData, f, indent=2, separators=(',', ': '), sort_keys=True)
    else:
        json.dump(jsonData, f, sort_keys=True)
    f.close()


#================= obj manipulation stuff ===================
def getObjValue(obj, key, default=None):
    return obj[key] if key in obj else default
def removeKey(key, obj):
    obj.pop(key, None)
def renameKey(obj, oldKey, newKey):
    obj[newKey] = obj.pop(oldKey)
def renameKeys(keyMap, obj):
    #note: use keys bc renameKey alters obj
    keys = obj.keys()
    for key in keys:
        if key in keyMap:
            renameKey(obj, key, keyMap[key])
def filterObj(validKeys, obj):
    keys = obj.keys()
    for key in keys:
        if key not in validKeys:
            removeKey(key, obj)
    return obj
def addPrefixToArray(arr, prefix):
    return map(lambda x: prefix + x, arr)
def addPrefixToObj(obj, prefix):
    #This adds a prefix to all TOP LEVEL key names
    #note: use obj.keys() because renameKeys alters the obj
    map(lambda x: renameKey(obj, x, prefix + x), obj.keys())
    return obj
def mapSome(func, obj, keyNames):
    for key in keyNames:
        obj[key] = func(obj[key])


#================= date stuff ===================
def parseDate(dateStr, dateFormat='%Y-%m-%d'):
    from datetime import datetime
    return datetime.strptime(dateStr, dateFormat)
def parseAsDate(dateStr, dateFormat='%Y-%m-%d'):
    import datetime
    parsedDatetime = parseDate(dateStr, dateFormat)
    return datetime.date(parsedDatetime.year, parsedDatetime.month, parsedDatetime.day)
def formatDate(date, dateFormat='%Y-%m-%d'):
    return date.strftime(dateFormat)
def getTodayAsDate():
    from datetime import date
    return date.today()
def getOneDay():
    from datetime import timedelta
    return timedelta(days=1)
def getOneWeek():
    from datetime import timedelta
    return timedelta(weeks=1)
def getYesterdayAsDate():
    return getTodayAsDate() - getOneDay()
def getDate(year, month, day):
    import datetime
    return(datetime.date(year, month, day))

#================= error stuff ===================
def headsUp(msg):
    print '==========================================='
    print '***HEADS UP! ', msg
    print '==========================================='
def stop(msg):
    headsUp(msg)
    exit()


#================= print stuff ===================
def printObj(obj):
    keys = obj.keys()
    keys.sort()
    for key in keys:
        print key + ': ' + str(obj[key])
def printArray(arr):
    for a in arr:
        print a


#================= check type ===================
def isString(value):
    return (type(value) is str)
def isUnicode(value):
    return (type(value) is unicode)

#================= misc ===================
def removePercentSign(string):
    if string[-1] == '%':
        return string[:-1]
    return string
