$(document).ready(function () {
  // Unveil images 50px before they appear
  $('img').unveil(50);
});

// Show exception warnings upon hover
(function (root, $) {
  $('span.popup.exception').popup({
    hoverable: true
  });
  $('a.popup.exception').popup();
}(window, jQuery));

var jets = new Jets({
  searchTag: '#jets-search',
  contentTag: '.jets-content',
  didSearch: function (searchPhrase) {
    $('.category h5 i').removeClass('active-icon');
    // Non-strict comparison operator is used to allow for null
    if (searchPhrase == '') {
      $('*.website-table').css('display', 'none');
      $('.category').show();
      $('table').show();
    } else {
      $('.category').hide();
      $('*.website-table').css('display', 'block');
      $('.jets-content').each(function () {
        // Hide table when all rows are hidden by Jets
        if ($(this).children(':hidden').length === $(this).children().length) $(this).parent().hide();
      });
    }
  },
  columns: [0] // Search by first column only
});

// Display tables and color category selectors
$('.category').click(function () {
  var icon = $(this).find('h5 i');
  var table = $('#' + $(this).attr('id') + '-table');
  if (table.css('display') == 'block') {
    table.css('display', 'none');
  } else {
    $('*.website-table').css('display', 'none');
    $('.category h5 i').removeClass('active-icon');
    table.css('display', 'block');
  }
  icon.hasClass('active-icon') ? icon.removeClass('active-icon') : icon.addClass('active-icon');
});
