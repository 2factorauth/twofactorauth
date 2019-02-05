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
  if (getUrlParameter('filter') == 'all') {
    $('#show-bch-only').prop('checked', false);
  }

  // Check if URL parameter exists to skip to content (due to window.location.hash being used for categories)
  if (getUrlParameter('skipToListings')) {
    var body = $("html, body");
    body.stop().animate({scrollTop: $('#maingrid').offset().top - 128}, 500, 'swing');
  }

  // Clear the BCH-only view
  $('.clear-bch-only').click(function () {
    $('#show-bch-only').prop('checked', false);
    BCHfilter();
  });

  // Check if URL references specific category
  if (window.location.hash && window.location.hash.indexOf('#') > -1) {
    openCategory(window.location.hash.substring(1));
  }

  // Stick the BCH-only filter to the top on scroll
  $('.ui.sticky.bch-only').sticky({
		onStick: function(){
			$(this).css({
				height: 'auto'
			});
		}
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

  // Scroll to the main content grid
  $('#skip-to-content').on('click', function () {
    var body = $("html, body");
    body.stop().animate({scrollTop: $('#maingrid').offset().top - 128}, 500, 'swing');
  });

  // Clear and collapse all open categories
  $('.fab button:nth-child(3)').on('click', function () {
    if (isSearching) jets.options.didSearch( $('#bch-merchant-search').val() );
    if (isSearching == false) {
      $('.website-table').slideUp();
      var body = $("html, body");
      body.stop().animate({scrollTop: $('.category h5.active-icon').offset().top - 120}, 1000, 'swing');
      $('.category h5').removeClass('active-icon');
      $(this).css('display', 'none');
      document.location.hash = '';
    } else {
      if ($(this).hasClass('attention')) {
        $(this).removeClass('attention');
        $("#bch-merchant-search").removeClass('attention');
      } else {
        $(this).addClass('attention');
        $("#bch-merchant-search").addClass('attention');
      }
    }
  });

  // Clear the active search terms
  $('button#search-clear').on('click', function () {
    $('#search-wrapper input#bch-merchant-search').val('');
    $('#no-results').css('display', 'none');
    $('.category').show();
    $('.website-table').hide();
    $('#maingrid').css('visibility', 'visible');
    $('#search-wrapper input#bch-merchant-search').focus();
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
    $('img.p-logo').trigger('unveil');
    $('img.image').trigger('unveil');
  });

  $('#art-collections').on('click', function () {
    $('.ui.modal.art-collections').modal('show');
  });

  $('#abci-logo, h1 i, #about-this-site').on('click', function () {
    $('.ui.modal.about-this-site').modal('show');
    $('.about-this-site img').trigger('unveil');
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
if(document.getElementById('bch-merchant-search') instanceof Object){
	var jets = new Jets({
	  callSearchManually: true,
	  contentTag: '.bch-merchant-content',
	  didSearch: function (searchPhrase) {
		document.location.hash = '';
		$('#no-results').css('display', 'none');
		$('#maingrid').css('visibility', 'visible');
		$('.category h5').removeClass('active-icon');
		// Two separate table layouts are used for desktop/mobile
		var platform = ($(window).width() > 768) ? 'desktop' : 'mobile';
		var content = $('.' + platform + '-table .bch-merchant-content');
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
			  $('#maingrid').css('visibility', 'hidden');
		  }

		  $('#search-clear').fadeIn('slow');

		  isSearching = true;

		  //$('html, body').stop().animate({scrollTop: $('#maingrid').offset().top - 120}, 500, 'swing');
		  $('html, body').scrollTop($('#maingrid').offset().top - 128);
		}
	  },
	  addImportant: true,
	  // Process searchable elements manually
	  manualContentHandling: function(tag) {
		var searchItems = $(tag).find('.title > div.keywords').text();
		return searchItems;
	  }
	});
	
	// Wrap the jets.search function with a debounced function
	var debouncedSearch = debounce(function(e) {
	  jets.search(e.target.value);
	}, 350);

	// Attach a keyup event listener to the input
	$('#bch-merchant-search').keyup(debouncedSearch);

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
/**
 * Ensure searching is conducted with regard to the user's viewport
 * after re-sizing the screen and close all categories after re-sizing
 */
$(window).on('resizeEnd', function () {
  if (isSearching) jets.options.didSearch( $('#bch-merchant-search').val() );
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
  BCHfilter();
});

/**
 * Check if the user wants to filter by Bitcoin Cash only
 */
function BCHfilter() {
 if ($('#show-bch-only').is(':checked')) {
    $('.no-bch').css('display', 'none');
    $('.bch-only-none-found').css('display', 'table-row');
    $('.bch-only-none-found-mobile').css('display', 'block');
    $('.bch-only-hidden').css('opacity', '0.4');
  } else {
    $('.website-table:visible img').trigger('unveil');
    $('.bch-only-none-found, .bch-only-none-found-mobile').css('display', 'none');
    $('.bch-only-hidden').css('opacity', '1');
    $('.mobile-table .no-bch').css('display', 'block');
    $('.desktop-table .no-bch').css('display', 'table-row');
  }
  if (isSearching) jets.options.didSearch( $('#bch-merchant-search').val() );
}

/**
 * Checks if a category is open
 *
 * @param category The id of a category as a string
 * @returns {*|jQuery} A true or false value, whether the category is open
 */
function isOpen(category) {
  return $('#' + category + ' h5').hasClass('active-icon');
}

/**
 * Opens a category, ensures the icon is active and scrolls to the icon
 *
 * @param category The id of a category as a string
 */
function openCategory(category) {
  // Close all active categories
  $('.category h5').removeClass('active-icon');
  $('.website-table').css('display', 'none');
  $('.fab button:nth-child(3)').css('display', 'inline-block');
  BCHfilter();

  // Place the category being viewed in the URL bar
  window.location.hash = category;

  var cat = $('#' + category + ' h5');
  var icon = $('#' + category + ' h5 i');
  cat.addClass('active-icon');
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
  $('#' + category + ' h5').removeClass('active-icon');
  history.pushState('', document.title, window.location.pathname);
  $('.fab button:nth-child(3)').css('display', 'none');
}
