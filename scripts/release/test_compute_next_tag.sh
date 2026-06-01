#!/usr/bin/env bash
# Tests for compute-next-tag.sh.
# Each test creates an ephemeral git repo (optionally seeded with a VERSION
# file), populates it with tags, runs the script, and asserts on
# stdout/stderr/exit code.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/compute-next-tag.sh"

PASS=0
FAIL=0
# Track temp dirs in a file so command-substitution subshells can append.
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

assert_contains() {
  local name="$1" needle="$2" haystack="$3"
  if [[ "$haystack" == *"$needle"* ]]; then
    echo "PASS: $name"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $name"
    echo "  expected to contain: $needle"
    echo "  actual: $haystack"
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

# Create an ephemeral repo. If a sensor arg is given, write it to VERSION and
# commit it; otherwise make an empty initial commit (no VERSION file).
mktmprepo() {
  local sensor="${1:-}"
  local dir
  dir=$(mktemp -d)
  echo "$dir" >> "$TMPDIRS_FILE"
  (
    cd "$dir"
    git init -q -b main
    git config user.email test@example.com
    git config user.name test
    if [[ -n "$sensor" ]]; then
      printf '%s\n' "$sensor" > VERSION
      git add VERSION
      git commit -q -m "initial"
    else
      git commit -q --allow-empty -m "initial"
    fi
  )
  echo "$dir"
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

# ---- tests ----

test_same_sensor_increment() {
  local repo out
  repo=$(mktmprepo 29.0.5)
  (cd "$repo" && git tag v29.0.5-3)
  out=$(cd "$repo" && "$SCRIPT" 2>/dev/null)
  assert_eq "same-sensor increment" "next_tag=v29.0.5-4" "$out"
}

test_same_sensor_increment

test_first_release_of_sensor() {
  # VERSION set, but no tags exist yet for this sensor -> meta 1.
  local repo out
  repo=$(mktmprepo 29.0.5)
  out=$(cd "$repo" && "$SCRIPT" 2>/dev/null)
  assert_eq "first release of sensor -> -1" "next_tag=v29.0.5-1" "$out"
}

test_first_release_of_sensor

test_sensor_reset() {
  # VERSION bumped to a new sensor; only old-sensor tags exist -> meta 1.
  local repo out
  repo=$(mktmprepo 30.0.0)
  (cd "$repo" && git tag v29.0.5-1 && git tag v29.0.5-7)
  out=$(cd "$repo" && "$SCRIPT" 2>/dev/null)
  assert_eq "sensor bump resets meta to 1" "next_tag=v30.0.0-1" "$out"
}

test_sensor_reset

test_multi_digit_meta() {
  local repo out
  repo=$(mktmprepo 29.0.5)
  (cd "$repo" && git tag v29.0.5-9 && git tag v29.0.5-10)
  out=$(cd "$repo" && "$SCRIPT" 2>/dev/null)
  assert_eq "multi-digit meta (-10 > -9)" "next_tag=v29.0.5-11" "$out"

  repo=$(mktmprepo 29.0.5)
  (cd "$repo" && git tag v29.0.5-99)
  out=$(cd "$repo" && "$SCRIPT" 2>/dev/null)
  assert_eq "two-digit roll-over (-99 -> -100)" "next_tag=v29.0.5-100" "$out"
}

test_multi_digit_meta

test_other_sensor_tags_ignored() {
  # Tags for a different sensor must not affect the current sensor's meta.
  local repo out
  repo=$(mktmprepo 29.0.5)
  (cd "$repo" && git tag v29.0.5-3 && git tag v30.0.0-9)
  out=$(cd "$repo" && "$SCRIPT" 2>/dev/null)
  assert_eq "other-sensor tags ignored" "next_tag=v29.0.5-4" "$out"
}

test_other_sensor_tags_ignored

test_missing_version_fails() {
  local repo rc out err
  repo=$(mktmprepo)   # no VERSION file
  set +e
  out=$(cd "$repo" && "$SCRIPT" 2>/tmp/compute-next-tag.stderr.$$)
  rc=$?
  set -e
  err=$(cat /tmp/compute-next-tag.stderr.$$)
  rm -f /tmp/compute-next-tag.stderr.$$
  assert_nonzero_exit "missing VERSION exits non-zero" "$rc"
  assert_contains "missing VERSION message" "VERSION file not found" "$err"
  assert_eq "missing VERSION emits nothing on stdout" "" "$out"
}

test_missing_version_fails

test_malformed_version_fails() {
  local repo rc out err
  repo=$(mktmprepo "29.0.5-3")   # has a meta -> not a bare sensor
  set +e
  out=$(cd "$repo" && "$SCRIPT" 2>/tmp/compute-next-tag.stderr.$$)
  rc=$?
  set -e
  err=$(cat /tmp/compute-next-tag.stderr.$$)
  rm -f /tmp/compute-next-tag.stderr.$$
  assert_nonzero_exit "malformed VERSION (with meta) exits non-zero" "$rc"
  assert_contains "malformed VERSION message" "sensor version like" "$err"

  repo=$(mktmprepo "garbage")
  set +e
  out=$(cd "$repo" && "$SCRIPT" 2>/dev/null)
  rc=$?
  set -e
  assert_nonzero_exit "garbage VERSION exits non-zero" "$rc"
  assert_eq "garbage VERSION emits nothing on stdout" "" "$out"
}

test_malformed_version_fails

test_force_push_warning() {
  # Highest-meta tag is on a commit no longer reachable from HEAD.
  local repo out err
  repo=$(mktmprepo 29.0.5)
  (
    cd "$repo"
    git checkout -q -b orphan
    git commit -q --allow-empty -m "orphaned commit"
    git tag v29.0.5-3
    git checkout -q main
    git commit -q --allow-empty -m "main moved on"
  )
  out=$(cd "$repo" && "$SCRIPT" 2>/tmp/compute-next-tag.stderr.$$)
  err=$(cat /tmp/compute-next-tag.stderr.$$)
  rm -f /tmp/compute-next-tag.stderr.$$
  assert_eq "force-push: still emits next tag" "next_tag=v29.0.5-4" "$out"
  assert_contains "force-push: warns on stderr" "not an ancestor" "$err"
}

test_force_push_warning

test_leading_zero_meta() {
  # A hand-pushed zero-padded meta must not trigger octal arithmetic.
  local repo out
  repo=$(mktmprepo 29.0.5)
  (cd "$repo" && git tag v29.0.5-08)
  out=$(cd "$repo" && "$SCRIPT" 2>/dev/null)
  assert_eq "leading-zero meta (-08 -> -9, not octal crash)" "next_tag=v29.0.5-9" "$out"
}

test_leading_zero_meta

test_malformed_same_sensor_tags_ignored() {
  # Garbage metas on the matching sensor are filtered by the meta anchor.
  local repo out
  repo=$(mktmprepo 29.0.5)
  (cd "$repo" \
     && git tag v29.0.5-foo \
     && git tag v29.0.5-1-rc \
     && git tag v29.0.5 \
     && git tag v29.0.5-4)
  out=$(cd "$repo" && "$SCRIPT" 2>/dev/null)
  assert_eq "malformed same-sensor tags ignored" "next_tag=v29.0.5-5" "$out"
}

test_malformed_same_sensor_tags_ignored

echo
echo "$PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
