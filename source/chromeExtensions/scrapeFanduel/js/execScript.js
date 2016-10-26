
function getChildByClassName(parent,cl) {
	var myclass = new RegExp('\\b'+cl+'\\b');
	var children = parent.childNodes;
	return getChildByClassName2(children,myclass);
}
function getChildByClassName2(children,myclass) {
	for(var j=0;j<children.length;j++){
		classe=children[j].className;
		if (myclass.test(classe))
			return children[j];
		var child=getChildByClassName2(children[j].childNodes,myclass);
		if(child)
			return child;
	}
}

function scrapeResults(){
    results = []

    $('.live-leaderboard-entry').each(function(index, node) {
        rank = $(node).find('.rank').text().trim()
        username = $(node).find('.username').text().trim()
        winnings = $(node).find('.user-winnings').text().trim()
        score = $(node).find('.user-score').text().trim()

        results.push({
            rank: rank,
            username: username,
            winnings: winnings,
            score: score,
        });
    });

	return results;
}

chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
	if(request.req=='scrapeResults'){
		sendResponse(scrapeResults());
	}
});
