FROM alpine

ARG TF_VERSION=0.11.13

ENV BUILD_PACKAGES bash curl curl-dev ruby-dev build-base
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
RUN curl -sSL https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip --output - \
    | unzip -d /usr/app - \
    && chmod +x terraform

RUN chown nobody /usr/app

USER nobody

EXPOSE 4570
ENTRYPOINT ["/bin/bash","-c"]
CMD ["thin start -C thin.yml"]
