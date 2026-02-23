FROM ruby:3.1.3-alpine3.15
ADD Gemfile /root
ADD Gemfile.lock /root
RUN \
    apk --update add --no-cache git openssh-client && \
    apk --update add --no-cache --virtual .build-deps build-base && \
    cd /root && \
    bundle install && \
    apk del .build-deps && \
    mkdir -p /repo && \
    mkdir -p ~/.ssh && chmod 700 ~/.ssh && \
    echo 'StrictHostKeyChecking no' >> ~/.ssh/config && chmod 600 ~/.ssh/config
WORKDIR /repo
ENTRYPOINT ["git-pr-release"]
