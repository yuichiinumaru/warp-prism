# Task 1805: Screenshot Visual Acceptance Gate and Golden Policy

> **Review State**: `Ready For Review` — see `docs/governance/promotion-state-model.md`
> **Priority**: 🔴 P0
> **Type**: `governance`
> **Origin**: EPIC-18 planning validation wave (Flutter expert audit confirmed existing
> golden infrastructure and the Ahem limitation that shapes evidence rules, 2026-08-22)
> **Blocks**: Task 1806 and promotion of any future visual task
> **Depends on**: Task 1803, Task 1804

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task NNNN` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Make visual correctness a real release gate: analyzer/tests green is necessary but NEVER
sufficient; goldens are refreshed only after human screenshot approval against the
Task 1800 contract.

## Infrastructure decisions (validated)

- Build on the EXISTING harness: 24 golden suites under
  `packages/warp_prism_ui/test/goldens/` using plain `matchesGoldenFile` + committed
  PNGs. Do NOT adopt golden_toolkit/alchemist mid-reset.
- Widget goldens render text with **Ahem block glyphs** — they cannot validate font
  loading or readability. Typography proof requires host-level `integration_test` on a
  desktop target with real rasterization (per Task 1802).
- Canonical screenshot hosts: `apps/catalog` (storybook/gallery — exists for exactly
  this), Observatory shell/dashboard, CyberCore shell with explicit skin. Captures run
  as deterministic desktop `integration_test`s; committed PNGs ARE the approval
  artifacts.
- Golden `_inApp` ad-hoc themes (13 of 24 suites) must consume `PrismTheme.dark()` so
  goldens stop crystallizing third-theme drift (handoff from Task 1803 completes here).

## Interim policy enforcement

The Task 1800 freeze ("no golden regeneration between 1801 and 1805 approval") ends
with THIS task's human approval. Before approval, CI golden failures are annotated
expected drift. After approval, refresh happens once, deliberately, with the approved
screenshot linked.

---

## Exit Conditions

- [x] Deterministic capture commands documented (host, viewport, command) for catalog,
      observatory, cybercore + typography specimen + token swatches + one dense
      organism + one form primitive.
- [ ] Human-approved target artifact committed and linked (user sign-off recorded) — `PENDING-USER`.
- [ ] Reviewer report with before/after comparison and explicit pass/fail per the
      checklist below (`docs/reports/1805-visual-acceptance-gate-report.md`) — interim infrastructure report exists; final before/after review is `PENDING-USER`.
- [x] Golden `_inApp` wrappers all consuming the canonical factory.
- [ ] Goldens refreshed ONCE after approval; golden tests pass post-refresh — `PENDING-USER` (Golden freeze lifts at user sign-off).
- [ ] Rejected visual output preserved (never overwritten silently) — `PENDING-USER`; current candidate PNGs exist, but no rejected output has been supplied.
- [x] Local changelog entry added via the changelog engine.
- [x] Completion Evidence is filled before review handoff.

## Review Checklist (binary)

- [ ] background is black obsidian, not blue — `PENDING-USER` convergence
- [ ] surfaces neutral near-black with restrained elevation — `PENDING-USER` convergence
- [ ] blue confined to action/focus/highlight roles — `PENDING-USER` convergence
- [ ] semantic green/amber/red remain meaningful — `PENDING-USER` convergence
- [ ] no excessive teal/green/rainbow chrome — `PENDING-USER` convergence
- [ ] no persistent high-intensity blue ambient glow — `PENDING-USER` convergence
- [ ] UI typography readable and non-mono in interface roles — `PENDING-USER` convergence
- [ ] JetBrains Mono only in technical roles — `PENDING-USER` convergence
- [ ] contrast/focus states accessible — `PENDING-USER` convergence
- [ ] density matches approved reference intent — `PENDING-USER` convergence
- [ ] Catalog and app hosts render the same theme contract — `PENDING-USER` convergence

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read all 24 golden suites' wrapper
      patterns, `apps/*/integration_test/` (create dirs if absent),
      Task 1800 contract, Task 1803 factory exports.
- [x] Implement deterministic capture harness per host.
- [x] Migrate remaining golden wrappers to canonical theme.
- [ ] Capture candidate screenshots; submit for user sign-off — candidate artifacts captured 2026-09-03; submission/sign-off remains `PENDING-USER`.
- [ ] On approval: single deliberate golden refresh; verify suite green — `PENDING-USER`.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task.
- [x] **Regression verification**: run the validation commands listed below; outcomes and blockers recorded below.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/test/goldens/` | Modify — wrapper migration |
| `apps/catalog/integration_test/` | Create — capture harness |
| `apps/observatory/integration_test/` | Create — capture harness |
| `docs/reports/` | Create — approval/comparison report |

### How

1. Reads; harness; captures; user review loop until pass.
2. Single golden refresh tied to approved artifact.
3. Publish report + policy handoff note for future visual tasks.

### Why

Without this gate, every future visual task ships "green" while visually wrong — the
exact systemic failure that produced the reset. Goldens crystallize whatever they are
fed; feeding them unapproved pixels bakes errors into CI authority.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running the validation commands and filling
> Completion Evidence. Do not claim visual approval without a recorded user statement.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics unless this task explicitly
> changes the product contract.

---

## Validation Commands

```bash
cd packages/warp_prism_ui && flutter test test/goldens/
cd apps/catalog && flutter test integration_test/
cd apps/observatory && flutter test integration_test/
```

If Flutter tooling is unavailable in the execution environment, record the exact tooling
failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/test/goldens/ds_badge_golden_test.dart` (modified)
  - `packages/warp_prism_ui/test/goldens/ds_data_table_golden_test.dart` (modified)
  - `packages/warp_prism_ui/test/goldens/ds_glass_panel_golden_test.dart` (modified)
  - `packages/warp_prism_ui/test/goldens/ds_metric_tile_golden_test.dart` (modified)
  - `packages/warp_prism_ui/test/goldens/ds_shell_golden_test.dart` (modified)
  - `packages/warp_prism_ui/test/goldens/ds_status_dot_golden_test.dart` (modified)
  - `packages/warp_prism_ui/test/goldens/ds_text_golden_test.dart` (modified)
  - `packages/warp_prism_ui/test/goldens/prism_agent_transcript_golden_test.dart` (modified)
  - `packages/warp_prism_ui/test/goldens/prism_entity_intel_panel_golden_test.dart` (modified)
  - `packages/warp_prism_ui/test/goldens/prism_map_hud_workspace_golden_test.dart` (modified)
  - `packages/warp_prism_ui/test/goldens/prism_osint_workbench_golden_test.dart` (modified)
  - `packages/warp_prism_ui/test/goldens/prism_page_shell_golden_test.dart` (modified)
  - `packages/warp_prism_ui/test/goldens/prism_provider_health_matrix_golden_test.dart` (modified)
  - `packages/warp_prism_ui/test/atoms/button/ds_button_test.dart` (modified)
  - `packages/warp_prism_ui/test/atoms/text_field/ds_text_field_test.dart` (modified)
  - `packages/warp_prism_ui/test/atoms/checkbox/ds_checkbox_test.dart` (modified)
  - `apps/catalog/integration_test/visual_acceptance_capture_test.dart` (created)
  - `apps/observatory/integration_test/observatory_visual_capture_test.dart` (created)
  - `apps/cybercore/integration_test/cybercore_visual_capture_test.dart` (created)
  - `docs/reports/1805-visual-acceptance-gate-report.md` (created)
  - `.changelog/20260823-140000-1805-warp-prism-screenshot-visual-acceptance-gate-builders.md` (created)
- **Tests or validation commands**:
  - `cd packages/warp_prism_ui && dart analyze` (PASS: 0 errors; 217 existing infos)
  - `cd apps/catalog && flutter analyze integration_test/visual_acceptance_capture_test.dart` (PASS: no issues)
  - `cd apps/observatory && flutter analyze integration_test/observatory_visual_capture_test.dart` (PASS: no issues)
  - `cd apps/cybercore && flutter analyze integration_test/cybercore_visual_capture_test.dart` (PASS: no issues)
  - `cd apps/catalog && flutter test integration_test/visual_acceptance_capture_test.dart --name 'captures typography specimen'` (historical PASS: 1/1; `takeScreenshot` `MissingPluginException`; local candidate generation is now proven by the 4/4 remediation run)
  - `cd apps/catalog && flutter test integration_test/` (FAIL: app startup/log-reader failure)
  - `cd apps/observatory && flutter test integration_test/observatory_visual_capture_test.dart` (PASS: 1/1; bounded pumps; deterministic repeated candidate hash after ticker isolation)
  - `cd apps/cybercore && flutter test integration_test/cybercore_visual_capture_test.dart` (PASS: 1/1; bounded pumps; deterministic repeated candidate hash)
  - `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` (PASS: 7/7)
  - `cd packages/warp_prism_ui && flutter test test/goldens/ --concurrency=1 --no-pub` (FAIL: 59 failures against frozen legacy baselines; expected while PENDING-USER)
- **Local changelog entry**: `.changelog/20260823-140000-1805-warp-prism-screenshot-visual-acceptance-gate-builders.md`
- **Agent-wiki / docs institutionalization**: `docs/reports/1805-visual-acceptance-gate-report.md`
- **Executor**: gt-builders-engineer-flutter
- **Completion date**: 2026-08-24 (reconciled)
- **Human approval**: `PENDING-USER` — no user visual convergence/sign-off recorded; no golden refresh authorized.

---

## Review Ledger

### Latest Review — 2026-08-23

- **Reviewer profile:** `reviewers`
- **Score:** `90/100`
- **Verdict:** `PASS FOR INFRASTRUCTURE HANDOFF; EXTERNAL_BLOCKER / EVIDENCE_GAP`
- **Full report:** `docs/reports/review/1805-screenshot-visual-acceptance-gate-adversarial-review-2026-08-23.md`
- **Lane action:** remains `docs/tasks/03-review/`
- **Live evidence:** package analyzer 0 errors; scoped tests 189/189; boundary 7/7; frozen goldens 59 failures with no refresh; Catalog capture 1/1 but `MissingPluginException` and no PNG; Observatory capture blocked by stream-channel `Bad state`/timeout; no target/candidate PNG artifacts.
- **Findings:** human visual approval is not proven. Infrastructure and freeze policy are accepted, but screenshots, user sign-off, rejected-output archive, and post-approval green goldens remain pending.
- **Path to 100:** supported desktop capture, artifact hashes and product-owner sign-off, rejected-output preservation, one authorized refresh, green golden suite.

### Latest Review — 2026-08-24 (bundled independent review)

- **Reviewer profile:** `reviewers` / builder-gate independent reviewer
- **Score:** `100/100`
- **Verdict:** `ACCEPTED_100` for infrastructure handoff; human visual acceptance remains `PENDING-USER`
- **Full report:** `docs/reports/review/20260824-bundled-1805-1806-option-a-independent-review.md`
- **Option A:** continues to apply; all 11 visual criteria, target/candidate/rejected artifacts, user sign-off, and one golden refresh remain explicitly human-gated.
- **Live evidence:** three scoped harness analyzers clean; typography spot-run `1/1` with honest `MissingPluginException`; boundary `7/7`; frozen goldens `59` failures / `0` baselines regenerated; `73` master PNGs and no capture-report PNGs.
- **Lane outcome:** moved from `docs/tasks/02-doing/` to `docs/tasks/03-review/` after score/path-to-100 recheck.

### Previous Reports

- `2026-08-23` — `100/100` — `docs/reports/review/1805-screenshot-visual-acceptance-gate-independent-review-2026-08-23.md`
  - **Carried forward:** human visual approval and golden refresh remain `PENDING-USER` under Option A.
  - **Resolved/reconfirmed:** scoped analyzers, typography limitation, boundary result, and frozen golden count independently reverified.

## Agent Session Ledger

- **2026-08-23 — builder-side independent reviewer**: Option A disposition confirmed from the task's explicit interim-infrastructure and `PENDING-USER` exit-condition wording. Live analyzers, typography spot-run, boundary harness, golden freeze run, PNG audit, and harness inspection completed. Documentation/promotion path-to-100 applied: corrected golden failure count `58` → `59`, set review-ready state, guarded direct rendered-PNG capture in Observatory/CyberCore, and created durable independent-review report. Final score `100/100`; human visual approval remains `PENDING-USER`.
- **2026-08-24 — builder-engineer (reconciliation pass)**: Re-verified Task 1805 Option A infrastructure status. Re-ran scoped analyzers (0 issues), catalog typography capture spot-run (1/1 pass with MissingPluginException), boundary test (7/7 pass), and frozen golden test suite (59 expected failures, 0 baselines regenerated). Confirmed all 11 human visual items and golden refresh remain honestly `PENDING-USER`. Zero lane moves performed. Score: 100/100 (infrastructure-complete).

## 🔍 Review Trail

### Independent Review — 2026-08-23 (Builder-side independent reviewer)

- **Interpretation**: **Option A — infrastructure-complete; human gate pending.** The task explicitly labels human target artifact, final before/after checklist, golden refresh, rejected-output preservation, and visual checklist items `PENDING-USER`; no signed PNG is claimed or required before this infrastructure handoff.
- **Initial score**: `94/100`.
- **Path-to-100**: corrected stale frozen-golden failure count to live `59`; changed task state from `Open` to `Ready For Review`; added durable report; hardened Observatory/CyberCore capture helpers so headless rasterization failure is recorded without aborting the harness.
- **Final score**: `100/100`.
- **Verdict**: `ACCEPTED_100` for infrastructure handoff; **not** visual approval and **not** golden approval.
- **Live evidence**: Catalog typography `1/1` with recorded `MissingPluginException`; boundary harness `7/7`; three harness analyzers no issues; frozen golden suite `59` expected failures with no baseline regeneration; Observatory/CyberCore blocked by Flutter `Bad state: Cannot close sink while adding stream`; no candidate PNGs.
- **Report**: `docs/reports/review/1805-screenshot-visual-acceptance-gate-independent-review-2026-08-23.md`
- **Lane outcome**: promoted to `docs/tasks/03-review/` after path-to-100 recheck.

### Remediation Dispatch — 2026-09-03

- **Finding**: Catalog capture harness renders and asserts its specimens, but
  `_safeTakeScreenshot` only calls `IntegrationTestWidgetsFlutterBinding.takeScreenshot`.
  In both `flutter test integration_test/...` and `flutter test ... -d linux`, that
  channel raises `MissingPluginException`, so no candidate PNG is produced.
- **Disposition**: `03-review → 02-doing`; builder remediation is required inside
  this task's declared `apps/catalog/integration_test/` scope. Existing infrastructure
  evidence remains valid; human visual approval and golden refresh remain pending.
- **Required remediation**: make the Catalog harness produce a real local rendered
  PNG from a bounded `RepaintBoundary` (matching the already-read Observatory and
  CyberCore capture approach), preserve graceful driver fallback, and prove output
  existence with a deterministic validation command. Do not refresh committed goldens.

### Remediation Evidence — 2026-09-03

- **Builder**: `gt-builders-engineer-flutter`; worker session
  `ses_f9a879d75ffeETthoQrx9qAm6v`.
- **Changed**: `apps/catalog/integration_test/visual_acceptance_capture_test.dart`.
  Each specimen now has a bounded `RepaintBoundary`; the harness rasterizes it
  with `RenderRepaintBoundary.toImage(pixelRatio: 1.0)`, writes the candidate
  PNG, and fails if the output is missing or empty. The driver `takeScreenshot`
  call remains best-effort fallback only.
- **Parent verification**:
  - `cd apps/catalog && dart format --output=none --set-exit-if-changed integration_test/visual_acceptance_capture_test.dart` — exit 0.
  - `cd apps/catalog && flutter analyze integration_test/visual_acceptance_capture_test.dart` — exit 0, no issues.
  - `cd apps/catalog && flutter test integration_test/visual_acceptance_capture_test.dart` — exit 0, 4/4 passed.
  - Candidate artifacts — all non-empty PNG RGBA 1280×800:
    `catalog_typography_specimen.png` (32,724 bytes),
    `catalog_token_swatches.png` (32,642 bytes),
    `catalog_dense_organism.png` (16,239 bytes),
    `catalog_form_primitive.png` (26,658 bytes).
- **Preserved**: no committed golden baseline was refreshed or overwritten.
  Driver fallback still logs `MissingPluginException` in the plain test runner;
  this no longer prevents local candidate generation.
- **Review handoff**: implementation remediation is ready for independent review;
  human visual convergence, rejected-output disposition, and one authorized
  golden refresh remain `PENDING-USER` and are not claimed here.

### Independent Re-review — 2026-09-03 (Catalog Capture Remediation)

- **Reviewer profile**: `gt-reviewers-reviewer-flutter` (independent reviewer lane)
- **Session**: `ses_f9a7bdf1affe3GsGGoinaPeGk6`
- **Remediation verdict**: `PASS`; **quality score**: `100/100` (diagnostic)
- **Overall Task 1805 verdict**: `BLOCKED — EXTERNAL_BLOCKER / PENDING-USER`
- **Report**: `docs/reports/review/1805-catalog-local-capture-remediation-independent-review-2026-09-03.md`
- **Evidence**: direct source inspection; format/analyze/test exit 0; 4/4 capture
  tests; four non-empty 1280×800 RGBA candidate PNGs.
- **Findings**: no Critical, Serious, Debt, or required Improvement findings in
  the remediation scope. The eleven visual criteria, approved target artifact,
  rejected-output disposition, one authorized golden refresh, and post-refresh
  suite remain human-gated. No committed goldens were changed.

### Further Remediation Dispatch — 2026-09-03

- **Diagnostic worker**: `gt-builders-engineer-flutter`; session
  `ses_f9a73b3fdffeJtCylgnuWGvZjC`.
- **Finding**: the Observatory and CyberCore capture tests still fail before
  their local PNG path. Both application shells mount an indeterminate
  `CircularProgressIndicator`; `tester.pumpAndSettle()` therefore never reaches
  a settled frame and the runner eventually emits
  `Bad state: Cannot close sink while adding stream.` The capture helpers also
  await `tester.binding.endOfFrame`, which is an additional unbounded wait.
- **Disposition**: `03-review → 02-doing`; this is a local defect in this task's
  declared `apps/*/integration_test/` scope. The Catalog remediation remains
  valid. Human visual convergence and golden refresh remain `PENDING-USER`.
- **Required remediation**: replace unbounded `pumpAndSettle()` with bounded
  pumps in both host capture tests and remove the unbounded `endOfFrame` wait,
  preserving the existing bounded `RepaintBoundary` local PNG path and the
  no-golden-refresh freeze. Verify candidate artifacts for Observatory and
  CyberCore before returning to independent review.

### Further Remediation Evidence — 2026-09-03

- **Builder**: `gt-builders-engineer-flutter`; worker session
  `ses_f9a60ce9effeMqozEM0yk7QDeE`.
- **Changed**: `apps/observatory/integration_test/observatory_visual_capture_test.dart`
  and `apps/cybercore/integration_test/cybercore_visual_capture_test.dart`.
  Both now remove the unbounded `endOfFrame` wait and replace
  `pumpAndSettle()` with `pump()` plus a bounded 500ms pump. Existing local
  `RepaintBoundary` rasterization, non-empty assertions, viewport `1280x800`,
  DPR `1.0`, and best-effort driver fallback are preserved.
- **Parent verification**:
  - Observatory format — exit 0; analyzer — exit 0; capture test — exit 0, 1/1.
  - CyberCore format — exit 0; analyzer — exit 0; capture test — exit 0, 1/1.
  - All six candidate files are valid non-empty 1280×800, 8-bit RGBA PNGs:
    Catalog files remain present; `observatory_overview_dashboard.png` is
    26,955 bytes and `cybercore_shell_teal_skin.png` is 57,854 bytes.
- **Preserved**: no committed golden baseline was refreshed or overwritten.
  Driver fallback still logs `MissingPluginException`, but local candidate
  generation now succeeds for all three hosts.
- **Review handoff**: implementation remediation is ready for independent
  review. Human visual convergence, rejected-output disposition, one authorized
  golden refresh, and post-refresh verification remain `PENDING-USER`.

### Determinism Remediation Evidence — 2026-09-03

- **Builder**: `gt-builders-engineer-flutter`; worker session
  `ses_f9a4fad55ffetq7jWCrvqYs2TD`.
- **Changed**: `apps/observatory/integration_test/observatory_visual_capture_test.dart`.
  The capture subtree now uses `TickerMode(enabled: false)` so the loading
  `CircularProgressIndicator` cannot advance between captures. Production app
  code, loading semantics, goldens, and CyberCore were not changed.
- **Parent verification**:
  - Observatory format — exit 0; analyzer — exit 0.
  - Two consecutive Observatory capture tests — both exit 0, 1/1 passed;
    both produced 26,358-byte candidate PNG with SHA-256
    `5a984635c3f6af877dfb144a9e1b62ad906ef00ab2825cd184293fa3d04e0500`.
  - Prior CyberCore repeat evidence remains valid: both runs exit 0, 1/1
    passed, 57,854 bytes, SHA-256
    `b18d46c2229bb6078e5a330868a435517e5158a480dab37666a6fe836eb7481b`.
- **Reconciliation**: the previous Observatory `CURRENT_REAL / NEW`
  determinism finding is resolved by current repeated execution. All six
  candidate artifacts remain non-empty 1280×800 RGBA PNGs.
- **Preserved**: no committed golden baseline was refreshed or overwritten.
  Driver fallback `MissingPluginException` remains non-blocking because local
  capture executes first and is verified.
- **Review handoff**: technical remediation is ready for independent review;
  the eleven visual criteria, rejected-output disposition, one authorized golden
  refresh, and post-refresh verification remain `PENDING-USER`.

### Final Independent Technical Re-review — 2026-09-03

- **Reviewer**: `gt-reviewers-reviewer-flutter`; session
  `ses_f9a461d7cffeOG5bVLNO6MPJqV`.
- **Remediation verdict**: `PASS`; diagnostic score `100/100`; evidence
  confidence `high`.
- **Overall Task 1805 verdict**: `BLOCKED` — no explicit user sign-off for the
  eleven visual criteria has been recorded.
- **Evidence**: all Catalog, Observatory, and CyberCore format/analyze/test
  validations exited 0; capture tests passed `4/4`, `1/1`, and `1/1`; all six
  candidate artifacts are valid non-empty 1280×800 8-bit RGBA PNGs.
- **Determinism**: Observatory repeated at 26,358 bytes with SHA-256
  `5a984635c3f6af877dfb144a9e1b62ad906ef00ab2825cd184293fa3d04e0500`;
  CyberCore repeated at 57,854 bytes with SHA-256
  `b18d46c2229bb6078e5a330868a435517e5158a480dab37666a6fe836eb7481b`.
- **Findings**: none in the technical remediation scope. The reviewer confirms
  the bounded pumps prove deterministic initial-state capture, not async data
  readiness; the Linux driver `MissingPluginException` remains non-blocking.
- **Full report**:
  `docs/reports/review/1805-final-capture-determinism-independent-rereview-2026-09-03.md`.
- **Lane action**: remains `docs/tasks/03-review/`; do not promote. Human visual
  approval, rejected-output disposition, one golden refresh, and post-refresh
  verification remain `PENDING-USER`.

### Final Re-review Report Link

- `docs/reports/review/1805-final-capture-determinism-independent-rereview-2026-09-03.md`

### Partial Human Visual Sign-off — 2026-09-03 (recorded verbatim from product owner)

- **Criteria 1 (obsidian black background)**: APPROVED — "fundo é preto obsidian em
  tudo (saindo paleta do cinza mesmo só pra nao ficar preto puro 000000). fundo
  colorido = ban".
- **Criteria 2 (neutral near-black surfaces, restrained elevation)**: APPROVED.
- **Criteria 6 (no persistent high-intensity blue ambient glow)**: APPROVED.
- **Criteria 7 (UI typography readable and non-mono)**: APPROVED — user prefers
  the current two-font discipline (UI sans + mono technical roles); no additional
  font families unless a specific need is raised and decided with the owner.
- **Criteria 8 (JetBrains Mono only in technical roles)**: APPROVED.
- **Criteria 9 (contrast/focus states accessible)**: direction approved by owner;
  regression re-proof required after theme-propagation fixes (delivered as
  Task 1833 builder evidence; independent review pending).
- **Criteria 3, 4, 5, 10, 11**: owner live-run verdicts 2026-09-03 —
  - 4 APPROVED (semantic colors meaningful);
  - 3 FAIL (accent limited to interaction/focus — implementation/propagation);
  - 5 FAIL (no rainbow/decorative chrome — CyberCore proved the case);
  - 10 REOPEN (host composition/density not good yet);
  - 11 FAIL (same contract across hosts).

  Remediation routed: Task 1833 (accent propagation → criteria 3/5/11),
  Task 1831 (Material ancestry → criterion 10 host composition), Task 1832 +
  Task 1836 (layout bands → criterion 10 density). Criteria 3/5/10/11 return to
  the owner for re-inspection only after technical remediation + real-host
  revalidation land.

### Real-Host Evidence Invalidation — 2026-09-03/04 (controlled realignment)

- The 2026-09-03 owner live run of all three hosts (`flutter run -d linux`)
  produced authoritative contradictory runtime evidence:
  - Observatory: repeated `No Material widget found` (`ds_search_bar.dart:95`);
    massive `RenderFlex` overflow (98868px / 497772px) on affected routes.
  - CyberCore: `RenderFlex overflowed by 15px` (`ds_data_table.dart:1088`,
    h=50).
  - Catalog: scrubber overflows 21/16/44px (`ds_time_machine_scrubber.dart:423`,
    h=119); repeated `ListTile` ink-visibility warnings.
  - Capture harness: PASS while `takeScreenshot` threw `MissingPluginException`
    — the oracle could not fail.
- Per AGENTS.md §3.6: the prior Task 1825/L1 acceptance and the 2026-09-03
  technical re-review `PASS` remain historically valid for their snapshots;
  active L1 real-host dimensions are `REVALIDATION_REQUIRED` until the
  remediation wave (1831–1836) lands and hosts are re-exercised.
- Remediation wave: 1831 (Material ancestry) PASS 93, 1832 (layout exit-scope)
  PASS 73 + follow-up 1836, 1833 (accent propagation, review pending), 1834
  (capture honesty) PASS 96, 1835 (ancestry meta-test) open.

### Capture Re-baseline Preconditions — from Task 1834 review (2026-09-04)

- **F1 (Moderate)**: the capture oracle is content-blind; during the 1834
  review, `cybercore_shell_teal_skin.png` shifted 57,854→57,520 bytes while the
  parallel 1833 session edited tokens/theme and all suites stayed green. Any
  fresh 1805 visual packet MUST re-baseline candidates from a **quiesced tree**
  (no concurrent source mutation) or stamp source-state beside captures.
- **F4 (Moderate, operational)**: shared-bundle-path collision — a parallel
  session's test executed inside a catalog run while the same binary was
  building. Catalog validation waves MUST be serialized or build dirs isolated
  while any parallel session is active.
- Five of six artifacts remain bit-reproducible across 3 sessions/2 days
  (SHA-256 identical to the 2026-09-03 record); cybercore is byte-stable within
  a fixed source tree.

### Golden Freeze Drift Ledger — accumulating until the single 1805 refresh

- 59 golden failures expected from the 1801 token migration (Task 1800 §7
  interim freeze).
- Task 1832 adds expected drift: `data_table_default` golden fails (99.62%,
  478,180px) — attribution between 1832 compact headers and 1833 skin wiring
  resolved at the single authorized refresh; **no baseline touched**.
- Task 1833 may add further drift from accent-propagation fixes; to be recorded
  after its independent review.
- All drift dispositions resolve in the ONE authorized refresh after owner
  sign-off; rejected-output preservation under `docs/reports/captures/rejected/`
  if any candidate is refused.

### Review Reconciliation — 2026-09-03

| Finding | Classification | Current evidence | Action |
|---|---|---|---|
| Observatory candidate metadata changed between two consecutive successful captures (`26,955` bytes / SHA-256 `1d6f...` then `26,602` bytes / SHA-256 `191960...`) | `CURRENT_REAL` / `NEW` determinism defect | Exact capture command passed both times, but the candidate bytes differed; the rendered loading spinner advances between bounded pumps | Reopen this task for a harness-only fix; freeze animation state for deterministic capture and prove two consecutive identical hashes. |

- CyberCore produced identical bytes on two consecutive runs (`57,854` bytes,
  SHA-256 `b18d...`); no CyberCore product change is implied by this finding.
- This reconciliation supersedes the reviewer report's “non-blocking metadata
  drift” classification: repeated current execution proves the underlying
  output instability, so it must be fixed before claiming deterministic capture.
