# Contributing to 2fa.directory

All the data is managed through a series of [JSON][json] files so it may be
useful to read up on the JSON syntax.

To add a new site, go to the [data files][entries] and get familiar with how it
is set up. There is one file per entry named after the domain, located in the
subdirectory starting with the first letter of the domain. Site icons
are stored in folders corresponding to each of those entries in their own
[folder][img].

## Guidelines

1. **Don't break the build**: We have a simple continuous integration system
   setup with Github Actions. If your pull request doesn't pass, it won't be
   merged. GH Actions will only check your changes after you submit a pull request.
   If you want to test locally, instructions are listed below. Keep reading!
2. **Use a Nice Icon**: SVG is the preferred format. If possible, please also run the image 
   through an optimizing utility such as [svgo][svgo] to reduce the file size.
   If an SVG icon is not available, the icon should be a PNG with a resolution of 32x32.
   If possible, please also run the image through an optimizing
   utility such as [TinyPNG][tinypng] before committing it to the repo and keep
   the file to be under 2.5 kB.
3. **HTTPS links**: All sites that support HTTPS should also be linked with an
   HTTPS address.
4. **Alexa top 200K**: A new site that is not already listed has to be within the
   Alexa top 200,000 ranking. You can check the ranking of a site [here][alexa].
5. **No 2FA providers**: We do not list 2FA providers, such as [Authy][authy], [Duo][duo] or
   [Google Authenticator][googleauthenticator].
6. **Be Awesome**: You need to be awesome. That is all.

## Running Locally

It's easy to run everything locally to test it out. Either you can have plain
[Jekyll][jekyll] installed or you can use [Bundler][bundler] to manage
everything for you.

### Using Bundler

1. To install Bundler, just run `gem install bundler`.
2. Install dependencies in the [Gemfile][gemfile], `bundle install`.
3. Run Jekyll: `bundle exec jekyll serve --watch`. The `--watch` is optional and
   makes Jekyll watch for file changes.

#### Testing with Bundler

There are a number of tests that are run automatically for a GitHub pull request.
They are listed in `.github/workflows/repository.yml` in the `tests:` block.
You can run these manually as well, e.g to test your JSON changes:

```bash
$ bundle exec ruby ./tests/validate-json.rb
```

### Using Vanilla Jekyll

1. Install Jekyll if you don't already have it: `gem install jekyll`.
2. Run Jekyll: `jekyll serve --watch`. The `--watch` is again optional.

## Site Criteria

The following section contains rough criteria and explanations regarding
what websites should be listed on 2fa.directory. If one of the following
criteria is met, it belongs on 2fa.directory:

1. **Personal Info/Image**: Any site that deals with personal info or a person's
   image. An example of a site with **Personal Info** would be their Amazon
   account and a site regarding **Personal Image** would be one like Twitter.
2. **Data**: This criteria relates to data that is either important or sensitive.
   Websites detailed in criteria 1 also fit this criteria.
3. **Money**: Any site that deals with money.
4. **Control**: This criteria is more general, in that it includes sites that
   give access to things that may infringe upon criteria 1, 2, or 3. An example
   of this is a website that allows remote access to a device.

If you have any questions regarding whether or not a site matches one of the
criteria, simply open an issue and we'll take a look.

### Excluded Sites

A list for excluded sites has also been created to ensure sites that have been
removed are not added in the future. The list also contains the reason for
its removal.

View the complete list in the [EXCLUSION.md file][exclude].

## New Categories

To add a new category, modify the [categories file][categories] and follow the
template below:

```JSON
  {
    "name" : "category-id",
    "title": "Category Title",
    "icon": "icon-class"
  },
```

The `icon-class` value needs to be chosen from [Font Awesome][font-awesome].

Then you can use the `category-id` as a keyword in the JSON file of your entry.

## New Sites

First and foremost, make sure the new site meets our [definition
requirements][definitions] of Two Factor Auth.

