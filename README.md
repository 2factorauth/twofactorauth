TwoFactorAuth.org
=================

[![Build Status](https://img.shields.io/travis/2factorauth/twofactorauth/master?style=for-the-badge)](https://travis-ci.org/2factorauth/twofactorauth)
[![License](https://img.shields.io/badge/license-mit-9A0F2D.svg?style=for-the-badge)](/LICENSE)
[![Gitter](https://img.shields.io/gitter/room/2factorauth/twofactorauth.svg?style=for-the-badge&logo=gitter&color=ED1965)](https://gitter.im/2factorauth/twofactorauth)
[![Twitter](https://img.shields.io/badge/Twitter-@2faorg-1DA1F2.svg?style=for-the-badge&logo=twitter)](https://twitter.com/2faorg)

A list of popular sites and whether or not they accept two factor auth.

## The Goal

The goal of this project is to build a website ([TwoFactorAuth.org](https://twofactorauth.org)) with a list of popular sites that support
Two Factor Authentication, as well as the methods that they provide.

Our hope is to aid consumers who are deciding between alternative services based on the security they
offer for their customers. This project also serves as an indicator of general security efforts used on a site. 

## Contributing

If you would like to contribute, please read the entire guidelines here in
[CONTRIBUTING.md][contrib].

## Running Locally

TwoFactorAuth.org is built upon [Jekyll](https://jekyllrb.com/), using the [github-pages](https://github.com/github/pages-gem) gem.
In order to run the site locally, bundler, and all other dependencies will need to be installed, and afterwards Jekyll can serve
the site. If the `gem` command is not available, Ruby with RubyGems needs to be installed.
Once Ruby and RubyGems are installed and available from the command line, TwoFactorAuth can be setup using the following commands.

```shell
gem install bundler
cd ~/twofactorauth
bundle install
bundle exec jekyll serve
```

If you're using Ubuntu or [Bash on Windows (WSL)](https://docs.microsoft.com/en-us/windows/wsl/install-win10) you'll probably need to install these dependencies first:

```shell
sudo apt install build-essential ruby-bundler ruby-dev make gcc g++ zlib1g-dev
```

The TwoFactorAuth website should now be accessible from `http://localhost:4000`.

Another option is to run Jekyll inside a [Docker](https://www.docker.com/) container.  Please read the [Jekyll Docker Documentation](https://github.com/envygeeks/jekyll-docker/blob/master/README.md) on how to use Jekyll.

## License

This code is distributed under the MIT license. For more info, read the
[LICENSE][license] file distributed with the source code.

[contrib]: /CONTRIBUTING.md
[license]: /LICENSE
