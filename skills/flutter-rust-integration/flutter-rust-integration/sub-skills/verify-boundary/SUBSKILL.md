---
name: verify-boundary
parent: flutter-rust-integration
description: |
  Verify Flutter↔Rust claims using the minimum evidence class that can actually observe
  them. Separates static boundaries, Rust semantics, Dart adapters, codegen,
  native crossings, streams, cancellation, cleanup, performance, and real-host proof.
triggers:
  - verify flutter rust bridge
  - prove frb works
  - flutter rust integration test
  - native crossing evidence
  - frb codegen drift
  - bridge cancellation test
metadata:
  owner: flutter-rust-integration
  maturity: candidate
  implementation_kind: full
  inputs:
    - explicit integration claims
    - available test/runtime surfaces
  outputs:
    - claim-to-oracle matrix
    - evidence packet with scope limits
  side_effects:
    - read-only by default
    - tool-execution when authorized to collect evidence
  evidence_required:
    - fresh command/test/runtime outputs for claims under verification
  completion_signal: "Every accepted integration claim has an oracle that can observe that claim, with stronger unproven claims explicitly withheld."
---

# Verify Boundary

Do not ask "did tests pass?" Ask **what did those tests observe?**

## Claim → Oracle Matrix

| Claim | Minimum useful oracle |
|---|---|
| Rust semantic contract behaves correctly | Rust unit/contract/property test |
| Dart adapter mapping behaves correctly | Dart unit/test of adapter |
| forbidden transport imports absent | static boundary validator/source inspection |
| generated surfaces are reproducible | clean regeneration + normalized diff/hash |
| native library can load | real native load in target environment |
| Dart call actually executes Rust | native integration smoke with unmistakable Rust-side observation |
| async return crosses correctly | in-flight async native test |
| Rust→Dart stream works | live multi-event native stream proof |
| structured error maps correctly | induced Rust-side failure crossing boundary |
| cancellation works | in-flight work + request + native stop + terminal state |
| native handle/resource cleans up | lifecycle/resource observation |
| heavy payload path meets target | representative measurement/profile |
| application integration works | real Flutter host composition/runtime evidence |

A stronger claim needs stronger evidence. Lower classes remain useful; they simply do not
authorize stronger conclusions.

## Evidence Scope Labels

When useful, label receipts:

```text
STATIC_BOUNDARY
RUST_SEMANTICS
DART_ADAPTER
CODEGEN_REPRO
NATIVE_LOAD
NATIVE_CALL
NATIVE_ASYNC
NATIVE_STREAM
NATIVE_ERROR
NATIVE_CANCELLATION
RESOURCE_LIFECYCLE
DATA_PLANE_PERF
REAL_HOST
```

These are evidence scopes, not task lifecycle statuses.

## Native Crossing Calibration

A native-crossing test should make it difficult to accidentally pass without Rust.

Useful calibration patterns:

- Rust returns/builds a value impossible for the Dart fake to synthesize unnoticed.
- A Rust-side counter/log/fixture is observed.
- Test fails when native library is unavailable.
- Test fails when the generated/native call is deliberately disconnected.

Avoid tests whose fallback path silently replaces the native operation with a fake/demo
result.

## Honest Blockers

If target toolchain/native host/device is unavailable:

```text
BLOCKED/UNAVAILABLE evidence
!= PASS
```

Preserve lower-class evidence and state the exact unproven claim.

## Scripts

- `scripts/validate_boundary_imports.py` — static import/dependency evidence only.
- `scripts/audit_frb_codegen.py` — generated-tree drift evidence only.
- `scripts/collect_bridge_evidence.py` — command receipt collector; it does not grant acceptance.

Scripts are mechanisms. `code-quality`/review governance interprets evidence.
