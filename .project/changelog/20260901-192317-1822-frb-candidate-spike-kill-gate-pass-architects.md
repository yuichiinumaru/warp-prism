---
date: 20260901-192317
timestamp: 20260901-192317
project: "unspecified"
agent: "architects"
task: "1822"
description: "FRB candidate spike on toolchain rustc 1.95.0/cargo 1.95.0/Flutter 3.44.1/Dart 3.12.1 (Linux x86_64): flutter_rust_bridge 2.13.0 + codegen 2.13.0 via cdylib dynamic loading. Codegen 1.34s; cold release build 8.57s; incremental 0.46s; Dart bridge suite 3/3 PASS (sync add, async echo, reactive stream). KILL-GATE: PASS. Cargo placement ADR RESOLVED -> rust/Cargo.toml (nested workspace) with comparative evidence (Variant A root 8.72s vs Variant B nested 8.64s parity; B wins isolation/cleanliness/codegen symmetry/CI cache). Review: FAIL (ADR lacked comparative evidence) -> remediated with A/B build matrix -> focal re-review PASS."
is_rebuild_safe: true
---

# Task 1822: frb-candidate-spike-kill-gate-pass

## Summary

FRB candidate spike on toolchain rustc 1.95.0/cargo 1.95.0/Flutter 3.44.1/Dart 3.12.1 (Linux x86_64): flutter_rust_bridge 2.13.0 + codegen 2.13.0 via cdylib dynamic loading. Codegen 1.34s; cold release build 8.57s; incremental 0.46s; Dart bridge suite 3/3 PASS (sync add, async echo, reactive stream). KILL-GATE: PASS. Cargo placement ADR RESOLVED -> rust/Cargo.toml (nested workspace) with comparative evidence (Variant A root 8.72s vs Variant B nested 8.64s parity; B wins isolation/cleanliness/codegen symmetry/CI cache). Review: FAIL (ADR lacked comparative evidence) -> remediated with A/B build matrix -> focal re-review PASS.

## Changes

- Documented task completion details.

## Verification

- [x] both placement variants build Finished dev profile; report has measured comparative table; candidate (not adopted) framing retained; repo root clean of Cargo.toml