If you are adding multiple sites to the TwoFactorAuth list, please create a new
git branch for each website, and submit a separate pull request for each branch.
More information regarding how to create new git branches can be found on
[GitHub's Help Page][github-tutorial]
or [DigitalOcean's Tutorial][do-tutorial].

Adding a new website should be pretty straight-forward. Create a JSON file in
the corresponding [subdirectory][entries] as shown in the following example:

```JSON
{
  "Site Name": {
    "domain": "site.com",
    "url": "https://www.site.com",
    "img": "site.com.png",
    "tfa": [
      "sms",
      "call",
      "email",
      "totp",
      "u2f",
      "custom-software",
      "custom-hardware"
    ],
    "documentation": "<link to site TFA documentation>",
    "keywords": [
      "keyword1",
      "keyword2"
    ]
  }
}
```

The `url` field is optional if the value is `https://` followed by the `domain`.
The default value for the icon is `<domain>.svg`, but can be overridden by an `img`
field.

#### Adding a site that _supports_ TFA

If a site does provide TFA, it is strongly recommended that you add the `doc`
field where public documentation is available. Other fields should be included
if the website supports them. Any services that are not supported can be excluded.
Sites supporting TFA must not have a `contact` property.

The following is an example of a website that _supports_ TFA:

```JSON
{
  "YouTube": {
    "domain": "youtube.com",
    "tfa": [
      "sms",
      "call",
      "totp",
      "custom-software",
      "u2f"
    ],
    "documentation": "https://www.google.com/intl/en-US/landing/2step/features.html",
    "keywords": [
      "entertainment"
    ]
  }
}
```

#### Adding a site that _does not_ support TFA

If a site does not provide TFA, the `twitter` field should be included if the site uses
Twitter. Facebook can also be included using the `facebook` field, as well as Email using
the `email_address` field. If the website does not use the English language, the `lang`
field should also be included. The fields `tfa` and `doc` can be completely removed.

The following is an example of a website that _does not_ support TFA:

```JSON
{
  "Netflix": {
    "domain": "netflix.com",
    "url": "https://www.netflix.com/us/",
    "contact": {
      "facebook": "netflix",
      "twitter": "Netflixhelps"
    },
    "keywords": [
      "entertainment"
    ]
  }
}
```

The `language` field inside `contact` can be included for non-English websites. The language
codes should be lowercase [ISO 639-1][iso-lang-wikipedia] codes.

### Exceptions & Restrictions

If a site requires the user to do something out of the ordinary to set up 2FA or if 2FA is
only available in specific countries, you can note this on the website.

```JSON
{
  "Site Name": {
    "domain": "site.com",
    "tfa": [
      "totp"
    ],
    "documentation": "<link to site TFA documentation>",
    "notes": "Specific text goes here.",
    "keywords": [
      "keyword"
    ]
  }
}
```

### Adding a site that is only available in specific regions

If a site (with or without 2FA) is only available in certain countries - for example a
government site - you can note this with the `regions` field.

```JSON
{
  "Site Name": {
    "domain": "site.com",
    "tfa": [
      "totp"
    ],
    "documentation": "<link to site TFA documentation>",
    "keywords": [
      "keyword"
    ],
    "regions": [
      "us",
      "ca"
    ]
  }
}
```

The country codes should be lowercase [ISO 3166-1][iso-country-wikipedia] codes.

### Other Properties

- `additional-domains`
  If a site exists at another domain in addition to the main domain that is listed in the
  `domain` field, you can mark this with the `additional-domains` property.

```JSON
{
  "Site Name": {
    "domain": "site.com",
    "additional-domains": [
      "site.net",
      "site.io"
    ],
    "tfa": [
      "totp"
    ],
    "documentation": "<link to site TFA documentation>",
    "keywords": [
      "keyword"
    ]
  }
}
```

- `recovery`
  The recovery field can be used to link to acccount recovery documentation about what to do
  if you lose access to your 2FA method.

```JSON
{
  "Site Name": {
    "domain": "site.com",
    "tfa": [
      "totp"
    ],
    "documentation": "<link to site TFA documentation>",
    "recovery": "<link to site TFA recovery documentation>",
    "keywords": [
      "keyword"
    ]
  }
}
```
- `custom-software`/`custom-hardware`
  If a site uses a proprietary software or hardware method, you can add specific details of what
  is being used. Examples would be Authy or non-U2F security keys.

```JSON
{
  "Site Name": {
    "domain": "site.com",
    "tfa": [
      "custom-software",
      "custom-hardware"
    ],
    "custom-software": [
      "Authy"
    ],
    "custom-hardware": [
      "Yubico OTP"
    ],
    "documentation": "<link to site TFA documentation>",
    "keywords": [
      "keyword"
    ]
  }
}
```

### Pro Tips

- See Guideline #2 about icons. The SVG file should go in the corresponding
  `img/` folder.

- For the sake of organization and readability, it is appreciated if your site chunk
  follows the same order as the example above.

- If a site supports TFA, their contact information is not needed and can be left out
  for cleanliness.

## A Note on Definitions

A lot of people have different ideas of what constitutes Two Factor Auth and
what doesn't, so it stands to reason that we should clarify a bit. For the
purposes of this site, Two Factor Auth is defined as any service provided as a
redundant layer for account _authentication_. Services that provide
_authorization_ redundancy are certainly appreciated, but should not be
considered Two Factor Auth.

As an example, a site that prompts you for an authentication token following
user login would be considered Two Factor Auth. A site that does not prompt you
for a token upon login, but prompts you for a token when you try to perform a
sensitive action would not be considered Two Factor Authentication.

For context, check out the discussion in issue [#242][242].

[json]: https://www.json.org/
[entries]: entries/
[img]: img/
[svgo]: https://github.com/svg/svgo
[tinypng]: https://tinypng.com/
[alexa]: https://www.alexa.com/siteinfo
[authy]: https://authy.com/
[duo]: https://duo.com/
[googleauthenticator]: https://github.com/google/google-authenticator
[jekyll]: https://jekyllrb.com/
[bundler]: https://bundler.io/
[gemfile]: /Gemfile
[exclude]: /EXCLUSION.md
[categories]: _data/categories.json
[font-awesome]: https://fontawesome.com/icons?d=gallery&p=2&m=free
[definitions]: #a-note-on-definitions
[github-tutorial]: https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/
[do-tutorial]: https://www.digitalocean.com/community/tutorials/how-to-use-git-branches
[iso-lang-wikipedia]: https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
[iso-country-wikipedia]: https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes
[242]: https://github.com/2factorauth/twofactorauth/issues/242
