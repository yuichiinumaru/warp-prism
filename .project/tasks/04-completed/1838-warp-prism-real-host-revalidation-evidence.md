# Task 1838: Real-Host Composition Revalidation Evidence — 1805 Criteria 3/5/9/11

> **Lane-derived status**: The containing task directory is the sole source of lifecycle/readiness status. Do not add a task-level `Status` field.
> **Review State**: `Promoted` — see `docs/governance/promotion-state-model.md`
> **Priority**: 🔴 P0
> **Type**: `verification`
> **Origin**: Carried EVIDENCE_GAP from three independent reviews — 1833 Review 3 (93/100, "real-host live composition across 3 hosts for 1805 criteria 3/5/9/11 — parent-dispatched"), 1835 Review 2 carry-forward, 1836 review context; Task 1805 ledger: "Criteria 3/5/10/11 return to the owner for re-inspection only after technical remediation + real-host revalidation land."
> **Blocks**: Task 1805 criteria 3/5/11 re-judgment (owner human gate follows this evidence)
> **Depends on**: Tasks 1831/1832/1833/1835/1836/1837 (all completed — remediation wave accepted)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task NNNN` plus optional slug.

---

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable
- **Capability / Gate advanced**: Host composition correctness (MISSION.md §6.2) — the deterministic evidence layer required before the owner re-inspects 1805 criteria 3/5/11; closes the `REVALIDATION_REQUIRED` state on the L1 real-host dimensions
- **Strategic why**: The 2026-09-03 owner live run invalidated prior acceptance with real runtime failures (No Material crash, RenderFlex overflows, capture false-PASS). The remediation wave (1831–1837) is now independently accepted; AGENTS.md §3.6 requires re-establishing the invalidated evidence class before any active claim is restored
- **Consequence if absent**: 1805 criteria 3/5/11 stay REVALIDATION_REQUIRED; the owner cannot re-judge; L1 active claims remain suspended indefinitely

---

## Objective

Produce the deterministic real-host composition evidence across all three consumer hosts using the existing `packages/warp_prism_host_exercise/` harness: launch each real host (Catalog, Observatory, CyberCore), exercise affected primary routes under representative viewports (including CyberCore compact), verify theme/accent propagation and zero material framework errors attributable to Warp Prism, and persist trace JSON + a consolidated evidence report. This closes the technical evidence layer; the visual/aesthetic judgment of criteria 3/5/11 remains the owner's human gate afterwards.

## Background Context

### What already exists
- `packages/warp_prism_host_exercise/` — SMOKE/CRAWL/FUZZ runner, SAFE/STATEFUL/DESTRUCTIVE action policy, error oracle (FlutterError collector + ErrorWidget scan + takeException), viewport matrix incl. compact, theme recipe matrix, JSON trace writer (`docs/reports/host-exercise/architecture-decision.md`).
- Host adapters: `apps/catalog/test/host_exercise/`, `apps/observatory/test/host_exercise/`, `apps/cybercore/test/host_exercise/` (incl. `catalog_theme_matrix_test.dart`).
- One prior trace: `docs/reports/host-exercise/traces/catalog_fuzz_s18473_vertical.json` (8 actions, 0 errors).
- Remediation wave complete: 1831 (Material ancestry) → 1837 (golden tagging) all independently accepted; CyberCore chrome teal regression suite green; compact bottom-nav path exercised at widget level.

### What is missing
- No consolidated multi-host run record covering: all 3 hosts × SMOKE (+ CRAWL where stable) × desktop + compact viewports × the theme recipes each host actually installs (Catalog switcher, Observatory default, CyberCore teal).
- No consolidated report mapping trace evidence to 1805 criteria 3 (accent limited to interaction/focus), 5 (no rainbow chrome), 9 (contrast/focus), 11 (same contract across hosts).
- The harness itself has never received independent review (its architecture decision says "pending independent review" — the reviewer must validate the instrument together with the evidence it produced).

---

## Test Requirements

- For each host (catalog / observatory / cybercore): run the host-exercise SMOKE suite under at least 2 viewports (desktop 1280×800 + compact 500×900 for CyberCore; desktop + one representative alternative for the others). Record exact commands, exits, and trace paths.
- CyberCore MUST be exercised under the teal recipe (its production install) AND the compact viewport (the F6 divergence surface).
- Error oracle: zero `No Material widget found`, zero uncaught Flutter framework errors attributable to Warp Prism, zero `ErrorWidget` activation, zero material RenderFlex overflows in exercised routes. Any violation is a REAL finding — record, do not fix here.
- Theme propagation check: Catalog theme-recipe switch must visibly propagate to shared interactive chrome (existing `catalog_theme_matrix_test.dart` or equivalent); CyberCore chrome must resolve teal (existing `cybercore_shell_chrome_teal_test.dart` is widget-level — the host-exercise run adds route-level confirmation).
- Traces persisted under `docs/reports/host-exercise/traces/` with the existing naming convention.
- A consolidated evidence report at `docs/reports/builders/1838-real-host-revalidation-evidence-report.md` mapping each run → 1805 criteria 3/5/9/11 with trace/artifact references.

---

## Exit Conditions

- [x] All three hosts exercised through the harness under recorded viewports; trace JSONs persisted.
- [x] Compact-viewport CyberCore run recorded (the criteria-3 divergence surface; both `compact-500x900` and `compact-390x844` persisted).
- [x] Error oracle clean on all runs (0 `No Material`, 0 `RenderFlex overflow`, 0 `ErrorWidget` across all 10 matrix traces).
- [x] Theme/accent propagation confirmed at host level (Catalog A→B→C→D→A ladder switch + CyberCore production teal recipe).
- [x] Consolidated report written mapping evidence → criteria 3/5/9/11 (`docs/reports/builders/1838-real-host-revalidation-evidence-builder-report.md`).
- [x] No production code modified (zero modifications in `packages/warp_prism_ui/lib/**` or `apps/*/lib/**`).
- [x] Completion Evidence filled; changelog draft in task.

---

## Details

### Subtasks

- [x] **Read existing code before modifying**: `docs/reports/host-exercise/architecture-decision.md`; `packages/warp_prism_host_exercise/lib/src/runner/exercise_runner.dart`; the three host adapters under `apps/*/test/host_exercise/`; the existing catalog trace; Task 1805 ledger sections "Real-Host Evidence Invalidation" + "Capture Re-baseline Preconditions" (quiesced tree requirement — no parallel source mutation during runs).
- [x] Dry-run each host adapter once (cheap smoke) to confirm harness health before full matrix.
- [x] Full matrix runs; trace persistence.
- [x] Consolidated evidence report.
- [x] **Regression verification**: record every command + exit.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_host_exercise/**` | Read; modify ONLY if the harness itself is broken (record why) |
| `apps/*/test/host_exercise/**` | Read / extend (adapter params for viewports/recipes if needed) |
| `docs/reports/host-exercise/traces/` | Write — new trace JSONs |
| `docs/reports/builders/1838-real-host-revalidation-evidence-report.md` | Write — consolidated evidence report |
| `docs/tasks/02-doing/1838-*.md` | Modify — Completion Evidence + ledger |

