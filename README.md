# docker-git-pr-release

[![Docker Pulls](https://img.shields.io/docker/pulls/kitsuyui/docker-git-pr-release.svg)](https://hub.docker.com/r/kitsuyui/docker-git-pr-release/)

Docker distribution of [git-pr-release](https://github.com/motemen/git-pr-release)

## Usage

Create a local env file for the variables passed to `git-pr-release`:

```dotenv
GIT_PR_RELEASE_TOKEN=xxxxxxxxxxx
GIT_PR_RELEASE_BRANCH_PRODUCTION=production
GIT_PR_RELEASE_BRANCH_STAGING=master
```

Keep this file untracked and restrict its permissions, for example with
`chmod 600 .git-pr-release.env`.

```console
$ docker run \
  --env-file .git-pr-release.env \
  -v "$(pwd):/repo" \
  -v "$HOME/.ssh:/root/.ssh:ro" \
  kitsuyui/docker-git-pr-release
```

Avoid passing tokens inline with `-e GIT_PR_RELEASE_TOKEN=...`, because that
can expose the token through shell history or process listings. Docker still
stores container environment variables in metadata visible to Docker users; in
CI/CD, prefer the platform's secret injection features instead of printing
token values in job commands.

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

## Concurrency

`git-pr-release` checks for an existing release PR and creates one if none is
found. This check-then-create sequence is not atomic: if two container runs
overlap (e.g. two CI jobs triggered by rapid pushes to the staging branch),
both may observe "no open PR" and each create a duplicate release PR.

To prevent duplicate PRs, serialize runs at the CI level. With GitHub Actions,
add a `concurrency` group to the workflow:

```yaml
concurrency:
  group: git-pr-release-${{ github.ref }}
  cancel-in-progress: false
```

Setting `cancel-in-progress: false` ensures that a queued run still executes
after the current one finishes, so no release PR is skipped.

## Update Gemfile.lock

```console
$ docker run -v $(pwd):/root -it ruby sh -c 'cd /root; rm Gemfile; bundle lock'
```

## LICENSE

MIT License. See also LICENSE file.
