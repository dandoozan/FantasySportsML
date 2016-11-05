import os

def createDirIfNecessary(fullPathToDir):
    if not os.path.isdir(fullPathToDir):
        print 'Creating dir: ' + fullPathToDir + '...'
        os.makedirs(fullPathToDir)

def getFilesInDir(fullPathToDir):
    return [f for f in os.listdir(fullPathToDir) if (os.path.isfile(os.path.join(fullPathToDir, f)) and f[:1] != '.')]

def headsUp(msg):
    print '==========================================='
    print '***HEADS UP! ', msg
    print '==========================================='

def stop(msg):
    headsUp(msg)
    exit()

def createFullPathFilename(fullPathToParentDir, filename):
    return os.path.join(fullPathToParentDir, filename)

def joinDirs(*dirNames):
    return os.path.join(*dirNames)

def getObjValue(obj, key, default=None):
    return obj[key] if key in obj else default