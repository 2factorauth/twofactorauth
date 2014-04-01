TwoFactorAuth.org [![Build Status](https://travis-ci.org/jdavis/twofactorauth.png?branch=master)](https://travis-ci.org/jdavis/twofactorauth)
=================

A list of popular sites and whether or not they accept two factor auth.

## The Goal

The goal is to have a website with a comprehensive list of sites that support
two factor auth as well as the methods that they support it.

This is to aid when deciding on alternative services based on the security they
offer for their customers.

This also is a way for consumers to see what sites still need to invest in
further security practices and which ones already do.

## Contributing

All the data is managed through a series of [Yaml][yaml] files so it may be useful to read
up on the Yaml syntax.

To add a new site, go to the [data files](_data/) and get familiar with
how it is setup. There is a section and coresponding file for each Category and they all follow this
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

First and foremost, make sure the new site meets our [definition requirements](#a-note-on-definitions) for Two Factor Auth.

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
          sms: No
          email: Yes
          phone: Yes
          software: Yes
          hardware: Yes
          doc: <link to site 2FA documentation>
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

### A Note on Definitions

A lot of people have different ideas of what constitutes Two Factor Auth and what doesn't, so it stands to reason that we should clarify a bit. For the purposes of this site, Two Factor Auth is defined as any service provided as a redundant layer for account *authentication*. Services that provide *authorization* redundancy are certainly appreciated, but should not be considered Two Factor Auth.

As an example, a site that prompts you for an authentication token following user login would be considered Two Factor Auth. A site that does not prompt you for a token upon login, but prompts you for a token when you try to perform a sensitive action would not be considered Two Factor Auth.

For context, check out the discussion in [#242](https://github.com/jdavis/twofactorauth/issues/242).

## License

This code is distributed under the MIT license. For more info, read the
[LICENSE](/LICENSE) file distributed with the source code.

[yaml]: http://www.yaml.org/
[travis]: https://travis-ci.org/jdavis/twofactorauth
