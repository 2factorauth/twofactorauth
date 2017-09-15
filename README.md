acceptBitcoin.Cash
==================

Community-curated list of sites/merchants that accept Bitcoin Cash. Submit a pull request with your contribution to add! Read below for help.

[![Join the chat at https://gitter.im/acceptbitcoincashproject/Lobby](https://badges.gitter.im/acceptbitcoincashproject/Lobby.svg)](https://gitter.im/acceptbitcoincashproject/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

### _This repo has been cloned recently. More changes to come..._

[![Build Status](https://travis-ci.org/2factorauth/twofactorauth.svg)](https://travis-ci.org/2factorauth/twofactorauth)
[![License](https://img.shields.io/badge/license-mit-blue.svg?style=flat)](/LICENSE)
[![Gitter](https://img.shields.io/gitter/room/2factorauth/twofactorauth.svg)](https://gitter.im/2factorauth/twofactorauth)
[![Twitter](https://img.shields.io/badge/Twitter-@2faorg-blue.svg)](https://twitter.com/2faorg)

## The Goal

The goal is to build a website ([TwoFactorAuth.org](https://twofactorauth.org)) with a comprehensive list of sites that support
Two Factor Authentication, as well as the methods that they provide.

Our hope is to aid consumers who are deciding between alternative services based on the security they
offer for their customers. This can also serve as an indicator for the effort a site has put into security in general.

## Contributing

If you'd like to contribute, read the entire guidelines here in
[CONTRIBUTING.md][contrib].

## Running Locally

TwoFactorAuth.org is built upon [Jekyll](https://jekyllrb.com/), using the [github-pages](https://github.com/github/pages-gem) gem.
In order to run the site locally, it is necessary to install bundler, install all dependencies, and then use Jekyll to serve
the site. If the `gem` command is not available to you, it is necessary to install Ruby with RubyGems.
Once Ruby and RubyGems are installed and available from the command line, TwoFactorAuth can be setup using the following commands.

```
gem install bundler
cd ~/twofactorauth
bundle install
bundle exec jekyll serve
```

The TwoFactorAuth website should then be accessible from `http://localhost:4000`.

## License

This code is distributed under the MIT license. For more info, read the
[LICENSE][license] file distributed with the source code.

[contrib]: /CONTRIBUTING.md
[license]: /LICENSE
