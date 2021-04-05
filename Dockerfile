FROM ruby:2.7-alpine
WORKDIR /twofactorauth
COPY Gemfile .
COPY _deployment/entrypoint.sh .
RUN apk add --no-cache npm libwebp-tools build-base git bash dos2unix
RUN bundle install
RUN npm i -g babel-minify
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "./_deployment/entrypoint.sh" ]
