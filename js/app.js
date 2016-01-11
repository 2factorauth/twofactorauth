// When DOM elements are ready, excluding images
$(document).ready(function () {
  // Check if URL references specific category
  if (window.location.hash && window.location.hash.indexOf('#') > -1) {
    openCategory(window.location.hash.substring(1));
  }

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
    var content = $('.jets-content');
    // Non-strict comparison operator is used to allow for null
    if (searchPhrase == '') {
      $('*.website-table').css('display', 'none');
      $('.category').show();
      $('table').show();
    } else {
      $('.category').hide();
      $('*.website-table').css('display', 'block');
      content.parent().show();
      content.each(function () {
        // Hide table when all rows are hidden by Jets
        if ($(this).children(':hidden').length === $(this).children().length) $(this).parent().hide();
      });
    }
  },
  columns: [0] // Search by first column only
});

// Display tables and color category selectors
$('.category').click(function () {
  var name = $(this).attr('id');
  isOpen(name) ? closeCategory(name) : openCategory(name);
});

/**
 * Checks if a category is open
 *
 * @param category The id of a category as a string
 * @returns {*|jQuery} A true or false value, whether the category is open
 */
function isOpen(category) {
  return $('#' + category + ' h5 i').hasClass('active-icon');
}
/**
 * Opens a category, ensures the icon is active and scrolls to the icon
 *
 * @param category The id of a category as a string
 */
function openCategory(category) {
  // Close all active categories
  $('.category h5 i').removeClass('active-icon');
  $('*.website-table').css('display', 'none');

  var icon = $('#' + category + ' h5 i');
  icon.addClass('active-icon');
  $('#' + category + '-table').css('display', 'block');

  // Scroll smoothly to category selector
  $('html, body').animate({
    scrollTop: icon.offset().top - 25
  }, 1000);
}

/**
 * Closes a category and ensures the icon is inactive
 *
 * @param category The id of a category as a sring
 */
function closeCategory(category) {
  $('#' + category + ' h5 i').removeClass('active-icon');
  $('#' + category + '-table').css('display', 'none');
}
