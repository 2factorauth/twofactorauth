# 2fa.directory

[![Build Status](https://img.shields.io/github/workflow/status/2factorauth/twofactorauth/Repository%20builds%20and%20tests?style=for-the-badge)][build_status]
[![License](https://img.shields.io/badge/license-mit-9A0F2D.svg?style=for-the-badge)][license]
[![Twitter](https://img.shields.io/badge/Twitter-@2faorg-1DA1F2.svg?style=for-the-badge&logo=twitter)][twitter]

A list of popular sites and whether or not they support two factor authentication.

## The Goal :goal_net:

The goal of this project is to build a website ([2fa.directory][site_url]) with a list of popular sites that support
two factor authentication, as well as the methods that they provide.

Our hope is to aid consumers who are deciding between alternative services based on the security they
offer for their customers. This project also serves as an indicator of general security efforts used on a site.

## Contributing :pencil2:

2fa.directory is only possible thanks to community contributions. We welcome all contributions to the project.
If you would like to contribute, please read the entire guidelines in
[CONTRIBUTING.md][contrib].

## Installing dependencies :hammer_and_wrench:

### 1. Docker

```BASH
docker pull 2factorauth/twofactorauth
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
sudo apt install build-essential ruby-bundler ruby-dev make gcc g++ zlib1g-dev npm
npm i babel-minify
bundle config set path './vendor/cache'
bundle install
```

MacOS (_Requires Xcode_):

```bash
# Install homebrew
xcode-select --install
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh

# Install ruby & nodejs(npm)
brew install ruby
brew install nodejs
echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.bash_profile

# Install Bundler and dependencies
gem install bundler
bundle config set path './vendor/cache'
bundle install
npm i babel-minify
```

## Building :running:

Docker (Windows/Linux/MacOS):

```BASH
docker run -p 4000:4000 -v $(pwd):/twofactorauth 2factorauth/twofactorauth
```

Snap/Manual:

```bash
# Create _data/all.json
ruby ./scripts/join-entries.rb > _data/all.json

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
[license]: /LICENSE.md
[gitter]: https://gitter.im/2factorauth/twofactorauth
[twitter]: https://twitter.com/2faorg
[site_url]: https://2fa.directory
[contrib]: /CONTRIBUTING.md
[jekyll]: https://jekyllrb.com/
[pages-gem]: https://github.com/github/pages-gem
[docker]: https://www.docker.com/
