
window.onload=function(){
	chrome.tabs.getSelected(function(tab){
		chrome.tabs.sendRequest(tab.id, {req:'scrapeData'}, function(data) {
			displayPage(data);
		});
	});
}

function displayInfo(info) {
    $('#title').text(info.title);
    $('#type').text(info.type);
    $('#prizes').text(info.prizes);
    $('#entryFee').text(info.entryFee);
}

function displayResultSet(parent, results) {
    for (var i = 0; i < results.length; i++) {
        var str = '';
        var cnt = 0;
        for (var item in results[i]) {
            if (cnt != 0) {
                str += ',';
            }
            str += results[i][item];
            cnt++;
        }
        parent.append($('<div>').text(str));
    }
}

function displayPage(data){

    //display contest info
    displayInfo(data.info);

    //display top results
    resultsContainer = $('#results');
    displayResultSet(resultsContainer, data.results.top);

    //display last winning results
    lastWinningPositionResults = data.results.lastWinningPosition;
    if (lastWinningPositionResults.length > 0) {
        resultsContainer.append($('<div>...</div>'))
        displayResultSet(resultsContainer, lastWinningPositionResults);
    }

}
