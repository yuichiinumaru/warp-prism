# Review loop — Task 1844 `warp-prism-adapter-frb-hardening`

## Entry 1 — Fresh independent mixed Dart/Rust review (reviewer: Implacable Flutter Reviewer)

- **Date (UTC):** 2026-10-16. Worktree `/home/sephiroth/working/ganthritor/warp-prism`, branch `main` @ `4ac3d0d`.
- **Subject binding:** Task `1844-warp-prism-adapter-frb-hardening.md` (lane `03-review`) **plus** the uncommitted worktree deltas that now overlap it. Every reviewed file (adapter lib, both Rust crates, all five test files) is **uncommitted worktree state** — `git status` shows `M` against HEAD for all of them, and the two F1–F7 test files are untracked (`??`). No historical builder result is applied to changed source: counts, line refs, and claims below are all established fresh against current source in this session.
- **Method:** `sw-code-quality-review-flutter` (Phase 0–6) + `flutter-rust-integration/verify-boundary` (claim→surface→provenance→witness→runtime-composition) + `govern-lifecycle` (creation→cancellation→cleanup→ownership→failure) + `code-quality` verdict/score gates. Single session, no nested workers (Rule 33).
- **Prior entries:** none — this file did not exist; created by this entry.
- **Verdict for Task 1844: PASS (scoped).**
- **Diagnostic score: 86/100** (Good/Elite boundary; diagnostic only — never gates acceptance).
  Deductions, all explicit: boundary gate not executed in this wave per direct
  instruction, source-audited instead (−5); historical integration flake not
  reproduced in 9 fresh runs but root cause not proven absent (−4); `JoinError`
  branch structurally covered but never directly exercised (−2); adapter-F1
  test hedges terminal status with `anyOf` (−2); `count_stream` producer-thread
  teardown relies on sink-error break, effective but implicit (−1).
- **Separately-scoped later-delta findings:** F1–F7 are **not** Task-1844
  acceptance. Each is reported below with its own evidence and owner. No
  Task-1844 verdict is borrowed by them and none borrows from it.

### What was actually verified (fresh evidence, this session)

| Gate | Command (exact) | Result |
|---|---|---|
| Adapter analyzer | `dart analyze` in `packages/warp_prism_adapter_frb` | **No issues found, exit 0** |
| Adapter suite | `flutter test --no-pub --reporter compact` in `packages/warp_prism_adapter_frb` | **+154 All tests passed, exit 0** (5 files; 70 static `test(` blocks expand to 154 via testkit contract suites) |
| Rust workspace | `cargo_queue test --manifest-path rust/Cargo.toml --workspace` (canonical queue; `--manifest-path` needed because the workspace root has no `Cargo.toml`) | **exit 0: 23 passed core + 14 passed frb, 0 failed** (log `20261015-224604-…-3731026.log`) |
| Native dylib freshness | `cargo_queue build --manifest-path rust/Cargo.toml -p warp_bridge_frb` + mtime audit | **exit 0; `rust/target/debug/libwarp_bridge_frb.so` (2026-10-04 19:03:06) is newer than every Rust source** (latest source edit `command.rs` 19:02:10) — the task's "dylib staleness" quarantine is resolved by measurement, and the rebuild was a no-op |
| Integration flake trials | `flutter test --no-pub test/integration/frb_parity_lab_test.dart` ×9, logs in `.archive/tmp/1844-review-current/integration-runs/run-{1..9}.log` | **9 passes / 0 failures / 0 skips, +99 each, exit 0 every run**; the recorded 1/9 historical failure did **not** reproduce |
| Registry-guard sabotage probe (scratch copy only) | scratch workspace `.archive/tmp/1844-review-current/rust-sabotage/` with `CommandRegistrationGuard::drop` neutralised, run via `cargo_queue test --manifest-path …/rust-sabotage/Cargo.toml -p warp_bridge_frb --lib` | **12 passed, 2 failed** — exactly `test_failing_command_does_not_leak_registry_entry` (tests.rs:205) and `test_dropped_command_future_does_not_leak_registry_entry` (tests.rs:253); F4/F5 tests stayed green (log `20261015-230824-…-3750019.log`) |
| Contract-family neighbors (F1/F2 touch them) | `dart analyze` + `flutter test --no-pub` in `warp_prism_runtime`, `warp_prism_testkit`, `warp_prism_bindings` | analyzers clean (exit 0); runtime suite pass; testkit **+70 pass** (incl. F1 overlapping-execution tests vs `FakeAsyncCommand`); bindings **+47 pass** (incl. F2 stale-completion guard tests) |
| Boundary gate (67 checks) | **NOT executed** — explicitly forbidden this wave (another reviewer owns UI/gallery suites; no duplicate execution). **Source-audited instead** (see §Boundary). | gate status honestly reported as not-run; promotion still needs its result from the owning reviewer |

