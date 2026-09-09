# Task 1838 — Real-Host Revalidation Evidence — Review Loop (additive)

> Convention: `.projects/sessions/sessions.md` / `AGENTS.md` §16. Newest entry at TOP; still-open findings at top, resolved findings in the bottom `Resolved` section. This is the **first** independent review of Task 1838. The builder additive report is seeded as claim source at the bottom.

---

## Entry 1 — 2026-09-07 — Independent review (instrument + evidence interlocked)

**Reviewer**: `reviewers` (Flutter route, dedicated fleet session `ses_f8745bd18ffephR7OiLVh6S8xJ`; Score-only — no lane authority; no implementation, golden, lane, or protected-file mutation performed).

### Review Lineage

- **Current task**: Task 1838; live path `docs/tasks/02-doing/1838-warp-prism-real-host-revalidation-evidence.md`.
- **Previous reports read / origin context**:
  - `docs/reports/reviewers/1833-theme-role-accent-propagation-review-loop.md` Entry 3 — the EVIDENCE_GAP this task closes (real-host live composition across 3 hosts for 1805 criteria 3/5/9/11, parent-dispatched).
  - `docs/reports/reviewers/1835-material-ancestry-meta-test-review-loop.md` Entry 2 — same carry-forward note.
  - `docs/reports/host-exercise/architecture-decision.md` — harness architecture decision (Status: "pending independent review" — this entry *is* that review; see Instrument Validity).
  - `docs/reports/review/1831-host-composition-material-contract-independent-review-2026-09-04.md` (Material-ancestry canon), `docs/reports/review/1832-responsive-layout-contract-independent-review-2026-09-04.md` (overflow canon), `docs/reports/review/1834-capture-hero-grid-independent-review-2026-09-04.md` + `1834-observatory-capture-defects-independent-review-2026-09-04.md` (capture false-PASS + spinner byte-instability canon the dispatch flagged).
- **Builder claim source**: `docs/reports/builders/1838-real-host-revalidation-evidence-builder-report.md` (initial consolidated evidence).
- **Review mode**: `initial` independent review with a mandatory **instrument audit** (Task 1838 Requirement: "The harness itself has never received independent review — the reviewer must validate the instrument together with the evidence it produced").

### Score And Verdict

- **Score**: **93/100** (Elite band — `APPROVED_PATH100`)
- **Verdict**: **APPROVED_PATH100_HELD_IN_REVIEW** — promote-ready; parent may route `02-doing → 03-review` after the ledger patch. Not `ACCEPTED_100`: two evidence-honesty corrections (N1/N2, both recording-not-mechanism) remain open.
- **Evidence confidence**: high (instrument audited line-by-line with sabotage-calibration read; all four gate suites + a regeneration probe re-executed by this reviewer; all 11 traces parsed and spot-checked).
- **REGRESSION findings**: **NONE**.

### Instrument Validity (dispatch item 1 — audited first, by design)

The harness must not be able to false-PASS, or every trace it emits is worth zero. Verdict: **the oracle is hard-fail in production runs and is calibration-proven to detect all three defect classes it claims to catch.**

