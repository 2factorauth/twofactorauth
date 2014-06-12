TwoFactorAuth.org [![Build Status](https://travis-ci.org/jdavis/twofactorauth.png?branch=master)](https://travis-ci.org/jdavis/twofactorauth)
=================

A list of popular sites and whether or not they accept two factor auth.

## The Goal

The goal is to have a website with a comprehensive list of sites that support
two factor auth as well as the methods that they support it.

This is to aid when deciding on alternative services based on the security they
offer for their customers.

This also is a way for consumers to see what sites still need to invest in
further security practices and which ones already do.

## Running Locally

It's easy to run everything locally to test it out. Either you can have plain
[Jekyll][jekyll] installed or you can use [Bundler][bundler] to manage
everything for you.

### Using Bundler

1. To install Bundler, just run `gem install bundler`.
2. Install dependencies in the [Gemfile][gemfile], `bundle install`.
3. Run Jekyll: `bundle exec jekyll serve --watch`. The `--watch` is optional and
   makes Jekyll watch for file changes.

### Using Vanilla Jekyll

1. Install Jekyll if you don't already have it: `gem install jekyll`.
2. Run Jekyll: `jekyll serve --watch`. The `--watch` is again optional.

## Contributing

If you'd like to contribute, read the entire guidelines here in
[CONTRIBUTING.md][contrib].

## License

This code is distributed under the MIT license. For more info, read the
[LICENSE](license) file distributed with the source code.

[bundler]: http://bundler.io/
[contrib]: /CONTRIBUTING.md
[gemfile]: /Gemfile
[jekyll]: http://jekyllrb.com/
[license]: /LICENSE