### Task-1844 work-package verdicts (all against current source)

- **WP-001/002 (naming honesty):** PASS. `FrbNativeEventStream` wires
  `frb_api.streamEvents` in its constructor (`frb_event_stream.dart:332-350`);
  `FrbLocalEventStream` contains zero `frb_api` references outside the shared
  top-of-file converter; the deprecated `FrbEventStream` alias (440-444) now
  documents that it never touched native and has no remaining call sites
  (only a group label in `adapter_test.dart:117`).
- **WP-003:** PASS. Pinned by `frb_hardening_test.dart` native-vs-local group
  (green in the 154-run).
- **WP-004 (registry cleanup on all exits):** PASS, with the strongest evidence
  in this review. `execute_command` (`api.rs:119`) registers (`api.rs:114`),
  refuses duplicates **before** guard construction (`api.rs:129-137`, no leak
  possible on that path), installs `CommandRegistrationGuard` (`api.rs:144`)
  whose `Drop` calls identity-checked `unregister_if` (`api.rs:80-87`); the
  `JoinError` early return (`api.rs:162-177`) drops the guard on the way out.
  Both Rust leak tests observe absence via `get().is_none()` +
  `cancel_command() == false`, and the sabotage probe proves they fail iff the
  guard is removed. Limitation (not a failure): no command type panics, so the
  `JoinError` branch is covered by construction, not by an induced panic.
- **WP-005/006/010 (health/watch/dispose):** PASS by source (`frb_health_source.dart:19-36`
  lazy `_ensureNativeStream`, `close()` 165-174 cancels `_watchSub` and closes
  the controller) + green tests. Same close discipline in `frb_graph_source.dart:20-35,213-222`.
- **WP-007 (count_stream effectiveness):** PASS with a source-reality
  correction: the task's `api.rs:186-208` Timer citation is stale. Current
  `count_stream` (`api.rs:31-40`) is a bounded `std::thread` loop that breaks
  on sink error — no Timer, no detached-async-after-drop hazard exists.
- **WP-008/009 (dylib probe + init):** PASS. Four-candidate probe in every
  test `setUpAll` plus `WarpBridge.init` default resolution; the loaded binary
  is proven fresh (see freshness gate).
- **WP-011 (execution vs transport taxonomy):** PASS. `error_kind: Option<String>`
  on `FrbCommandResult` (`api.rs:110`); duplicate→`"duplicate"`, join
  failure→`"transport"`, domain/validation rejections preserve their native
  kind (`api.rs:183-195`); the Dart adapter branches on
  `nativeRes.errorKind` (`frb_async_command.dart:178-207`), never on message
  text. Pinned by WP-011/F5 tests, all green.
- **WP-012 (close cancels retained native subscription):** PASS.
  `FrbNativeEventStream.close()` (`frb_event_stream.dart:409-422`) cancels the
  retained subscription first (resuming first if paused so cancel cannot hang),
  counts genuine cancellations, nulls the handle, sets `_upstreamClosed`, and
  is idempotent. The `nativeSubscriptionCancellations == 1` assertion
  discriminates genuine cancellation from orphaning by construction (a removed
  fix leaves the counter at 0). Base-class `close()` (238-255) resumes paused
  handles before closing the broadcast controller so close cannot hang.
- **WP-013/014/015 (graph/health close + error/close propagation):** PASS by
  source + green adapter tests.
