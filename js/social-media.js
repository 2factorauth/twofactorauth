---
---
$('.facebook-button').click(function () {
    window.open("https://facebook.com/" + $(this).data('facebook'), '_blank');
})

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

$('.twitter-button').click(function () {
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

  let lang = $(this).data('lang');
  const handle = $(this).data('twitter');

  if (!langs.has(lang) || lang == null) lang = "en";
  const index = Math.floor(Math.random() * langs.get(lang).length);
  const text = langs.get(lang)[index].replace('TWITTERHANDLE', handle);
  const url = "{{ site.url | cgi_escape }}";
  const tfa_handle = "{{ site.twitter | cgi_escape }}";

  window.open(`https://twitter.com/intent/tweet?text=${text}&url=${url}&hashtags=SupportTwoFactorAuth&related=${tfa_handle}`, '_blank');
})
