# docker-git-pr-release

[![Docker Pulls](https://img.shields.io/docker/pulls/kitsuyui/docker-git-pr-release.svg)](https://hub.docker.com/r/kitsuyui/docker-git-pr-release/)

Docker distribution of [git-pr-release](https://github.com/motemen/git-pr-release)

## Usage

```console
$ docker run \
  -e GIT_PR_RELEASE_TOKEN='xxxxxxxxxxx' \
  -e GIT_PR_RELEASE_BRANCH_PRODUCTION=production \
  -e GIT_PR_RELEASE_BRANCH_STAGING=master \
  -v $(pwd):/repo \
  -v $HOME/.ssh:/root/.ssh:ro kitsuyui/docker-git-pr-release
```

For interactive debugging sessions, add `-it` flags to the command above.
CI/CD environments typically do not allocate a TTY, so `-t` is omitted here.

When you use SSH remotes, prepare `known_hosts` on the host before mounting
the SSH directory. The image does not disable SSH host key checking by default.

```console
$ ssh-keyscan github.com >> $HOME/.ssh/known_hosts
```

Verify scanned host keys before trusting them.

If an environment needs a different trust policy, pass it explicitly with
`GIT_SSH_COMMAND`.

## Update Gemfile.lock

```console
$ docker run -v $(pwd):/root -it ruby sh -c 'cd /root; rm Gemfile; bundle lock'
```

## LICENSE

MIT License. See also LICENSE file.
