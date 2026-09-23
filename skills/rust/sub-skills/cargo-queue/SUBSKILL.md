---
name: cargo-queue
description: "Serialized cargo operations via POSIX flock with agent-decides dedup (success/fail/running). Part of rust."
parent: rust
triggers:
  - cargo queue
  - cargo lock contention
  - serialized cargo
  - cargo check
  - cargo test
  - cargo dedup
  - CARGO_QUEUE_ENVELOPE
---

# cargo-queue

> **Purpose**: Serialize cargo operations and surface prior identical results so agents can decide reuse vs force  
> **When to use**: When multiple agents may run cargo commands concurrently, or when re-running the same gate  
> **Do NOT use**: For non-cargo operations (use regular bash)

---

## Overview

The cargo-queue system:

- **Serializes** cargo via POSIX `flock` (one cargo process at a time; lock held for the full cargo lifetime)
- **Enforces a single target directory**: only `$PROJECT_ROOT/target` (refuses custom `CARGO_TARGET_DIR`, `--target-dir`, and orphan `target-*` / `.tmp-target-*` trees)
- **Fingerprints** each request (command + normalized args + project root + canonical target dir + clean threshold)
- **Dedups** identical requests for **success, failure, and in-flight** runs (unless `--force` / `CARGO_QUEUE_FORCE=1`)
- **Size-gates clean** on `target/` (default **30 GiB**); runs the same gate **after every non-clean cargo** under the lock
- Emits a machine-parseable **`CARGO_QUEUE_ENVELOPE`** on every path
- Appends an append-only **`ledger.jsonl`** and O(1) FP index under `fp/<hh>/<fingerprint>.json`
- Preserves cargo exit codes; `dedup_running` exits **75** (`EX_TEMPFAIL`)

### Two layers (do not conflate)

| Layer | Owner | Meaning |
|-------|--------|---------|
| **A. Enqueue / skip cargo** | Queue (mechanical) + agent (judgment) | Avoid identical re-runs; always expose prior artifacts |
| **B. Claim PASS for a task** | Agent + reviewer only | **Never** auto-mark task green from a failure log (or from a green log without scope judgment) |

**Failures are often more valuable than successes.** The queue surfaces them; it does not hide them.

---

## Usage

### Basic Command

```bash
AGENT_NAME=your-agent TASK_ID=NNNN \
  bash .agents/skills/rust/sub-skills/cargo-queue/scripts/cargo-queue.sh check --lib
```

### Available Commands

| Command | Description |
|---------|-------------|
| `check` | Run `cargo check` |
| `test` | Run `cargo test` |
| `clippy` | Run `cargo clippy` |
| `build` | Run `cargo build` |
| `clean` | Run `cargo clean` only when `target/` is larger than the configured threshold (canonical `target/` only) |
| `status` | Show queue status + thin envelope (reports orphan `target-*` dirs; does not hard-fail) |

### Force re-run

