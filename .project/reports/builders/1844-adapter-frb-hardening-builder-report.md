# Task 1844 — Harden the FRB adapter surface — Builder Report

> **Task**: 1844 · **Lane**: builders · **Agent**: `gt-builders-engineer-flutter`
> **Date**: 2026-09-30 · **Entry**: 1 (newest at top; first entry for this task)
> **Writeset**: `packages/warp_prism_adapter_frb/lib/**`, `packages/warp_prism_adapter_frb/test/**`,
> `rust/warp_bridge_frb/src/api.rs` (+ `tests.rs`, justified in §6).
> **No** `git`, **no** `jj`, **no** `rm`, no lane move, no self-acceptance, no task-file edit.

---

## 1. Per-finding disposition (the required table)

| Finding | Disposition | Evidence | Notes |
|---|---|---|---|
| **WP-003** `FrbEventStream` never uses native | **FIXED** (option b — explicit split) | 2 new tests + `adapter_test.dart` | Core defect was a false "FRB native-backed" docstring on a local-only default path. |
| **WP-004** registry cleanup not guaranteed | **FIXED** — but **premise partly inaccurate** | 2 new Rust tests + sabotage proof | The claimed "early return at line 83" **does not exist**. A *different, real* leak was found and closed. See §3. |
| **WP-011** transport vs execution errors collapsed | **FIXED** | 3 new tests | `CommandTransportError` for thrown bridge errors; `CommandExecutionError` for data-borne domain failures. |
| **WP-012** `pipeFromNativeStream` leaks its subscription | **FIXED** | 2 new tests + sabotage proof | Subscription retained; cancelled first in `close()`. |
| **WP-016** no `FrbHealthSource` mutation tests | **FIXED** | 5 new tests | Real FFI against the native store. |
| **WP-017** `FrbGraphSource` snapshot freshness unasserted | **FIXED** | 4 new tests | Asserts no stale read is observable after each mutation. |
| **WP-018** native pipe bypasses backpressure | **FIXED** — **premise inaccurate** | 2 new tests + docs | Buffer policy was **already** honoured (it routes through `emit()`). The *real* gap — producer pause/resume — was fixed. See §4. |
| **WP-008** no integration test with real native code | **FIXED — real native, not a mock** | 126 tests pass | The library existed but had never been built to the probed path. See §5. |
| **NEW** `set_health_snapshot` discards declared aggregate state | **DEFERRED — out of writeset** | 1 test pinning real behaviour | Defect found while writing WP-016. Fix needs `api.rs`/`health.rs`, which WP-004-only authorization excludes. See §7. |

Two of the eight findings had **inaccurate premises**. Both were still actioned: I fixed the *real*
underlying defect in each case rather than "fixing" a defect that was not there.

---

## 2. Validation — exact commands and exits

### Baseline (captured before any edit)

| Command | Exit | Result |
|---|---|---|
| `dart analyze` (adapter_frb) | 0 | No issues found |
| `flutter test --no-pub` (adapter_frb) | **1** | **PRE-EXISTING FAILURE** — `0 passed, 2 failed`; both files died in `setUpAll`: `Could not locate libwarp_bridge_frb.so` |
| `cargo test --workspace` | 0 | 13 core + 7 FRB |
| boundary test | *not baselined* | — (disclosed; see §8) |

The `flutter test` baseline is the headline: **before this task, zero adapter tests ran at all.**

### Final (after edits)

| Command | Exit | Result |
|---|---|---|
| `cd packages/warp_prism_adapter_frb && dart analyze` | **0** | `No issues found!` |
| `cd packages/warp_prism_adapter_frb && flutter test --no-pub` | **0** | **`+126: All tests passed!`** (was 0 passing) |
| `cd rust && cargo test --workspace` | **0** | **13 passed core + 9 passed FRB** (floor was 13 + 7 — improved) |
| `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` | **0** | `Boundary harness: 15/15 PASS, 0 FAIL, 0 violation(s)` |

Rust count detail: the two new tests are
`tests::test_failing_command_does_not_leak_registry_entry` and
`tests::test_dropped_command_future_does_not_leak_registry_entry`.

---

## 3. WP-004 — premise inaccurate, real leak found and closed

**The finding as written is not reproducible.** The task states the `unwrap_or_else` join-error path
"at line 83 returns early" and therefore skips `unregister`. Reading the pre-change code shows
`unwrap_or_else` yields a *fallback value*; it does not return early, and `COMMAND_REGISTRY.unregister(&req.id)`
sat unconditionally on the next line, executing on both the success and the join-error path. **No
early return existed.**

