# Review loop — Task 1873: Shell-slot router + Draw-derived focus + sidebar section model (F-06)

> **Task**: `02-doing/1873-warp-prism-shell-router-focus-sidebar.md` · **Mode**: BUILDER_CONTEXT (independent bundled review; review-only, no lane move)
> **Reviewer**: Implacable Flutter Reviewer · **Date (UTC)**: 2026-11-06
> **Skills/methods**: `code-quality`, `flutter`, `gt-global-subagent-review.md`, `sw-code-quality-bundled-review.md`, `sw-code-quality-review-flutter.md`
> **Prior entries**: none (initial review in this file).

## Verdict: PASS · Diagnostic score: 88/100 (Elite-band; diagnostic only, does not gate)

## 1. Scope and diff ownership (Task 1873 owns)

| File | Ownership |
|---|---|
| `packages/warp_prism_interaction/lib/src/state_machine/shell_slot_machine.dart` | NEW (IDS machine + `ShellRegion`/`ShellLayout`/`FocusReturnToken`/`ScrollEdge`/`ShellRowGate`/`ReferenceShellCatalog`), 1873-owned |
| `packages/warp_prism_ui/lib/src/organisms/shell_router/ds_shell_router.dart` | NEW, 1873-owned (imports `ds_shell.dart`, `ds_sidebar_sections.dart`, `split_pane` only — no interaction import in `lib/`) |
| `packages/warp_prism_ui/lib/src/organisms/ds_sidebar_sections.dart` | NEW, 1873-owned |
| `packages/warp_prism_interaction/test/shell_slot_machine_test.dart` | NEW, 1873-owned (12/12) |
| `packages/warp_prism_ui/test/organisms/shell_router/{shell_router_test.dart,sidebar_sections_test.dart,cc_multipane_host_test.dart}` | NEW, 1873-owned (12 + 3 in the two re-run suites; 15 total per parent incl. host sweep) |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | ADDITIVE-ONLY: 4 `shell_1873_*` checks; shared cross-task |
| `packages/warp_prism_ui/lib/src/organisms/{ds_shell.dart,ds_sidebar.dart}` | NOT touched (read-only bases) |

