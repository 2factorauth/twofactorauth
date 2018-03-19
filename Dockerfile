FROM jekyll/jekyll:latest

WORKDIR /tmp
ADD Gemfile /tmp/
RUN ls -lah / && whoami && bundle install

COPY . /jekyll
WORKDIR /jekyll

EXPOSE 4000
ENTRYPOINT ["jekyll", "serve", "--watch", "--incremental"]
