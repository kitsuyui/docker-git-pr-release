FROM ruby:3.3.11-alpine@sha256:dc01e7d51e7ec9b9d1b27b80dab38d313b338fce50489e9b0f128b861712b7ef
COPY Gemfile /root
COPY Gemfile.lock /root
COPY bin/git-pr-release-entrypoint /usr/local/bin/git-pr-release-entrypoint
RUN \
    apk --update add --no-cache git=2.54.0-r0 openssh-client-default=10.3_p1-r0 && \
    apk add --no-cache --virtual .build-deps build-base=0.5-r4 && \
    cd /root && \
    bundle config set --local frozen true && \
    bundle install && \
    apk del .build-deps && \
    chmod +x /usr/local/bin/git-pr-release-entrypoint && \
    mkdir -p /repo
WORKDIR /repo
ENTRYPOINT ["git-pr-release-entrypoint"]
