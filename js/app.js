// When DOM elements are ready, excluding images
$(document).ready(function () {

  // Get all URL parameters
  var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
      sURLVariables = sPageURL.split('&'),
      sParameterName,
      i;

    for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split('=');
      if (sParameterName[0] === sParam) {
        return sParameterName[1] === undefined ? true : sParameterName[1];
      }
    }
  };

  // Check if URL parameter exists to filter by BCH-only
  if (getUrlParameter('filter') == 'bch') {
    $('#show-bcc-only').prop('checked', true);
  }

  // Clear the BCH-only view
  $('.clear-bch-only').click(function () {
    $('#show-bcc-only').prop('checked', false);
    BCCfilter();
  });

  // Check if URL references specific category
  if (window.location.hash && window.location.hash.indexOf('#') > -1) {
    openCategory(window.location.hash.substring(1));
  }

  // Some frilly animations on click of the main Bitcoin Cash logo
  $('#coin-toggle').click(function (){
    coinEffect();
  });

  // Stick the BCC-only filter to the top on scroll
  $(".bcc-only").fixTo('html', {
    useNativeSticky: false
  });

  // Scroll to the top via floating action button and filter bar link, then pop some flair
  $('.fab button:nth-child(1), #top-btn-top').on('click', function () {
    var body = $("html, body");
    body.stop().animate({scrollTop:0}, 500, 'swing', function () {
      coinEffect();

      // Restores the opened category hash in URL, but causes Firefox to skip back to it
      //if (window.location.hash && window.location.hash.indexOf('#') > -1) {
        //document.location.hash = window.location.hash.substring(1);
      //}
    });
  });

  // Scroll to the search field and focus it via floating action button and filter bar link
  $('.fab button:nth-child(2), #top-btn-search').on('click', function () {
    var body = $("html, body");
    body.stop().animate({scrollTop: $('#search-wrapper').offset().top}, 500, 'swing');
    $('#search-wrapper input').focus();
  });

  // Clear and collapse all open categories
  $('.fab button:nth-child(3)').on('click', function () {
    if (isSearching) jets.options.didSearch( $('#bcc-merchant-search').val() );
    if (isSearching == false) {
      $('.website-table').slideUp();
      var body = $("html, body");
      body.stop().animate({scrollTop: $('.category h5 i.active-icon').offset().top - 120}, 1000, 'swing');
      $('.category h5 i').removeClass('active-icon');
      $(this).css('display', 'none');
      document.location.hash = '';
    } else {
      if ($(this).hasClass('attention')) {
        $(this).removeClass('attention');
        $("#bcc-merchant-search").removeClass('attention');
      } else {
        $(this).addClass('attention');
        $("#bcc-merchant-search").addClass('attention');
      }
    }
  });

  // Clear the active search terms
  $('button#search-clear').on('click', function () {
    $('#search-wrapper input#bcc-merchant-search').val('');
    $('#no-results').css('display', 'none');
    $('.category').show();
    $('.website-table').hide();
    $('#maingrid').css('visibility', 'visible');
    $('#search-wrapper input#bcc-merchant-search').focus();
    $('head style').html("");
  });

  $('#ama-merchant').on('click', function () {
    $('.ui.modal.ama-merchant').modal('show');
  });

  $('#ama-customer').on('click', function () {
    $('.ui.modal.ama-customer').modal('show');
  });

  $('#assets').on('click', function () {
    $('.ui.modal.assets').modal('show');
  });

  $('#art-collections').on('click', function () {
    $('.ui.modal.art-collections').modal('show');
  });

  $('#about-this-site').on('click', function () {
    $('.ui.modal.about-this-site').modal('show');
  });

  $('#show-disclaimer').on('click', function () {
    $('.ui.modal.disclaimer').modal('show');
  });

  // Unveil images 50px before they appear
  $('img').unveil(50);

  // Show exception warnings upon hover
  $('span.popup.exception').popup({
    hoverable: true
  });
  $('a.popup.exception').popup();

  // Display progress counter for sites accepting BCH out of total sites listed
  $('.ui.bch-progress').progress({
    label: 'percent',
    showActivity: false
  });
});

/**
 * Draw a neat animation on the main Bitcoin Cash logo at the top of the page
 */
function coinEffect() {
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
}


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
    $('#maingrid').css('visibility', 'visible');
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
          $('#maingrid').css('visibility', 'hidden');
      }

      $('#search-clear').fadeIn('slow');

      isSearching = true;

      $('html, body').stop().animate({scrollTop: $('#maingrid').offset().top - 120}, 500, 'swing');
      //$('html, body').scrollTop($('#search-wrapper').offset().top - 15);
    }
  },
  addImportant: true,
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
  if (isSearching) jets.options.didSearch( $('#bcc-merchant-search').val() );
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
    $('.no-bcc').css('display', 'none');
    $('.bcc-only-none-found').css('display', 'table-row');
    $('.bcc-only-none-found-mobile').css('display', 'block');
    $('.bcc-only-hidden').css('opacity', '0.4');
    if (isSearching) jets.options.didSearch( $('#bcc-merchant-search').val() );
  } else {
    $('.bcc-only-none-found, .bcc-only-none-found-mobile').css('display', 'none');
    $('.bcc-only-hidden').css('opacity', '1');
    $('.mobile-table .no-bcc').css('display', 'block');
    $('.desktop-table .no-bcc').css('display', 'table-row');
    if (isSearching) jets.options.didSearch( $('#bcc-merchant-search').val() );
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
  $('.fab button:nth-child(3)').css('display', 'inline-block');
  BCCfilter();

  // Place the category being viewed in the URL bar
  window.location.hash = category;

  var icon = $('#' + category + ' h5 i');
  icon.addClass('active-icon');
  if ($(window).width() > 768) {
    $('#' + category + '-desktoptable').slideDown('slow');

    // Scroll smoothly to category selector
    var body = $("html, body");
    body.stop().animate({scrollTop: icon.offset().top - 120}, 1000, 'swing');

  } else {
    $('#' + category + '-mobiletable').css('display','block');
    // Quickly snap to category selector
    var body = $("html, body");
    body.stop().animate({scrollTop: icon.offset().top - 120}, 1000, 'swing');
    //document.location.hash = category;
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
  history.pushState('', document.title, window.location.pathname);
  $('.fab button:nth-child(3)').css('display', 'none');
}
