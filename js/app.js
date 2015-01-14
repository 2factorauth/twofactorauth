(function (root, $) {
    $('.menu .dropdown').dropdown();
    $('span.popup.exception').popup();
    $('a.popup.exception').popup();
    $('.ui.checkbox').checkbox();
}(window, jQuery));

$(document).ready(function() {
    $("img").unveil(50);
    updateFilterClasses();
});

var filter = { 
	noTfa: false,
	tfaProgress: false,
	category: 'all',
	methods: []
}

// Initialize the main searcher: searches through
// text in applicable rows and hides rows that don't
// match the search criteria
$("tbody").searcher({
    itemSelector: "tr.filtered-in",
    textSelector: "td",
    inputSelector: "#searchinput",
    toggle: function(item, containsText) {
        if (containsText) {            
        	$(item).show();
        } else {            
        	$(item).hide();
        }
    }
});

// Initialize the secondary searcher: searches through
// the same text, but if there are no rows to search,
// the entire section is hidden. This works because
// only 'filtered-in' rows are searched. If a section
// contains no rows that contain the class filtered-in
// then the entire section is hidden 
$("#main-container").searcher({
    itemSelector: ".section",
    textSelector: "table > tbody > tr.filtered-in > td",
    inputSelector: "#searchinput",
    toggle: function(item, containsText) {
        if (containsText) {            
        	$(item).show();
        } else {            
        	$(item).hide();
        }
    }
});


// For a given methodFilter (sms, phone, email, hw, sw)
// This will find each of the td elements of that type
// and check if they have children. If not, the filtered-in
// class is REMOVED from their row parent.
//
// This method is called by updateFilterClasses
function updateMethodFilter(method) {
	$('td.' + method).each(function() {
		// if it has children -- meaning the checkmark is there and it is supported
		if ($(this).children().length == 0) {
			// add filter to row so it can be shown
			$(this).closest('tr').toggleClass('filtered-in', false);
			$(this).closest('tr').hide();
		}
	});	
}

// This method updates the appropriate classes
// on table rows such that the searching and
// filtering will only display the matching rows.
// This is done by assigning the class 'filtered-in'
// to rows that match the filters.
function updateFilterClasses() {

	// Only tr's containing the filtered-in class
	// will be shown.
	//
	// IF the PROGRESS filter is selected, ensure 
	// all NON PROGRESS rows are hidden by removing the
	// filtered-in class from them and hiding them.
	// Ensure the IN PROGRESS rows are visible by
	// adding the filtered-in class to them all and
	// showing them.
	// 
	// ELSEIF the NON-TFA filter is selected, ensure 
	// all TFA rows are hidden by removing the
	// filtered-in class from them and hiding them.
	// Ensure the NON-TFA rows are visible by
	// adding the filtered-in class to them all and
	// showing them.
	// 
	// ELSEIF a method filter is selected, ensure
	// all NON-TFA rows are hidden by removing the
	// filtered-in class from them and hiding them.
	// Ensure the TFA rows are visible by adding the
	// filtered-in class to them all and showing them,
	// then evaluating them against the proper filters
	//
	// ELSE no filters are selected so all rows must
	// have the filtered-in class and be shown.
	//
	// FINALLY re-trigger any search filtering
	if (filter.tfaProgress) {
		$('tbody > tr').each(function() {
			$(this).toggleClass('filtered-in', false);
			$(this).hide();
		});

		$('tbody > tr.tfa-progress').each(function() {
			$(this).toggleClass('filtered-in', true);
			$(this).show();
		});		
	}
	else if (filter.noTfa) {
		$('tbody > tr.tfa').each(function() {
			$(this).toggleClass('filtered-in', false);
			$(this).hide();
		});

		$('tbody > tr.no-tfa').each(function() {
			$(this).toggleClass('filtered-in', true);
			$(this).show();
		});
	} else if(filter.methods.length > 0) {
		$('tbody > tr.tfa').each(function() {
			$(this).toggleClass('filtered-in', true);
			$(this).show();
		});

		$('tbody > tr.no-tfa').each(function() {
			$(this).toggleClass('filtered-in', false);
			$(this).hide();
		});

		$.each(filter.methods, function(index, value) {
			updateMethodFilter(value);
		});

	} else {
		$('tbody > tr').each(function() {
			$(this).toggleClass('filtered-in', true);
			$(this).show();
		})
	}

	// Dirty trick to leverage the searching plugin
	// to filter out empty sections after a filter
	// operation. Visually unnoticeable though
	var searchVal = $("#searchinput").val();
	$("#searchinput").val(' ');
	$('#searchinput').trigger('change');
	$("#searchinput").val(searchVal);
	$('#searchinput').trigger('change');
}

// Initializes the no-tfa filter checkboxes.
// These checkboxes limit the results to 
// sites that do not implement 2FA or only
// sites that are in-progress
$('.no-tfa-filter > input:checkbox').change(function() {
	filter[this.name] = this.checked;
	$('.method-filter > input:checkbox').prop('disabled', (filter.noTfa || filter.tfaProgress));
	updateFilterClasses();
});

// Initializes the method filter checkboxes.
// These checkboxes limit the results to the sites that
// implement all of the methods selected. For example,
// if both SMS and EMAIL are selected, only the sites
// that implement at least SMS and EMAIL.
$('.method-filter input:checkbox').change(function() {
	if( this.checked ) {
		if (!filter.methods[this.name]) {
			filter.methods.push(this.name);
			//updateMethodFilter(this.name)
		}
	} else {
		var index = $.inArray(this.name, filter.methods);
		if (index>=0) {
			filter.methods.splice(index, 1);
		}
	}

	if (filter.methods.length > 0) {
		$('.no-tfa-filter > input:checkbox').prop('disabled', true);
	} else {
		$('.no-tfa-filter > input:checkbox').prop('disabled', false);		
	}
	updateFilterClasses();
});