- **`error_oracle.dart`** (`ExerciseErrorCollector`): `install()` chains `FlutterError.onError` (records into `flutterErrors` AND re-invokes the previous handler — no diagnostic swallowing); `collectTreeState` scans `find.byType(ErrorWidget)` after each pump (the deliberate decision to leave `ErrorWidget.builder` untouched is correct — `flutter_test` rejects its mutation, verified against the binding); `pumpAndEnforce` feeds `tester.takeException()` into `asyncErrors` on every step; `failIfMaterial` throws `FlutterError` on any non-empty register. `isMissingAncestorMessage` covers `No Material widget found` (+ MediaQuery/Directionality/Scaffold/Overlay); `isOverflowMessage` covers `RenderFlex overflowed`/`overflowed by`/`RenderBox was not laid out`/ParentDataWidget.
- **No false-PASS path in production gates**: the revalidation suites (all three) call `runSmoke`/`runCrawl` with `softFail` **defaulting to false** (verified in `cybercore_revalidation_test.dart` — no `softFail` argument anywhere), then explicitly `expect(trace.errors, isEmpty, ...)`. `softFail: true` exists only for the calibration escape hatch (`catalog_theme_matrix_test.dart`'s known-drift control), which is the documented design.
- **Known-bad calibration read** (`known_bad_control_test.dart`): three controls inject the exact 1831-class defect (raw `TextField` without Material → asserts `No Material widget found` detected), the 1832-class defect (fixed-height overflow → asserts `RenderFlex overflowed` detected), and a deliberate build-throw; a fourth asserts the oracle stays silent on a healthy tree. Plus a determinism + destructive-filter discovery test. This is a real sabotage oracle for the oracle itself.
- **Runner honesty**: `ExerciseRunner.pumpAndEnforce` deliberately avoids `pumpAndSettle` (documented: real hosts own perpetual animations — quiescence is not correctness) and uses bounded frames (pump + 100ms + 300ms) + the oracle. No `pumpAndSettle` hang risk, no false-quiescence claim.
- **Documented blind spots are declared, not hidden** (architecture-decision §6): below-fold discovery (v1 only hitTestables), no text entry, no visual-taste judgment. The evidence claims stay inside these blind spots.
- **One residual nuance recorded, not a defect**: when `oracle.failIfMaterial` throws inside a step, the runner's `catch` records the error into `trace.errors` and `break`s — so a material error both fails the test (via the throw) AND lands in `trace.errors`. The suite-level `expect(trace.errors, isEmpty)` is a second, independent assertion over the same register. There is no single-channel dependency.

### Gates Re-Run (reviewer-executed, exact exits)

| Command (reviewer-executed) | Exit | Result |
|---|---|---|
| `cd apps/catalog && flutter test test/host_exercise/ --no-pub` | **0** | `+9: All tests passed!` |
| `cd apps/observatory && flutter test test/host_exercise/ --no-pub` | **0** | `+8: All tests passed!` |
| `cd apps/cybercore && flutter test test/host_exercise/ --no-pub` | **0** | `+8: All tests passed!` |
| `cd packages/warp_prism_host_exercise && flutter test --no-pub` | **0** | `+10: All tests passed!` (5 calibration + 5 unit — includes the `kExerciseDesktopMatrix.length == 4` test, which still passes because `compact500x900` is a named free-standing viewport, NOT a matrix member) |
| `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` | **0** | `15/15 PASS, 0 FAIL, 0 violation(s)` |

### Trace Authenticity (dispatch item 2)

All **11** trace files exist under `docs/reports/host-exercise/traces/`, all parse as valid JSON, all have `errors: []`:

| Trace | host / mode / seed / recipe / viewport | actions | errors | matches matrix |
|---|---|---|---|---|
| `catalog_smoke_s0_desktop-1280x800.json` | catalog / smoke / 0 / khalai-blue / desktop-1280x800 | 2 | 0 | ✓ |
| `catalog_crawl_s0_desktop-1280x800.json` | catalog / crawl / 0 / khalai-blue / desktop-1280x800 | 8 | 0 | ✓ |
| `catalog_smoke_s0_laptop-1366x768.json` | catalog / smoke / 0 / khalai-blue / laptop-1366x768 | 2 | 0 | ✓ |
| `observatory_smoke_s0_desktop-1280x800.json` | observatory / smoke / 0 / khalai-blue / desktop-1280x800 | 5 | 0 | ✓ |
| `observatory_crawl_s0_desktop-1280x800.json` | observatory / crawl / 0 / khalai-blue / desktop-1280x800 | 10 | 0 | ✓ |
| `observatory_smoke_s0_narrow-800x600.json` | observatory / smoke / 0 / khalai-blue / narrow-800x600 | 5 | 0 | ✓ |
| `cybercore_smoke_s0_desktop-1280x800.json` | cybercore / smoke / 0 / cybercore-teal / desktop-1280x800 | 4 | 0 | ✓ |
| `cybercore_crawl_s0_desktop-1280x800.json` | cybercore / crawl / 0 / cybercore-teal / desktop-1280x800 | 10 | 0 | ✓ |
| `cybercore_smoke_s0_compact-500x900.json` | cybercore / smoke / 0 / cybercore-teal / **compact-500x900** | 4 | 0 | ✓ (F6 surface) |
| `cybercore_smoke_s0_compact-390x844.json` | cybercore / smoke / 0 / cybercore-teal / compact-390x844@2.0 | 4 | 0 | ✓ |
| `catalog_fuzz_s18473_vertical.json` | catalog / fuzz / 18473 / khalai-blue / desktop-1280x800 | 8 | 0 | prior trace (preexisting, 0 errors) |

**Spot-check content** (3 traces, deeper): actions are real UI actions (`tap` on semantic/keyed targets with genuine `route_before → route_after` transitions — e.g. cyercore crawl navigates `/providers→/live-logs→/mcp-inspector→/mcp-servers→/providers`, observatory desktop-nav landing on `Map/Operate/History/Governance/Overview`), `state_marker` candidate counts are non-trivial and vary as the tree changes (26/4/26/20 on catalog crawl; 7/5/20 on cybercore desktop smoke), and no `errors` strings are present. The `catalog_fuzz_s18473_vertical` (the pre-existing trace) was left untouched (not regenerated into the new naming pattern).

### Trace Regeneration Determinism (dispatch item 3)

`flutter test apps/cybercore/test/host_exercise/cybercore_revalidation_test.dart --no-pub --plain-name "compact-500x900"` → **exit 0, +1 passed**. Regenerated trace is **action-identical** to the builder's persisted one (same 4 taps, same route transitions, same `errors: []`) but **not byte-identical** (sha256 differs: pre-regen `e3a4a3cc…` → post `904113cb…`). Root cause is the documented spinner/capture non-determinism (Task 1834 F1 canon: Observatory candidate bytes were not bit-stable due to animated chrome in a nearby zone — the same class applies to trace JSON bytes when ticks land mid-frame). **Recorded, not a defect**: the task's determinism claim is about action-sequence determinism and error emptiness, both of which regenerate identically; byte-stability of JSON artifacts was never claimed (and per 1834 F1 is not claimed for PNG captures either).

### Compact Coverage Honesty (dispatch item 4)

**F6 divergence surface genuinely exercised, not just launched**:

- `cybercore_shell.dart:87-88` — compact gate is `MediaQuery.sizeOf(context).width < PrismBreakpoints.narrow` (600px). The `compact-500x900` viewport is 500×1.0 logical — **below** the breakpoint; the `_CompactShell` branch (`:96-104`) is definitely entered.
- `_CompactShell` renders the `BottomNavigationBar` (`:226`) with the four navigation items (`Providers`, `MCP Servers`, `MCP Inspector`, `Live Logs` — `navItems` at `:25-45`, `_buildBottomNavItems` at `:73-82`).
- The compact-500x900 trace's 4 actions are taps on `sem:MCP Servers`, `sem:MCP Inspector`, `sem:Live Logs`, `sem:Providers` — the same labels on the BottomNavigationBar items — and the recorded route transitions traverse all four branches. Desktop smoke shows `candidates=7` (sidebar semantics visible); compact shows `candidates=0`, which is consistent with BottomNavigationBar items not being `Semantics(button:true)`-flagged and carrying no keys (the explicit `smokeTargets` resolver still finds them for the taps — the taps succeed because the targets exist).
- Theme recipe check: `expect(trace.themeRecipe, 'cybercore-teal')` asserted in every cybercore suite test; the teal install is produced inside `WarpPrismCyberCoreApp.build` (1833 R3 canon), and the compact trace re-navigates the exact F6 surface (bottom-nav selection) under that recipe with zero errors.
- **Router factory discipline**: `cybercore_host.dart` uses `cybercore.createAppRouter()` fresh per reset + `KeyedSubtree(UniqueKey())` — no singleton carry-over (the documented Observatory-router limitation explicitly does NOT apply to CyberCore; verified `cybercoreCallbacks` does not take the router singleton).

### Criteria Mapping Honesty (dispatch item 5)

The builder report's §3 maps traces to 1805 criteria 3/5/9/11 with **technical-status precision**, and **explicitly does not** claim aesthetic approval:
- Each criterion section ends with "**PROVEN BY TRACE EVIDENCE**" / "Technical Status: …" and the residual-limitations §5.4 states: "final aesthetic approval of Task 1805 criteria 3, 5, 11 remains the owner's human gate." The task's own guardrail (`:106`) forbids claiming "criteria are approved"; the report complies.
- One weakness to record (N1, evidence-precision Debt): task Completion Evidence's prose is marginally stronger than the builder report's — it says the criteria are "PROVEN" without the builder's §5.4 qualifier adjacency, and the changelog draft says "closing the REVALIDATION_REQUIRED state on Task 1805 criteria 3, 5, 9, 11" where the precise claim is "restores the *technical* evidence layer; re-judgment remains owner-gated". This is a wording-tightening, not an over-claim — the task's guardrail + the builder report's own §5.4 hold the line; the changelog/Completion-Evidence prose should import the same parenthetical.

### Historical Invalidations (dispatch item 6)

All three 2026-09-03 invalidations are addressed by a specific run:

| Invalidation (2026-09-03 owner live run) | Addressed by | Verified |
|---|---|---|
| Observatory `ds_search_bar.dart:95` `No Material widget found` (search bar under MaterialApp-without-Scaffold) | `observatory_smoke_s0_desktop-1280x800` + `observatory_crawl_s0_desktop-1280x800` — both traverse the shell route chain (overview→map→operate→history→governance) where `DSSearchBar` is the original crash surface; oracle reported 0 missing-ancestor errors | ✓ |
| CyberCore `ds_data_table.dart:1088` `RenderFlex overflow` (table/scroll overflow under the actual host) | `cybercore_crawl_s0_desktop-1280x800` (10 steps across the four pilot routes incl. the tables) + `cybercore_smoke_s0_compact-500x900` — oracle reported 0 `RenderFlex overflowed` | ✓ |
| CyberCore chrome divergence (Khalai-Blue header/bottom-nav mixed with teal; F6 in 1833 Review 2) | `cybercore_smoke_s0_compact-500x900` (the exact F6 viewport) + widget-level `cybercore_shell_chrome_teal_test.dart` (1833 R3 canon, still green in this repo at +8) — same recipe, exact viewports, zero errors | ✓ |

The three criteria-3/5/11 regressions are re-validated at the same scale the invalidation ran at (real host, real route, real viewport class — not a fixture layer).

### Harness-Change Blast Radius (dispatch item 7)

- `compact500x900` (`viewport_matrix.dart:59-65`) added as a **named free-standing viewport constant**, not appended to `kExerciseDesktopMatrix` — so the existing `kExerciseDesktopMatrix.length == 4` test and every consumer of the matrix are untouched. Verify: harness suite `+10` passes, including the matrix-length unit test. No regression.
- No adapter contract changed: `cybercoreExerciseConfig(..., viewport: ...)` already accepted a viewport; this round passes the new constant. The Observatory `observatory_exercise_test.dart` and catalog adapters are unchanged.
- The `ExerciseViewport.compact500x900` addition is additive-only (a new `static const`), so serialized-prior-traces referencing older viewport names still parse through `fromJson` correctly (`name` is opaque; no renaming occurred).

### Task Evidence Coherence (dispatch item 8)

- **Completion Evidence** — filled; trace census accurate (10 new traces + 1 pre-existing fuzz = 11 files; the exit-condition phrasing "across all 10 matrix traces" correctly scopes to the 10 new matrix traces); gates table matches reviewer re-runs exactly.
- **`affected_consumers: {catalog, observatory, cybercore}`** — correctly honest (all three hosts exercised); this is a verification task, so affected-consumers listing the exercised hosts is right, not NONE.
- **Mirror-file consistency** — the task Where table names `docs/reports/builders/1838-real-host-revalidation-evidence-report.md` as the consolidated-evidence report; the builder instead wrote the substantive report at `docs/reports/builders/1838-real-host-revalidation-evidence-builder-report.md` (within the additive convention) and placed a 6-line redirect stub at the `-report.md` path pointing to the builder report. **This is NOT a convention violation**: the additive convention says ONE additive builder file per task (respected — there is one builder report and one redirect); the `-report.md` path is a task-Where-table accommodation, and the redirect stub makes both paths live and consistent (same content, one canonical body). No duplicate content, no divergence.
- **Changelog draft** — present and accurate to the runs (10 traces, 0 errors, 4 gates exit 0), with the N1 wording caveat above.
- **Agent Session Ledger** entry — present (2026-09-07 entry), records the harness addition honestly.

### Findings

| ID | Class | Severity | Status | Summary | Evidence |
|---|---|---|---|---|---|
| N1 | NEW (first review) | Debt | Open | Changelog + Completion Evidence criteria prose marginally stronger than the builder report's §5.4 owner-gate qualifier; tighten to "restores the technical evidence layer for criteria 3/5/9/11 re-judgment; owner visual gate remains open" to match the task's own guardrail. | `task:146-149`, task changelog `:184`; builder report §5.4 `:93` |
| N2 | NEW | Info | Closed | Trace byte-level non-determinism (spinner-class, documented Task 1834 F1 canon): regenerated compact-500×900 trace is action-identical but not byte-identical to the persisted builder trace. Not a defect — the determinism claim is about actions+errors, which regenerate identically. Recorded for the evidence ledger. | sha256 `e3a4a3cc…` → `904113cb…` after a —plain-name re-run, action sequence + `errors: []` identical |
| N3 | NEW (verified-no-action) | Info | Closed | `candidates=0` in compact cybercore traces vs `candidates=7` on desktop is explained (compact BottomNavigationBar items carry no `Semantics(button:true)` flag and no keys, so the discovery pass finds nothing; the explicit smoke-target `resolveFinder` path still resolves and taps them — the taps succeed and the route transitions prove it). Not a defect: discovery blind spot is documented (architecture-decision §6.1). | trace content + `cybercore_shell.dart:73-82` + `action_discovery.dart:47-63` |
| N4 | NEW | Improvement | Open | Harness unit-test corpus could gain a negative control asserting that `runSmoke` with `softFail: false` fails on a sabotage candidate reachable in a known-bad fixture (currently the calibration is on individual oracle methods, not the end-to-end `ExerciseRunner` gate). Future-proof, non-blocking. | `known_bad_control_test.dart` covers the collector; `runSmoke` end-to-end under sabotage is covered only transitively by the production suites |

No Critical findings. No Serious findings. No REGRESSION findings.

### Path To 100

1. **(N1)** Tighten the criteria prose in the task Completion Evidence + changelog draft to match the builder report's §5.4 boundary ("technical evidence layer restored; owner visual gate remains open"). One-line edits; no test/code change required.
2. *(Parent)* apply the Task Ledger Patch below; route `02-doing → 03-review`.
3. *(Parent)* the 1805 owner re-judgment can now proceed — the technical-evidence precondition it was blocked on is green across all three hosts and the four viewports.
4. *(Optional, N4)* add the end-to-end runner sabotage negative control to `known_bad_control_test.dart` when the harness is next touched.

### Task Ledger Patch Suggestion

```markdown
### Latest Review — 2026-09-07 (Review 1)

- **Reviewer profile**: `reviewers`
- **Score**: `93/100`
- **Verdict**: `APPROVED_PATH100_HELD_IN_REVIEW` (promote-ready)
- **Full report**: `docs/reports/reviewers/1838-real-host-revalidation-evidence-review-loop.md` (Entry 1)
- **Lane outcome**: remains in 02-doing; parent may promote to 03-review
- **Task reference**: Task 1838 (`1838-warp-prism-real-host-revalidation-evidence`)

#### Open Items

- `NEW`/Debt N1: criteria prose in Completion Evidence + changelog should import the builder report's §5.4 owner-gate qualifier (technical layer green; owner visual gate remains open). One-line edits.

#### Verified (this review)

- Instrument audit: `ExerciseErrorCollector` hard-fails on FlutterError/ErrorWidget/takeException; softFail default false in all production suites; known-bad calibration validates all three defect classes; instrument cannot false-PASS.
- Gates: catalog +9 / observatory +8 / cybercore +8 / harness +10 — all exit 0 (exact matches). Boundary 15/15.
- Traces: all 11 exist, valid JSON, `errors: []`; 10 new matrix traces + pre-existing fuzz; action counts match the matrix exactly; 3 spot-checks show real UI actions with genuine route transitions.
- Trace regeneration: action-identical, byte-not-stable (spinner-class; 1834 F1 canon; not a claimed property).
- Compact coverage: 500px < 600px breakpoint genuinely enters `_CompactShell`; BottomNavigationBar items (Providers/MCP Servers/MCP Inspector/Live Logs) genuinely tapped through all four branches under teal.
- Historical invalidations all re-addressed: Observatory No Material / CyberCore RenderFlex overflow / chrome divergence each covered by specific runs.
- Harness-change blast radius: `compact500x900` is an additive free-standing constant (NOT in `kExerciseDesktopMatrix`) — matrix-length test still green; no adapter contract change.
- Mirror files: `-report.md` is a redirect stub to the single canonical builder report; no duplicate content, consistent with the additive convention.
```

### Falsification bottom line

The instrument audit came first and showed the oracle cannot false-PASS in these runs (hard-fail default, known-bad calibration for all three defect classes, correct binding-mechanism choices, no swallowed handlers). Every falsification attempt on the evidence failed to find a defect: all four suites green at exact counts, all 11 traces authentic with empty error registers and real action transitions, the F6 compact path genuinely exercised at a viewport below the documented breakpoint, all three 2026-09-03 invalidations covered by specific runs, the harness addition proven non-breaking, and both report paths consistent under the additive convention. The two open items are one-line evidence-precision tightenings, not mechanism fixes.

---

## Resolved (bottom section — none yet; first review)

*(Nothing to move here — Entry 1 found no PERSISTENT findings from prior reviews; the EVIDENCE_GAP carried forward from 1833 Review 3 / 1835 Review 2 is RESOLVED by this task's evidence and is closed at the wave level rather than in this task's resolved list, since it was never a finding against 1838 itself.)*

---

## Prior One-Shot Reports (seed references — valid historical evidence)

- **None exist for Task 1838** — Entry 1 is the first independent review.
- **Claim source**: `docs/reports/builders/1838-real-host-revalidation-evidence-builder-report.md` (additive builder report, initial consolidated evidence 2026-09-07).
- **Redirect stub**: `docs/reports/builders/1838-real-host-revalidation-evidence-report.md` (6-line pointer to the canonical builder report; consistent, no duplicate prose).
- **Origin lineage**: `docs/reports/reviewers/1833-theme-role-accent-propagation-review-loop.md` (Entry 3, the EVIDENCE_GAP this task closes) + `docs/reports/reviewers/1835-material-ancestry-meta-test-review-loop.md` (the carry-forward note).
- **Harness provenance**: `docs/reports/host-exercise/architecture-decision.md` (Status "pending independent review" — satisfied by Entry 1's instrument audit).