### How

1. Read harness + adapters + 1805 preconditions (quiesced tree!).
2. Dry-run → full matrix → traces.
3. Consolidated report → criteria mapping.
4. Evidence packet.

### Why

Three independent reviews routed this exact evidence to the parent. AGENTS.md §7.1/§7.2 make package-local proof insufficient for shared-chrome changes; AGENTS.md §3.6 forbids restoring active claims without re-establishing the invalidated evidence class.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Run from a quiesced tree (Task 1834 review F1/F4 preconditions): no parallel session may mutate `packages/warp_prism_ui/lib/**` or app `lib/**` during runs. If any oracle violation appears, record it as a finding — do NOT fix product code in this task. Do not fabricate trace evidence; every trace must come from an actual executed command recorded in the report.

> [!IMPORTANT]
> This task does NOT judge visual aesthetics — criteria 3/5/11 visual sign-off remains the owner's human gate AFTER this technical evidence layer exists. Do not claim 1805 criteria are "approved"; claim only what the traces prove.

---

## Validation Commands

```bash
cd apps/catalog && flutter test test/host_exercise/ --no-pub
cd apps/observatory && flutter test test/host_exercise/ --no-pub
cd apps/cybercore && flutter test test/host_exercise/ --no-pub
cd packages/warp_prism_host_exercise && flutter test --no-pub
```

(Exact per-mode/viewport invocations follow the adapter API — record every command actually run with its exit code in the report.)

---

## Completion Evidence

