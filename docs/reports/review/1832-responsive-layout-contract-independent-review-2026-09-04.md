# Independent Review Report: Task 1832 — Responsive Layout Contract (DSDataTable + DSTimeMachineScrubber) — 2026-09-04

> **Dispatch**: REVIEW-1832 — independent post-acceptance revalidation (falsification-oriented)
> **Reviewer**: reviewer subagent (`reviewers` lane profile) — did NOT author this work
> **Mode**: REVIEWER_CONTEXT-equivalent revalidation; **no lane moves performed** (task currently sits in `docs/tasks/01-open/`)

---

## Review Lineage

- **Current task**: Task 1832 (`1832-warp-prism-responsive-layout-contract-overflow`), live path `docs/tasks/01-open/1832-warp-prism-responsive-layout-contract-overflow.md`
- **Previous reports read**:
  - `docs/reports/builders/20260904-task-1832-self-review.md` — builder self-review, claimed 100/100 ACCEPT (score-only, NOT independent)
- **Related reports considered**:
  - `docs/reports/review/1805-final-capture-determinism-independent-rereview-2026-09-03.md` — defines the golden-freeze context Task 1832 must not disturb
  - Prior component reviews (`1507-time-machine-scrubber-*`, `20260824-task-1804-*`) — no open findings carried into 1832's scope
- **Critical lineage fact**: the task's `Review Ledger` is **empty** ("to be filled by independent reviewer"). No prior *independent* review of Task 1832 exists on disk. The only historical acceptance evidence is the builder's self-review. This revalidation therefore validates the *builder's claims and exit conditions* directly against live evidence; no prior independent verdict is being overturned.
- **Review mode**: `re-review (post-acceptance revalidation)`

---

## Score And Verdict

