// When DOM elements are ready, excluding images
$(document).ready(function () {
  // Check if URL references specific category
  if (window.location.hash && window.location.hash.indexOf('#') > -1) {
    openCategory(window.location.hash.substring(1));
  }

  // Some frilly animations on click of the main Bitcoin Cash logo
  $('#coin-toggle').on('click', function () {
    var mainCoin = $('#main-coin path.glyph');
    var leftSideCoin = $('.top-side-left-side, .top-side-left-side-force');
    var rightSideCoin = $('.top-side-right-side, .top-side-right-side-force');

    mainCoin.removeClass("anim-glyph anim-glyph-force");
    leftSideCoin.removeClass("top-side-left-side top-side-left-side-force");
    rightSideCoin.removeClass("top-side-right-side top-side-right-side-force");
    setTimeout(
      function(){ mainCoin.addClass('anim-glyph-force') }
    , 1);
    setTimeout(
      function(){ leftSideCoin.addClass('top-side-left-side-force') }
    , 1);
    setTimeout(
      function(){ rightSideCoin.addClass('top-side-right-side-force') }
    , 1);
  });

  // Activate elevator power to the search floor
  var primaryElevator = new Elevator({
    element: document.querySelector('.fab button:nth-child(2)'),
    targetElement: document.querySelector('#search-wrapper'),
    verticalPadding: 90,  // in pixels
    duration: 420, // milliseconds
    endCallback: function() {
      $('#search-wrapper input').focus();
    }
  });

  // Stick the BCC-only filter to the top on scroll
  $(".bcc-only").stick_in_parent({
    parent: 'html'
  });

  // Scroll to the top via floating action button
  $('.fab button:nth-child(1)').on('click', function () {
    var body = $("html, body");
    body.stop().animate({scrollTop:0}, 500, 'swing');
  });

  // Clear the active search terms
  $('button#search-clear').on('click', function () {
    $('#search-wrapper input').val('');
    $('#no-results').css('display', 'none');
    $('.category').show();
    $('table').show();
    $('#search-wrapper input').focus();
  });

  $('#ama-merchant').on('click', function () {
    $('.ui.modal.ama-merchant').modal('toggle');
  });

  $('#ama-customer').on('click', function () {
    $('.ui.modal.ama-customer').modal('toggle');
  });

  $('#about-this-site').on('click', function () {
    $('.ui.modal.about-this-site').modal('toggle');
  });

  $('#show-disclaimer').on('click', function () {
    $('.ui.modal.disclaimer').modal('toggle');
  });

  // Unveil images 50px before they appear
  $('img').unveil(50);

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
  searchTag: '#bcc-merchant-search',
  contentTag: '.bcc-merchant-content',
  didSearch: function (searchPhrase) {
    document.location.hash = '';
    $('#no-results').css('display', 'none');
    $('.category h5 i').removeClass('active-icon');
    // Two separate table layouts are used for desktop/mobile
    var platform = ($(window).width() > 768) ? 'desktop' : 'mobile';
    var content = $('.' + platform + '-table .bcc-merchant-content');
    var table = $('.' + platform + '-table');

    // Non-strict comparison operator is used to allow for null
    if (searchPhrase == '') {
      // Show all categories when no search term is entered
      $('.website-table').css('display', 'none');
      $('.website-table .label').css('display', 'none');
      $('#search-clear').css('display', 'none');
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
      content.each(function () {
        // Hide table when all rows within are hidden by Jets
        if ($(this).children(':hidden').length === $(this).children().length) {
          if (platform == 'mobile') $(this).parent().hide();
          else $(this).parent().parent().hide();
        }
      });

      if (table.children().length == table.children(':hidden').length) {
          $('#no-results').css('display', 'block');
      }

      $('#search-clear').fadeIn('slow');

      isSearching = true;

      $('html, body').scrollTop($('#search-wrapper').offset().top - 15);
    }
  },
  // Process searchable elements manually
  manualContentHandling: function(tag) {
    return $(tag).find('.title > a.name').text();
  }
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
 * Toggle visibility of merchants who accept Bitcoin Cash
 */
$('.z-switch').click(function () {
  BCCfilter();
});

/**
 * Check if the user wants to filter by Bitcoin Cash only
 */
function BCCfilter() {
  if ($('#show-bcc-only').is(':checked')) {
    $('.no-bcc').css('display', 'none')
  } else {
    $('.no-bcc').css('display', 'table-row')
  }
}

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
  $(document.body).trigger("sticky_kit:recalc");
  BCCfilter();

  // Place the category being viewed in the URL bar
  window.location.hash = category;

  var icon = $('#' + category + ' h5 i');
  icon.addClass('active-icon');
  if ($(window).width() > 768) {
    $('#' + category + '-desktoptable').slideDown('slow');

    // Scroll smoothly to category selector
    var body = $("html, body");
    body.stop().animate({scrollTop: icon.offset().top - 15}, 1000, 'swing');

  } else {
    $('#' + category + '-mobiletable').css('display','block');
    // Quickly snap to category selector
    document.location.hash = category;
  }

}

/**
 * Closes a category and ensures the icon is inactive
 *
 * @param category The id of a category as a string
 */
function closeCategory(category) {
  $('.' + category + '-table').slideUp();
  $('#' + category + ' h5 i').removeClass('active-icon');
  // Remove hash from URL, prevent the scroll position from jumping to the top
  $(document.body).trigger("sticky_kit:recalc");
  history.pushState('', document.title, window.location.pathname);
}