```bash
# CLI flag (stripped before cargo; never passed through)
bash .../cargo-queue.sh check --lib --force

# Environment
CARGO_QUEUE_FORCE=1 bash .../cargo-queue.sh check --lib
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `AGENT_NAME` | Agent name | `unknown` |
| `TASK_ID` | Task ID | `none` |
| `CARGO_QUEUE_TIMEOUT` | Lock wait timeout (seconds) | `1800` |
| `CARGO_QUEUE_CLEAN_THRESHOLD_GB` | Min `target/` GiB before `clean` runs | `30` |
| `CARGO_QUEUE_DIR` | Override queue state dir (tests) | `$PROJECT_ROOT/.agents/cargo-queue` |
| `CARGO_QUEUE_PROJECT_ROOT` | Override project root (tests) | nearest `Cargo.toml` from cwd |
| `CARGO_QUEUE_FORCE` | `1` = force enqueue | unset |
| `CARGO_QUEUE_DEDUP` | `0` = disable dedup short-circuits | `1` (enabled) |
| `CARGO_QUEUE_DEDUP_TTL_SEC` | Max age of prior result for hit | `3600` |
| `CARGO_QUEUE_FP_INCLUDE_RUSTC` | `1` = include short `rustc -vV` hash in FP | `0` |
| `CARGO_TARGET_DIR` | **Forbidden** unless it resolves to exactly `$PROJECT_ROOT/target`. Custom values → exit **1** (policy). Prefer unset. | unset |

### Target directory policy (absolute)

> **One project → one `target/`.** The queue exists so agents wait on flock — not so they invent parallel target trees.

| Rule | Behavior |
|------|----------|
| Only `$PROJECT_ROOT/target` | Canonical; fingerprint always uses this path |
| Custom `CARGO_TARGET_DIR` | **Rejected** (exit 1, envelope `status=error`) unless equal to default |
| `--target-dir` / `--target-dir=…` | **Rejected** (exit 1) |
| Orphan `target-*` or `.tmp-target-*` at project root | **Rejected** (exit 1) until human removes them |
| Env normalization | On accept, `CARGO_TARGET_DIR` is **unset** so cargo uses default `./target` |

No documented exception for per-task / blrev / expert fanout targets. Parallel agents **wait on the queue**.

### Clean Threshold

`clean` is size-gated against **`$PROJECT_ROOT/target` only**. By default it skips `cargo clean` unless `target/` is larger than **30 GiB**. Missing `target/` also skips (exit 0). Invalid thresholds fail before queue mutation.

**Post-run gate:** after every successful lock acquisition for `check` / `test` / `clippy` / `build`, the queue runs the same size gate (still under flock). Primary cargo exit code is preserved even if the reclaim clean fails.

---

## Response envelope (required parse)

Every cargo path prints:

```text
=== CARGO_QUEUE_ENVELOPE ===
schema: 1
request_id: ...
timestamp: ISO-8601
status: accepted|running|completed|failed|dedup_hit|dedup_running|timeout|error
fingerprint: <64 hex>
command: check
args: --lib
project_root: /abs/path
cargo_target_dir: /abs/or/empty
log_path: /abs/path/....log
result_path: /abs/path/....json
exit_code: 0|101|75|...
dedup: none|hit|running
prior_request_id: ...
prior_timestamp: ...
prior_status: ...
prior_exit_code: ...
prior_log_path: ...
prior_result_path: ...
force: 0|1
hint: ...
=== END_CARGO_QUEUE_ENVELOPE ===
```

Parse markers, not emoji lines. Paths are absolute.

---

## Exit codes

| Case | Exit | Notes |
|------|------|-------|
| Fresh run success | **0** | cargo |
| Fresh run failure | **cargo code** (e.g. 101) | preserved |
| Lock timeout / bad usage / **target policy violation** | **1** | custom `CARGO_TARGET_DIR`, `--target-dir`, orphan `target-*` |
| `dedup_hit` prior success | **0** | gate artifact available — agent still judges scope |
| `dedup_hit` prior failure | **prior exit** | preserve fail signal |
| `dedup_running` | **75** | not green; wait / poll `status` / or `--force` |
| Forced run | cargo exit | serialized behind lock |

---

## Agent decision tree (normative)

```text
1. Run cargo-queue as today.
2. Parse CARGO_QUEUE_ENVELOPE (required).
3. If status == dedup_running (exit 75):
     - Prefer: poll `status` / sleep / wait for prior to finish; re-invoke without force
     - Or: --force only if justified (stuck peer → ask user; do not kill peer)
4. If status == dedup_hit:
     - Always open prior_log_path (tail / rg 'error\[')
     - If prior_exit_code != 0:
         * May cite as residual/EXTERNAL evidence
         * MUST NOT claim task PASS from this alone
         * --force if you need a post-fix signal on your edits
     - If prior_exit_code == 0:
         * Cite as gate evidence ONLY if your task scope was not invalidated
           (you did not edit relevant code since prior_timestamp; lock/manifest TTL ok)
         * If you edited Rust sources in scope → --force
