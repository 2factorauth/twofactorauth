---
name: 🔒 Add site with 2FA
about: Request that a site that supports 2FA be added.
title: Add [WebOké]
labels: add site
assignees: ''

---

<!-- Before submitting this issue, please update the title to include the name of the site to be added.
Submit a single issue for each site to be added.

In Markdown, checkboxes work like this:
- [ ] Unchecked box.
- [x] Checked box.

Check both boxes below before submitting your issue to verify that you have already checked for duplicate issues and pull requests relating to your request. -->

- [x] I have searched both open and closed [issues](https://github.com/2factorauth/twofactorauth/issues). The issue I'm creating is not a duplicate of an existing issue.
- [x] I have searched both open and closed [pull requests](https://github.com/2factorauth/twofactorauth/pulls). The issue I'm creating is not a duplicate of an existing pull request.

### Information about the site to be added that supports 2FA: ###
<!-- Official name of the site -->
* Site name - `WebOké`

<!-- Link to the main page -->
* Site URL - `https://www.weboke.nl`

* Does the site support 2FA? - `Yes`

<!-- Link to documentation on how to enable 2FA on the site.
Attach screenshots of the setup/login process if no public-facing documentation link is available, redacting any personal information. -->
* Documentation URL - `https://www.weboke.nl/knowledgebase/127/Hoe-schakel-ik-tweestapsverificatie-in.html`

### Information about what methods of 2FA the site supports: ###
<!-- Mark each implementation of 2FA that the site supports.
See our [wiki](https://github.com/2factorauth/twofactorauth/wiki/FAQ-2FA-Types) for more information about different types of 2FA implementations. -->

* Software:
  - [x] TOTP (RFC-6238, Google Authenticator)
  - [x] Proprietary (Authy, Duo, etc.)

* Hardware:
  - [x] FIDO2/U2F security keys
  - [] Other

- [ ] Phone calls
- [ ] SMS tokens
- [ ] Email tokens

### Information about the site's eligibility to be added to 2fa.directory: ###
<!-- Check each box below to verify that the site meets our requirements for being listed.
If a site does not meet all of these requirements, feel free to continue your issue submission.
Leave any unmet requirements unchecked, and add any additional information or questions in the "Additional information" section below. -->

- [x] I have checked that the site meets 2fa.directory's [contributing guidelines and site criteria](https://github.com/2factorauth/twofactorauth/blob/master/CONTRIBUTING.md).
- [] The site is ranked within the top 200,000 sites on [Alexa](https://www.alexa.com/siteinfo/) or has a substantial social media following.
- [x] The site does not contain or promote content that violates 2fa.directory's [excluded categories and websites guidelines](https://github.com/2factorauth/twofactorauth/blob/master/EXCLUSION.md), including pornographic, discriminatory, or unlawful content.

### Additional information: ###
<!-- If you have any additional information to provide, please do so below. -->
WebOké is a webhosting company from the Netherlands which takes security extremely serious. We are in the Hosting Hall-Of-Fame of a program funded by the Dutch government to make the internet more secure. I am confident that we make a good fit for this website.
