FROM alpine as builder

ARG TF_VERSION=0.11.13
ARG APP_ROOT=/usr/app

ENV BUILD_PACKAGES bash curl curl-dev ruby-dev build-base
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler

RUN apk update && \
    apk upgrade && \
    apk add $BUILD_PACKAGES && \
    apk add $RUBY_PACKAGES && \
    rm -rf /var/cache/apk/*

RUN mkdir ${APP_ROOT}
WORKDIR ${APP_ROOT}

COPY Gemfile ${APP_ROOT}/Gemfile
RUN bundle install
RUN curl -sSL https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip --output - \
    | unzip -d /usr/app - \
    && chmod +x terraform

COPY . ${APP_ROOT}/
RUN chown nobody ${APP_ROOT}

USER nobody

EXPOSE 4570
ENTRYPOINT ["/bin/sh","-c"]
CMD ["thin start -C thin.yml"]
