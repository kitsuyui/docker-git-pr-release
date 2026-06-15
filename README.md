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

Common optional variables include:

- `GIT_PR_RELEASE_TEMPLATE`: path to an ERB template file used for the
  release pull request title and body.
- `GIT_PR_RELEASE_LABELS`: comma-separated labels to add to the release pull
  request.
- `GIT_PR_RELEASE_MENTION`: name source listed next to each released pull
  request, such as `author`.
- `GIT_PR_RELEASE_SSL_NO_VERIFY`: set to `1` only when connecting to a GitHub
  Enterprise server with a self-signed certificate.

See the upstream
[`git-pr-release` configuration reference](https://github.com/x-motemen/git-pr-release#configuration)
for the authoritative option list. This image installs the version pinned in
`Gemfile.lock`; update the lockfile before relying on newer upstream options.

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

### Default behavior

The container's `ENTRYPOINT` is `git-pr-release` with no default `CMD` arguments.
Running the container without extra arguments invokes the tool directly, which
creates or updates the release pull request. There is no built-in help screen: if a
required environment variable such as `GIT_PR_RELEASE_TOKEN` is missing,
`git-pr-release` exits with a non-zero status and writes an error to standard error.

To open a shell inside the container for debugging, override the entrypoint:

```console
docker run --rm --entrypoint sh -it kitsuyui/docker-git-pr-release
```

### Configuration file precedence

The upstream `git-pr-release` gem reads a `.git-pr-release` file from the
working directory in addition to environment variables. Because the container
mounts your repository at `/repo` (`-v "$(pwd):/repo"`), any `.git-pr-release`
file present in your repository will be read at runtime.

When both a `.git-pr-release` file and environment variables are present, the
configuration file takes precedence over the environment variables for the keys
it defines. This means that if your repository contains a `.git-pr-release`
file with `BRANCH_PRODUCTION` or other settings, those values will override the
corresponding environment variables you pass to the container.

If you rely exclusively on environment variables for configuration, verify that
your repository does not contain a `.git-pr-release` file. If the file exists
for local use, you can prevent it from affecting the container by not mounting
the directory that contains it, or by removing the file before running the
container in CI/CD.

When you use SSH remotes, prepare `known_hosts` on the host before mounting
the SSH directory. The image does not disable SSH host key checking by default.

```console
ssh-keyscan github.com >> "$HOME/.ssh/known_hosts"
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
docker run -v "$(pwd):/root" -it ruby sh -c 'cd /root; rm Gemfile; bundle lock'
```

## LICENSE

MIT License. See also LICENSE file.
