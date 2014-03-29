TwoFactorAuth.org [![Build Status](https://travis-ci.org/jdavis/twofactorauth.png?branch=master)](https://travis-ci.org/jdavis/twofactorauth)
=================

A list of popular sites and whether or not they accept two factor auth.

## The Goal

The goal is to have a website with a comprehensive list of sites that support
two factor auth, as well as the methods that they support it.

This is to aid when deciding on alternative services based on the security they
offer for their customers.

This also is a way for consumers to see what sites still need to invest in
further security practices and which ones already do.

## Contributing

All the data is managed through a series of [Yaml][yaml] files so it may be useful to read
up on the Yaml syntax.

To add a new site, go to the [data files](_data/) and get familiar with
how it is set up. There is a section and corresponding file for each Category and they all follow this
syntax:

### Guidelines

1. **Don't break the build**: We have a simple continuous integration system
   setup with [Travis][travis]. If your pull request doesn't pass, it won't be
   merged.

   To manually test the build, just run the following:

    ```bash
    $ ruby verify.rb
    ```

2. **Use a Nice Icon**: The icon must be 32x32 in dimension. Earlier we were
   using 16x16 but upgraded for various high density screens.
3. **Be Awesome**: You need to be awesome. That is all.

### New Sections

To add a new section, modify the `sections` value in [main.yml](_data/main.yml) and follow the template below:

```yml
sections:
  - id: category-id
    title: Category Name
    icon: icon-class
```

Then create a new file in the `_data` directory named the same as your section's id with the `.yml` extension.

### New Sites

The values should be pretty straightforward for adding a new website. The
`websites` array should already be defined, just add a new website to it like
this example:

```yml
    websites:
        - name: Site
          url: https://site.com
          img: site.png
          twitter: twitter_handle   # To tweet at site, if tfa is No
          tfa: Yes
          goog: Yes
          authy: Yes
          verisign: Yes
          sms: Yes
          doc: <url to the documentation>
          custom:
              - icon: android
                url: <url to a custom Android client>
              - icon: apple
                url: <url to a custom iOS client>
              # Any other custom clients...
```

If a site does not have 2FA but there is documentation that they are adding it, then use

```yml
tfa: no
status: <url to documentation>
```

~~Note: A tip on getting icons, use Google's icon api. Just go to
`https://www.google.com/s2/favicons?domain=http://example.com`
and you will get sites the icon as png.~~

We are now looking for higher resolution images than offered by Google's favicon service.

### Custom

The `custom` section is for an app or site that doesn't use SMS, Google Auth, or Authy. This app should have its own way of generating 2FA from within the app or a special 2FA service such as via `email`, `yubikey`, etc.

## License

This code is distributed under the MIT license. For more info, read the
[LICENSE](/LICENSE) file distributed with the source code.

[yaml]: http://www.yaml.org/
[travis]: https://travis-ci.org/jdavis/twofactorauth
