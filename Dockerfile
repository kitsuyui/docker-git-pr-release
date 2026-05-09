FROM ruby:3.2.11-alpine
ADD Gemfile /root
ADD Gemfile.lock /root
RUN \
    apk --update add --no-cache git openssh-client && \
    apk --update add --no-cache --virtual .build-deps build-base && \
    cd /root && \
    bundle install && \
    apk del .build-deps && \
    mkdir -p /repo
WORKDIR /repo
ENTRYPOINT ["git-pr-release"]
