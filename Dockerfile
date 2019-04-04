ARG RUBY_VERSION=2.6.2

### Build Container ###
FROM ruby:${RUBY_VERSION}-alpine as builder-base

ARG BUNDLE_VERSION=2.0.1
ARG APP_ROOT=/usr/app
ARG USER=nobody

WORKDIR ${APP_ROOT}

ENV HOME=${APP_ROOT}
ENV BUILD_PACKAGES build-base

RUN apk update && \
    apk upgrade && \
    apk add ${BUILD_PACKAGES} && \
    rm -rf /var/cache/apk/*

RUN gem install bundler:${BUNDLE_VERSION}

RUN mkdir -p ${APP_ROOT} \
    && chown ${USER} ${APP_ROOT}

USER ${USER}

# NOTE: I would not use this pattern outside my own projects.  Any Gemfile updates should be reviewed, and the lock committed.
# Phase 1: Generate new Gemfile.lock on Gemfile change
FROM builder-base as builder-lock
ARG APP_ROOT=/usr/app
COPY Gemfile ${APP_ROOT}
RUN bundle install --path=vendor

# Phase 2: Generate new gem bundle
FROM builder-base as builder-bundle
ARG APP_ROOT=/usr/app
COPY --from=builder-lock ${APP_ROOT}/Gemfile ${APP_ROOT}
COPY --from=builder-lock ${APP_ROOT}/Gemfile.lock ${APP_ROOT}
RUN bundle install --deployment --binstubs

# Phase 3: Generate new source artifact
FROM builder-base as builder-artifact
ARG APP_ROOT=/usr/app
COPY . ${APP_ROOT}/
COPY --from=builder-bundle ${APP_ROOT}/ ${APP_ROOT}/

### Production Container ###
FROM ruby:${RUBY_VERSION}-alpine

ARG BUNDLE_VERSION=2.0.1
ARG TF_VERSION=0.11.12
ARG APP_ROOT=/usr/app
ARG USER=nobody

WORKDIR ${APP_ROOT}

ENV RUNTIME_PACKAGES curl
ENV HOME=${APP_ROOT}

RUN apk update && \
    apk upgrade && \
    apk add ${RUNTIME_PACKAGES} && \
    rm -rf /var/cache/apk/*

RUN gem install bundler:${BUNDLE_VERSION}
RUN mkdir -p ${APP_ROOT} \
    && chown ${USER} ${APP_ROOT}

RUN curl -sSL https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip --output - \
    | unzip -d ${APP_ROOT} - \
    && chmod 700 ${APP_ROOT}/terraform \
    && chown ${USER} ${APP_ROOT}/terraform

USER ${USER}

COPY --chown=nobody --from=builder-artifact ${APP_ROOT}/ ${APP_ROOT}/
RUN bundle install --deployment --binstubs

EXPOSE 4570
ENTRYPOINT ["/bin/sh","-c"]
CMD ["bundle exec thin start -C thin.yml"]
