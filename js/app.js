/*! jQuery Searcher Plugin - v0.1.0 - 2014-08-18
 * https://github.com/lloiser/jquery-searcher/
 * Copyright (c) 2014 Lukas Beranek; Licensed MIT 
*/

(function (root, $) {
    $('.menu .dropdown').dropdown();
    $('span.popup.exception').popup();
    $('a.popup.exception').popup();
}(window, jQuery));

$(document).ready(function() {
    $("img").unveil(50);
});

$("tbody").searcher({
    itemSelector: "tr",
    textSelector: "td",
    inputSelector: "#searchinput",
    toggle: function(item, containsText) {
        // use a typically jQuery effect instead of simply showing/hiding the item element
        if (containsText) {            
        	$(item).fadeIn();
        } else {            
        	$(item).fadeOut();
        }
    }
});

$("#main-container").searcher({
    itemSelector: ".section",
    textSelector: "td",
    inputSelector: "#searchinput",
    toggle: function(item, containsText) {
        if (window.console) console.log(containsText + ' ' + item);
        // use a typically jQuery effect instead of simply showing/hiding the item element
        if (containsText) {            
        	$(item).fadeIn();
        } else {            
        	$(item).fadeOut();
        }

    }
});