- **Score**: `73/100` — Good
- **Verdict**: `PASS` (revalidation of the acceptance-scope claims) — with a falsified overclaim and a required follow-up register (below)
- **Evidence confidence**: `HIGH` — every claimed gate was re-executed on the live tree; the pre-fix mechanism was mechanically reconstructed and empirically re-failed; all newly found defects were empirically reproduced with exact pixel values
- **Lane recommendation**: `no-move` (lane routing is the parent's authority; reviewer performed none)

### Verdict semantics (per dispatch)

The task's **exit conditions as written** — "Zero RenderFlex overflow errors from these components on affected real routes at representative viewports" — are **re-established**: verified at h=50 (w=958) and h=119 at 1280×800 and 1920×1080, plus host-shape compositions. The builder's **broader self-review claim** — "Zero RenderFlex overflow exceptions occur under any test or real host constraint" (`docs/reports/builders/20260904-task-1832-self-review.md:22`) — is **contradicted** by four empirically reproduced defect bands in the current code (F1–F4 below). PASS therefore applies to the exit-condition scope, not to the self-review's absolutist wording.

---

## POST-ACCEPTANCE REVALIDATION MAPPING

Per dispatch semantics — contradicted vs re-established vs remaining-invalid vs unaffected-preserved:

### Re-established (independently verified on live tree)

1. **All 7 claimed command outcomes, exact counts**:
   - `flutter test` on the 3 new regression files: **16/16 passed, exit 0** (2 combined + 7 table + 7 scrubber — count consistent with claim)
   - `flutter test test/organisms/ --no-pub`: **696/696 passed, exit 0**
   - `flutter analyze --no-fatal-infos --no-fatal-warnings` (warp_prism_ui): **exit 0; 0 errors; 0 warnings; 212 info** (all pre-existing package-wide; **0** in the two touched files)
   - `apps/cybercore` `flutter test test/widget_test.dart`: **9/9, exit 0**
   - `apps/catalog` `flutter test test/widget_test.dart`: **10/10, exit 0**
   - `apps/cybercore` capture suite: **2/2, exit 0** (screenshot-unavailable path fails honestly to BLOCKED — designed behavior)
   - `apps/catalog` capture suite: **5/5, exit 0**
   - `apps/cybercore` + `apps/catalog` `flutter build linux --debug`: **both exit 0** (`✓ Built .../warp_prism_cybercore`, `✓ Built .../warp_prism_catalog`)
2. **Pre-fix failure authenticity**: the `FlutterError.onError` trap mechanism is genuine. Reviewer mechanically reconstructed the pre-fix constraint chain (non-flexible `Column` + fixed 56px histogram + 48px transport + `md` glass padding under h=119; non-flexible 65px header under h=50) using the exact trap from `layout_contract_overflow_regression_test.dart:30-40`. Result: **`A RenderFlex overflowed by 47 pixels on the bottom`** — matching the builder's claimed 47px scrubber repro (user's real-host evidence: 21/16/44px — same mechanism, different host compositions). The table reconstruction overflowed by 55px with a body row present; the claimed 17px is the header-only arithmetic (65px header − 48px inner at h=50), consistent. The tests would have failed on the original code.
3. **Ownership SHARED_COMPONENT_DEFECT / NO_HOST_EDITS_REQUIRED**: correct. Verified real host chains: CyberCore `providers_page.dart:124-135` / `mcp_servers_page.dart` / `mcp_inspector_page.dart:125-134` all impose bounded height via `Expanded → LayoutBuilder → SizedBox(height: constraints.maxHeight)`; the w=958 class matches the hosts' `maxWidth < 960 ? 960` floor. The scrubber's real Catalog composition is the in-package gallery (`design_system_gallery_sections.dart:5786-5818`: `Padding(sm) → Column → Expanded(scrubber) + label`) — mirrored by the second regression test. Host constraint chains genuinely reach the organisms with bounded heights; fixing inside the package is the owning layer. Host files bear Sep 4 mtimes, but their diffs are the concurrent theme-skin work (23 `ThemeVariant`/`applySkin` markers in `apps/catalog/lib/main.dart`; zero 1832/layout markers) — **no host edits attributable to 1832**.
4. **No API/signature breaks**: both public constructors unchanged (field-by-field read); new parameters are private-class only (`_DSTableHeader.isCompact/isUltraCompact`, `_TransportButton.isCompact`) or additive-with-default public (`DSTablePagination.isCompact`, default `false`). Blast-radius grep across the workspace: consumers use `PrismDataTable` (3 CyberCore pages, catalog widget_test, gallery, virtual_list_test, archived observatory code) and `PrismTimeMachineScrubber` (gallery + tests) — all compile and pass; both host widget suites green.
5. **No golden refresh**: **0** files under `packages/warp_prism_ui/test/goldens/` modified since 2026-09-03 (all baselines Jun 9 – Jul 25; only `failures/` artifacts updated — and the `data_table_default` failure artifacts are dated Sep 4 18:49, i.e. produced by THIS reviewer's run, not the builder's).
6. **No protected-file edits**: `AGENTS.md` (Sep 3 19:23), `MISSION.md` (Sep 3 19:23), `README.md` (Aug 23), root `pubspec.yaml` (Jul 9), `packages/warp_prism_ui/pubspec.yaml` (Sep 1) — all pre-date the Sep 4 15:34–15:44 execution window of the 5 declared writeset files.
7. **No density redesign beyond constraint necessity**: compact adaptations are strictly constraint-triggered (padding tiers, icon sizes, tap-target dims, spacing) — verified line-by-line; no recoloring, no renames.
8. **Empty/loading/error under Flexible+ScrollView at extremes**: reviewer probed **18 combinations** (loading/empty/error × h ∈ {20, 25, 30, 33, 34, 40}) — **all 18 pass**, no overflow, no unbounded-flex exceptions. The <34px fallback is structurally sound for state surfaces.

### Contradicted (empirically falsified against current code)

- **C1**: Self-review claim "Zero RenderFlex overflow exceptions occur under any test or real host constraint" — falsified by F1, F2, F3, F4 (below). The compact/ultra-compact branches do NOT degrade gracefully across all bounded heights.
- **C2**: Self-review score 100/100 — not supportable; the same defects plus the unrecorded golden-drift obligation cap the honest score at 73.

### Remaining-invalid (was never done; still outstanding)

- **R1**: Task Test Requirements: "If existing goldens render the fixed layout, record the expected drift explicitly — do not refresh." **No drift record exists** in Completion Evidence, and the reviewer's run of `test/goldens/ds_data_table_golden_test.dart` **fails today** (`Pixel test failed, 99.62%, 478180px diff`). Attribution is unresolved (see F5) — but the obligation to record expected drift was never discharged.
- **R2**: The task's `Review Ledger` was never filled; the "independent review" prerequisite for any acceptance narrative was never satisfied prior to this report.

