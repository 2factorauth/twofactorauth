Contributing to TFA.org
=======================

All the data is managed through a series of [Yaml][yaml] files so it may be
useful to read up on the Yaml syntax.

To add a new site, go to the [data files](_data/) and get familiar with how it
is setup. There is a section and coresponding file for each Category. Site icons
are stored in folders corresponding to each of those categories in their own 
[folder](img/).

## Guidelines

1. **Don't break the build**: We have a simple continuous integration system
   setup with [Travis][travis]. If your pull request doesn't pass, it won't be
   merged. Travis will only check your changes after you submit a pull request.
   If you want to test locally, instructions are listed below. Keep reading!
2. **Use a Nice Icon**: The icon must have a resolution of 32x32. PNG is the
   preffered format. If possible, please also run the image through an optimizing 
   utility such as OptiPNG before committing it to the repo.
3. **Be Awesome**: You need to be awesome. That is all.

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

## Site Criteria

The following is a rough criteria and explanations for what sites should be on
TFA.org. If one of the following Criteria is met, it belongs on TFA.org:

1. **Personal Info/Image**: Any site that deals with personal info or a person's
   image. An example of a site with **Personal Info** would be their Amazon
   account and a site regarding **Personal Image** would be one like Twitter.
2. **Data**: This means data that is either important or sensitive. It also is
   any data relating to Criteria 1.
3. **Money**: Any site that deals with money.
4. **Control**: This is a more general Criteria that includes sites that give
   access to things that might infringe upon Criteria 1, 2, and 3. An example of
   this is a site that allows remote access.

If you have any questions regarding whether or not a site matches one of the
Criteria, just open an Issue and we'll take a look.

### Excluded Sites

A list for excluded sites has also been created to ensure sites that have been
removed don't get re-added. The list also contains the reason for its removal.

View the complete list in the [EXCLUSION.md file][exclude].

## New Sections

To add a new section, modify the `sections` value in [main.yml](_data/main.yml)
and follow the template below:

```yml
sections:
  - id: category-id
    title: Category Name
    icon: icon-class
```

Then create a new file in the `_data` directory named the same as your section's
id with the `.yml` extension.

## New Sites

First and foremost, make sure the new site meets our [definition
requirements](#a-note-on-definitions) for Two Factor Auth.

The values should be pretty straight forward for adding a new website. The
`websites` array should already be defined, just add a new website to it like
this example:

```yml
websites:
  - name: Site Name
    url: https://www.site.com/
    twitter: SiteTwitter
    img: site.png
    tfa: Yes
    sms: Yes
    email: Yes
    phone: Yes
    software: Yes
    hardware: Yes
    doc: <link to site TFA documentation>
```
Fields `name:`, `url:`, `img:`, `tfa:` are required for all entries. If a site 
does not provide TFA, `twitter:` should be included if they have one. If a site 
does provide TFA, `doc:` field is strongly encouraged where public documentation 
is available. Other fields should be included if the site supports it. Any services 
that are not supported can be excluded.

If you are adding multiple sites, please add each site to its own new branch and 
submit a separate pull request for each branch.

### Exceptions & Restrictions

If a site doesn't support TFA in certain countries, you can note this on the
website. There are 4 ways to customize how it is displayed:

1. A default message acknowledging restrictions will be used with the following
   config:

   ```yml
    - name: Site Name
      url: https://www.site.com/
      twitter: SiteTwitter
      img: site.png
      tfa: Yes
      sms: Yes
      exceptions: Yes
      doc: <link to site TFA documentation>
   ```
2. The message can be replaced with a custom set of words:

   ```yml
    - name: Site Name
      url: https://www.site.com/
      twitter: SiteTwitter
      img: site.png
      tfa: Yes
      sms: Yes
      exceptions:
          text: "Specific text goes here."
      doc: <link to site TFA documentation>
   ```
3. The icon can be made into a link in which more details can be revealed such
   as country specific info and anything else.

   ```yml
    - name: Site Name
      url: https://www.site.com/
      twitter: SiteTwitter
      img: site.png
      tfa: Yes
      sms: Yes
      exceptions:
          link: Yes
      doc: <link to site TFA documentation>
   ```
4. 2 and 3 can be combined into:

   ```yml
    - name: Site Name
      url: https://www.site.com/
      twitter: SiteTwitter
      img: site.png
      tfa: Yes
      sms: Yes
      exceptions:
          link: Yes
          text: "Specific text can go here as well."
      doc: <link to site TFA documentation>
   ```

### Pro Tips

- See Guideline #2 about icons. The png file should go in the corresponding
  `img/section` folder.

- For the sake of organization and readability, it is appreciated if you insert
  new sites alphabetically and that your site chunk follows the same order as the
  example above.

- If a site supports TFA, their Twitter handle is not needed and can be left out
  for cleanliness.

- If a site does not have TFA but there is documentation that they are adding
  it, then use:

  ```yml
  tfa: No
  status: <url to documentation>
  ```

## A Note on Definitions

A lot of people have different ideas of what constitutes Two Factor Auth and
what doesn't, so it stands to reason that we should clarify a bit. For the
purposes of this site, Two Factor Auth is defined as any service provided as a
redundant layer for account *authentication*. Services that provide
*authorization* redundancy are certainly appreciated, but should not be
considered Two Factor Auth.

As an example, a site that prompts you for an authentication token following
user login would be considered Two Factor Auth. A site that does not prompt you
for a token upon login, but prompts you for a token when you try to perform a
  sensitive action would not be considered Two Factor Auth.

For context, check out the discussion in [#242][242].

### New Providers

Rather than split out providers on the main page, we elected to keep the main
page clean and add another page dedicated to TFA providers.

To add a new provider simply add to the `providers.yml` file, marking `Yes`
where appropriate.

```yml
  - name: Company Name
    url: https://example.com
    img: company.png
    sms: Yes
    email: Yes
    phone: Yes
    software: Yes
    hardware: Yes
```

[242]: https://github.com/jdavis/twofactorauth/issues/242
[exclude]: /EXCLUSION.md
[bundler]: http://bundler.io/
[gemfile]: /Gemfile
[jekyll]: http://jekyllrb.com/
[travis]: https://travis-ci.org/jdavis/twofactorauth
[yaml]: http://www.yaml.org/
