# _plugins/URLEncoding.rb
require 'liquid'
require 'uri'

# Percent encoding for URI conforming to RFC 3986.
# Ref: http://tools.ietf.org/html/rfc3986#page-12
module URLEncoding
  def url_encode_mail(url)
    return URI.escape(url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")).gsub("\'", "%27").gsub("+", "%20")
  end
end

Liquid::Template.register_filter(URLEncoding)
