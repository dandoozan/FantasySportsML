
window.onload=function(){
	chrome.tabs.getSelected(function(tab){
		chrome.tabs.sendRequest(tab.id, {req:'scrapeResults'}, function(results) {
            console.log(results)
			displayPage(results)
		});
	});
}

function displayPage(results){
    table = $('#results');

    for (var i = 0; i < results.length; i++) {
        tr = $('<tr>')
        for (var item in results[i]) {
            tr.append($('<td>').text(results[i][item]));
        }
        table.append(tr)
    }
}
