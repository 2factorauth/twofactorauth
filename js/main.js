$(document).ready(function () {
  // Show region notice
  if (window.localStorage.getItem('region-notice') !== 'hidden') $('#region-notice').collapse('show');

  // Register service worker
  if ('serviceWorker' in navigator) navigator.serviceWorker.register('/service-worker.js');

  // Show category of query
  const query = window.location.hash;
  if (query && query.indexOf('#') > -1) showCategory(query.substring(1));
});

$(window).on('hashchange', function () {
  const query = window.location.hash;
  if (query && query.indexOf('#') > -1) showCategory(query.substring(1));
});

$('.exception').popup({position: 'right center', hoverable: true, title: 'Exceptions & Restrictions'});

// On category click
$('.category-btn').click(function () {
  let query = window.location.hash.substring(1);

  // Collapse all other tables
  $('.category-table.collapse').collapse('hide');
  $('.category-btn').removeClass('active');

  // Check if category tables are displayed
  if (!$(`#${query}-table`).hasClass('collapsing') && !$(`#${query}-mobile-table`).hasClass('collapsing') || query !== this.id) {
    window.location.hash = this.id;
    showCategory(this.id);
  } else {
    // Remove #category in URL
    history.pushState("", document.title, window.location.pathname + window.location.search);
  }
});

$('#region-notice-close-btn').click(function () {
  $('#region-notice').collapse('hide');
  window.localStorage.setItem('region-notice', 'hidden');
});

// Show desktop and mobile tables
function showCategory(category) {
  $('.category-table.collapse').collapse('hide');
  $(`#${category}-table`).collapse("show");
  $(`#${category}-mobile-table`).collapse("show");
  $('.category-btn').removeClass('active');
  $(`[id=${category}]`).addClass('active');
}

let resizeObserver = new ResizeObserver(() => {
  // Fix the footer to bottom of viewport if body is less than viewport
  if ($('body').height() < $(window).height()) {
    $('.footer').css({position: 'absolute'});
  } else {
    $('.footer').css({position: 'static'});
  }
});

resizeObserver.observe($('body')[0]);