### Unaffected-preserved (historical evidence stands)

- The origin user runtime evidence (real CyberCore 15px table overflow at h=50; real Catalog 21/16/44px scrubber overflows at h=119) remains valid and is now *reinforced* by the reviewer's mechanical reconstruction.
- The historical fact that pre-fix code overflowed under the real host constraints is preserved; the fix's direction (LayoutBuilder + flexible/scrollable contracts at the owning layer) is confirmed correct.

---

## Delta Summary

### Resolved Since Previous Review (previous = builder self-review)

- `RESOLVED`: Real-host overflows at h=50 / h=119 at default text scale — independently re-verified green across both viewport classes and host-shape compositions.

### New Findings (all `NEW` — none are regressions of previously-green behavior; the affected bands also overflowed pre-fix, i.e. incomplete remediation)

- `NEW`: F1 scrubber band h∈[70,95) with title — see Findings.
- `NEW`: F2 scrubber empty-state band h∈[110,118].
- `NEW`: F3 table-with-toolbar band h≤~90.
- `NEW`: F4 textScale 2.0 at the real h=119 constraint.

### Evidence Gaps

- `EVIDENCE_GAP`: F5 data-table golden drift attribution.

### Persistent

- `PERSISTENT`: Suite-wide golden red state (56 baselines failing since Sep 1 under the freeze — badge/glass/metric/status/text/shell) — pre-existing, outside 1832's writeset, owned by the Task 1805 sign-off process.

