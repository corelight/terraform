#!/usr/bin/env bash
# Compute the next release tag for this repo.
#
# Source of truth:
#   - sensor version: the VERSION file at the repo root (e.g. "29.0.5")
#   - meta counter:   highest existing v<sensor>-<n> git tag, + 1 (or 1 if none)
#
# Output: a single line `next_tag=v<sensor>-<meta>` on stdout, suitable for
# appending to $GITHUB_OUTPUT.
#
# Exits non-zero with a helpful message on stderr if VERSION is missing or
# malformed.
set -euo pipefail

# Ensure we have tags (caller usually does fetch-tags, but be defensive).
git fetch --tags --quiet 2>/dev/null || true

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  echo "compute-next-tag: not inside a git repository." >&2
  exit 1
fi
version_file="$repo_root/VERSION"

if [[ ! -f "$version_file" ]]; then
  echo "compute-next-tag: VERSION file not found at $version_file." >&2
  exit 1
fi

# Read the first line and strip all whitespace.
read -r sensor < "$version_file" || true
sensor="${sensor//[[:space:]]/}"

if [[ ! "$sensor" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "compute-next-tag: VERSION must contain a sensor version like 29.0.5 (got: '$sensor')." >&2
  exit 1
fi

# Escape '.' so it matches literally in the grep regex.
sensor_re="${sensor//./\\.}"

# Highest existing meta for this exact sensor (numeric sort).
highest=$(git tag --list "v${sensor}-*" \
            | grep -E "^v${sensor_re}-[0-9]+$" \
            | sed -E "s/^v${sensor_re}-//" \
            | sort -n \
            | tail -n 1 || true)

if [[ -z "$highest" ]]; then
  next_meta=1
else
  next_meta=$((10#$highest + 1))

  # Soft sanity check: warn if the highest-meta tag's commit isn't an ancestor
  # of HEAD (e.g., after a force-push to main). Don't fail — failing here would
  # block all future tagging.
  latest_tag="v${sensor}-${highest}"
  latest_sha=$(git rev-list -n 1 "$latest_tag" 2>/dev/null || true)
  head_sha=$(git rev-parse HEAD 2>/dev/null || true)
  if [[ -n "$latest_sha" && -n "$head_sha" ]]; then
    if ! git merge-base --is-ancestor "$latest_sha" "$head_sha" 2>/dev/null; then
      echo "compute-next-tag: warning: latest tag $latest_tag ($latest_sha) is not an ancestor of HEAD ($head_sha). Possible force-push." >&2
    fi
  fi
fi

echo "next_tag=v${sensor}-${next_meta}"
