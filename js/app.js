// When DOM elements are ready, excluding images
$(document).ready(function () {
  // Check if URL references specific category
  if (window.location.hash && window.location.hash.indexOf('#') > -1) {
    openCategory(window.location.hash.substring(1));
  }

  // Unveil images when visible in jquery
  $(function() { $('img').Lazy({visibleOnly: true}); });

  // Show exception warnings upon hover
  $('span.popup.exception').popup({
    hoverable: true
  });
  $('a.popup.exception').popup();
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

var isSearching = false;
var jets = new Jets({
  callSearchManually: true,
  contentTag: '.jets-content',
  didSearch: function (searchPhrase) {
    document.location.hash = '';
    $('#no-results').css('display', 'none');
    $('.category h5 i').removeClass('active-icon');
    // Two separate table layouts are used for desktop/mobile
    var platform = ($(window).width() > 768) ? 'desktop' : 'mobile';
    var content = $('.' + platform + '-table .jets-content');
    var table = $('.' + platform + '-table');

    // Non-strict comparison operator is used to allow for null
    if (searchPhrase == '') {
      // Show all categories when no search term is entered
      $('.website-table').css('display', 'none');
      $('.website-table .label').css('display', 'none');
      $('.category').show();
      $('table').show();
      isSearching = false;
    } else {
      // Hide irrelevant categories
      $('.website-table').css('display', 'none');
      $('.website-table .label').css('display', 'block');
      $('.category').hide();
      table.css('display', 'block');
      content.parent().show();
      for(var i = 0; i < content.length; i++) {
			  var section = $(content[i]);
        // Hide table when all rows within are hidden by Jets
        if (section.children(':hidden').length === section.children().length) {
          if (platform == 'mobile') section.parent().hide();
          else section.parent().parent().hide();
        }
      }

      if (table.children().length == table.children(':hidden').length) {
          $('#no-results').css('display', 'block');
      }

      isSearching = true;
    }
  },
  // Process searchable elements manually
  manualContentHandling: function(tag) {
    return $(tag).find('.keywords').text();
  }
});

// Wrap the jets.search function with a debounced function
var debouncedSearch = debounce(function(e) {
  jets.search(e.target.value);
}, 350);

// Attach a keyup event listener to the input
$('#jets-search').keyup(debouncedSearch);

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

  // Place the category being viewed in the URL bar
  window.location.hash = category;

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
 * @param category The id of a category as a string
 */
function closeCategory(category) {
  $('#' + category + ' h5 i').removeClass('active-icon');
  $('.' + category + '-table').css('display', 'none');
  document.location.hash = '';
}

/**
 * Returns a function, that, as long as it continues to be invoked, will not
 * be triggered. The function will be called after it stops being called for
 * N milliseconds.
 * 
 * @param func The function to be debounced
 * @param wait The time in ms to debounce 
 */
function debounce(func, wait) {
  var timeout;
  
	return function() {
		var context = this, args = arguments;
		var later = function() {
			timeout = null;
			func.apply(context, args);
    };
    
		clearTimeout(timeout);
		timeout = setTimeout(later, wait);
		if (!timeout) func.apply(context, args);
	};
};
