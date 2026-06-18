FROM ruby:3.3.11-alpine
ADD Gemfile /root
ADD Gemfile.lock /root
RUN \
    apk --update add --no-cache git=2.52.0-r0 openssh-client-default=10.2_p1-r0 && \
    apk add --no-cache --virtual .build-deps build-base=0.5-r3 && \
    cd /root && \
    bundle config set --local frozen true && \
    bundle install && \
    apk del .build-deps && \
    mkdir -p /repo
WORKDIR /repo
ENTRYPOINT ["git-pr-release"]
