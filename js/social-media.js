---
---
$('.facebook-button').click(function () {
    window.open("https://facebook.com/" + $(this).data('facebook'), '_blank');
})

$('.email-button').click(function () {
  let langs = new Map();
{% for lang in site.data.languages %}
  {% unless lang[1].email_subject == '' %}
  langs.set("{{ lang[0] }}", "{{ lang[1].email_subject }}");
  {% endunless %}
{% endfor %}
let lang = $(this).data('lang')

  if (!langs.has(lang)) lang = "en"
  window.open('mailto:' + $(this).data('email') + '?subject=' + langs.get(lang))
})

$('.twitter-button').click(function () {
  let langs = new Map();
{% for lang in site.data.languages %}
  {% unless lang[1].tweet == '' %}
  langs.set("{{ lang[0] }}", "{{ lang[1].tweet |cgi_escape }}");
  {% endunless %}
{% endfor %}

let lang = $(this).data('lang')
  const handle = $(this).data('twitter')

  if (!langs.has(lang) || lang == null) lang = "en"
  const text = langs.get(lang).replace('TWITTERHANDLE', handle)

  window.open('https://twitter.com/share?hashtags=SupportTwoFactorAuth&text=' + text, '_blank');
})
