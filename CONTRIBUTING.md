# Contributing

Thank you for considering contributing to docker-git-pr-release.

## How to contribute

1. Fork the repository and create a feature branch from `main`.
2. Make your changes. If you are updating the base image or gem versions, also update `Gemfile.lock` (see below).
3. Verify the Docker image builds successfully:
   ```console
   docker build -t docker-git-pr-release:local .
   ```
4. Open a pull request against `main` and fill out the PR template.

## Updating Gemfile.lock

Run the following command to regenerate the lockfile inside a matching Ruby image:

```console
docker run -v "$(pwd):/root" -it ruby sh -c 'cd /root; rm Gemfile.lock; bundle lock'
```

## Reporting issues

Use the GitHub issue tracker. For security vulnerabilities, see [SECURITY.md](SECURITY.md).
