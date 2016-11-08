
window.onload=function(){
    chrome.tabs.getSelected(function(tab){
        cookieRequestDetails = {
            url: tab.url,
            name: 'X-Auth-Token',
        };
        chrome.cookies.get(cookieRequestDetails, function(cookie) {
            $('#xAuthToken').text(cookie.value);
        });
    });
}
