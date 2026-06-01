# Release scripts

This directory contains the scripts that drive auto-tagging on merges to
`main`.

## Tag format

`v<sensor>-<meta>`, e.g. `v29.0.5-3`.

- `<sensor>` is the Corelight sensor version this Terraform release supports.
- `<meta>` increments on every merge to `main` and resets to `1` when the
  sensor version changes.

## Source of truth

Two inputs, with a clear split:

- **`VERSION` file** (repo root) — the sensor version, e.g. `29.0.5`. One line,
  no meta. Bumped by hand when a new sensor ships.
- **git tags** — the meta counter for the current sensor. The next meta is
  `(highest existing v<sensor>-<n>) + 1`, or `1` if there are no tags for the
  sensor yet.

`scripts/release/compute-next-tag.sh` reads `VERSION`, scans the matching tags,
and emits `next_tag=v<sensor>-<meta>` on stdout.

## How it runs in CI

`.github/workflows/auto-tag.yml` runs on every push to `main`:

1. Checkout (with full tag history).
2. `scripts/release/compute-next-tag.sh` -> emits `next_tag=...`.
3. `git tag <next_tag>` and `git push origin <next_tag>`.
4. `gh release create <next_tag> --generate-notes`.

A GHA `concurrency` group serializes runs so two near-simultaneous merges
don't race.

## How a new sensor version is rolled out

1. Edit `VERSION`, changing the sensor (e.g. `29.0.5` -> `30.0.0`).
2. Merge the change to `main`.
3. Auto-tag sees no `v30.0.0-*` tags and produces `v30.0.0-1`.
4. Subsequent merges produce `v30.0.0-2`, `-3`, and so on.

## Running tests locally

```bash
just test-release
```

Or directly:

```bash
./scripts/release/test_compute_next_tag.sh
```

The script uses `sort -n` on numeric metas; the system `sort` on Linux and
macOS both handle this. No special coreutils install is required.

## Force-push recovery

If `main` is force-pushed and old tags now point at orphaned commits, the
compute script logs a warning to stderr but continues to tag normally. To
retire orphaned tags:

```bash
git push origin --delete v<sensor>-<n>
gh release delete v<sensor>-<n>
```
