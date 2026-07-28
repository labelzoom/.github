#!/usr/bin/env bash
#
# Cut a version tag and move the major alias that consumer repos pin to.
#
#   ./script/cut-release.sh v1.3.0
#
# Run locally by a member of @labelzoom/labelzoom. This is deliberately NOT a
# workflow: the `v*` tag ruleset restricts creation and update, and GitHub Actions
# cannot be granted a bypass — the API rejects it with "Actor GitHub Actions
# integration must be part of the ruleset source or owner organization", because
# Actions is built into the platform rather than installed as an org integration.
# Only a custom org-owned GitHub App could bypass, and that would mean keeping a
# private key around to automate two git commands. Not worth it.
#
# So promoting a commit to the ref that every consumer repo executes is an
# explicit, local, human act. Which is the semantic we wanted anyway.

set -euo pipefail

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
  echo "usage: $0 vX.Y.Z" >&2
  exit 64
fi

if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "error: version must look like v1.2.3 (got '$VERSION')" >&2
  exit 64
fi

MAJOR="${VERSION%%.*}"

git fetch --quiet origin --tags

if git rev-parse -q --verify "refs/tags/$VERSION" >/dev/null; then
  echo "error: tag $VERSION already exists; versions are immutable, pick a new one" >&2
  exit 1
fi

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$BRANCH" != "main" ]]; then
  echo "error: releases are cut from main, not '$BRANCH'" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "error: working tree is dirty; commit or stash first" >&2
  exit 1
fi

if [[ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]]; then
  echo "error: local main is not level with origin/main; pull first" >&2
  exit 1
fi

echo "Cutting $VERSION and moving $MAJOR to $(git rev-parse --short HEAD) on main."
echo "This immediately becomes live CI for every repo pinning @$MAJOR."
read -r -p "Continue? [y/N] " reply
[[ "$reply" == "y" || "$reply" == "Y" ]] || { echo "aborted"; exit 1; }

git tag -a "$VERSION" -m "$VERSION"
git tag -f -a "$MAJOR" -m "$MAJOR -> $VERSION"
git push origin "$VERSION"
git push origin -f "$MAJOR"

echo "Done. $MAJOR now points at $VERSION."