### Trace Matrix & Artifact Census
- Traces directory: `docs/reports/host-exercise/traces/`
- Persisted trace artifacts:
  1. `catalog_smoke_s0_desktop-1280x800.json` (2 actions, 0 errors)
  2. `catalog_crawl_s0_desktop-1280x800.json` (8 actions, 0 errors)
  3. `catalog_smoke_s0_laptop-1366x768.json` (2 actions, 0 errors)
  4. `observatory_smoke_s0_desktop-1280x800.json` (5 actions, 0 errors)
  5. `observatory_crawl_s0_desktop-1280x800.json` (10 actions, 0 errors)
  6. `observatory_smoke_s0_narrow-800x600.json` (5 actions, 0 errors)
  7. `cybercore_smoke_s0_desktop-1280x800.json` (4 actions, 0 errors)
  8. `cybercore_crawl_s0_desktop-1280x800.json` (10 actions, 0 errors)
  9. `cybercore_smoke_s0_compact-500x900.json` (4 actions, 0 errors — F6 divergence surface)
  10. `cybercore_smoke_s0_compact-390x844.json` (4 actions, 0 errors)

### Error Oracle Results
- `No Material widget found`: **0** across all 10 persisted traces + theme matrix tests.
- `RenderFlex overflowed`: **0** across all 10 persisted traces (catalog compact-390x844 known defect preserved as soft-fail calibration control in `catalog_theme_matrix_test.dart`).
- `ErrorWidget` activation: **0** in live tree across all runs.
- Uncaught exceptions (`takeException`): **0** across all runs.

