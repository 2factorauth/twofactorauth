$(document).ready(function () {

  // Show popup notice
  $('.exception').popup({ position: 'right center', hoverable: true, title: 'Exceptions & Restrictions' });

  // Register service worker
  if ('serviceWorker' in navigator) navigator.serviceWorker.register('/service-worker.js');

  // Show category of query
  const query = window.location.hash;
  if (query && query.indexOf('#') > -1) {
    // Remove all tables before showing the correct one
    $('.collapse').collapse('hide');
    showCategory(query.substring(1));
  }
});

// On category click
$('.cat').click(function () {
  let query = window.location.hash;

  // Collapse all other tables.
  $('.collapse').collapse('hide');
  $('.cat').removeClass('active');

  // Check if category tables are displayed
  if (!$(`#${query.substring(1)}-table`).hasClass('collapsing') && !$(`#${query.substring(1)}-mobile-table`).hasClass('collapsing') || query.substring(1) !== this.id) {
    window.location.hash = this.id;
    showCategory(this.id);
  } else {
    // Remove #category in URL
    history.pushState("", document.title, window.location.pathname + window.location.search);
  }
});


// Show desktop & mobile tables
function showCategory(category) {
  $(`#${category}-table`).collapse("show");
  $(`#${category}-mobile-table`).collapse("show");
  $(`#${category}`).addClass('active');
}

let resizeObserver = new ResizeObserver(() => {
  // Fix the footer to bottom of viewport if body is less than viewport
  if($('body').height() < $(window).height()){
    $('.footer').css({position: 'absolute'});
  }else{
    $('.footer').css({position: 'static'});
  }
});

resizeObserver.observe($('body')[0]);
