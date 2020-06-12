# TwoFactorAuth.org

[![Build Status](https://img.shields.io/github/workflow/status/2factorauth/twofactorauth/Jekyll%20Tests?style=for-the-badge)](https://github.com/2factorauth/twofactorauth/actions)
[![License](https://img.shields.io/badge/license-mit-9A0F2D.svg?style=for-the-badge)](/LICENSE)
[![Gitter](https://img.shields.io/gitter/room/2factorauth/twofactorauth.svg?style=for-the-badge&logo=gitter&color=ED1965)](https://gitter.im/2factorauth/twofactorauth)
[![Twitter](https://img.shields.io/badge/Twitter-@2faorg-1DA1F2.svg?style=for-the-badge&logo=twitter)](https://twitter.com/2faorg)

A list of popular sites and whether or not they accept two factor auth.

## The Goal

The goal of this project is to build a website ([TwoFactorAuth.org](https://twofactorauth.org)) with a list of popular sites that support
Two Factor Authentication, as well as the methods that they provide.

Our hope is to aid consumers who are deciding between alternative services based on the security they
offer for their customers. This project also serves as an indicator of general security efforts used on a site.

## Contributing :pencil2:

If you would like to contribute, please read the entire guidelines here in
[CONTRIBUTING.md][contrib].

## Local installation :hammer_and_wrench:

TwoFactorAuth.org is built upon [Jekyll](https://jekyllrb.com/), using the [github-pages](https://github.com/github/pages-gem) gem.
In order to run the site locally, bundler, and all other dependencies will need to be installed, and afterwards Jekyll can serve
the site. Ubuntu:

```bash
sudo snap install ruby --classic
sudo apt install webp npm
npm i babel-minify
bundle install --path vendor/bundle
```

Windows Subsystem for Linux (WSL)

```bash
sudo apt install build-essential ruby-bundler ruby-dev make gcc g++ zlib1g-dev npm webp
npm i babel-minify
bundle install --path vendor/bundle
```

MacOS (_Requires Xcode_)

```bash
# Install homebrew
xcode-select --install
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh

# Install ruby, webp & nodejs(npm)
brew install ruby
brew install webp
brew install nodejs
echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.bash_profile

# Install Bundler and dependencies
gem install bundler
bundle install --path vendor/bundle
npm i babel-minify
```

## Running locally :running:

Ubuntu/WSL/MacOS:

```bash
# Generating regional sites (Optional)
ruby ./_deployment/regions.rb

# Minify JS (Optional)
./_deployment/minify-js.sh

# Generate WebP images
./_deployment/webp.sh

# Building the site
bundle exec jekyll build

# Running the site locally
bundle exec jekyll serve --watch
```

The TwoFactorAuth website should now be accessible from `http://localhost:4000`.

Another option is to run Jekyll inside a [Docker](https://www.docker.com/) container. Please read the [Jekyll Docker Documentation](https://github.com/envygeeks/jekyll-docker/blob/master/README.md) on how to use Jekyll.

## License :balance_scale:

This code is distributed under the MIT license. For more info, read the
[LICENSE][license] file distributed with the source code.

[contrib]: /CONTRIBUTING.md
[license]: /LICENSE
