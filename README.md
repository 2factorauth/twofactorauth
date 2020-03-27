# ![Bitcoin Cash](img/ab.c-logo.png "the Accept Bitcoin Cash initiative")

A community-curated list of sites/merchants that accept [**Bitcoin Cash**](https://www.bitcoincash.org), _a peer-to-peer electronic cash system_ suitable for the digital age, and the future of online commerce.

Add a site that's not listed, or provide any updates/corrections by submitting a pull request, or [creating an issue](https://github.com/acceptbitcoincash/acceptbitcoincash/issues). Learn how to do either by reading [our contribution guidelines](CONTRIBUTING.md).

[![Build Status](https://travis-ci.org/acceptbitcoincash/acceptbitcoincash.svg?branch=master)](https://travis-ci.org/acceptbitcoincash/acceptbitcoincash)
[![GitHub pull-requests](https://img.shields.io/github/issues-pr/acceptbitcoincash/acceptbitcoincash.svg)](https://github.com/acceptbitcoincash/acceptbitcoincash/pulls/)
[![GitHub issues-closed](https://img.shields.io/github/issues-closed/acceptbitcoincash/acceptbitcoincash.svg)](https://github.com/acceptbitcoincash/acceptbitcoincash/issues?q=is%3Aissue+is%3Aclosed)
[![Twitter](https://img.shields.io/badge/Twitter-@useBitcoinCash-blue.svg)](https://twitter.com/useBitcoinCash)
[![License](https://img.shields.io/badge/license-mit-blue.svg?style=flat)](/LICENSE)

## The Goal

The goal is to build a website ([https://acceptBitcoin.cash](https://acceptBitcoin.Cash)) with a comprehensive list of sites that accept or support Bitcoin Cash, as well as Bitcoin (Legacy).

Our hope is to connect consumers and merchants while spreading awareness and promoting the global adoption of [Bitcoin Cash](https://www.bitcoincash.org).

The site maintainers do not endorse nor confirm the legitimacy of the listings linked to on this site. This is an open source project which accepts submissions from the general community. While we try our best to verify the information submitted, it's possible that we may miss something.

## Contributing

If you'd like to contribute to the list, please read the entire guidelines here in
[CONTRIBUTING.md](CONTRIBUTING.md).

## Running Locally

acceptBitcoin.cash is built upon [Jekyll](https://jekyllrb.com/), using the [github-pages](https://github.com/github/pages-gem) gem.
In order to run the site locally, it is necessary to install bundler, install all dependencies, and then use Jekyll to serve
the site. If the `gem` command is not available to you, it is necessary to install Ruby with RubyGems.
Once Ruby and RubyGems are installed and available from the command line, acceptBitcoin.cash can be set up using the following commands.

```
gem install bundler
cd ~/acceptbitcoincash
bundle install
bundle exec jekyll serve
```

The acceptBitcoin.cash website should then be accessible from `http://localhost:4000`.

## Docker

acceptBitcoin.cash also includes a Docker image for easy deployment. You can build and run the Docker image using the following commands.

```
cd ~/acceptbitcoincash
gem install bundler
bundle install
bundle exec jekyll build
docker build -t acceptbitcoincash .
docker run -p 4000:80 acceptbitcoincash
```

If you are doing development, and want to launch a Jekyll server which can track your changes. Then you can use the following commands.

```
cd ~/acceptbitcoincash
docker run --rm --label=jekyll --volume=$(pwd):/srv/jekyll:z \
  -it -p 127.0.0.1:4000:4000 jekyll/jekyll:latest jekyll s
```

The acceptBitcoin.cash website should then be accessible from `http://localhost:4000`.

## License

This code is distributed under the MIT license. For more info, read the
[LICENSE](/LICENSE) file distributed with the source code.

[#478559](https://blockchair.com/bitcoin-cash/block/478559 "The Exodus block.")
