$(document).ready(function () {
  let didSetConsent = false;

  function allowAnalytics() {
    gtag('consent', 'update', {
      'ad_storage': 'granted',
      'analytics_storage': 'granted',
    });
  }

  function processConsent() {
    didSetConsent = true;
    if (this.hasConsented()) {
      allowAnalytics();
    }
  }

  // Always called after consentcookie finishes, we just need to handle if consentcookie determined
  // it didn't need to ask the user for consent
  function onComplete() {
    if (!didSetConsent) {
      allowAnalytics();
    }
  }

  window.cookieconsent.initialise({
    container: document.getElementById("consentCookie"),
    type: 'opt-in',
    palette: {
      popup: { background: "#efefef" },
    },
    content: {
      allow: 'Allow',
      message: 'We use cookies and other tracking technologies to improve your browsing experience on our website to analyze our website traffic and to understand where our visitors are coming from.',
      href: '/privacy',
    },
    onStatusChange: processConsent,
    onInitialise: processConsent,
    location: true,
  }, onComplete);
  gtag('js', new Date());
  gtag('consent', 'default', {
    'ad_storage': 'denied',
    'analytics_storage': 'denied',
    // Delay setting default consent settings until consentcookie has started up
    'wait_for_update': 500
  });
  gtag('config', 'G-SMXGN4C672');
});

window.dataLayer = window.dataLayer || [];
function gtag() { dataLayer.push(arguments); }
