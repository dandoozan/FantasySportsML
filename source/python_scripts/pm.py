import _util as util

PYTHON_SOURCE_DIR = util.joinDirs('source', 'python_scripts')
baseFilenamesToRun = [
    'scrapeNumberFire',
    'scrapeRotoGrindersHtml',
    'scrapeRotoGrindersJson',
    'downloadFanDuelJson',
]

for baseFilename in baseFilenamesToRun:
    fullPathFilename = util.createFullPathFilename(PYTHON_SOURCE_DIR, util.createPyFilename(baseFilename))
    util.headsUp('Executing file: ' + fullPathFilename + '...')
    execfile(fullPathFilename)
    print '\n'

