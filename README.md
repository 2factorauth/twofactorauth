TwoFactorAuth.org
=================

[![Build Status](https://travis-ci.org/2factorauth/twofactorauth.svg)](https://travis-ci.org/2factorauth/twofactorauth)
[![License](https://img.shields.io/badge/license-mit-blue.svg?style=flat)](/LICENSE)
[![Gitter](https://img.shields.io/gitter/room/2factorauth/twofactorauth.svg)](https://gitter.im/2factorauth/twofactorauth)
[![Twitter](https://img.shields.io/badge/Twitter-@2faorg-blue.svg)](https://twitter.com/2faorg)

A list of popular sites and whether or not they accept two factor auth.

## The Goal

The goal is to build a website ([TwoFactorAuth.org](https://twofactorauth.org)) with a list of popular sites that support
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

```shell
gem install bundler
cd ~/twofactorauth
bundle install
bundle exec jekyll serve
```

If you're using Ubuntu or [Bash on Windows (WSL)](https://docs.microsoft.com/en-us/windows/wsl/install-win10) you'll probably need to install these dependencies first:

```shell
sudo apt install libffi-dev nodejs python-dev gcc ruby rails make zlib1g-dev ruby-dev libcurl3
gem install bundler
```

The TwoFactorAuth website should then be accessible from `http://localhost:4000`.

Another option is to run Jekyll inside a [Docker](https://www.docker.com/) container.  Please read the [Jekyll Docker Documentation](https://github.com/envygeeks/jekyll-docker/blob/master/README.md) on how to do this.

## License

This code is distributed under the MIT license. For more info, read the
[LICENSE][license] file distributed with the source code.

[contrib]: /CONTRIBUTING.md
[license]: /LICENSE
