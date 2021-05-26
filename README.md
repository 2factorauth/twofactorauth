# 2fa.directory

[![Build Status](https://img.shields.io/github/workflow/status/2factorauth/twofactorauth/Jekyll%20Tests?style=for-the-badge)][build_status]
[![License](https://img.shields.io/badge/license-mit-9A0F2D.svg?style=for-the-badge)][license]
[![Gitter](https://img.shields.io/gitter/room/2factorauth/twofactorauth.svg?style=for-the-badge&logo=gitter&color=ED1965)][gitter]
[![Twitter](https://img.shields.io/badge/Twitter-@2faorg-1DA1F2.svg?style=for-the-badge&logo=twitter)][twitter]

A list of popular sites and whether or not they accept two factor auth.

## The Goal :goal_net:

The goal of this project is to build a website ([2fa.directory][site_url]) with a list of popular sites that support Two
Factor Authentication, as well as the methods that they provide.

Our hope is to aid consumers who are deciding between alternative services based on the security they offer for their
customers. This project also serves as an indicator of general security efforts used on a site.

## Contributing :pencil2:

If you would like to contribute, please read the entire guidelines here in
[CONTRIBUTING.md][contrib].

## Installing dependencies :hammer_and_wrench:

### 1. Docker

```BASH
docker pull 2factorauth/twofactorauth:4.0
```

### 2. Snap

```bash
  sudo snap install ruby --classic
  npm i babel-minify
  bundle config set path './vendor/cache'
  bundle install
```

### 3. Manual installation

This is the most difficult option and recommended for environments where Docker or Snap can't be used.

GNU/Linux and WSL:

```bash
sudo apt install build-essential ruby-bundler ruby-dev make gcc g++ zlib1g-dev npm webp
npm i babel-minify
bundle config set path './vendor/cache'
bundle install
```

MacOS (_Requires Xcode_):

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

## Building :running:

Docker (Windows/Linux/MacOS):

```BASH
docker run -p 4000:4000 -v $(pwd):/twofactorauth
```

Snap/Manual:

```bash
# Generating API files
mkdir -p api/v1 api/v2 api/v3
bundle exec ruby ./scripts/APIv1.rb
bundle exec ruby ./scripts/APIv2.rb
bundle exec ruby ./scripts/APIv3.rb

# Building the site
bundle exec jekyll build

# Minify JS (Optional)
./scripts/minify-js.sh

# Building regional sites (Optional)
ruby ./scripts/regions.rb
```

To run the site on a minimal WEBrick webserver, do:
```BASH
bundle exec jekyll serve
```
The website should now be accessible from `http://localhost:4000`.

## License :balance_scale:

This code is distributed under the MIT license. For more info, read the
[LICENSE][license] file distributed with the source code.

[build_status]: https://github.com/2factorauth/twofactorauth/actions
[license]: /LICENSE
[gitter]: https://gitter.im/2factorauth/twofactorauth
[twitter]: https://twitter.com/2faorg
[site_url]: https://2fa.directory
[contrib]: /CONTRIBUTING.md
[jekyll]: https://jekyllrb.com/
[pages-gem]: https://github.com/github/pages-gem
[docker]: https://www.docker.com/
[jekyll_docker]: https://github.com/envygeeks/jekyll-docker/blob/master/README.md
