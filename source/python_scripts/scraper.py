import urllib
import urllib2
import json

USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36'

def _download(url, extraHeaders={}, verbose=False):
    if verbose:
        print '    Downloading data...'
        print '        url:', url

    headers = { 'User-Agent': USER_AGENT }
    headers.update(extraHeaders)

    req = urllib2.Request(url, headers=headers)
    return urllib2.urlopen(req)
def downloadPageSource(url, extraHeaders={}, verbose=False):
    return _download(url, extraHeaders, verbose).read()
def downloadJson(url, extraHeaders={}, verbose=False):
    return json.load(_download(url, extraHeaders, verbose))

def createUrl(baseUrl, urlParams):
    #Note: baseUrl should contain the '?' at the end
    return baseUrl + urllib.urlencode(urlParams)

def getText(soupNode):
    #remove all commas
    #and replace funny apostrophe with regular one (for player E'Twaun Moore)
    return soupNode.get_text().replace(',', '').replace(u'\u2019', '\'').strip()
