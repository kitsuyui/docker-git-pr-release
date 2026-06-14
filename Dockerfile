FROM ruby:3.3.11-alpine@sha256:f00dbaf04ec980f2545fc4ecb39f01ba5b9c10c70ff322735b203ea1ed816dfb
ADD Gemfile /root
ADD Gemfile.lock /root
RUN \
    apk --update add --no-cache git=2.54.0-r0 openssh-client-default=10.3_p1-r0 && \
    apk add --no-cache --virtual .build-deps build-base=0.5-r4 && \
    cd /root && \
    bundle config set --local frozen true && \
    bundle install && \
    apk del .build-deps && \
    mkdir -p /repo
WORKDIR /repo
ENTRYPOINT ["git-pr-release"]
