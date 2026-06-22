# Release process

This repository distributes a Docker image for `git-pr-release`. Pull request
CI verifies that the image builds and that the container can run
`git-pr-release`, but this repository does not currently contain an automated
Docker Hub publishing workflow. Treat the Git tag and GitHub Release as the
source of truth for published image versions.

## Version policy

- Use tags in the `vMAJOR.MINOR.PATCH` format.
- Publish the same version as the Docker image tag, for example
  `kitsuyui/docker-git-pr-release:1.2.3`.
- Move `latest` only when publishing a stable release that should be the
  default image for new users.
- If the pinned `git-pr-release` gem changes, mention the old and new gem
  versions in the release notes.
- If the Docker runtime contract changes, such as required environment
  variables, mounted paths, or SSH behavior, call it out as a breaking change.

## Release checklist

1. Start from a clean `main` branch.
2. Confirm the pinned gem version in `Gemfile.lock`.
3. Build the image locally:

   ```console
   docker build --load -t docker-git-pr-release:ci .
   ```

4. Run the same runtime smoke test as CI:

   ```console
   docker run --rm --entrypoint sh docker-git-pr-release:ci \
     -c "which git-pr-release && git --version"
   ```

5. Draft release notes with:
   - the image tag,
   - the pinned `git-pr-release` gem version,
   - user-visible behavior changes,
   - any migration or breaking-change notes.
6. Create a `vMAJOR.MINOR.PATCH` Git tag and GitHub Release.
7. Publish the Docker image with the matching version tag. Update `latest`
   only for stable releases.
8. Verify that the Docker Hub page shows the expected tag and that the image
   can be pulled by tag.

## Artifact contract

The published image should:

- run `git-pr-release` as its entrypoint,
- keep `/repo` as the expected mounted working directory,
- read runtime configuration from the upstream `git-pr-release` environment
  variables and optional `.git-pr-release` file,
- include the `git-pr-release` version pinned by `Gemfile.lock`.

## Pre-releases

For experimental changes, publish a GitHub pre-release and a versioned image
tag only. Do not move `latest` for pre-releases.

## Failed publish handling

If publishing fails after a GitHub Release exists, leave the release visible
only if the matching Docker image tag is available. Otherwise, mark the release
as a draft or delete it, fix the publish problem, and recreate the release with
notes that match the actually published artifact.
