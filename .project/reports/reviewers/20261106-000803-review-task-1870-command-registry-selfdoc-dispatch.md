# Independent review — Task 1870 command registry, self-documentation, and dispatch

> **Reviewed task:** `.project/tasks/02-doing/1870-warp-prism-command-registry-selfdoc-dispatch.md`  
> **Review date:** 2026-11-06 UTC  
> **Verdict:** **AMEND — evidence completion required**  
> **Score:** 83/100

## Scope and basis

This review examined the Task 1870 contract; the IDS command module under `packages/warp_prism_interaction/lib/src/command/`; the runtime seam at `packages/warp_prism_runtime/lib/src/describe/runtime_describe.dart`; the presentation router at `packages/warp_prism_ui/lib/src/molecules/ds_command_router.dart`; palette and tool-strip integration at `packages/warp_prism_ui/lib/src/organisms/command_palette/ds_command_palette.dart` and `packages/warp_prism_ui/lib/src/organisms/tool_strip_slideout/ds_tool_strip_slideout.dart`; focused tests; shared boundary checks; and public export/alias surfaces.

The package implementation meets its substantive design obligations:

- Registry identity, enumeration, applicability, enabled-reason handling, deterministic chord normalization, and collision/precedence behavior are implemented and suite-covered.
- The runtime `describe()` seam returns command leaf information without a presentation dependency.
- `DSCommandRouter` remains presentation-only, protects editable-focus contexts, and has parity coverage for its deliberately duplicated chord normalization. The duplication is justified because a production UI-to-interaction import is prohibited.
- Disabled reasons propagate from IDS applicability into palette and tool-strip presentation.
- The module and router remain internal/EXPERIMENTAL: neither `src/command/command.dart` nor `DSCommandRouter` is publicly barrel-exported or Prism-aliased.
- The registry consumes the Task 1868 authority vocabulary rather than introducing an incompatible availability model.

## Validation observed

| Check | Result |
|---|---|
| `dart format --set-exit-if-changed packages/warp_prism_interaction/lib/src packages/warp_prism_ui/lib/src/organisms/command_palette` | PASS — 32 files checked, 0 changed |
| Task-exact `flutter test packages/warp_prism_interaction/test packages/warp_prism_ui/test/organisms packages/warp_prism_ui/test/boundaries/boundary_test.dart` | PASS — 1,214 passing |
| Root shared boundary run: `dart packages/warp_prism_ui/test/boundaries/boundary_test.dart` | PASS — 81/81 checks, 0 failures, 0 violations |
| Focused analysis of Task 1870 touched implementation paths | PASS — `No issues found!` |
| `flutter analyze packages/warp_prism_interaction packages/warp_prism_ui packages/warp_prism_runtime` | NOT CLEAN — exit 1, 226 issues reported |

The global analyzer result is a pre-existing package baseline rather than a Task 1870 defect: focused touched-path analysis passed, and review found no emitted diagnostics in Task 1870 implementation paths. The exact command nonetheless is not a passing validation gate.

## Required amendment / blocker

The task requires real Warpblade and Command Center host proof: exercise the router on a real route with a chord conflict and a disabled-with-reason command, with the required host interaction evidence. Those consumers are outside this workspace, so the available headless composition sweep does not prove the named-host condition.

No code change is requested. Obtain and record the actual WB and CC exercise evidence when the hosts are accessible, and have the owning baseline policy disposition the non-clean exact analyzer command.

## Cross-task blast-radius assessment — Tasks 1868–1870

The three tasks form a contained trust/dispatch chain with no observed forbidden public-surface expansion:

1. **Authority source (1868 → 1870).** `ActionAvailability` is the single eligibility vocabulary that command applicability consumes. A semantic change to deny/constrain handling or its reason text can change keyboard routing availability and the disabled explanations rendered in both command palette and tool strip. The 1870 registry does not duplicate that model, which reduces divergence risk.
2. **Honest indeterminacy (1869 → downstream consumers).** Unknown/abstained state is intentionally fail-closed. It is not a command-authority result, but consumers that bridge state resolution into command eligibility must not translate unknown into allow, success, enabled, or verified. The current boundary/conformance tests cover the vocabulary within its own layers; no real CC/WB composition can yet demonstrate this property across product adapters.
3. **Containment.** All new experimental seams are kept out of public barrels and aliases. This constrains immediate external API blast radius and permits internal evolution. Existing pre-task public modules remain distinct from new standalone EXPERIMENTAL export policy.
4. **Presentation seam.** UI chord normalization intentionally mirrors interaction behavior because importing IDS into the UI production surface is disallowed. Parity tests mitigate drift, but a future normalization change must update both implementations and retain parity coverage.
5. **Shared boundary health.** The single root boundary run passed 81/81 with zero violations, providing evidence that the combined change set respects layer and dependency laws. It does not substitute for missing product-host exercises.

**Conclusion:** package-level blast radius is controlled and its critical dependency direction is correct. The principal residual is integration uncertainty at the absent CC/WB consumers, not an identified cross-task source defect.

## Review conclusion

**AMEND (83/100).** Registry, self-documentation, router safety, disabled-reason propagation, focused quality checks, and EXPERIMENTAL containment are accepted at package level. Required live CC/WB proof and a clean exact analyzer command are absent; therefore PASS cannot be granted.
