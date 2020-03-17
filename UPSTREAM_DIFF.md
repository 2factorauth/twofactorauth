# Main Differences to twofactorauth

This list includes the main files diverting from 'upstream' twofactorauth.org.
If there are changes here, look carefully, if we can adapt these easily without
breaking dongleauth.info.

* \_config.yml
* \_data/providers.yml
* \_includes/desktop-table.html
* \_includes/header.html
* \_includes/mobile-table.html
* \_layouts/default.html
* \_layouts/secondary.html
* css/base.scss
* CNAME
* dongles.html
* img/nitrokey.png
* img/providers/\*
* img/usb_stick.png
* index.html
* providers.html
* websites.yml

# How to compare changes

It is recommended to use the program [meld](http://meldmerge.org/) and git's mergetool
to compare the dongleauth.info and twofactorauth.org step by step.

```
git clone https://github.com/Nitrokey/dongleauth.git
git remote add upstream https://github.com/2factorauth/twofactorauth.git
git fetch upstream
git merge upstream/master
git mergetool -t meld # use meld to compare, other tools possible
```

Be careful what to include. Especially changes in the files mentioned above should be inlcuded with
care.

We are able to use their changes directly, but unfortunately we can not push ours directly upstream.
Thus, every `otp`, `u2f`, `multipleu2f`, `passwordless` should be kept when comparing. Sites deleted
on twofactorauth.org may be deleted on dongleauth.info as well.