- **WP-016/017 (health/graph mutations):** PASS. All six Dart mutation methods
  await the native call then refresh `_cachedSnapshot` from the returned
  snapshot; `setSnapshot`'s aggregate-derivation divergence is pinned (not
  hidden) by the `frb_hardening_test.dart:369-425` test per the file-header NEW
  FINDING, which remains **outside** this task's writeset and is carried as a
  residual note, not a silent fix.
- **WP-018 (backpressure on the native pipe):** PASS. Native events are
  funnelled through `emit` (`frb_event_stream.dart:341-343`), so the policy
  bounds retention and delivery on the same path; pinned by dropOldest/dropNewest
  native tests, green.
- **Invariants:** `now_millis()` preserved (`lib.rs:15`; used at
  `command.rs:315,509,519,523`, `api.rs:130,170,283,381,812`); **every**
  production mutex site uses poison-recovering
  `.lock().unwrap_or_else(|e| e.into_inner())` (`command.rs:253,267,281,291,303,308`;
  `api.rs:389,413,439,448,811,825,837,854,872,884,901,919`) — verified by grep,
  not by historical count. Remaining `.unwrap()`/`.expect()` sites are confined
  to `#[cfg(test)]` modules (behind `command.rs:362`) and FRB-generated code.

### Separately-scoped later-delta findings (NOT Task-1844 acceptance)

No task file owns F1–F7 in any lane (checked `00-planning/`, `01-open/`,
`02-doing/`, `03-review/`). Each delta is judged on its own current-source
evidence; none is required for the 1844 verdict above.

- **F4 (identity uniqueness + duplicate rejection):** Verified working.
  `CommandIdGenerator` is monotonic-per-generator with isolate tag
  (`frb_async_command.dart:30-60`); registry `register` rejects duplicates and
  the duplicate path returns `error_kind: "duplicate"` with
  `is_cancelled: false`. Dart F4 tests (incl. a real in-flight occupier +
  collider through the native registry) green. Note: the "registry rejects
  duplicate and leaves incumbent intact" proof lives in Dart
  (`frb_async_command_hardening_test.dart:110-157`) while the Rust side pins
  rejection at `tests.rs:320+`; both green.
- **F3 (requested ≠ observed cancellation):** Verified working. Terminal state
  derives **only** from `nativeRes.isCancelled` (`frb_async_command.dart:198`);
  the local token only routes cancellation *into* native. The late-cancel test
  (`frb_async_command_hardening_test.dart:164-204`) would fail under the old
  `||` logic by construction; pre-cancel short-circuit and listener-detach
  tests green.
