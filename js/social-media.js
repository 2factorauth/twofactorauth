---
---
$('.facebook-button').click(function () {
    window.open("https://facebook.com/" + $(this).data('facebook'), '_blank');
})

$('.email-button').click(function () {
  let langs = new Map();
{% for lang in site.data.languages %}
  langs.set("{{ lang[0] }}", "{{ lang[1].email_subject }}");
{% endfor %}
let lang = $(this).data('lang') // TODO: See lang in function below

  if (!langs.has(lang)) lang = "en"
  window.open('mailto:' + $(this).data('email') + '?subject=' + langs.get(lang))
})

$('.twitter-button').click(function () {
  let langs = new Map();
{% for lang in site.data.languages %}
  langs.set("{{ lang[0] }}", "{{ lang[1].tweet |cgi_escape }}");
{% endfor %}

let lang = $(this).data('lang') // TODO: Check if langs contains key of lang value
  const handle = $(this).data('twitter')

  if (!langs.has(lang)) lang = "en"
  const text = langs.get(lang).replace('TWITTERHANDLE', handle)

  window.open('https://twitter.com/share?url={{site.url | cgi_escape}}&hashtags=SupportTwoFactorAuth&text=' + text, '_blank');
})
