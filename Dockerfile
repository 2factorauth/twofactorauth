FROM ruby:2.7-alpine
WORKDIR /twofactorauth
COPY Gemfile .
COPY ./scripts/entrypoint.sh .
RUN apk add --no-cache build-base git bash dos2unix npm gnupg
RUN bundle config set path '/twofactorauth/vendor/cache'
RUN bundle install
RUN npm i -g babel-minify
RUN chmod +x entrypoint.sh
WORKDIR /twofactorauth/site
ENTRYPOINT ["/twofactorauth/entrypoint.sh"]
