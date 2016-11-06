
def createDirIfNecessary(fullPathToDir):
    import os
    if not os.path.isdir(fullPathToDir):
        print 'Creating dir: ' + fullPathToDir + '...'
        os.makedirs(fullPathToDir)

def getFilesInDir(fullPathToDir):
    import os
    return [f for f in os.listdir(fullPathToDir) if (os.path.isfile(os.path.join(fullPathToDir, f)) and f[:1] != '.')]

def headsUp(msg):
    print '==========================================='
    print '***HEADS UP! ', msg
    print '==========================================='

def stop(msg):
    headsUp(msg)
    exit()

def createFullPathFilename(fullPathToParentDir, filename):
    import os
    return os.path.join(fullPathToParentDir, filename)

def joinDirs(*dirNames):
    import os
    return os.path.join(*dirNames)

def getObjValue(obj, key, default=None):
    return obj[key] if key in obj else default

def fileExists(fullPathFilename):
    import os
    return os.path.exists(fullPathFilename)

def createCsvFilename(baseFilename):
    return baseFilename + '.csv'

def printObj(obj):
    keys = obj.keys()
    keys.sort()
    for key in keys:
        print key + ':' + str(obj[key])

def printArray(arr):
    for a in arr:
        print a

def loadCsvFile(fullPathFilename, keyRenameMap={}, delimiter=','):
    import csv
    data = []
    with open(fullPathFilename) as f:
        reader = csv.DictReader(f, delimiter=delimiter)
        for rowAsObj in reader:
            #Map keys to the ones I want to use
            renameKeys(keyRenameMap, rowAsObj)

            #strip whitespace from each value
            for key in rowAsObj:
                rowAsObj[key] = rowAsObj[key].strip()

            data.append(rowAsObj)
    return data

def removeKey(key, obj):
    obj.pop(key, None)

def renameKey(obj, oldKey, newKey):
    obj[newKey] = obj.pop(oldKey)

def renameKeys(keyMap, obj):
    for key in obj:
        if key in keyMap:
            renameKey(obj, key, keyMap[key])

def filterObj(validKeys, obj):
    keys = obj.keys()
    for key in keys:
        if key not in validKeys:
            removeKey(key, obj)
    return obj