No other bundle task writes these paths (parent confirms 1872's in-progress files untouched and vice versa).

## 2. Lifecycle audit (Flutter ΔR) — the highest-risk surface in this bundle, audited line by line

- **Controller disposal — `DSShellRouter` (`ds_shell_router.dart:120-145`)**: `_paneNodes` (`FocusNode`) and `_paneScrollers` (`ScrollController`) maps are disposed elementwise in `dispose()` (lines 137–145), and `didUpdateWidget` (lines 148–161) prunes + disposes entries for panes removed from the layout. Creation is lazy via `putIfAbsent`, single owner. **No leak on unmount or pane removal.**
- **Unmounted async update**: the only deferred work is `WidgetsBinding.instance.addPostFrameCallback` in `_scheduleRestore` (lines 169–193). It guards `if (!mounted) return;` (line 174), re-checks pane presence, null-checks the node, checks `canRequestFocus` before requesting focus, and checks `scroller.hasClients` before `jumpTo`. **Use-after-dispose and unmounted-update are both guarded.**
- **`ShellSlotMachine` (`shell_slot_machine.dart:251-408`)**: pure-Dart, no Flutter lifecycle. Listener list snapshots (`List.of(_listeners)`) before notify (line 273) — no concurrent-modification. `dispose()` (lines 405–408) sets `_isDisposed` and clears listeners; `commitLayout` throws `StateError` after disposal (lines 268–270), `addListener` is a no-op post-dispose. **Deterministic, fail-loud, clean.** Exhaustive edge coverage (`refocus` 5-step fallback incl. empty token; `scrollTo` NaN/negative/unknown-region clamps that never throw) is suite-proven.
- **`DSSidebarSections` (`_DSSidebarSectionsState`)**: holds only a `Set<String>` — no controllers, no subscriptions. `setState` only from a direct tap callback (line 195), synchronous, no `await` gap. **Clean.**
- **Riverpod/`AsyncValue`**: N/A — no providers; focus token arrives as plain data. Honestly N/A.
- **Layer direction**: IDS file imports only `meta` + `action_availability`; ADS router imports only sibling organisms; sidebar-sections imports atoms/theme/tokens + `ds_sidebar`. No domain leakage, no DB/backend, focus mechanics stay ADS while token semantics stay IDS as the task requires. Grep confirms zero `warp_prism_interaction` imports in UI `lib/`. **Clean.**
- **1868 eligibility consumption**: interface projection only (`DSSidebarRowGateData.denied` from IDS `availabilityFor`; denied rows render disabled-with-reason, never hidden). Mapping proof lives in the widget test per task design. Noted without re-reviewing 1868.

## 3. Findings

### Task-specific
- None blocking. Two non-blocking observations:
  1. `_scheduleRestore` fires `onFocusRestored` only when the pane id changes (`_restoredForToken` guard, lines 188–191) — correct dedup, but a product re-requesting the same token after an external focus steal gets no re-fire. Documented behavior choice; STABLE should decide whether a force-restore path is needed.
  2. `DSSidebarSections.didUpdateWidget` (lines 160–168) rebuilds `_collapsed` from `initiallyCollapsed` whenever the sections list identity changes, discarding user toggles on any parent rebuild that passes a new list. Minor UX-state fragility; acceptable for EXPERIMENTAL, worth a keyed-state or toggle-preservation pass before STABLE.

### Cross-cutting
- `boundary_test.dart` additive-only; 4 `shell_1873_*` checks PASS within 81/81. See return-packet blast radius.

## 4. Commands run (exact, with exits/counts)

- Format on full touched tree (incl. `state_machine`) → 0 changed, exit 0.
- `flutter analyze packages/warp_prism_ui packages/warp_prism_interaction` → **0 errors**, exit 0 (sole warning pre-existing, out of scope).
- `flutter test packages/warp_prism_interaction/test/shell_slot_machine_test.dart` → **12/12 pass**.
- `flutter test …/shell_router/shell_router_test.dart …/shell_router/sidebar_sections_test.dart` → **12/12 pass** (fresh re-run; parent-reported 15/15 includes the host sweep file below).
- `flutter test …/shell_router/cc_multipane_host_test.dart` → **3/3 pass** (headless CC multi-pane sweep).
- `dart …/boundaries/boundary_test.dart` → **81/81 PASS** incl. all 4 `shell_1873_*`; exit 0.
- Barrel/alias grep for new symbols → zero matches. **EXPERIMENTAL hold verified.**

## 5. Affected consumers / host proof

- Claimed consumer: CC (only real multi-pane host); WB single-column recorded as negative evidence. Real-display CC/Tempest proof was **substituted with headless sweep** (`cc_multipane_host_test.dart`, 3/3). Per dispatch, package proof suffices for EXPERIMENTAL without demanding out-of-workspace hosts or treating unavailable proof as PASS. Classification: `affected_consumers: [CC multi-pane shell — headless sweep only; real-display exercise deferred]`. Not a verdict blocker at EXPERIMENTAL; the STABLE task must carry the AGENTS §7.1 real-host gate.

## 6. Remediation targets

None — no FAIL/BLOCKED findings.

## 7. Compact ledger suggestion

```markdown
- 2026-11-06 independent bundled review (reviewer, BUILDER_CONTEXT): PASS, diag 88. Evidence: slot-machine 12/12, router+sidebar 12/12, CC headless host 3/3, boundary 81/81 (4 shell_1873_* PASS), analyze 0 errors, disposal/mounted guards verified line-by-line, no barrel/alias exports. Residuals: real-display CC proof deferred to STABLE; toggle-state fragility noted (non-blocking). Report: `.project/reports/reviewers/1873-warp-prism-shell-router-focus-sidebar-review-loop.md`.
```
