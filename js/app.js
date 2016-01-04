(function (root, $) {
    $('.menu .dropdown').dropdown();
    $('span.popup.exception').popup({
    	hoverable: true
    });
    $('a.popup.exception').popup();
}(window, jQuery));

$(document).ready(function() {
    $("img").unveil(50);
});
