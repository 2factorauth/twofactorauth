FROM ruby:2.3.5

COPY . /acceptbitcoin
WORKDIR /acceptbitcoin

RUN bundle install

EXPOSE 4000

CMD [ "jekyll", "serve", "-H", "0.0.0.0"]
