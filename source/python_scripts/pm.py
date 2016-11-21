import sys
import _util as util

PYTHON_SOURCE_DIR = util.joinDirs('source', 'python_scripts')
SLEEP = 10

xAuthToken = util.readInput('Enter X-Auth-Token: ')
filesToRun = [
    { 'baseFilename': 'scrapeNumberFire' },
    { 'baseFilename': 'scrapeRotoGrindersHtml' },
    { 'baseFilename': 'scrapeRotoGrindersJson' },
    { 'baseFilename': 'downloadFanDuelJson', 'args': [xAuthToken] },
]

for fileToRun in filesToRun:
    baseFilename = fileToRun['baseFilename']
    args = util.getObjValue(fileToRun, 'args', [])

    fullPathFilename = util.createFullPathFilename(PYTHON_SOURCE_DIR, util.createPyFilename(baseFilename))
    util.headsUp('Executing file: ' + fullPathFilename + '...')

    sys.argv = [fullPathFilename]
    sys.argv.extend(args)
    execfile(fullPathFilename)

    util.sleep(SLEEP)
    print '\n'
