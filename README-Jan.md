Setup
=====
1) On Ubuntu, follow the instructions here under section "Using rvm":
https://gorails.com/setup/ubuntu/14.10
For non-Ubuntu systems you may follow: https://rvm.io/rvm/install

2) sudo apt-get install nodejs

Working
=======
1) git checkout device_authenticators
always work in device_authenticators branch (think of dev branch) or gh-pages branch (think of deployment branch).

2) Open _config.yml and change "uri: /dongleauth" -> "uri: "
This change is to show it locally only and shouldn't be committed.

3) bundle

4) jekyll serve

5) open: http://0.0.0.0:4000/

* Data to be changed is in _data/devices
* Images are in folder "img"
* You can manage categories in main.yml - remove, add...

Deployment:
===========
git checkout gh-pages
git merge device_authenticators
git push

Todo
====
* mailing: posteo
* incorporate https://www.saaspass.com/authenticator/justcoin-exchange-two-factor-authentication-two-step-verification.html
* gaming: ab humble bundle bis wild star noch nicht gemacht
* https://de.wikipedia.org/wiki/Google_Authenticator
* https://en.wikipedia.org/wiki/Google_Authenticator