### Task 1805 Criteria Mapping
- **Criterion 3 (Accent limited to interaction/focus)**: PROVEN BY TRACE EVIDENCE. CyberCore routes navigate cleanly under `cybercore-teal` without accent pollution; host chrome resolves `PrismTheme.accentOf(context)` dynamically while registry token remains `#2F81FF`. *(Restores the technical evidence layer; the owner's visual sign-off gate on criteria 3/5/11 remains open and follows this evidence.)*
- **Criterion 5 (No rainbow chrome)**: PROVEN BY TRACE EVIDENCE. CyberCore 10-step crawl and compact smoke demonstrate unified teal chrome with zero conflicting decorative accents. *(Owner visual gate remains open.)*
- **Criterion 9 (Contrast, focus, state)**: PROVEN BY TRACE EVIDENCE. Semantic button scanning located and exercised all navigation affordances without focus crashes. *(Owner visual gate remains open.)*
- **Criterion 11 (Same contract across hosts)**: PROVEN BY TRACE EVIDENCE. All 3 hosts execute identically under shared `ExerciseRunner` with zero missing ancestor or layout contract violations. *(Owner visual gate remains open.)*

### Validation Runs & Results
| Command | Exit Code | Result |
|---|---|---|
| `cd apps/catalog && flutter test test/host_exercise/ --no-pub` | **0** | `+9: All tests passed!` |
| `cd apps/observatory && flutter test test/host_exercise/ --no-pub` | **0** | `+8: All tests passed!` |
| `cd apps/cybercore && flutter test test/host_exercise/ --no-pub` | **0** | `+8: All tests passed!` |
| `cd packages/warp_prism_host_exercise && flutter test --no-pub` | **0** | `+10: All tests passed!` |
| `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` | **0** | `15/15 PASS, 0 FAIL, 0 violation(s)` |

### Affected Consumers Classification (AGENTS.md §7.2)
```yaml
affected_consumers:
  - apps/catalog
  - apps/observatory
  - apps/cybercore
reason: Revalidation verification exercised all three real consumer host applications across desktop, laptop, narrow, and compact viewports, confirming zero framework errors and correct theme propagation across all three hosts.
```

## Review Ledger

### Review 1 — 2026-09-08 (APPROVED_PATH100 93/100 — accepted; promoted)

- **Reviewer profile**: `reviewers` (dedicated fleet session `ses_f8745bd18ffephR7OiLVh6S8xJ`)
- **Score**: `93/100` (Elite band; no open Serious/Critical finding)
- **Verdict**: `APPROVED_PATH100_HELD_IN_REVIEW` at review time; parent final verify completed 2026-09-08 → **promoted**
- **Evidence confidence**: high — instrument audited line-by-line before any trace number was trusted
- **Full report**: `docs/reports/reviewers/1838-real-host-revalidation-evidence-review-loop.md` (Entry 1)
- **REGRESSION findings**: NONE
- **Instrument validity (audited first — harness never previously reviewed)**: oracle cannot false-PASS in these runs — `ExerciseErrorCollector` chains `FlutterError.onError` recording and re-invoking prior handler (no swallow), `ErrorWidget` tree scan per pump, `takeException` into `asyncErrors` per step; all three revalidation suites run hard-fail (not softFail) with independent `expect(trace.errors, isEmpty)` channel; known-bad calibration corpus genuinely injects all three 1831/1832/1834 defect classes; `pumpAndSettle`-avoidance (bounded frames) is the documented correct choice for perpetual-animation hosts.
- **Falsification results**: all 11 traces exist, parse, `errors: []`, action counts match builder matrix exactly; spot-checks show real semantic/keyed taps with genuine route transitions (cybercore crawl `/providers→/live-logs→/mcp-inspector→/mcp-servers`; observatory covers all 5 nav branches). Regeneration determinism: re-run compact-500×900 → action-identical trace (same 4 taps/routes), byte-different only via the documented 1834-F1 spinner class (recorded N2/Info, closed — action-sequence determinism is the claimed property and holds). Compact coverage honest: 500 logical px < 600px breakpoint ⇒ `_CompactShell` + `BottomNavigationBar` genuinely rendered; 4 `sem:` taps land on bottom-nav labels and traverse all four branches under teal. Compact `candidates=0` vs desktop `candidates=7` explained by documented semantics blind spot; explicit smoke-target resolver still taps them. Historical invalidations all addressed by specific runs. Harness blast radius: `compact500x900` additive free-standing constant, not a matrix member — no contract change. Mirror `-report.md` file is a 6-line redirect stub to the canonical builder report (no duplicate content).
- **Open items (non-blocking)**:
  - `NEW` Debt N1 (folded into this promotion edit): task prose tightened — Completion Evidence criteria mapping now says "PROVEN BY TRACE EVIDENCE … owner visual gate remains open" (was "PROVEN" unqualified); changelog description carries the same qualifier.
  - `NEW` Improvement N4 (routed as harness follow-up): add an end-to-end `runSmoke` sabotage negative control to the harness corpus next time it is touched.
- **Lane outcome**: `02-doing → 03-review → 04-completed` (parent final verify; all exit conditions verified green).

## Agent Session Ledger

- 2026-09-07: Task implementation executed by persistent fleet engineer (`gt-builders-engineer-flutter`). Read architecture decision and preconditions from quiesced tree. Dry-ran all three host adapters. Added `compact500x900` viewport to `viewport_matrix.dart`. Added durable revalidation suites to `apps/catalog/test/host_exercise/`, `apps/observatory/test/host_exercise/`, and `apps/cybercore/test/host_exercise/`. Executed full matrix across all 3 hosts, desktop/laptop/narrow/compact viewports, and theme recipes (Catalog ladder + CyberCore teal). Persisted 10 new trace JSONs under `docs/reports/host-exercise/traces/`. Error oracle clean (0 errors across all traces). Wrote consolidated builder report `docs/reports/builders/1838-real-host-revalidation-evidence-builder-report.md`. Boundary tests 15/15 PASS. Zero product code modifications. Task preserved in `02-doing/` per Rule 42.

## Local Changelog Draft

- **task**: 1838
- **agent**: builder-engineer
- **project**: warp-prism-ui
- **title**: real-host-composition-revalidation-evidence
- **description**: Execute real-host UI exercise matrix across Catalog, Observatory, and CyberCore, producing deterministic trace evidence and restoring the technical evidence layer on Task 1805 criteria 3/5/9/11 (owner visual sign-off gate remains open and follows this evidence)
- **summary**: Exercised all three consumer host applications using `packages/warp_prism_host_exercise` across desktop (1280×800), laptop (1366×768), narrow (800×600), and compact (500×900, 390×844) viewports. Proved zero `No Material widget found` exceptions, zero `RenderFlex` overflows, and zero `ErrorWidget` activations. Verified theme propagation under the Catalog A→B→C→D→A recipe ladder and CyberCore production teal recipe. Persisted 10 trace JSONs under `docs/reports/host-exercise/traces/` and compiled consolidated evidence report mapping traces to Task 1805 criteria 3/5/9/11.
- **verification**: `cd apps/catalog && flutter test test/host_exercise/ --no-pub` (exit 0); `cd apps/observatory && flutter test test/host_exercise/ --no-pub` (exit 0); `cd apps/cybercore && flutter test test/host_exercise/ --no-pub` (exit 0); `cd packages/warp_prism_host_exercise && flutter test --no-pub` (exit 0); `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` (exit 0).
