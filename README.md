# docker-git-pr-release

[![Docker Pulls](https://img.shields.io/docker/pulls/kitsuyui/docker-git-pr-release.svg)](https://hub.docker.com/r/kitsuyui/docker-git-pr-release/)

Docker distribution of [git-pr-release](https://github.com/motemen/git-pr-release)

## Usage

```console
$ docker run -it \
  -e GIT_PR_RELEASE_TOKEN='xxxxxxxxxxx' \
  -e GIT_PR_RELEASE_BRANCH_PRODUCTION=production \
  -e GIT_PR_RELEASE_BRANCH_STAGING=master \
  -v $(pwd):/repo \
  -v $HOME/.ssh:/root/.ssh kitsuyui/docker-git-pr-release
```

## Update Gemfile.lock

```console
$ docker run -v $(pwd):/root -it ruby sh -c 'cd /root; rm Gemfile; bundle lock'
```

## LICENSE

MIT License. See also LICENSE file.
