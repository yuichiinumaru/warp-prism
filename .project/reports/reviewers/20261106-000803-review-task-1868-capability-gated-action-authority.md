# Independent review — Task 1868 capability-gated action authority

> **Reviewed task:** `.project/tasks/02-doing/1868-warp-prism-capability-gated-action-authority.md`  
> **Review date:** 2026-11-06 UTC  
> **Verdict:** **AMEND — evidence completion required**  
> **Score:** 82/100

## Scope and basis

This independent review examined the Task 1868 contract; the IDS availability authority at `packages/warp_prism_interaction/lib/src/input/action_availability.dart`; the token and gate implementations at `packages/warp_prism_ui/lib/src/tokens/ds_action_authority.dart` and `packages/warp_prism_ui/lib/src/molecules/ds_action_gate.dart`; their focused tests; the boundary harness; and relevant export/alias surfaces.

The implementation is substantively sound at the package level:

- `ActionAvailability` has the intended allow/constrain/deny authority vocabulary and preserves refusal reasons.
- Missing capability resolves fail-closed to a denial with a reason rather than a silent enable.
- `DSActionGate` renders the three outcomes without hiding the denied case, disables unavailable actions, and exposes the refusal through its accessibility/semantic presentation.
- The new surfaces remain EXPERIMENTAL: no public barrel or Prism alias export was found. This is the applicable containment rule; STABLE promotion gates were not imposed.

The task prose calls the molecule `PrismActionGate`, while the landed implementation is named `DSActionGate`. This is a nomenclature discrepancy, not a behavioral or containment defect: the implementation and tests consistently use `DSActionGate`, and it satisfies the stated presentation contract.

## Validation observed

| Check | Result |
|---|---|
| `dart format --set-exit-if-changed packages/warp_prism_interaction/lib packages/warp_prism_ui/lib/src/molecules` | PASS — 0 files changed |
| `flutter test packages/warp_prism_interaction/test packages/warp_prism_ui/test/boundaries/boundary_test.dart` | PASS — 281 passing |
| Root shared boundary run: `dart packages/warp_prism_ui/test/boundaries/boundary_test.dart` | PASS — 81/81 checks, 0 failures, 0 violations |
| Focused analysis of Task 1868 touched implementation paths | PASS — `No issues found!` |
| `flutter analyze packages/warp_prism_interaction packages/warp_prism_ui` | NOT CLEAN — exit 1, 226 issues reported |

The full-package analyzer result is not attributed to the Task 1868 implementation: focused analysis of its touched paths is clean, and the reported package-wide baseline contains pre-existing UI diagnostics. It nevertheless does not satisfy the task's literal full-package “analyze clean” validation command and therefore must be recorded as unavailable gate evidence rather than passed evidence.

## Required amendment / blocker

Task 1868 explicitly requires real-host proof in both Command Center and Warpblade: exercise the gate on the affected route, interact with it, and establish no framework errors with focus and theme intact. Those named consumer hosts are absent from this workspace. Headless/widget composition evidence is valuable package evidence, but it cannot establish the required real-host claim.

Accordingly, no code defect is assigned. The amendment is to obtain and record actual CC and WB host-exercise evidence in an environment containing those hosts, then rerun or otherwise disposition the exact full-package analyzer gate under the owning baseline policy. Until then, the task cannot receive PASS under its stated success conditions.

## Risk and blast-radius notes

`ActionAvailability` is a foundation vocabulary consumed by Task 1870's command applicability path. Its fail-closed behavior and reason propagation are covered by focused tests, reducing package-level regression risk. However, a change to its reason or deny semantics has downstream impact on command palette and tool-strip disabled-reason presentation. The canonical cross-task assessment is recorded in the Task 1870 review report.

## Review conclusion

**AMEND (82/100).** The implementation, focused analysis, formatting, conformance suite, boundary clearance, and EXPERIMENTAL containment are accepted as strong package-level evidence. The required CC/WB real-host proof is unavailable, and the literal full analyzer command is non-clean despite its non-task-owned diagnostics. These are material unmet verification conditions, so PASS is withheld.