- **F5 (panic/join ≠ cancelled; taxonomy without heuristics):** Verified
  working, with one scope note: unlike the original 1844 wave ("no
  FRB-exposed signature changed"), this delta **did change the generated
  surface** — `errorKind` is present in regenerated `lib/src/rust/api.dart:132`
  and `frb_generated.dart:990,1345-1352` (Oct 4). Blast-radius inventory:
  **no other package or app constructs or matches on `FrbCommandResult` /
  `errorKind`** (repo-wide grep finds only the unrelated
  `ds_command_palette.dart` `_executeCommand`), so the signature change is
  contained to the adapter. The `single Source of Truth` doc
  (`api.rs:89-96`) is accurate as of this review.
- **F1 (single-flight cancel-and-replace in the adapter):** Implemented
  (`_supersede()` + `_authoritativeGeneration`, `frb_async_command.dart:62-112,119-171`)
  and generation-authority is pinned deterministically
  (`authoritativeGeneration == genB`). **Evidence limitation:** the adapter F1
  test asserts the terminal status with `anyOf(succeeded, cancelled)`
  (`frb_async_command_hardening_test.dart:352-355`) and carries an unused
  `aToken` (339, 358-359) kept only for the analyzer — so stale-completion
  exclusion *at the adapter level* is pinned for authority but hedged for
  outcome. The strong form of F1 lives in the testkit suite vs the fake
  (green, +70 run), not against the live adapter.
- **F2 (stale-completion exclusion):** Lives in `warp_prism_bindings`
  (`async_command_binding.dart:21-28,50-74`, `_authoritativeGeneration`) and
  the runtime contract (`async_command_contract.dart:12-56`, SINGLE-FLIGHT /
  CANCEL-AND-REPLACE). The adapter relies on the contract but does not
  implement the binding-side guard. Neighbor suites green (bindings +47 incl.
  four stale-completion permutations). **Ownership note:** the F1/F2 contract
  change spans runtime + testkit + bindings (all modified Oct 4, all
  uncommitted) — it needs its own task/review ownership before it can be
  cited as accepted; this review records it as *observed working*, not as
  *accepted*.
- **F7 (per-subscriber pause without starvation):** Verified working. Model
  (b) is implemented (`_syncUpstreamPauseState`, `frb_event_stream.dart:393-407`)
  and documented (279-307) with all five rules; 11 F7 tests green covering
  one-paused-of-two, all-paused, resume-without-unpausing, cancel-removes-from-count,
  close-exactly-once (incl. close-while-paused and idempotency), policy-bounded
  buffers under pause, and 3-subscriber starvation freedom. Attribution basis
  is current source + these tests; no `1843`-named report exists on disk and
  no "model (b)" text exists anywhere else in the repo, so F7 is attested from
  this review's evidence alone.
- **F8 / `_isTestIsolate` / `_nativePrefix`:** **absent from current source.**
  Repo-wide grep for `_isTestIsolate`, `_nativePrefix`, and all
  TODO/FIXME/XXX/HACK in the adapter lib + `api.rs` + `command.rs` returns
  empty. Whatever that workaround was, it is not present now; nothing is
  claimed for or against it, and no legacy tmp brief was relied upon (the
  packet stands on the evidence above).

### Integration evidence, flake record, and consumer classification

- **Actual-native provenance:** every Dart test in the 154-run and all 9
  integration trials loaded `rust/target/debug/libwarp_bridge_frb.so`, proven
  newer than all Rust sources. This is genuine native-crossing evidence, not
  mock proof — with the standard boundary caveat that Dart tests prove Dart
  mapping + observed native behaviour, not Rust-internal soundness (covered
  separately by the 23+14 cargo tests).
- **`Shell: Fail to post message to Dart`:** deterministic, not random —
  exactly 3 occurrences in each of the 9 runs, located (run-1.log) after the
  health-watch close (3.3), during the live-adapter graph incremental tests
  (4.2), and at 4.3. Signature matches native `watch_*` broadcast loops and
  producer threads outliving their Dart sinks at teardown (health/graph
  `close()` uses fire-and-forget `unawaited(sub?.cancel())`). Benign in all
  observed runs (no test failed), but it is the same channel that carried the
  single historical failure, so the flake mechanism (late native event vs
  closed sink / 10ms non-awaited mutation windows in the testkit graph suite)
  is narrowed, not eliminated.
- **Historical failure not reproduced:** 9/9 green here vs 8/9 with 1 failure
  on record (`FrbGraphSource … incremental node updates emit structured events
  on watchUpdates`). Combined 17/18. No faked proof, no PASS-by-absence
  claimed: the flake stays a residual risk (see below).
- **Real consumers:** `affected_consumers: NONE` in production. Verified:
  only `apps/catalog/lib/connected/connected_bridge_lab_page.dart` (a lab
  proof surface, `FrbGraphSource` only) and the boundary test's own patterns
  reference the adapter; `FrbAsyncCommand`/`FakeAsyncCommand` have no
  non-test construction sites; `AsyncCommandBinding` has no construction site
  at all (consistent with the runtime contract's own claim). No real-host
  composition run was performed (no device/host launch, catalog lab page not
  exercised) — package-local + actual-native-library proof only, which is
  proportionate for an EXPERIMENTAL adapter with no production wiring but is
  stated here as the integration-evidence limit.

### Boundary / layer-direction (source-audited, NOT executed)

`boundary_test.dart` was read, not run. It machine-enforces exactly the
direction this review cares about: no `warp_prism_adapter_frb` /
`flutter_rust_bridge` imports in ui/interaction/runtime (148-150, impl
632-655), no domain types in core packages incl. the adapter (152-154,
657-682), no `src/rust/` / `frb_generated` imports outside the adapter
(684-733, adapter excluded at 715), bindings isolation (735+), runtime
Flutter-purity (136-138). Independent repo-wide greps replicate the material
checks with clean results: no adapter imports outside the adapter package +
catalog app + the boundary test itself; no generated-surface imports outside
the adapter (only the test's own regexes match). **The 67-check execution
itself is deferred to its owning reviewer and remains a promotion
precondition.**

### Residual risks (explicit, uninspected or limited)

1. Boundary-gate execution outstanding (owned elsewhere; source-audit clean).
2. Integration flake narrowed, not eliminated (17/18 combined; mechanism:
   teardown races between native producers and closed sinks + 10ms
   non-awaited windows in the testkit graph suite, which the adapter cannot
   fix from its side).
3. No real-host composition evidence (catalog lab page never launched).
4. `JoinError`/panic path covered by construction + sabotage, never by an
   induced panic (no command type panics today).
5. Adapter-level stale-completion exclusion hedged (`anyOf`) — strong form
   proven only vs the fake.
6. `setSnapshot` aggregate-derivation divergence pinned-but-unfixed (out of
   writeset; carried, not hidden).
7. Windows/web targets uninspected; all native evidence is Linux `x86_64` debug.

### Minimal fix targets

- **Task-1844 scope: none.** No FAIL finding; no remediation performed (review
  session scores and reports only).
- **Delta-scope notes (for whichever task adopts F1–F7, not for 1844):**
  (a) tighten the adapter F1 test's terminal-status assertion or document why
  the hedge is inherent; remove the dead `aToken`; (b) consider a panic-inducing
  test-only command path or document the JoinError branch as
  construction-covered; (c) give F1/F2's runtime+testkit+bindings contract
  change its own task/review home; (d) optionally await native watch
  cancellations in health/graph `close()` to shrink the teardown-race window
  behind the `Shell:` noise.

### Skill, independence, and write-scope attestation

- Skills loaded and applied: `code-quality` (verdict/score gates, lineage),
  `flutter` (analyzer/test/baseline rules; no phantom validation — unavailable
  evidence is reported as such), `flutter-rust-integration` (`verify-boundary`
  five-pressure audit; `govern-lifecycle` seven-checkpoint audit),
  `rust` (P4/P5/P8/P9 — lifecycle explicitness, escape-hatch burden,
  cheapest-capable oracles, evidence-bounded claims).
- Owning narrow methods read: `sw-code-quality-review-flutter`,
  `verify-boundary/SUBSKILL.md`, `govern-lifecycle/SUBSKILL.md,
  `gt-global-subagent-review` (verdict/score/report-path/remediation-target
  handoff followed).
- Independence: fresh session this wave; no prior 1844 review existed to
  anchor on; no product, test, task, changelog, harness, session-ledger, or
  lane edits; no VCS writes; no files created under `tmp/` or system `/tmp`;
  no historical dispatch scripts run; all Rust operations went through
  `cargo_queue` (direct cargo never invoked); UI/gallery suites untouched.
- Write scope honoured: this report file + bounded new scratch
  `.archive/tmp/1844-review-current/` (9 integration logs + `summary.txt` +
  `rust-sabotage/` copy) only.
- Incidental side effects disclosed (not authorship): validation runs churned
  tracked `rust/target/**` cache/fingerprint files (M/D entries) — expected
  compiler-cache fallout, reported for Task-1845 triage, deliberately not
  restored (restoration would itself be a VCS write). No source/test/task
  file was modified by this session.
- Legacy tmp triage: no legacy tmp artifact was relied upon. (Observed but
  unused: `.archive/tmp/1840_fixed_backup.dart`, `rem-0005-*.sh`,
  `1843-review-current/` — none read, none needed.)

### Handoff to parent orchestrator

- **Subject:** Task 1844 + overlapping F1–F7 deltas, worktree `main` @
  `4ac3d0d` with uncommitted deltas; native binary proven fresh (Oct 4 19:03).
- **Verdict:** **PASS (scoped)** for Task 1844 — every work package verified
  with fresh evidence; F1–F7 reported as separate, unowned deltas.
- **Diagnostic score:** **86/100** (deductions itemised above; never gates).
- **Report path:** `.project/reports/reviewers/1844-adapter-frb-hardening-review-loop.md` (this file).
- **Promotion precondition:** boundary-gate execution result from its owning
  reviewer; F1–F7 need their own task/review home before being cited as
  accepted.
