import sys
import _util as util

PYTHON_SOURCE_DIR = util.joinDirs('source', 'python_scripts')

xAuthToken = util.getCommandLineArgument()
filesToRun = [
    { 'baseFilename': 'downloadFanDuelJson', 'args': [xAuthToken] },

    #NOTE: you MUST run this every day because it looks only for yesterday's results
    { 'baseFilename': 'scrapeFanDuel', 'args': [xAuthToken] },

    #these are unnecessary to run every day
    #{ 'baseFilename': 'scrapeRotoGuruDay', },
    { 'baseFilename': 'scrapeStatsNba', 'args': ['Daily', 'Player', 'Traditional', '2016']},
    { 'baseFilename': 'scrapeStatsNba', 'args': ['Season', 'Player', 'Traditional', '2016']},
    { 'baseFilename': 'scrapeStatsNba', 'args': ['Season', 'Player', 'Advanced', '2016']},
    { 'baseFilename': 'scrapeStatsNba', 'args': ['Season', 'Player', 'Defense', '2016']},
    { 'baseFilename': 'scrapeStatsNba', 'args': ['Season', 'Player', 'PlayerBios', '2016']},
    { 'baseFilename': 'scrapeStatsNba', 'args': ['Season', 'Team', 'Traditional', '2016']},
    { 'baseFilename': 'downloadFanDuelContestResults', 'args': [xAuthToken] },
]


for fileToRun in filesToRun:
    baseFilename = fileToRun['baseFilename']
    args = util.getObjValue(fileToRun, 'args', [])

    fullPathFilename = util.createFullPathFilename(PYTHON_SOURCE_DIR, util.createPyFilename(baseFilename))
    util.headsUp('Executing file: ' + fullPathFilename + '...')

    sys.argv = [fullPathFilename]
    sys.argv.extend(args)
    execfile(fullPathFilename)

    util.sleep(10)
    print '\n'
