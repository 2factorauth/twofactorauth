---
---

$('.email-button').click(function () {
  let langs = new Map();
{% for lang in site.data.languages %}
  {% if lang[1].email_subject %}
  langs.set("{{ lang[0] }}", "{{ lang[1].email_subject }}");
  {% endif %}
{% endfor %}
  let lang = $(this).data('lang');

  if (!langs.has(lang)) lang = "en";
  window.open('mailto:' + $(this).data('email') + '?subject=' + langs.get(lang));
})

$('.facebook-button').click(function () {
  const uri = `https://facebook.com/${$(this).data('facebook')}`;
  social_media_notice(uri);
})

$('.twitter-button').click(function () {
  const uri = twitter_uri($(this).data('lang'), $(this).data('twitter'));
  social_media_notice(uri);
})

function social_media_notice(uri){
  if (window.localStorage.getItem('social-media-notice') !== 'hidden') {
    let modal = new bootstrap.Modal($('#social-media-warn'));
    modal.toggle();
    $('#social-media-accept').attr('onclick', `window.localStorage.setItem('social-media-notice', 'hidden');window.open('${uri}', '_blank');`)
  } else {
    window.open(uri, '_blank');
  }
}

function twitter_uri(lang,handle){
  let langs = new Map();
  let tweets = [];
  {% for lang in site.data.languages %}
    {% if lang[1].tweets %}
      tweets = [];
      {% for tweet in lang[1].tweets %}
        tweets.push("{{ tweet |cgi_escape }}");
      {% endfor %}
      langs.set("{{ lang[0] }}", tweets);
    {% endif %}
  {% endfor %}

  if (!langs.has(lang) || lang == null) lang = "en";
  const index = Math.floor(Math.random() * langs.get(lang).length);
  const text = langs.get(lang)[index].replace('TWITTERHANDLE', handle);
  const url = "{{ site.url | cgi_escape }}";
  const tfa_handle = "{{ site.twitter | cgi_escape }}";
  return `https://twitter.com/intent/tweet?text=${text}&url=${url}&hashtags=SupportTwoFactorAuth&related=${tfa_handle}`
}
