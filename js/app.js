(function (root, $) {
  $('.menu .dropdown').dropdown();
  $('span.popup.exception').popup({
    hoverable: true
  });
  $('a.popup.exception').popup();
}(window, jQuery));

$(document).ready(function () {
  $("img").unveil(50);
});

function getStyle(element, styleProp) {
  var validElement = document.getElementById(element),
    validStyle;
  if (validElement.currentStyle)
    validStyle = validElement.currentStyle[styleProp];
  else if (window.getComputedStyle)
    validStyle = document.defaultView.getComputedStyle(validElement, null).getPropertyValue(styleProp);
  return validStyle;
}

$('.category').click(function () {
  var id = $(this).attr('id');
  var table = $('#' + id + '-table');
  if (table.css('display') == 'block') {
    table.css('display', 'none');
  } else {
    $('*.website-table').css('display', 'none');
    table.css('display', 'block');
  }
});
