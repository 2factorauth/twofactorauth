(function (root, $) {
  $('span.popup.exception').popup({
    hoverable: true
  });
  $('a.popup.exception').popup();
}(window, jQuery));

$(document).ready(function () {
  $("img").unveil(50);
});

var jets = new Jets({
  searchTag: '#jets-search',
  contentTag: '.jets-content',
  didSearch: function (searchPhrase) {
    if (searchPhrase == '') {
      $('*.website-table thead').css('display', 'block');
      $('*.website-table').css('display', 'none');
    } else {
      $('*.website-table thead').css('display', 'none');
      $('*.website-table').css('display', 'block');
    }
  },
  columns: [0] // Search by first column only
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
  var icon = $(this).find('h5 i');
  var table = $('#' + id + '-table');
  if (table.css('display') == 'block') {
    table.css('display', 'none');
  } else {
    $('*.website-table').css('display', 'none');
    $('.category h5 i').removeClass('active-icon');
    table.css('display', 'block');
  }
  icon.hasClass('active-icon') ? icon.removeClass('active-icon') : icon.addClass('active-icon');
});
