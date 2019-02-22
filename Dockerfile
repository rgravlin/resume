FROM alpine

ENV BUILD_PACKAGES bash curl-dev ruby-dev build-base
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler

RUN apk update && \
    apk upgrade && \
    apk add $BUILD_PACKAGES && \
    apk add $RUBY_PACKAGES && \
    rm -rf /var/cache/apk/*

RUN mkdir /usr/app
WORKDIR /usr/app

COPY . /usr/app/
RUN bundle install

EXPOSE 4568
ENTRYPOINT ["/bin/bash","-c"]
CMD ["ruby /usr/app/tf_runner.rb"]