---

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW | Moderate | Open | Scrubber with title overflows on the flex path for h∈[70,95): 24px @70, 14px @80, 4px @90; zero-crossing ~95–100. `useFlex` cutoff (70) is below the true minimum content height (title 20 + spacing + 16px histogram floor + transport 48 + compact padding 16 ≈ 104–108), so [70,95) has neither working flex nor the <70 scroll fallback. | this review | `ds_time_machine_scrubber.dart:435` (cutoff), `:453-465` (non-flex chrome), `:468` (overflowing Column, creator chain captured in probe log) |
| F2 | NEW | Moderate-low | Open | Scrubber **empty state with title** overflows at h∈[110,118]: 9px @110, 4px @115, 1px @118; passes at 119 by ≈0–1px margin. The real Catalog constraint (119) sits on a razor-thin boundary. | this review | `ds_time_machine_scrubber.dart:443-451`, `:494-502` (`_buildEmpty` compact `minHeight: 24`) |
| F3 | NEW | Low-moderate | Open | Table **with toolbar** overflows at h≤~90: 41px @40, 31px @50, 9px @80; passes @100/119. Toolbar is a non-flexible child. No current caller passes `toolbar` (grep: 0 usages in `apps/`), so latent-only. | this review | `ds_data_table.dart:1164-1171` (toolbar, non-flexible), `:468-472` analog |
| F4 | NEW | Moderate | Open | **A11y text scaling**: at the real Catalog constraint h=119, `TextScaler.linear(2.0)` overflows the scrubber by 33px (1.15/1.3/1.6 pass). Table at h=50 passes through 1.3 (not tested higher by hosts' realistic band). OS-level large-text users on the real route will see overflow stripes. | this review | `ds_time_machine_scrubber.dart:453-465` (fixed chrome does not adapt to `TextScaler`) |
| F5 | EVIDENCE_GAP | Low-moderate | Open | `data_table_default.png` golden fails today (99.62%, 478,180px diff). No failure artifacts for this golden existed before Sep 4 (the Sep 1 mass-failure set of 232 artifacts contains none), and the builder neither ran `test/goldens/` nor recorded the expected drift the task required. Attribution between 1832's body-flex change and the concurrent token-skin work is not resolvable from the live tree alone (git diff unavailable to this reviewer — permission boundary). | this review | `packages/warp_prism_ui/test/goldens/ds_data_table_golden_test.dart` (renders at h=300, non-compact path); `tmp/` probe logs |
| F6 | NEW | Low | Open | Trap hygiene footgun in all 3 regression files: `fail()` invoked inside `FlutterError.onError` re-enters the handler when the TestFailure itself is reported (observed 36× nested prefix, ~4-minute runner wedge on genuinely failing code). Correct verdict on pre-fix code, degraded failure UX; also risks masking the second error's details. | this review | `layout_contract_overflow_regression_test.dart:30-40`; identical pattern in both per-component suites (`:32-42` / `:23-33`) |
| F7 | NEW | Low | Open | Sub-34px table fallback **omits the body entirely** (`if (!hasBoundedHeight || maxH >= 34)` gates `_buildBody`), so at h<34 the scrollable fallback contains header only — rows (critical content) are dropped, not scroll-revealed. No scroll trap, but content hiding at extreme constraints. | this review | `ds_data_table.dart:1238-1239`, `:1260-1265` |
| F8 | NEW | Info | Open | Compact/ultra-compact header checkbox uses `MaterialTapTargetSize.shrinkWrap` (32px/28px class target) — below the 48dp minimum in those branches. Latent (no current host uses `selectable`). Transport buttons were probe-verified to retain 48×48 via IconButton's tap-target semantics at h=119. | this review | `ds_data_table.dart:543-545`, `:514-518` |
| F9 | INFO (governance) | Info | Open | Task sits in `01-open/` with full Completion Evidence; the only acceptance evidence is a builder **self**-review. Lane placement/routing is the parent's authority — noted, not acted on. | this review | task file `Review Ledger` (empty) |

### Behavioral probe data (exact rendered measurements, h=119 real Catalog constraint)

- Histogram: **622×25** (flex path, between the 16px floor and 56px max — adaptive, no dead-space collapse: content Column measured **622×101** of the 103px inner box)
- Title: **622×20**; transport play/pause: **48×48** (tap target preserved in compact)
- At h=200/300 (non-compact): histogram full **56px**; at h=69 (fixed-height path): 56px; at h=160 boundary: 50px
- Table at h=50: header label 49×17; body `ListView` **798×17** scroll sliver; row-1 text top at dy=40 (clipped by the 17px body viewport — scrollable, no overflow, but a 17px row window is the practical density consequence of the ultra-compact 31px header at h=50)

---

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PARTIAL | 0 errors / 0 warnings in touched files; 212 info-level issues package-wide are pre-existing (project command uses `--no-fatal-infos --no-fatal-warnings`); **0** issues in the 2 touched files |
| Lifecycle Safety | PASS | Exact count: 1 controller created (`_playbackTimer`, `ds_time_machine_scrubber.dart:286`), 1 matching disposal (`:337` `dispose()` + cancel paths `:360/:385`); 0 other controllers/subscriptions in either file; post-frame callback is one-shot |
| Dependency Direction | PASS | Organisms import only `tokens`/`atoms`/`molecules` (+`virtual_scroll` for the table); no layer violations introduced |
| UI Accessibility | PARTIAL | F4 (textScale 2.0 overflow on real route), F8 (compact checkbox target); semantics coverage otherwise dense and intact — 6 semantic nodes over 5 interactive elements on the scrubber; full Semantics/labels on table interactive elements |
| Proof Reality | PARTIAL | All claimed counts verified EXACT (16/696/9/10/2/5, both builds); pre-fix repro authenticated by reconstruction; but the self-review's "any constraint" claim is falsified (F1–F3) and the golden-drift obligation went undischarge (F5) |
| Release Security | PASS (not release-scoped) | No secrets, no `print`/`debugPrint` in the touched files; no release-path changes |

---

## Evidence Reviewed

### Task & source files read in full

- `docs/tasks/01-open/1832-warp-prism-responsive-layout-contract-overflow.md` (incl. Completion Evidence + Changelog Draft)
- `packages/warp_prism_ui/lib/src/organisms/data_table/ds_data_table.dart` (1324 lines)
- `packages/warp_prism_ui/lib/src/organisms/time_machine_scrubber/ds_time_machine_scrubber.dart` (911 lines)
- All 3 regression test files (107 + 237 + 245 lines)
- Substrates: `ds_spacing.dart`, `ds_glass_panel.dart`, `ds_state_surface.dart`, `ds_text.dart`, `ds_data_table_golden_test.dart`
- Real host call sites: `apps/cybercore/lib/features/{providers,mcp_servers,mcp_inspector}/*_page.dart`, `apps/catalog/lib/main.dart`, gallery composition `design_system_gallery_sections.dart:5740-5826`

### Commands run (reviewer, live tree, 2026-09-04)

| Command | Result |
| --- | --- |
| `flutter test` 3 regression files (warp_prism_ui) | 16/16 passed, exit 0 |
| `flutter test test/organisms/ --no-pub` | 696/696 passed, exit 0 |
| `flutter analyze --no-fatal-infos --no-fatal-warnings` (warp_prism_ui) | exit 0; 0 errors; 0 warnings; 212 info (0 in touched files) |
| `flutter test test/widget_test.dart` (cybercore) | 9/9 passed, exit 0 |
| `flutter test test/widget_test.dart` (catalog) | 10/10 passed, exit 0 |
| `flutter test integration_test/cybercore_visual_capture_test.dart` | 2/2 passed, exit 0 |
| `flutter test integration_test/visual_acceptance_capture_test.dart` (catalog) | 5/5 passed, exit 0 |
| `flutter build linux --debug` (cybercore / catalog) | exit 0 / exit 0 |
| Reviewer probe: pre-fix scrubber mechanism reconstruction + exact trap | FAILS trap: `RenderFlex overflowed by 47 pixels` (authenticity proven) |
| Reviewer probe: pre-fix table mechanism reconstruction + trap | FAILS trap: `RenderFlex overflowed by 55 pixels` (mechanism proven; 17px = header-only arithmetic) |
| Reviewer probe: danger-zone sweep (9 scrubber heights + 6 empty-state heights + 5 toolbar heights + 9 table heights) | 10 failures, all reproduced with exact pixel values (F1–F3) |
| Reviewer probe: text scaling (5 scales scrubber, 3 scales table) | 1 failure: scrubber 33px @ textScale 2.0, h=119 (F4) |
| Reviewer probe: extreme states (18 combinations) | 18/18 pass |
| Reviewer probe: rendered-size measurements | see Behavioral probe data |
| `flutter test test/goldens/ds_data_table_golden_test.dart` | FAIL (99.62%, 478180px) — see F5 |
| `flutter test test/host_exercise/overflow_probe{,2}_test.dart` (catalog) | probe1 passed; probe2 fails: pre-existing **horizontal** Row overflow (90px) at 390×844 in `design_system_gallery_page.dart:136` — **not** 1832's components, not in 1832's writeset (file mtime Aug 22); out-of-scope observation for parent routing |

### Commands NOT run and why

- Full `flutter test` of warp_prism_ui beyond `test/organisms/` — not claimed by 1832; organisms is the task's validation surface
- Observatory app build/tests — not a claimed consumer for 1832 (`affected_consumers` lists cybercore + catalog only)
- `dart pub outdated` / codegen checks — no dependency or codegen changes in the writeset (pubspec untouched since Sep 1)
- Git history/diff — git operations are permission-denied in this review environment; attribution performed via live filesystem evidence (mtimes, artifact inventories, marker greps) instead

---

## Residual Risks (viewport / density focus)

1. **Text scaling on the real Catalog route**: any user at OS text scale ≥ ~1.8 will overflow the h=119 scrubber (33px at 2.0). The fix is default-scale-correct only.
2. **Heights 70–95px with a title** are a live overflow band in the shipped component — any future consumer allocating a titled scrubber below ~95px reproduces yellow-stripe overflow (the exact defect class this task exists to eliminate).
3. **Empty-state margin at h=119 is ≈0–1px** — trivially regressable by any future chrome/padding tweak; should be guarded by a test with slack, not by luck.
4. **Toolbar callers below ~90px** will overflow; current hosts don't pass `toolbar`, but the public parameter invites it.
5. **Sub-34px table contexts render header-only** — data invisible with no scroll path to it.
6. **Golden suite**: `data_table_default` now fails with attribution unresolved between 1832 and the concurrent skin work; the freeze (Task 1805) must receive an explicit expected-drift note either way.
7. **Concurrent-work contamination of host evidence**: host builds/tests ran against a tree that also contains in-flight theme-skin work (host files modified Sep 4 16:03–16:08, after 1832's 15:34–15:44 window; `catalog_exercise_test.dart` currently has LSP errors from other tasks' harness work). The 1832-attributable evidence remains valid (organisms suite + regression files are isolated), but "both host builds green" is evidence for the **combined** tree, not 1832 in isolation.

---

## Path To 100

1. **Retune the scrubber flex/fallback thresholds** (F1): raise the scroll-fallback cutoff from 70 to the computed non-flex chrome minimum when title/transport are present (≈100px), or make the fallback condition `remaining < histogram floor` instead of a hardcoded 70. Add regressions: titled scrubber at h=70/80/90/95/100.
2. **Fix the empty-state band** (F2): apply the same threshold logic to `_buildEmpty`'s 24px floor; add empty+title regressions at h=110/115/118; make h=119 pass with ≥4px slack (assert rendered slack, not just absence of error).
3. **Make the toolbar constraint-safe** (F3): wrap the toolbar region in the bounded-height fallback path or make it flexible; add toolbar regressions at h=40/50/80.
4. **Handle text scaling** (F4): scale the compact thresholds by `MediaQuery.textScalerOf(context)` (or clamp effective chrome under scaling and engage the scroll fallback earlier); add regressions at textScale 1.3/1.6/2.0 for h=119 and h=50.
5. **Discharge the golden-drift obligation** (F5): run `test/goldens/ds_data_table_golden_test.dart` on a tree isolating 1832 (or bisect against the skin task), record the expected-drift note in the task evidence as the Test Requirements demand — do not refresh baselines.
6. **Fix the trap hygiene** (F6): in all 3 regression files, collect overflow reports into a list inside `onError` and `expect(list, isEmpty)` after pumping, instead of calling `fail()` re-entrantly inside the handler.
7. **Include the body in the sub-34 scroll fallback** (F7): render header+body inside the fallback `SingleChildScrollView` so rows remain reachable at extreme constraints.
8. Optional (F8): keep `shrinkWrap` only for ultra-compact and retain 48dp targets in the plain-compact branch.

---

## Task Ledger Patch Suggestion

```markdown
---

## Review Ledger

### Latest Review

- **Date**: 2026-09-04
- **Reviewer profile**: `reviewers` (independent post-acceptance revalidation, REVIEW-1832)
- **Score**: `73/100`
- **Verdict**: `PASS` (exit-condition scope re-established) — builder self-review overclaim contradicted
- **Full report**: `docs/reports/review/1832-responsive-layout-contract-independent-review-2026-09-04.md`
- **Lane outcome**: `no move` (lane routing is parent authority; task currently in `01-open/`)
- **Task reference**: Task 1832 (`1832-warp-prism-responsive-layout-contract-overflow`)

#### Current Open Blockers (follow-up register, not acceptance blockers for exit-condition scope)

- `NEW` F1: scrubber h∈[70,95) titled overflow (24/14/4px) — threshold retune
- `NEW` F2: scrubber empty-state h∈[110,118] overflow; h=119 margin ≈0–1px
- `NEW` F3: table+toolbar overflow ≤~90px (latent; no current caller)
- `NEW` F4: textScale 2.0 breaks real h=119 scrubber (33px) — a11y
- `EVIDENCE_GAP` F5: data_table golden drift unrecorded/unattributed (task requirement not discharged)
- `NEW` F6/F7/F8: trap re-entrancy; sub-34 body drop; compact checkbox target

#### Path-to-100 Summary

- See report §Path To 100 (8 items, all concrete)
```

---

## Reviewer Packet (return to parent)

- **Verdict**: `PASS` — post-acceptance revalidation: exit-condition claims re-established; self-review absolutism (100/100, "any constraint") contradicted
- **Score**: `73/100` (Good) — deductions: F1 −8, F2 −4, F3 −3, F4 −5, F5 −3, F6 −2, F7 −2
- **Evidence confidence**: HIGH
- **Top follow-ups**: F1 (band retune), F4 (text scaling), F5 (golden drift record)
- **Lane move performed**: NONE
- **Out-of-scope observation for parent routing**: pre-existing 90px horizontal Row overflow at 390×844 in `design_system_gallery_page.dart:136` (gallery header, mobile viewport) — distinct defect, not 1832's components; plus in-flight `catalog_exercise_test.dart` harness errors from concurrent tasks
