---
date: 20260901-224411
timestamp: 20260901-224411
project: "unspecified"
agent: "architects"
task: "1820"
description: "Created packages/warp_prism_bindings/ (Flutter package, deps ui+interaction+runtime, dev testkit): EventStreamBinding (subscription lifecycle, buffering, pause/resume/clear, deterministic epoch-0 fallback, optional advisory followState hook — zero owned presentation policy), GraphSourceBinding (semantic→renderable projection with layout Offset owned strictly in binding layer via deterministic circle/grid strategies; structural source-scan assertions enforce runtime purity), AsyncCommandBinding (executeWithIntent bridges IDS InputIntent→runtime AsyncCommand; executeWithQueryIntent bridges QueryIntent; cooperative cancellation). 33 tests via warp_prism_testkit fakes. Review: FAIL (isolation test weak; shallow ==; nondeterministic fallback; out-of-scope claim) -> remediation (source-scan assertions; identity semantics; deterministic sentinel; claim removed) -> re-review PASS."
is_rebuild_safe: true
---

# Task 1820: bindings-proof-ids-runtime-convergence

## Summary

Created packages/warp_prism_bindings/ (Flutter package, deps ui+interaction+runtime, dev testkit): EventStreamBinding (subscription lifecycle, buffering, pause/resume/clear, deterministic epoch-0 fallback, optional advisory followState hook — zero owned presentation policy), GraphSourceBinding (semantic→renderable projection with layout Offset owned strictly in binding layer via deterministic circle/grid strategies; structural source-scan assertions enforce runtime purity), AsyncCommandBinding (executeWithIntent bridges IDS InputIntent→runtime AsyncCommand; executeWithQueryIntent bridges QueryIntent; cooperative cancellation). 33 tests via warp_prism_testkit fakes. Review: FAIL (isolation test weak; shallow ==; nondeterministic fallback; out-of-scope claim) -> remediation (source-scan assertions; identity semantics; deterministic sentinel; claim removed) -> re-review PASS.

## Changes

- Documented task completion details.

## Verification

- [x] flutter analyze clean; flutter test 33 pass; boundary 10/10; grep bindings in ui lib = 0; grep domain/FRB in bindings = 0
