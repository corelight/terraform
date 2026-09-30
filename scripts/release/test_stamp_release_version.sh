#!/usr/bin/env bash
# Tests the tag-only release-version stamp used by the publishing workflow.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/stamp-release-version.sh"

PASS=0
FAIL=0
TMPDIRS_FILE=$(mktemp)

assert_eq() {
  local name="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    echo "PASS: $name"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $name"
    echo "  expected: $expected"
    echo "  actual:   $actual"
    FAIL=$((FAIL + 1))
  fi
}

assert_nonzero_exit() {
  local name="$1" rc="$2"
  if [[ "$rc" -ne 0 ]]; then
    echo "PASS: $name"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $name (expected non-zero exit, got 0)"
    FAIL=$((FAIL + 1))
  fi
}

mktmprepo() {
  local dir remote
  dir=$(mktemp -d)
  remote=$(mktemp -d)
  echo "$dir" >> "$TMPDIRS_FILE"
  echo "$remote" >> "$TMPDIRS_FILE"

  git init -q --bare "$remote"
  (
    cd "$dir"
    git init -q -b main
    git config user.email test@example.com
    git config user.name test
    printf '\n' > RELEASE_VERSION
    git add RELEASE_VERSION
    git commit -q -m "initial"
    git remote add origin "$remote"
    git push -q -u origin main
  )

  printf '%s\n%s\n' "$dir" "$remote"
}

cleanup() {
  if [[ -f "$TMPDIRS_FILE" ]]; then
    while read -r d; do
      [[ -n "$d" ]] && rm -rf "$d"
    done < "$TMPDIRS_FILE"
    rm -f "$TMPDIRS_FILE"
  fi
  return 0
}
trap cleanup EXIT

test_stamp_and_tag_only_push() {
  local paths repo remote main_before main_after stamped_commit tagged_commit stamped_version
  paths=$(mktmprepo)
  repo=$(sed -n '1p' <<< "$paths")
  remote=$(sed -n '2p' <<< "$paths")
  main_before=$(git --git-dir="$remote" rev-parse refs/heads/main)

  (
    cd "$repo"
    "$SCRIPT" v29.0.5-7
    git tag v29.0.5-7
    git push -q origin refs/tags/v29.0.5-7
  )

  main_after=$(git --git-dir="$remote" rev-parse refs/heads/main)
  stamped_commit=$(git -C "$repo" rev-parse HEAD)
  tagged_commit=$(git --git-dir="$remote" rev-parse refs/tags/v29.0.5-7)
  stamped_version=$(git --git-dir="$remote" show refs/tags/v29.0.5-7:RELEASE_VERSION)

  assert_eq "tag-only push leaves remote main unchanged" "$main_before" "$main_after"
  assert_eq "tag points at the stamped commit" "$stamped_commit" "$tagged_commit"
  assert_eq "tagged commit contains the release version" "v29.0.5-7" "$stamped_version"
}

test_stamp_and_tag_only_push

test_malformed_version_fails_without_commit() {
  local paths repo before after rc
  paths=$(mktmprepo)
  repo=$(sed -n '1p' <<< "$paths")
  before=$(git -C "$repo" rev-parse HEAD)

  set +e
  (cd "$repo" && "$SCRIPT" v29.0.5-07 >/dev/null 2>&1)
  rc=$?
  set -e
  after=$(git -C "$repo" rev-parse HEAD)

  assert_nonzero_exit "malformed release version exits non-zero" "$rc"
  assert_eq "malformed release version does not create a commit" "$before" "$after"

  set +e
  (
    cd "$repo" &&
      "$SCRIPT" v1234567890123456789012345678901234567890123456789012345678.0.0-1 >/dev/null 2>&1
  )
  rc=$?
  set -e
  after=$(git -C "$repo" rev-parse HEAD)

  assert_nonzero_exit "overlong release version exits non-zero" "$rc"
  assert_eq "overlong release version does not create a commit" "$before" "$after"
}

test_malformed_version_fails_without_commit

echo
echo "$PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
