import urllib
import urllib2
import json

USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36'

def _download(url, extraHeaders={}):
    print '    Downloading data...'
    print '        url:', url

    headers = { 'User-Agent': USER_AGENT }
    headers.update(extraHeaders)

    req = urllib2.Request(url, headers=headers)
    return urllib2.urlopen(req)

def downloadPageSource(url, extraHeaders={}):
    return _download(url, extraHeaders).read()

def downloadJson(url, extraHeaders={}):
    return json.load(_download(url, extraHeaders))

def createUrl(baseUrl, urlParams):
    #Note: baseUrl should contain the '?' at the end
    return baseUrl + urllib.urlencode(urlParams)

def writeJsonData(jsonData, fullPathFilename):
    print '    Writing data to ' + fullPathFilename + '...'
    f = open(fullPathFilename, 'w')
    json.dump(jsonData, f, indent=2, separators=(',', ': '), sort_keys=True)
    f.close()

def createJsonFilename(fullPathDir, baseFilename):
    #Note: fullPathDir should not contain the '/' at the end
    return fullPathDir + '/' + baseFilename + '.json'

def getText(soupNode):
    #remove all commas
    #and replace funny apostrophe with regular one (for player E'Twaun Moore)
    return soupNode.get_text().replace(',', '').replace(u'\u2019', '\'').strip()
