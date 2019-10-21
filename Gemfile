# frozen_string_literal: true

source 'https://rubygems.org'

# Dependencies are bundled with the github-pages gem
group :jekyll_plugins do
  gem 'github-pages'
  gem 'jekyll-minifier'
  gem 'jekyll-seo-tag'
  gem 'jekyll-sitemap'
end

group :test do
  gem 'diff-lcs'
  gem 'diffy'
  gem 'fastimage'
  gem 'highline'
  gem 'html-proofer'
  gem 'jsonlint'
  gem 'kwalify'
  gem 'rake'
  gem 'rubocop'
end

# rubocop:disable Style/SymbolArray
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
# rubocop:enable Style/SymbolArray

# Performance-booster for watching directories on Windows
gem 'wdm', '~> 0.1.0' if Gem.win_platform?
