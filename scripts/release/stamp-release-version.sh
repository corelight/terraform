#!/usr/bin/env bash
# Create the release-only commit that records the published module version.
set -euo pipefail

release_version="${1:-}"
release_version_re='^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)-[1-9][0-9]*$'

if [[ ${#release_version} -gt 64 || ! "$release_version" =~ $release_version_re ]]; then
  echo "error: expected a release version like v29.0.5-7 (maximum 64 bytes)" >&2
  exit 1
fi

if [[ ! -f RELEASE_VERSION ]]; then
  echo "error: RELEASE_VERSION file not found" >&2
  exit 1
fi

printf '%s\n' "$release_version" > RELEASE_VERSION
git add RELEASE_VERSION
git commit -m "chore: stamp Terraform module version"
