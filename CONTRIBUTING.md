Contributing to acceptBitcoin.Cash
=======================

## Introduction

First off, **thanks for your interest in contributing!** Your help will foster growth for the benefit of Bitcoin Cash, and the community overall. More are always welcomed.

### _A quick note..._

The site maintainers do not endorse nor confirm the legitimacy of any of the merchants linked to on this site. While we try our best to verify the merchant information submitted, it's possible that we may miss something, or a service may change/information becomes outdated. If you notice anything, please [raise a new issue](https://github.com/acceptbitcoincash/acceptbitcoincash/issues/new).

Adding a site is easy. Read below for the basics, and if you're more technically-inclined, detailed instructions are further down this document. Regardless, the only thing **you need** is **a Github account**.

## Submitting a site _the easy way_

[Open a new issue](https://github.com/acceptbitcoincash/acceptbitcoincash/issues/new) and fill out the template that's provided as a placeholder.
Try to fill out all of the fields as accurately as possible. They are:

- Name | `name`
- URL (http*s* preferred) | `url`
- Twitter Username (no @ symbol) | `twitter`
- Facebook Username or Page URL | `facebook`
- Logo Image (URL to PNG/JPG) | `img`
- Accepting Bitcoin Cash | `bch`
- Accepting Bitcoin Legacy | `btc`
- Accepting Other Crypto | `other`
- Documentation/Help Guides (URL) | `doc`
- _(Optional)_ Exceptions/General Notes | `exceptions/text`

Press the shiny `Submit new issue` button and you'll be notified when changes to your submission occur.

## Submitting a site _the developer/advanced way_

All the data is managed through a series of [YAML](http://yaml.org) files so it may be
useful to read up on the YAML syntax.

To add a new site, go to the [data files](_data/) and get familiar with how it
is setup. There is a section and corresponding file for each Category. Site icons
are stored in folders corresponding to each of those categories in their own
[folder](img/).

## Guidelines

1. **Don't break the build**: We have a simple continuous integration system
   setup with [Travis][travis]. If your pull request doesn't pass, it won't be
   merged. Travis will only check your changes after you submit a pull request.
   If you want to test locally, instructions are listed below. Keep reading!
2. **Use a Nice Icon**: The icon must have a resolution of 32x32. PNG is the
   preferred format.
3. **Be Awesome**: You need to be awesome, but you've read this far, so you probably are. That is all.

## Running Locally

It's easy to run everything locally to test it out. Either you can have plain
[Jekyll](http://jekyllrb.com/) installed or you can use [Bundler](http://bundler.io/) to manage
everything for you.

### Using Bundler

1. To install Bundler, just run `gem install bundler`.
2. Install dependencies in the [Gemfile](https://github.com/acceptbitcoincash/acceptbitcoincash/blob/master/Gemfile), `bundle install`.
3. Run Jekyll: `bundle exec jekyll serve --watch`. The `--watch` is optional and
   makes Jekyll watch for file changes.

#### Testing with Bundler
   To verify that your additions are fine, you can run the entire set of tests
   locally which will check all links and images with:

   ```bash
   $ bundle exec rake
   ```

   However, this can take a while as there are roughly 900 links that it checks.
   If you just wish to test your YAML changes, you can run:

   ```bash
   $ bundle exec rake verify
   ```

### Using Vanilla Jekyll

1. Install Jekyll if you don't already have it: `gem install jekyll`.
2. Run Jekyll: `jekyll serve --watch`. The `--watch` is again optional.

### Excluded Sites

A list for excluded sites has also been created to ensure sites that have been
removed are not added in the future. The list also contains the reason for
its removal.

View the complete list in the [EXCLUSION.md file][exclude].

## New Categories

To add a new category, modify the `sections` value in [sections.yml](_data/sections.yml)
and follow the template below:

```yml
- id: category-id
  title: Category Name
  icon: icon-class
```

Then create a new file in the `_data` directory with the same name as your section's
id, using the `.yml` extension.

## New Sites

If you are adding multiple sites to the AcceptBitcoinCash list, please create a new
git branch for each website, and submit a separate pull request for each branch.
More information regarding how to create new git branches can be found on
[GitHub's Help Page](https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/)
or [DigitalOcean's Tutorial](https://www.digitalocean.com/community/tutorials/how-to-use-git-branches).

Adding a new website should be pretty straight-forward. The `websites` array should
already be defined; simply add a new website to it as shown in the following example:

```yml
websites:
  - name: Site Name
    url: https://www.site.com/
    img: site.png
    bch: Yes
    btc: Yes
    othercrypto: Yes
    doc: <link to site BCH documentation>
```

The fields `name:`, `url:`, `img:`, `bch:` are required for all entries.
If the site supports Bitcoin (Legacy) or other cryptocurrencies, `btc` and `othercrypto` should be
entered as well.

#### Adding a site that *supports* BCH

If a site does accept BCH, it is strongly recommended that you add the `doc:`
field where public documentation is available. Other fields should be included
if the website supports them. Any services that are not supported can be excluded.
Sites supporting BCH should not have a Twitter, Facebook or Email field.

The following is an example of a website that *supports* BCH:

```yml
    - name: Rocketr
      url: https://rocketr.net/
      img: rocketr.png
      bch: Yes
      btc: No
      othercrypto: Yes
      doc: https://rocketr.net/blog/2017/07/30/bitcoin-cash-coming-rocketr/
```

#### Adding a site that *does not* support BCH

If a site does not accept BCH, the `twitter:` field should be included if the site uses
Twitter. Facebook can also be included using the `facebook` field, as well as Email using
the `email_address` field. If the website does not use the English language, the `lang:`
field should also be included. The fields `btc:` and `othercrypto:` can be completely removed
but should be added if they accept BTC or any other cryptocurrency respectively.

The following is an example of a website that *does not* support BCH:

```yml
    - name: Netflix
      url: https://www.netflix.com/us/
      twitter: Netflixhelps
      facebook: netflix
      email_address: example@netflix.com (Only if available and monitored)
      img: netflix.png
      bch: No
      btc: No
      othercrypto: yes
      lang: <ISO 639-1 language code> (Only for non-English websites)
```

The `lang:` field is only used for non-English websites. The language codes should be lowercase [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) codes.

### Exceptions & Restrictions

If a site doesn't support BCH in certain countries, you can note this on the
website. There are 4 ways to customize how it is displayed:

1. A default message acknowledging restrictions will be used with the following
   config:

   ```yml
    - name: Site Name
      url: https://www.site.com/
      img: site.png
      bch: Yes
      btc: No
      exceptions: Yes
      doc: <link to site BCH documentation>
   ```
2. The message can be replaced with a custom set of words:

   ```yml
    - name: Site Name
      url: https://www.site.com/
      img: site.png
      bch: Yes
      btc: No
      exceptions:
          text: "Specific text goes here."
      doc: <link to site BCH documentation>
   ```
3. The icon can be made into a link in which more details can be revealed such
   as country specific info and anything else.

   ```yml
    - name: Site Name
      url: https://www.site.com/
      img: site.png
      bch: Yes
      btc: No
      exceptions:
          link: Yes
      doc: <link to site BCH documentation>
   ```
4. 2 and 3 can be combined into:

   ```yml
    - name: Site Name
      url: https://www.site.com/
      img: site.png
      bch: Yes
      btc: No
      exceptions:
          link: Yes
          text: "Specific text can go here as well."
      doc: <link to site BCH documentation>
   ```

### Pro Tips

- You can use a <a href="https://codebeautify.org/yaml-validator" target="_blank">YAML validator</a>
  to ensure that you've used the correct syntax.

- See Guideline #2 about icons. The png file should go in the corresponding
  `img/section` folder.

- For the sake of organization and readability, it is appreciated if you insert
  new sites alphabetically and that your site chunk follows the same order as the
  example above.

- If a site supports BCH, their Twitter and Facebook handles as well as their email address
  are not needed and can be left out for cleanliness.

- If a site does not have BCH but there is documentation that they are adding
  it, then use:

  ```yml
  bch: No
  status: <url to documentation>
  ```
