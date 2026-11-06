# Task 1845: Untrack committed Rust build output (`rust/target`)

> **Priority**: 🟡 Medium (repository hygiene, no behaviour change)
> **Type**: `chore` | `hygiene`
> **Origin**: adversarial research scout review, 2026-09-29 (findings WP-019..WP-042)
> **Operator-gated**: the untracking step itself requires a VCS write

## Problem

`rust/target/` is committed to the repository: **437 tracked files, 144 MiB**,
made up of cargo build output (`.json` fingerprints, `.timestamp`, `.d`,
`.rmeta`, `.rlib`, `.so`, `.bin`, `.cargo-lock`, `CACHEDIR.TAG`).

`rust/target/` was **not** present in `.gitignore` before 2026-09-29. The
`.gitignore` rule has now been added by this task, but the already-tracked
files remain in the index until they are explicitly untracked.

For scale: the repository tracks 5603 files total, of which 437 (7.8%) are
cargo build output.

## Scope boundary

`.dart_tool/`, `build/`, `.idea/`, and `*.iml` were audited in the same sweep and
are **already clean** — 0 tracked files in each. Only `rust/target/` is affected.

309 tracked `.png` files under goldens paths are **intentional** — they are
golden baselines, not artifacts, and are governed by the Task 1805 freeze. Do
not touch them.

## Required action (operator / VCS-write authority)

```
git rm -r --cached rust/target
git commit -m "chore(hygiene): untrack rust/target build output (437 files, 144 MiB)"
```

The `.gitignore` rule is already in place as of this task, so the commit is
sufficient to complete the work. No working-tree deletion is required or
desired; only index untracking.

## Validation

```bash
git ls-files rust/target | wc -l     # must be 0 after the commit
ls rust/target >/dev/null            # local build output may remain on disk
```

## Non-Goals

- No `cargo clean` on a developer's machine.
- No change to the goldens or any other tracked content.
- No `rust/Cargo.lock` removal.

## Completion Evidence

- `git ls-files rust/target` count after commit
- total tracked file count before/after
- local changelog entry
