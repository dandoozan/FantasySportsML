import urllib
import urllib2
import json

USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36'

def _download(url):
    print '    Downloading data...'
    print '        url:', url
    req = urllib2.Request(url, headers={ 'User-Agent': USER_AGENT })
    return urllib2.urlopen(req)

def downloadPageSource(url):
    return _download(url).read().split('\n')

def downloadJson(url):
    return json.load(_download(url))

def createUrl(baseUrl, urlParams):
    #Note: baseUrl should contain the '?' at the end
    return baseUrl + urllib.urlencode(urlParams)

def writeJsonData(jsonData, fullPathFilename):
    print '    Writing data to ' + fullPathFilename + '...'
    f = open(fullPathFilename, 'w')
    json.dump(jsonData, f, indent=4, separators=(',', ': '), sort_keys=True)
    f.close()

def createJsonFilename(fullPathDir, baseFilename):
    #Note: fullPathDir should not contain the '/' at the end
    return fullPathDir + '/' + baseFilename + '.json'
