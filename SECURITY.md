# Security Policy

## Reporting a Vulnerability

Please **do not** report security vulnerabilities through public GitHub issues.

Instead, open a [GitHub Security Advisory](https://github.com/kitsuyui/docker-git-pr-release/security/advisories/new) or send an email to the maintainer. You can find contact information in the GitHub profile.

We aim to acknowledge receipt within 5 business days and to provide a fix or mitigation plan within 30 days, depending on severity.

## Scope

This repository distributes a Docker image that bundles:

- Ruby (base image version pinned in `Dockerfile`)
- `git-pr-release` gem (version pinned in `Gemfile.lock`)
- `git` and `openssh-client` (versions from the Alpine package index)

Vulnerabilities in any of these components are in scope. Please include the component name and version in your report.
