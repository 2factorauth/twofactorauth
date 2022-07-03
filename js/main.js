$(document).ready(() => {

  // Register service worker
  if ('serviceWorker' in navigator) navigator.serviceWorker.register('/service-worker.js');

  // Show region notice
  if (window.localStorage.getItem('region-notice') !== 'hidden') $('#region-notice').collapse('show');

  // Show category of query
  const query = window.location.hash;
  if (query && query.indexOf('#') > -1) showCategory(query.substring(1));
});

$(window).on('hashchange', async () => {
  const query = window.location.hash;
  if (query && query.indexOf('#') > -1) await showCategory(query.substring(1));
});

// On category click
$('.category-btn').click(async function () {
  const href = $(this).attr('href');
  if (window.location.hash === href) {
    history.pushState("", document.title, window.location.pathname + window.location.search);
    $('.category-table.collapse').collapse('hide');
    $('.category-btn').removeClass('active');
  } else {
    window.location.hash = href;
  }
})

$('#region-notice-close-btn').click(async () => {
  $('#region-notice').collapse('hide');
  window.localStorage.setItem('region-notice', 'hidden');
});

// Show desktop and mobile tables
async function showCategory(category) {
  $(`.category-table.collapse:not(#${category}-table, #${category}-mobile-table)`).collapse('hide');
  $(`.category-btn:not([id=${category}])`).removeClass('active');
  $(`#${category}-table, #${category}-mobile-table`).collapse("show");
  $(`[id=${category}]`).addClass('active');
}

let resizeObserver = new ResizeObserver(() => {
  if ($('body').height() < $(window).height()) {
    $('.footer').css({position: 'absolute'});
  } else {
    $('.footer').css({position: 'static'});
  }
});

resizeObserver.observe($('body')[0]);

// Initialise popovers
const exceptionPopoverList = [...document.querySelectorAll('.exception')].map(el => new bootstrap.Popover(el, {
  trigger: 'hover focus',
  title: 'Exceptions & Restrictions'
}));

const customTfaPopoverConfig = {
  html: true,
  sanitize: false,
  trigger: 'hover focus'
}
const customHardwarePopoverList = [...document.querySelectorAll('.custom-hardware-popover')].map(el => new bootstrap.Popover(el, {
  ...customTfaPopoverConfig,
  title: 'Custom Hardware 2FA'
}));
const customSoftwarePopoverList = [...document.querySelectorAll('.custom-software-popover')].map(el => new bootstrap.Popover(el, {
  ...customTfaPopoverConfig,
  title: 'Custom Software 2FA'
}));