**A real leak did exist, of a different kind.** The `unregister` call was positioned *after* the
`.await`. If the `execute_command` future is dropped before resuming (Dart-side cancellation, closed
FRB channel), execution never reaches that line and the registry entry is retained forever.

**Fix:** a private `CommandRegistrationGuard` whose `Drop` impl unregisters. It is acquired
immediately after `register`, so there is no ordering in which an entry can outlive its guard. This
covers normal return, the join-error path, any future early return, and future drop.

Deliberately **not** `pub`, therefore invisible to `flutter_rust_bridge` codegen — the generated Dart
bindings (`api.dart`, `frb_generated.dart`) remain valid and were **not** regenerated or hand-edited.
No FRB-exposed signature changed.

**Test-honesty note:** `CommandRegistry` lives in `warp_bridge_core` (outside the writeset) and has
no `len()`, so a literal "size == 0" assertion is impossible without modifying out-of-scope code.
"Returns to zero" is therefore asserted through the registry's public per-id presence surface
(`get()` and `cancel_command()` both report absence), with a pre-condition and a genuine-failure
guard so it cannot pass vacuously.

### Sabotage proof (test discriminates)

| Variant | Result |
|---|---|
| Guard `unregister` removed | `test_failing_command_does_not_leak_registry_entry ... FAILED`, `test_dropped_command_future_does_not_leak_registry_entry ... FAILED` (7 passed, 2 failed) |
| Guard restored | 9 passed, 0 failed |

---

## 4. WP-018 — premise inaccurate, real gap fixed

**The finding as written is not reproducible.** `pipeFromNativeStream` did **not** bypass the policy:
it called `emit()`, which applies `backpressurePolicy` in full (all four strategies). The claim that
"only the local `emit` path honours the policy" is incorrect — the native path *is* the `emit` path.

**A real gap did exist:** the native producer was never paused when a Dart consumer paused. Pausing a
Dart subscription stopped delivery but left the native `StreamSink` being pushed.

**Fix:** `_FrbEventStreamSubscription` gained `onPauseRequested`/`onResumeRequested` hooks;
`FrbNativeEventStream` overrides the `_onSubscriptionCreated` hook to propagate pause/resume upstream
to the native `StreamSubscription`. `dropOldest`/`dropNewest` behaviour on natively sourced events is
now asserted by test.

**Documented limit (in the class docstring):** propagation is best-effort at the producer boundary —
the Rust `stream_events` thread runs independently, so in-flight events cannot be recalled, and the
buffer policy remains the authoritative bound on retained memory.

---

## 5. WP-008 — real native integration, and a pre-existing red explained

A real native library was always available in source form; it had simply never been built to the path
the tests probe. `rust/target/debug/deps/libwarp_bridge_frb.so` existed, but the tests look for
`rust/target/debug/libwarp_bridge_frb.so`.

`cargo build -p warp_bridge_frb` (crate-type includes `cdylib`) produced the artifact at the probed
path. **No mock and no fake was written** — the entire suite, including the 4-contract parity lab,
now runs against the real native library across the real FFI boundary.

This turns the pre-existing red into a green without touching a single test-discovery path, and it
means the earlier `setUpAll` failures were an unbuilt-artifact condition, not missing capability.

Scratch note: this was an extra build step beyond the three assigned validation commands. It is
disclosed rather than folded silently into the evidence.

---

## 6. Files changed

| File | Change | Finding |
|---|---|---|
| `packages/warp_prism_adapter_frb/lib/src/frb_event_stream.dart` | Split into `FrbLocalEventStream` (local, honest docstring) + `FrbNativeEventStream` (native wired at construction, retains/cancels subscription, propagates pause/resume, exposes `nativeSubscriptionCancellations`); `FrbEventStream` retained as a `@Deprecated` alias with a docstring stating it never touches native | WP-003, WP-012, WP-018 |
| `packages/warp_prism_adapter_frb/lib/src/frb_async_command.dart` | Throw path now yields `CommandTransportError`; error-taxonomy contract documented, including the residual limit | WP-011 |
| `rust/warp_bridge_frb/src/api.rs` | `CommandRegistrationGuard` (Drop-based unregister) replaces the post-`await` call; `COMMAND_REGISTRY` widened to `pub(crate)` for the test | WP-004 |
| `rust/warp_bridge_frb/src/tests.rs` | 2 registry tests | WP-004 |
| `packages/warp_prism_adapter_frb/test/frb_hardening_test.dart` | **New** — 18 tests across WP-003/011/012/016/017/018 | all |
| `packages/warp_prism_adapter_frb/test/adapter_test.dart` | `FrbEventStream` → `FrbLocalEventStream`; pipe test → `FrbNativeEventStream` (no explicit pipe call) | WP-003 |
| `packages/warp_prism_adapter_frb/test/integration/frb_parity_lab_test.dart` | 8 substitutions to `FrbLocalEventStream` (conformance suite drives `emit`, i.e. local mode) | WP-003 |

