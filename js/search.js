$(document).ready(function () {
  var jets = new Jets({
    searchTag: '#innerSearchBox',
    contentTag: '.searchContainer',
    didSearch: function (search_phrase) {
      document.location.hash = '';

      if (search_phrase == '') {
        // Empty search value
        // Display everything. Close tables
        $('.cat').show();
        $('.cat').removeClass('active');
        $('.category-table').removeClass('show');
        $('.search-table-title').hide();
        $('#no-results').hide();
      } else {
        // Populated search field

        // Hide category icons
        $('.cat').hide();

        // Display all category tables
        $('.category-table').addClass('show');

        // Go through each table
        $('tbody').each(function (i) {
          // If tbody contains a visible table-*
          if ($(this).find('tr.table-success:visible').length > 0 || $(this).find('tr.table-danger:visible').length > 0) {
            $(this).parent().parent().addClass('show');
          } else {
            // Hide all tables not containing a visible tr
            $(this).parent().parent().removeClass('show');
          }
        });

        $('.searchContainer.mobile-only').each(function(i){
          if($(this).find('div.table-success:visible').length > 0 || $(this).find('div.table-danger:visible').length > 0){
            $(this).find('.search-table-title').show();
          }else{
            $(this).find('.search-table-title').hide();
          }
        });

        if ($('.searchContainer').find(':visible').length == 0){
          $('#no-results').show();
        }else{
          $('#no-results').hide();
        }

      }
    },
    // Process searchable elements manually
    manualContentHandling: function(tag){
      return $(tag).find('.searchWords').text();
    }
  });
});

// Wrap the jets.search function with a debounced function
var debouncedSearch = debounce(function(e) {
  jets.search(e.target.value);
}, 350);

// Attach a keyup event listener to the input
$('#jets-search').keyup(debouncedSearch);

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