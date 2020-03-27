Contributing to acceptBitcoin.Cash
=======================

## Introduction

First off, **thanks for your interest in contributing!** Your help will foster growth for the benefit of Bitcoin Cash and the community overall. More are always welcomed.

### _A quick note..._

The site maintainers do not endorse nor confirm the legitimacy of the listings linked to on this site. While we try our best to verify the information submitted, it's possible that we may miss something, or a service may change/information becomes outdated. If you notice anything, please [raise a new issue](https://github.com/acceptbitcoincash/acceptbitcoincash/issues/new).

Adding a site is easy. Read below for the basics, and if you're more technically-inclined, detailed instructions are further down this document. Regardless, the only thing **you need** is **a Github account**.

## Submitting a site _the easy way_

We offer two easy ways to submit a new site to be listed.
1. Use the [Merchant/Website Addition Request](https://AcceptBitcoin.Cash/add) form to the best of your ability.
2. [Open a new issue](https://github.com/acceptbitcoincash/acceptbitcoincash/issues/new) and fill out the template that's provided as a placeholder. Try to fill out all of the fields as accurately as possible. We are looking for the following:

- `name` -- Name of merchant/site
- `url` -- URL of merchant/site (http*s* preferred)
- `img` -- Logo Image (URL to PNG/JPG, ideally a square/circle, 32x32px)
- `twitter` -- Twitter Username (no @ symbol)
- `facebook` -- Facebook Username or Page URL
- `region` -- Region (see region code list below)
- `country` -- Country (see Wikipedia link below)
- _(Optional)_ `state` -- State (capitalize name, use full name)
- _(Optional)_ `city` -- City (capitalize name)
- `bch` -- Accepting Bitcoin Cash (yes/no)
- `btc` -- Accepting Bitcoin Legacy (yes/no)
- `othercrypto` -- Accepting Other Crypto (yes/no)
- `doc` -- Documentation/Help Guides (URL)
- _(Optional)_ `exceptions/text` Exceptions/General Notes
- _(Optional)_ `lang` -- Language if not `en` (see Wikipedia link below)
- _(Optional)_ `keywords/-` -- words that can be useful for users that are trying to search for something that relates to this listing.

For 2-letter _country_ codes, use [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements) codes.

For 2-letter _language_ codes, use [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) codes.

For 2-letter _region_ codes, use:

Code | Name
-- | --
af | Africa
na | North America
oc | Oceania
an | Antarctica
as | Asia
eu | Europe
sa | South America


Press the shiny `Submit new issue` button and you'll be notified when changes to your submission occur.

## Submitting a site _the developer/advanced way_

All the data is managed through a series of [YAML](http://yaml.org) files so it may be
useful to read up on the YAML syntax.

To add a new site, go to the [data files](_data/) and get familiar with how it
is set up. There is a section and corresponding file for each Category. Site icons
are stored in folders corresponding to each of those categories in their own
[folder](img/), and must be a 32x32 PNG (alpha optional) or JPG image.

## Guidelines

1. **Don't break the build**: If your pull request causes the Jekyll build to fail, it won't be
   merged. If you want to test locally, instructions are listed below. Keep reading!
2. **Use a Nice Icon**: The icon must have a resolution of 32x32. PNG is the
   preferred format, and remember to choose something that's legible at such a small size.
3. **Be Awesome**: You need to be awesome, but you've read this far, so you probably are. That is all.

## Running Locally

It's easy to run everything locally to test it out. Ensure you have [Ruby on Rails](http://guides.rubyonrails.org/getting_started.html) installed. You can then use either plain
[Jekyll](http://jekyllrb.com/) or [Bundler](http://bundler.io/) to manage
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

When adding a new category, you will need to select an icon from the [SemanticUI Icon set](https://semantic-ui.com/elements/icon.html). Once you have identified the icon to use, you can use any of the following means to add a new category:

### 1) To add a new category, modify the `sections` value in [sections.yml](_data/sections.yml)
and follow the template below:

```yml
- id: category-id
  title: Category Name
  icon: icon-class
  page: page the category shall belong to
```

Then create a new file in the `_data` directory with the same name as your section's
id, using the `.yml` extension.

### 2) Follow the following steps:
1) From the command line, run:
   ```bash
   $ bundle exec rake add:category
   ```
2) Answer ALL the questions it asks

When you are finished, it will add in the new category to the [sections.yml](_data/sections.yml) file and create a new file in the following format: `[<section id>].yml` in the `_data` folder for you to add listings to.

## New Sites

If you are adding multiple sites to the [AcceptBitcoin.Cash](https://AcceptBitcoin.Cash) list, please create a new
git branch for each website, and submit a separate pull request for each branch.
More information regarding how to create new git branches can be found on
[GitHub's Help Page](https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/)
or [DigitalOcean's Tutorial](https://www.digitalocean.com/community/tutorials/how-to-use-git-branches).

Adding a new website should be pretty straight-forward. The `websites` array should
already be defined; simply add a new website to it as shown in the following example:

```yml
websites:
  - name: Site that doesn't accept BCH (yet)
    url: https://example.site
    img: logo.png
    twitter: twitter_username
    facebook: fb_username
    bch: no
    btc: yes
    othercrypto: no
```

The fields `name:`, `url:`, `bch:` are required for all entries.
If the site supports Bitcoin (Legacy) or other cryptocurrencies, `btc` and `othercrypto` should be entered as well.

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
      keywords:
        - shops
        - payments
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
      region: na
      bch: No
      btc: No
      othercrypto: yes
```

### Exceptions & Restrictions

If a site has an exception or important detail regarding BCH, you can note this on the
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

### Pro Tips

- You can use a <a href="https://codebeautify.org/yaml-validator" target="_blank">YAML validator</a> to ensure that you've used the correct syntax.

- To validate a submission before committing the change you can run the following script to verify your work is done properly:

   ```bash
   $ bundle exec rake verify
   ```

- See Guideline #2 about icons. The png file should go in the corresponding `img/section` folder.

- For the sake of organization and readability, it is appreciated if you insert new sites alphabetically and that your site chunk follows the same order as the example above.

- If a site supports BCH, their Twitter and Facebook handles as well as their email address are not needed and can be left out for cleanliness.

- If a site does not yet support BCH but there is documentation that they are adding it, then use:

  ```yml
  status: <url to documentation>
  ```