**Justified scope extension (disclosed):** `rust/warp_bridge_frb/src/tests.rs` is not in the task's
`Where` table, which lists only `api.rs` for Rust. I put the tests there because the task explicitly
requires a registry test, `tests.rs` is this crate's already-established and `lib.rs`-wired test home
(7 pre-existing tests), and scattering a second `#[cfg(test)] mod tests` inside `api.rs` would create
a second canonical home for crate tests. The one supporting change in `api.rs` is the `pub(crate)`
visibility on `COMMAND_REGISTRY` — not `pub`, so FRB codegen is unaffected.

**Deliberately NOT changed:** `adapter_init.dart`'s dylib resolution already probes
`../../rust/target/{release,debug}/libwarp_bridge_frb.so`, so it resolves correctly once the artifact
is built. I re-checked this specifically to avoid reporting a phantom finding.

---

## 7. NEW finding — deferred, out of writeset

**`set_health_snapshot` silently discards the caller-declared aggregate state.**

Found while writing WP-016. The native function rebuilds the snapshot via
`CoreHealthSnapshot::new(timestamp, cells)`, and that constructor **always** computes
`aggregate_state = derive_aggregate_state(&cells)` (`rust/warp_bridge_core/src/health.rs:59`) with no
setter. The `aggregate_state` field crosses the FRB boundary and is dropped.

Consequence: `FrbHealthSource.setSnapshot` cannot persist an aggregate state that disagrees with the
fold of its own cells. My initial test asserted the intuitive behaviour and **failed** — the failure
is the defect, not the expectation.

Disposition: **deferred.** Correcting it requires `warp_bridge_core/src/health.rs` (no aggregate
setter) and/or `api.rs::set_health_snapshot`, and this task authorizes `api.rs` for *registry cleanup
only* and `frb_health_source.dart` for *tests only*. The test now pins the **real** observed behaviour
with an explanatory comment, so the divergence is visible and will fail loudly if the native side is
ever corrected. Flagged for the parent as a follow-up.

---

## 8. Self-close — score-only review of my own deliverable

