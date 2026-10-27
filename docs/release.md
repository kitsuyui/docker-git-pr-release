# Release process

This repository distributes a Docker image for `git-pr-release`. Pull request
CI verifies that the image builds and that the container can run
`git-pr-release`. Pushing a stable version tag runs the `Publish Docker image`
workflow, which publishes the matching version and `latest` to Docker Hub.
A GitHub Release provides the release notes for the tag.

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
6. Push a new `vMAJOR.MINOR.PATCH` Git tag for the verified commit. This
   triggers `.github/workflows/publish.yml` and updates `latest`.
7. Wait for the workflow to succeed, then verify that Docker Hub contains the
   matching version and that the image can be pulled by tag.
8. Create a GitHub Release with notes for the same tag.

## Artifact contract

The published image should:

- run `git-pr-release` as its entrypoint,
- keep `/repo` as the expected mounted working directory,
- read runtime configuration from the upstream `git-pr-release` environment
  variables and optional `.git-pr-release` file,
- include the `git-pr-release` version pinned by `Gemfile.lock`.

## Pre-releases

The stable-tag workflow always updates `latest` and does not provide an
automated pre-release image path. Do not use it for an experimental release.
Prepare a versioned image manually without updating `latest` if needed.

## Failed publish handling

If publishing fails, investigate the workflow and credentials and rerun the
failed job after the cause is fixed. Do not move or reuse the published tag.
If a GitHub Release already exists, make the incomplete image publication
clear in its notes until the matching image is available.
