#!/bin/sh
set -eu

ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
ENTRYPOINT="$ROOT/bin/git-pr-release-entrypoint"
WORKDIR=$(mktemp -d "${TMPDIR:-/tmp}/git-pr-release-entrypoint.XXXXXX")
PATH_WITH_STUB="$WORKDIR/bin:$PATH"
STUB_OUTPUT="$WORKDIR/stub-output"

cleanup() {
    rm -rf "$WORKDIR"
}
trap cleanup EXIT HUP INT TERM

mkdir -p "$WORKDIR/bin"
cat >"$WORKDIR/bin/git-pr-release" <<'STUB'
#!/bin/sh
printf '%s\n' "$*" >"$GIT_PR_RELEASE_STUB_OUTPUT"
STUB
chmod +x "$WORKDIR/bin/git-pr-release"

assert_contains() {
    case "$1" in
        *"$2"*) ;;
        *)
            printf 'expected output to contain: %s\nactual output:\n%s\n' "$2" "$1" >&2
            exit 1
            ;;
    esac
}

assert_fail_contains() {
    dir="$1"
    expected="$2"
    shift 2

    set +e
    output=$(cd "$dir" && env -i PATH="$PATH_WITH_STUB" GIT_PR_RELEASE_STUB_OUTPUT="$STUB_OUTPUT" "$ENTRYPOINT" "$@" 2>&1)
    status=$?
    set -e

    if [ "$status" -ne 2 ]; then
        printf 'expected exit status 2, got %s\noutput:\n%s\n' "$status" "$output" >&2
        exit 1
    fi
    assert_contains "$output" "$expected"
}

assert_success() {
    dir="$1"
    shift

    : >"$STUB_OUTPUT"
    (cd "$dir" && env -i \
        PATH="$PATH_WITH_STUB" \
        GIT_PR_RELEASE_STUB_OUTPUT="$STUB_OUTPUT" \
        GIT_PR_RELEASE_TOKEN=token \
        GIT_PR_RELEASE_BRANCH_PRODUCTION=production \
        GIT_PR_RELEASE_BRANCH_STAGING=main \
        "$ENTRYPOINT" "$@")

    if [ "$(cat "$STUB_OUTPUT")" != "$*" ]; then
        printf 'expected stub args "%s", got "%s"\n' "$*" "$(cat "$STUB_OUTPUT")" >&2
        exit 1
    fi
}

plain_dir="$WORKDIR/plain"
missing_env_repo="$WORKDIR/missing-env"
config_repo="$WORKDIR/config"
config_token_missing_repo="$WORKDIR/config-token-missing"
partial_missing_repo="$WORKDIR/partial-missing"
success_repo="$WORKDIR/success"

mkdir -p "$plain_dir" "$missing_env_repo" "$config_repo" "$config_token_missing_repo" "$partial_missing_repo" "$success_repo"
git -C "$missing_env_repo" init -q
git -C "$config_repo" init -q
git -C "$config_token_missing_repo" init -q
git -C "$partial_missing_repo" init -q
git -C "$success_repo" init -q

assert_fail_contains "$plain_dir" 'the current /repo directory must be a git working tree'
assert_fail_contains "$missing_env_repo" 'missing required environment variables: GIT_PR_RELEASE_TOKEN GIT_PR_RELEASE_BRANCH_PRODUCTION GIT_PR_RELEASE_BRANCH_STAGING'

touch "$config_token_missing_repo/.git-pr-release"
assert_fail_contains "$config_token_missing_repo" 'missing required environment variables: GIT_PR_RELEASE_TOKEN'

set +e
partial_output=$(cd "$partial_missing_repo" && env -i \
    PATH="$PATH_WITH_STUB" \
    GIT_PR_RELEASE_STUB_OUTPUT="$STUB_OUTPUT" \
    GIT_PR_RELEASE_TOKEN=token \
    GIT_PR_RELEASE_BRANCH_PRODUCTION=production \
    "$ENTRYPOINT" 2>&1)
partial_status=$?
set -e

if [ "$partial_status" -ne 2 ]; then
    printf 'expected exit status 2, got %s\noutput:\n%s\n' "$partial_status" "$partial_output" >&2
    exit 1
fi
assert_contains "$partial_output" 'missing required environment variables: GIT_PR_RELEASE_BRANCH_STAGING'

touch "$config_repo/.git-pr-release"
: >"$STUB_OUTPUT"
(cd "$config_repo" && env -i \
    PATH="$PATH_WITH_STUB" \
    GIT_PR_RELEASE_STUB_OUTPUT="$STUB_OUTPUT" \
    GIT_PR_RELEASE_TOKEN=token \
    "$ENTRYPOINT" --dry-run)
if [ "$(cat "$STUB_OUTPUT")" != "--dry-run" ]; then
    printf 'expected .git-pr-release config path to call stub with --dry-run\n' >&2
    exit 1
fi

assert_success "$success_repo" --dry-run
