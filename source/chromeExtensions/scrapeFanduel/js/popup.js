
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
    var table = $('<table>');
    for (var i = 0; i < results.length; i++) {
        tr = $('<tr>')
        for (var item in results[i]) {
            tr.append($('<td>').text(results[i][item]));
        }
        table.append(tr)
    }
    parent.append(table);
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
