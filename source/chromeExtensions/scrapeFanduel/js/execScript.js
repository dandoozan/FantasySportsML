var FIRST_PAGE_BUTTON_SELECTOR = 'button.page-first';
var LAST_WINNING_PAGE_BUTTON_SELECTOR = 'button[ng-click="detail.goToLastWinningPosition()"';

function scrapeUsers() {
    return $('.live-leaderboard-entry');
}

function scrapeRank(userNode) {
    return userNode.find('.rank').text().trim()
}

function scrapeUsername(userNode) {
    return userNode.find('.username').text().trim()
}

function scrapeWinnings(userNode) {
    return userNode.find('.user-winnings').text().trim()
}

function scrapeScore(userNode) {
    return userNode.find('.user-score').text().trim()
}

function scrapeCurrentPageResults() {
    var results = [];

    scrapeUsers().each(function(index, node) {
        var $node = $(node);
        results.push({
            rank: scrapeRank($node),
            username: scrapeUsername($node),
            winnings: scrapeWinnings($node),
            score: scrapeScore($node),
        });
    });

    return results;
}

function navigateToPage(buttonSelector, isFirstPage, callback) {
    var buttons = $(buttonSelector);
    var button = buttons.length ? buttons[0] : buttons;
    var $button = $(button);

    if ($button &&
        $button.attr('disabled') != 'disabled') {

        $button.click()

        //wait for the page to load the new results
        var intrvl = setInterval(function() {
            var rank = scrapeRank($(scrapeUsers()[0]));

            if ((isFirstPage && rank == '1st') ||
                (!isFirstPage && rank != '1st')) {
                    clearInterval(intrvl);
                    callback(true);
                    return;
            }
        }, 100);
    } else {
        callback(false);
    }
}

function scrapeTitle() {
    return $($('.contest-name')[0]).text().trim();
}

function scrapeEntryFee(entryDetailsNode) {
    var entryFeeFull = entryDetailsNode.find('.contest-entry-fee dd').text().trim();
    return entryFeeFull.substring(0, entryFeeFull.indexOf('(')).trim();
}

function scrapeEntryDetail(entryDetailsNode, selector) {
    return entryDetailsNode.find('.' + selector + ' dd').text().trim();
}

function scrapeEntryDetails() {
    var entryDetails = $($('.entry-details')[0]);
    return {
        title: scrapeTitle(),
        type: scrapeEntryDetail(entryDetails, 'contest-type'),
        prizes: scrapeEntryDetail(entryDetails, 'contest-prizes'),
        entryFee: scrapeEntryFee(entryDetails),
    }
}

function scrapeData(callback) {
    //first, get first page
    //then, click "Last winning position" link
    //then, scrape the 10 results that are there
    //thats it

    navigateToPage(FIRST_PAGE_BUTTON_SELECTOR, true, function() {
        var topResults = scrapeCurrentPageResults();

        navigateToPage(LAST_WINNING_PAGE_BUTTON_SELECTOR, false, function(didNavigate) {
            var lastWinningPositionResults = didNavigate ? scrapeCurrentPageResults() : [];
            callback({
                info: scrapeEntryDetails(),
                results: {
                    top: topResults,
                    lastWinningPosition: lastWinningPositionResults,
                }
            });
        });
    });
}

chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
	if(request.req=='scrapeData'){
        scrapeData(function(data) {
            sendResponse(data);
        });
	}
});