5. Layer B (task PASS) is always agent+reviewer judgment — queue never claims it.
```

> **NEVER auto-claim task PASS from a failure prior log.**  
> Success priors still require agent scope judgment (edits since prior, member manifests, etc.).

---

## Dedup validity (Phase 1)

A prior completed result is eligible when:

1. Exact fingerprint match
2. Age ≤ `CARGO_QUEUE_DEDUP_TTL_SEC` (default 60 min)
3. Root `Cargo.toml` and `Cargo.lock` mtimes are **not** newer than prior `finished_at`

**Not** in Phase 1 fingerprint: `AGENT_NAME`, `TASK_ID`, wall clock, `RUSTFLAGS`.

**Known Phase 1 misses** (prefer false negatives → extra runs):

- Feature list order (`--features a,b` ≠ `b,a`)
- Package flag order (`-p a -p b` ≠ `-p b -p a`)
- Nested member-only `Cargo.toml` edits (root mtime unchanged) → agent should `--force`
- ~~Different `CARGO_TARGET_DIR` → different fingerprint~~ **obsolete**: custom `CARGO_TARGET_DIR` is **refused** (single `target/` policy)

Running prior with live PID → `dedup_running` **before** lock wait. Dead PID → re-run.

---

## File locations

| Path | Purpose |
|------|---------|
| `.agents/skills/rust/sub-skills/cargo-queue/scripts/cargo-queue.sh` | Main script |
| `scripts/selftest-cargo-queue-dedup.sh` | P0/P1 selftest (fake cargo) |
| `$PROJECT_ROOT/.agents/cargo-queue/queue.lock` | Flock lock |
| `.../logs/` | Per-request logs |
| `.../results/` | Result JSON (schema 1 + fingerprint) |
| `.../ledger.jsonl` | Append-only event ledger |
| `.../fp/<hh>/<fingerprint>.json` | O(1) latest FP pointer |
| `.../current.json` | Current execution status |

Per-project queue root only (global `.cargo-queue/` is out of scope for P0/P1).

---

## 5-Step Protocol

To prevent ping-pong builds:

1. **List ALL errors** — Run cargo once, capture all failures
2. **Investigate root causes** — ZERO GUESSWORK — read code before fixing
3. **Make ALL fixes at once** — Batch corrections to minimize queue cycles
4. **Verify changes** — Use skill reasoning to validate approach
5. **Submit ONCE to queue** — Single check/test cycle per task phase; reuse EXTERNAL reds via dedup when appropriate

---

## Selftest

```bash
bash .agents/skills/rust/sub-skills/cargo-queue/scripts/selftest-cargo-queue-dedup.sh
# or subset: ... selftest-cargo-queue-dedup.sh T2 T3 T4 T9
```

Covers T0–T11: envelope, ledger, dedup success/fail/running, force, TTL, manifest invalidate, lock serialization, **target policy refuse** (custom env / `--target-dir` / orphans), dedup off.

---

## Integration with sccache

```toml
# .cargo/config.toml
[build]
rustc-wrapper = "sccache"
```

Lock FD is held for the full cargo lifetime (correctness over FD inheritance). If sccache inherits the lock FD in a stuck way, document and refine with a drop-inheritance helper — do not re-introduce early `exec 200>&-` before cargo finishes.

---

## Anti-Regressão

- ✅ No parallel cargo (flock for full cargo duration — T9)
- ✅ Exit code capture via `PIPESTATUS` through `tee`
- ✅ Dedup for success **and** fail **and** running (agent decides)
- ✅ `dedup_running` = exit 75; never treat as green
- ✅ Never auto-claim task PASS from queue failure reuse
- ✅ Single `target/` only — refuse custom `CARGO_TARGET_DIR` / `--target-dir` / orphan `target-*` (T10)
- ✅ Size-gated clean on canonical `target/` only; post-run gate after non-clean cargo
- ✅ `--force` / `CARGO_QUEUE_FORCE=1` always enqueues
- ✅ Envelope + ledger on terminal paths
- ✅ Prefer false negatives over wrong hits