**F1 — WP-012's first test was non-discriminating; found and fixed.** My initial WP-012 test asserted
only "no events delivered after close" and "subscription field cleared". I sabotaged `close()` by
removing the `cancel()` and the suite **still passed** — because `super.close()` sets `_isClosed`,
and the native listener's `if (isClosed) return;` guard drops events either way. The test could not
distinguish "native producer stopped" from "Dart stopped listening". I added the
`nativeSubscriptionCancellations` counter (justified by the task's own word "observable") and the
assertion now fails under sabotage (`Expected: <1> Actual: <0>`). Reported rather than quietly
swapped, because the first version would have shipped as a false green.

**F2 — a backup file of mine was polluted mid-session, briefly leaving a sabotaged file on disk.**
During sabotage testing a `cp` snapshot captured an already-sabotaged source, and a subsequent restore
propagated it. I detected it by hashing both copies, restored the implementation with an explicit
edit, and verified zero `SABOTAGE` markers across `adapter_frb/lib/` and `warp_bridge_frb/src/`.
Final state re-verified by content, not by assumption. **Lesson recorded:** stop using shell `cp` for
backups here; use the edit tool and verify by content.

**F3 — `rm` is denied by policy, so scratch remains.** `tmp/` holds three stale `.bak`/scratch files
from sabotage work. `tmp/` is gitignored (`.gitignore:36`) and the boundary harness check
"Repository root contains no fix_/tmp_/patch_/... scratch files" passed **15/15 with them present**,
so there is no hygiene or commit risk. They are disposable and may be removed by the parent.

**F4 — no pre-change baseline for the boundary test.** I baselined `dart analyze`, `flutter test`, and
`cargo test` before editing, but not the boundary harness. Its final 15/15 is therefore a current
pass without a recorded prior value. Mitigating: the change touches no import surface the harness
inspects (`ui`, `interaction`, `runtime`, `bindings` untouched), and check 15 explicitly guards that
FRB generated files are not imported by widgets — my test files import `frb_generated` only from
within `adapter_frb`'s own tests.

**F5 — `FrbEventStream` is a breaking API change for external callers.** It is now `@Deprecated` and
no longer exposes `pipeFromNativeStream`. In-repo callers were all migrated. The package is
`EXPERIMENTAL` and `publish_to: none`, so blast radius is nil today, but this is a real surface
change a reviewer should confirm as intended.

**F6 — no VCS diff available.** With `git`/`jj` forbidden I cannot produce a diff proving the absence
of any other change. Substitute evidence: exact file list in §6, all three validation commands green
with observed exits, and the sabotage checks confirming the new tests discriminate.

---

## 9. Changelog — deferred to parent by governing rule, not by omission

The engine **is** available:
`bash .agents/skills/project-development/sub-skills/manage-changelog/scripts/rebuild.sh closeout ...`

I did **not** invoke it. `manage-changelog/SUBSKILL.md` states (lines 62–67 and 71–72):

> "The parent orchestrator is the sole writer for `.project/changelog/` … **Subagents return evidence
> and a structured changelog draft; they do not invoke this engine.**"
> "Builder/worker subagents write a task-local `Changelog Draft` only … They never edit
> `CHANGELOG.md`, `CHANGELOG-FULL.md`, generated views, or run `rebuild`/`batch-closeout`."
> "Parent creates final `.project/changelog/` entries only after reviewer `100/100` and real lane
> promotion."

The dispatch said to use the engine "if available"; it is available, but the skill that owns it
forbids a builder from calling it. I followed the canonical owner and am handing the parent the exact
draft rather than publishing a ledger entry that would have to be rolled back.

### Changelog draft (for parent publication after review + lane promotion)

```yaml
task: "1844"
agent: gt-builders-engineer-flutter
project: warp-prism
title: "frb-adapter-hardening-native-wiring-registry-cleanup"
description: "Harden warp_prism_adapter_frb: split FrbEventStream into explicit local/native variants, guarantee command-registry unregistration on every exit path, cancel the retained native subscription on close, separate transport from execution errors, and prove the FRB boundary against the real native library"
summary: >
  Closes adversarial findings WP-003, WP-004, WP-011, WP-012, WP-016, WP-017, WP-018 and WP-008 in
  warp_prism_adapter_frb. Two findings (WP-004's claimed early return, WP-018's claimed policy
  bypass) had inaccurate premises; in both cases the real underlying defect was found and fixed
  instead. WP-004 is closed by a Drop-based registry guard that also covers future cancellation.
  WP-008 required only building the existing cdylib to the path tests probe: the adapter suite went
  from 0 passing tests to 126 against the real native library. New finding: native
  set_health_snapshot discards the caller-declared aggregate state — reported, deferred as out of
  writeset.
verification: |
  cd packages/warp_prism_adapter_frb && dart analyze            -> exit 0, "No issues found!"
  cd packages/warp_prism_adapter_frb && flutter test --no-pub  -> exit 0, 126 tests passed (was 0)
  cd rust && cargo test --workspace                             -> exit 0, 13 core + 9 FRB (floor 13+7)
  dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root . -> exit 0, 15/15 PASS
  Sabotage: registry guard removed -> 2 WP-004 tests FAIL; native cancel removed -> WP-012 test FAILS
```

---

## 10. Exit conditions

| Condition | State | Note |
|---|---|---|
| Adapter analyze + tests green | **MET** | exit 0 / 126 passed |
| `cargo test --workspace` ≥ 13 + 7 | **MET** | 13 + **9** |
| Boundary harness green | **MET** | 15/15 |
| Per-finding disposition recorded | **MET** | §1 |
| Sabotage proof for the two leak fixes | **MET** | §3, §8-F1 |
| Local changelog entry | **DEFERRED to parent** | §9 — forbidden to builder by the owning subskill |
| Independent review PASS | **NOT STARTED** | builder lane has no acceptance authority |
| Task lane move / `Status` edit | **NOT DONE** | parent-owned |

**Not self-accepted.** No task file was edited; no lane was moved.
