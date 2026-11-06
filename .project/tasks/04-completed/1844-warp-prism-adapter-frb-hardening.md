# Task 1844: Harden the FRB adapter surface (native wiring, registry cleanup, error taxonomy)

> **Priority**: 🟠 High (architecture + resource lifecycle)
> **Type**: `bugfix` | `architecture` | `flutter` | `rust`
> **Origin**: adversarial research scout review, 2026-09-29 (findings WP-003, WP-004, WP-011, WP-012, WP-016, WP-017, WP-018, WP-008)
> **Depends on**: nothing — the affected files are disjoint from Tasks 1839/1840
> **Writeset**: `packages/warp_prism_adapter_frb/lib/**`, `packages/warp_prism_adapter_frb/test/**`
> **Blocks**: promotion of any EXPERIMENTAL adapter claim in `docs/bridge/README.md`

## Objective

Make the FRB adapter surface honest, leak-free, and observable, so the
`warp_prism_adapter_frb` package can be promoted from EXPERIMENTAL to a
contract-tested adapter boundary.

## Verified findings (independently reproduced 2026-09-29)

### WP-003 — `FrbEventStream` does not use the native stream
`packages/warp_prism_adapter_frb/lib/src/frb_event_stream.dart:44-46`.
The default constructor only allocates a local
`StreamController<RuntimeEvent<String>>.broadcast()`. The native source
`frb_api.streamEvents(...)` is reached only if a caller manually invokes
`pipeFromNativeStream` (line 162). The class docstring claims an
"FRB native-backed implementation", which is false for the default
construction path.

Required: either (a) wire the native source at construction and rename the
local-only path explicitly, or (b) correct the class contract and document
the two distinct modes. Option (a) is preferred only if a real native stream
can be produced headlessly; otherwise (b) plus an explicit
`FrbLocalEventStream` / `FrbNativeEventStream` split.

### WP-004 — command registry cleanup is not guaranteed
`rust/warp_bridge_frb/src/api.rs:86` calls `COMMAND_REGISTRY.unregister(&req.id)`
after the await, but the `unwrap_or_else` join-error path at line 83 returns
early. A panic inside the blocking task therefore leaves the entry registered.
Dart side (`frb_async_command.dart`) has no compensating cleanup either.

Required: unregister on every exit path, including the error path, and prove it
with a test that asserts registry size returns to zero after a failing command.

### WP-011 — transport vs execution errors are not distinguished
`frb_async_command.dart` maps a native failure into `CommandFailure` with the
raw error message. A transport-level failure (bridge down, uninitialised) is
indistinguishable from a domain rejection. Required: a distinct transport
failure representation, or documented justification for collapsing them.

### WP-012 — `pipeFromNativeStream` leaks its subscription
`frb_event_stream.dart:162-171` returns a `StreamSubscription` that the
instance never retains, so `close()` (line 154) cannot cancel it. Required:
retain the subscription and cancel it from `close()`.

### WP-016 / WP-017 — mutation coverage gaps
No tests exist for `FrbHealthSource` mutation methods; `FrbGraphSource`
mutation methods return a snapshot that is not asserted for freshness. These
are the adapter surfaces most likely to ship a stale-read bug.

### WP-018 — no backpressure on the native pipe
The `pipeFromNativeStream` path bypasses `backpressurePolicy` entirely; only
the local `emit` path honours the policy.

### WP-008 — no integration test with real native code
There is no test that exercises the FRB boundary against a real native
library. Everything currently compiles but nothing is proven end-to-end.

## Where

- `packages/warp_prism_adapter_frb/lib/src/frb_event_stream.dart` — modify
- `packages/warp_prism_adapter_frb/lib/src/frb_async_command.dart` — modify
- `packages/warp_prism_adapter_frb/lib/src/frb_health_source.dart` — modify (tests)
- `packages/warp_prism_adapter_frb/lib/src/frb_graph_source.dart` — modify (tests)
- `rust/warp_bridge_frb/src/api.rs` — modify (registry cleanup only; the
  timestamp and mutex fixes from this cycle are already landed and must not
  be reverted)
- `packages/warp_prism_adapter_frb/test/**` — create

## Validation

```bash
cd packages/warp_prism_adapter_frb && dart analyze && flutter test --no-pub
cd rust && cargo test --workspace
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
```

## Non-Goals

- No change to `warp_prism_ui`, `warp_prism_runtime`, or `warp_prism_bindings`.
- No FRB version change; FRB remains a replaceable transport.
- No golden refresh.
- Do NOT revert the `now_millis()` clock helper or the poison-recovering locks
  landed in this cycle.

## Completion Evidence

- files changed
- per-finding disposition (fixed / deferred with reason)
- exact command exits
- local changelog entry
- independent review verdict

## Lane History

- **2026-09-29 (claim)**: moved to `01-open`, dispatched to builder session
  `ses_f173c15faffe7Ui6KQmQZfFA1Q` (the Task 1841 engineer — already owns the
  `warp_prism_adapter_frb` package and its doc-comment surface). Disjoint from
  Task 1842 (host_exercise + apps host_exercise tests) and Task 1843
  (`warp_prism_ui/test/gallery`).

## Already landed in this cycle — DO NOT REVERT

Two sibling fixes landed before this task was created and are part of the
accepted state:

- `warp_bridge_core::now_millis()` real wall-clock helper; all 5 production
  magic-timestamp sites replaced.
- All 16 `Mutex::lock().unwrap()` replaced with poison-recovering
  `unwrap_or_else(|e| e.into_inner())`.

`cargo test --workspace` is currently 13/13 core + 7/7 FRB. Your changes must
keep it green.

## Builder completion + orchestrator verification (2026-09-30)

- `warp_prism_adapter_frb`: `dart analyze` → No issues found; `flutter test
  --no-pub` → **+126 All tests passed**.
- `cargo test --workspace` → **13 passed (core) + 9 passed (frb)**, 0 failed.
  The frb crate gained 2 tests over the pre-task 7.
- WP-004 registry cleanup confirmed landed: `COMMAND_REGISTRY.unregister` moved
  onto a guaranteed path (`api.rs:80`).
- New `test/frb_hardening_test.dart` covers WP-003, WP-012, WP-017, and the
  health/graph mutation gaps (WP-016).
- Boundary harness: 15/15 PASS.

### Known instability — recorded, not hidden

The live-native FFI integration path is **intermittently flaky**: 9 consecutive
`flutter test` runs on this package produced 8 green and **1 failure** in
`test/integration/frb_parity_lab_test.dart` ("FrbGraphSource … incremental node
updates emit structured events on watchUpdates"), accompanied by
`Shell: Fail to post message to Dart` from the native isolate. This is the
WP-008 surface: the only test that exercises the real native library. It is a
genuine unresolved flake, not a one-off. A repeat-stable gate for this package
must either quiesce the native isolate or mark the live-native suite as
separately gated from the deterministic suite.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS scoped 86/100; adapter 154 + Rust 23+14 + 9/9 native trials; boundary precondition satisfied by reviewer-executed 81/81 runs on current tree; F1-F7 recorded as separate unowned deltas, not acceptance (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1844-warp-prism-adapter-frb-hardening-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
