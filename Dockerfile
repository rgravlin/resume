FROM alpine as builder

ARG TF_VERSION=0.11.13
ARG APP_ROOT=/usr/app

ENV BUILD_PACKAGES bash curl curl-dev ruby-dev build-base
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler
ENV HOME=/usr/app

RUN apk update && \
    apk upgrade && \
    apk add $BUILD_PACKAGES && \
    apk add $RUBY_PACKAGES && \
    rm -rf /var/cache/apk/*

RUN mkdir ${APP_ROOT} \
    && chown nobody ${APP_ROOT}

RUN gem install bundler --no-rdoc --no-ri

USER nobody

WORKDIR ${APP_ROOT}

COPY Gemfile ${APP_ROOT}/Gemfile
COPY Gemfile.lock ${APP_ROOT}/Gemfile.lock

RUN bundle install --deployment --binstubs
RUN curl -sSL https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip --output - \
    | unzip -d /usr/app - \
    && chmod +x terraform

COPY . ${APP_ROOT}/

EXPOSE 4570
ENTRYPOINT ["/bin/sh","-c"]
CMD ["bundle exec thin start -C thin.yml"]
