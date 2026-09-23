---
name: sk-flutter-rust-prove-vertical-slice
owner: flutter-rust-integration
kind: sequential-calibration
maturity: candidate
---

# Prove a Flutter↔Rust Vertical Slice

Use for a new bridge, major bridge rewrite, or when prior integration evidence is untrustworthy.

## Entry condition

- Flutter and Rust build surfaces exist.
- A minimal semantic contract is chosen.
- Target host/toolchain required for the proof is available, or unavailable dimensions will be reported as blocked.

## Invariant

Each stage must be capable of failing if that stage is disconnected. No fake/demo fallback may convert a native failure into PASS.

## Stage 1 — Static boundary

Prove:
- UI/domain forbidden imports absent;
- Rust semantic core transport dependency absent where contract requires;
- adapter/generated locations match architecture.

## Stage 2 — Reproducible generation

Regenerate/check generated surfaces under current dependency policy.

Prove only:
- generation works;
- generated tree is coherent/no unexpected drift.

## Stage 3 — Native load

Prove target host can load/initialize native integration.

## Stage 4 — Sync call

Use a trivial but unmistakably Rust-produced value.

## Stage 5 — Async call

Start an actual native async operation and prove completion crosses back.

## Stage 6 — Rust→Dart stream

Produce multiple native events and prove ordering/termination claims that matter.

## Stage 7 — Structured failure

Induce a Rust-side semantic failure and prove the Dart adapter receives the intended semantic category.

## Stage 8 — In-flight cancellation

Start work that is observably active.
Request cancellation from the consumer side.
Prove Rust work stops and reaches a terminal state.
Prove cleanup if cleanup is part of the claim.

## Stage 9 — Resource cleanup

If handles/resources exist, prove release/invalidation behavior.

## Stage 10 — Real host

Launch the real Flutter consumer and exercise at least one meaningful end-to-end interaction through the boundary.

## Result classes

```text
PASS            required stages observed successfully
FAIL            product/integration behavior contradicted
BLOCKED         required environment/tool unavailable
PARTIAL         some required stages not executed/proven
```

These describe the workflow result/evidence. They do not independently accept a project task.

## Output

Persist a compact receipt with:
- target host/toolchain;
- FRB/runtime/codegen tuple;
- stages executed;
- exact commands and exit codes;
- evidence artifacts;
- blocked stages;
- reproduction commands.
