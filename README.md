DongleAuth.info
=================

[![Build Status](https://travis-ci.org/Nitrokey/dongleauth.svg)](https://travis-ci.org/Nitrokey/dongleauth)
[![License](https://img.shields.io/badge/license-mit-blue.svg?style=flat)](/LICENSE)

List of 2FA dongle providers and the platforms they support. 

## The Goal

The goal is to build a website ([dongleauth.info](https://www.dongleauth.info)) with a comprehensive list of sites that support One Time Passwords (OTP) or Universal 2nd Factor (U2F).

Our hope is to aid consumers who are deciding between alternative services based on the security they
offer for their customers. This can also serve as an indicator for the effort a site has put into security in general.

This site is a fork of [TwoFactorAuth](https://twofactorauth.org). The fork is necessary to further differentiate the 'Hardware' section. The TwoFactorAuth projects wants to give a general overview and do not wants to mark the technical details as well. We respect this decision. In need of a differentiation between OTP and U2F we decided to fork the project. Please see [the note on definitions](https://github.com/Nitrokey/dongleauth/blob/device_authenticators/CONTRIBUTING.md#a-note-on-definitions) as well.

## Contributing

If you'd like to contribute, read the entire guidelines here in
[CONTRIBUTING.md][contrib].

## Running Locally

DongleAuth.info is built upon [Jekyll](https://jekyllrb.com/), using the [github-pages](https://github.com/github/pages-gem) gem.
In order to run the site locally, it is necessary to install bundler, install all dependencies, and then use Jekyll to serve
the site. If the `gem` command is not available to you, it is necessary to install Ruby with RubyGems.
Once Ruby and RubyGems are installed and available from the command line, TwoFactorAuth can be setup using the following commands.

```shell
gem install bundler
cd ~/dongleauth
bundle install
bundle exec jekyll serve
```

If you're using Ubuntu or [Bash on Windows (WSL)](https://docs.microsoft.com/en-us/windows/wsl/install-win10) you'll probably need to install these dependencies first:

```shell
sudo apt install libffi-dev nodejs python-dev gcc ruby rails make zlib1g-dev ruby-dev libcurl3
gem install bundler
```

The DongleAuth website should then be accessible from `http://localhost:4000`.

Another option is to run Jekyll inside a [Docker](https://www.docker.com/) container.  Please read the [Jekyll Docker Documentation](https://github.com/envygeeks/jekyll-docker/blob/master/README.md) on how to do this.

## License

This code is distributed under the MIT license. For more info, read the
[LICENSE][license] file distributed with the source code.

[contrib]: /CONTRIBUTING.md
[license]: /LICENSE
