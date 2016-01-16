// When DOM elements are ready, excluding images
$(document).ready(function () {
  // Check if URL references specific category
  if (window.location.hash && window.location.hash.indexOf('#') > -1) {
    openCategory(window.location.hash.substring(1));
  }

  // Unveil images 50px before they appear
  $('img').unveil(50);
});

/**
 * Create an event that is called 500ms after the browser
 * window is re-sized and has finished being re-sized.
 * This event corrects for browser differences in the
 * triggering of window resize events.
 */
$(window).resize(function () {
  if (this.resizeTO) clearTimeout(this.resizeTO);
  this.resizeTO = setTimeout(function () {
    $(this).trigger('resizeEnd');
  }, 500);
});

// Show exception warnings upon hover
(function (root, $) {
  $('span.popup.exception').popup({
    hoverable: true
  });
  $('a.popup.exception').popup();
}(window, jQuery));

var isSearching = false;
var jets = new Jets({
  searchTag: '#jets-search',
  contentTag: '.jets-content',
  didSearch: function (searchPhrase) {
    $('.category h5 i').removeClass('active-icon');
    var platform;
    $(window).width() > 768 ? platform = 'desktop' : platform = 'mobile';
    var content = $('.' + platform + '-table .jets-content');
    var table = $('.' + platform + '-table');

    // Non-strict comparison operator is used to allow for null
    if (searchPhrase == '') {
      $('.website-table').css('display', 'none');
      $('.website-table .label').css('display', 'none');
      $('.category').show();
      $('table').show();
      isSearching = false;
    } else {
      $('.website-table').css('display', 'none');
      $('.website-table .label').css('display', 'block');
      $('.category').hide();
      table.css('display', 'block');
      content.parent().show();
      content.each(function () {
        // Hide table when all rows are hidden by Jets
        if ($(this).children(':hidden').length === $(this).children().length) {
          if (platform == 'mobile') $(this).parent().hide();
          else $(this).parent().parent().hide();
        }
      });
      isSearching = true;
    }
  },
  columns: [0] // Search by first column only
});

/**
 * Ensure searching is conducted with regard to the user's viewport
 * after re-sizing the screen and close all categories after re-sizing
 */
$(window).on('resizeEnd', function () {
  if (isSearching) jets.options.didSearch($('#jets-search').val());
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
  $('.website-table').css('display', 'none');

  var icon = $('#' + category + ' h5 i');
  icon.addClass('active-icon');
  if ($(window).width() > 768) {
    $('#' + category + '-desktoptable').css('display', 'block');
  } else {
    $('#' + category + '-mobiletable').css('display', 'block');
  }

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
  $('.' + category + '-table').css('display', 'none');
}
