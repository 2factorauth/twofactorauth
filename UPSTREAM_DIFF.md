# Main Differences to twofactorauth

This list includes the main files diverting from 'upstream' twofactorauth.org. If there are changes here, look carefully, if we can adapt these easily without breaking dongleauth.info.

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

It is recommended to use the program [meld](http://meldmerge.org/) and compare the `_data` folder of dongleauth.info and twofactorauth.org accordingly.

```
git clone https://github.com/Nitrokey/dongleauth.git
git clone https://github.com/2factorauth/twofactorauth.git
```

Start 'meld' and choose folder comparing. Have a look, what needs to get merged, save and commit accordingly.

We are able to use their changes directly, but unfortunately we can not push ours directly upstream.
