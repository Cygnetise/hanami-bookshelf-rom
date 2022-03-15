FROM arm64v8/ruby:2.7.5-alpine

WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock ./

RUN apk add --update --no-cache \
    build-base gcompat \
    postgresql-dev postgresql-client
RUN apk add --update --virtual build-dependencies

RUN gem update --system && gem install bundler dotenv && \
  bundle install

COPY . ./

EXPOSE 80
ENTRYPOINT ["/bin/sh", "-c"]
