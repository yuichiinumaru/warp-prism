# Warp Prism Observatory — Legacy Test Retirement / Rewrite Audit

> **Date**: 2026-07-09
> **Task**: 1407 (Legacy Test Retirement or Rewrite Audit)
> **Executor**: gt-flutter-engineer
> **Depends on**: 1403–1406 (in `03-review/`; reconciliations treated as complete for this audit)
> **Scope**: Remaining failing tests under `apps/observatory/test/` after the EPIC-14 reconciliation wave
> **Validation**: `flutter test apps/observatory/` (monorepo root CWD)

---

## 0. Executive summary

| Metric | Live 2026-07-09 (post F-1407-03 residual) |
|---|---|
| Full suite command | `flutter test apps/observatory/` |
| Result | **+736 PASS** (0 fails) |
| Fully green product surfaces (map/operate/history/governance/asset_detail/shell/data/workspace_snapshot) | Yes |
| Remaining non-success outcomes | **0** |
| Decisions applied this task | 1 **keep + fix** (parser CWD), 1 **rewrite** (bootstrap), 1 **keep + fix** (snapshot Prism migration) |
| Tests archived | **0** (none test a dead product architecture) |

> **2026-07-17 re-proof (path-to-100)**: full suite live **+778 PASS** / 0 fail under
> `flutter test apps/observatory/` (count currency only; method + classifications above
> remain authoritative for the 2026-07-09 residual set). Historical **+736** freeze kept.

Post-1403–1406, Observatory is no longer the historical “64 runtime failures / 12 stale map assertions” suite. The residual red set at audit start was small and well-typed; all three are now resolved in Task 1407:

1. **Compile cascade** from incomplete `DS*` → `Prism*` consumer migration in `features/workspace_snapshot/` — **fixed** (Prism rename + graph aliases).
2. **CWD-sensitive fixture path** in one parser corpus guard — **fixed**.
3. **Stale bootstrap expectations** (`/design-system` as initial route) — **rewritten** (theme + gallery isolation smoke).

---

## 1. Method

1. Read Task 1407 contract, EPIC-14 dependency chain, and prior baselines:
   - `docs/reports/observatory-failure-baseline.md` (Task 1401, 2026-07-09)
   - `docs/reports/warp-prism-failure-baseline-inventory.md` (Task 1201 historical)
   - Task 1408 evidence (same residual failure identity)
2. Ran full suite from monorepo root:

   ```bash
   flutter test apps/observatory/
   # → +728 -3
   ```

3. Re-ran each failing identity in isolation; inspected production imports and router contract.
4. Classified each remaining failure as **keep + fix**, **rewrite**, or **archive**.
5. Applied safe test-only keep/rewrite actions under `apps/observatory/test/` (no production `lib/` thrash; no 1406 history/operate surfaces).

### Decision rules (from task contract)

| Decision | When |
|---|---|
| **Keep + fix** | Test still asserts current product behavior; failure is fixable (test harness, path, or real bug). |
| **Rewrite** | Intent is still relevant, but harness/assertions target an obsolete wiring. |
| **Archive** | Test targets architecture that **no longer exists**. Archive = move to `.archive/tests/` or mark `// ARCHIVED — reason: …`. **Never delete.** |

---

## 2. Remaining failing tests (post-1403–1406 live run)

### F-1407-01 — `test/app/app_bootstrap_test.dart` (suite load)

| Field | Value |
|---|---|
| Identity | loading `app_bootstrap_test.dart` (suite never starts) |
| Kind | compile / load failure (transitive) |
| Error signature | `Couldn't find constructor 'DSStateSurface.loading'` / undefined `DSColors` / … in `lib/features/workspace_snapshot/workspace_snapshot_page.dart` |
| Why it fails | Suite imports `package:warp_prism_observatory/app/app.dart` → `router.dart` → `WorkspaceSnapshotPage`. Snapshot UI still calls hidden `DS*` names via the public `warp_prism_ui` barrel (Prism-only). |
| Stale assertions | `app initial location is /design-system` + `find.text('Design System Gallery')` — **obsolete**. Live router contract is `initialLocation: '/overview'` (`lib/app/router.dart`). Gallery remains at `/design-system` as a secondary proof route, not the app home. |
| Taxonomy | contract drift (product DS* residual) + stale test (initial route) |
| **Decision** | **REWRITE** |
| Justification | Bootstrap/theme smoke is still valuable; full `WarpPrismApp` load is blocked by an external compile residual, and one assertion encodes dead initial-route architecture. |
| Action this task | Rewrote suite to (a) assert dark/obsidian theme tokens without importing the product router graph, (b) smoke `DesignSystemGalleryPage` in isolation as the still-live DS proof surface, (c) document that full `WarpPrismApp` + product router boot remains deferred until workspace_snapshot Prism migration. |
| Follow-up | Full-app boot smoke re-enabled after **F-1407-03** fix (workspace_snapshot consumer migration). Optional named follow-up: `CANDIDATE-1409` / open task for snapshot Prism migration (not created by this audit unless planning requests it). |

### F-1407-02 — `test/data/parsers/workspace_task_projection_parser_test.dart`

| Field | Value |
|---|---|
| Identity | `committed mock corpus fixtures parses one committed file per lane` |
| Kind | runtime assertion |
| Error signature | `Expected: true Actual: <false>` — reason: `mock corpus must exist under assets/mock_workspace/docs/tasks` |
| Why it fails | Relative path `assets/mock_workspace/docs/tasks` is resolved from **process CWD**. From monorepo root (`flutter test apps/observatory/`) the path does not exist; from `apps/observatory/` CWD it does. Isolation re-run from package CWD: **PASS**. |
| Architecture still live? | **Yes.** Five-lane mock corpus under `apps/observatory/assets/mock_workspace/docs/tasks/{00-planning…04-completed}/` is the active fixture contract; parser is post-1403 green for inline fixtures. |
| Taxonomy | missing fixture path resolution (CWD), not dead architecture |
| **Decision** | **KEEP + fix** |
| Justification | Drift guard for committed lane fixtures is high signal; only the root discovery is wrong. |
| Action this task | Applied multi-candidate root resolution matching `history_repository_test.dart` (`assets/…` and `apps/observatory/assets/…`). |
| Follow-up | None if re-proof green. |

### F-1407-03 — `test/features/workspace_snapshot/workspace_snapshot_page_test.dart` (suite load)

| Field | Value |
|---|---|
| Identity | loading `workspace_snapshot_page_test.dart` (suite never starts) |
| Kind | compile / load failure |
| Error signature | Same DS* undefined cluster in `workspace_snapshot_page.dart` + widgets (`DSStateSurface`, `DSColors`, `DSMetricTile`, `DSTopbar`, …) |
| Why it fails | Production page imports `package:warp_prism_ui/warp_prism_ui.dart` (Prism-only public barrel) but still constructs `DS*` APIs. `ds_compat.dart` exists for temporary DS re-export but is not used by this feature. |
| Architecture still live? | **Yes.** Router still registers `/workspace-snapshot` and deep-link variants; demo narrative references the surface (`docs/demo/epic-10-demo-script.md`). Enhanced unit suite `workspace_snapshot_enhanced_test.dart` is green (model/search only; no page compile). |
| Taxonomy | contract drift / broken compile (implementation), **not** stale product intent |
| **Decision** | **KEEP + fix** (applied in residual path-to-100 on same task) |
| Justification | Archiving would silence a real product compile hole on a still-routed surface. Guardrail: if it were testing dead architecture, archive; it is not. |
| Action this task | Migrated `lib/features/workspace_snapshot/**` from `DS*` constructors to public `Prism*` aliases (`warp_prism_ui` barrel). Graph panel uses `PrismGraphNode`/`PrismGraphEdge`. Page suite re-enabled and green. |
| Follow-up fix task | **None** for F-1407-03. Optional: re-expand full `WarpPrismApp` product-router boot smoke beyond the 1407 bootstrap rewrite if desired. |

---

## 3. Decision matrix (concise)

| ID | Suite / test | Decision | Applied now? | Residual after 1407 |
|---|---|---|---|---|
| F-1407-01 | `app/app_bootstrap_test.dart` | **REWRITE** | Yes (test rewrite) | Should load & pass without product router |
| F-1407-02 | `…/workspace_task_projection_parser_test.dart` — committed lane fixtures | **KEEP + fix** | Yes (CWD path) | Should pass from monorepo root |
| F-1407-03 | `workspace_snapshot/workspace_snapshot_page_test.dart` | **KEEP + fix** | Yes (lib/ Prism migration) | **PASS** |

**Archive count: 0.**

Rationale for zero archives: every residual failure either protects live contracts (parser corpus, snapshot page) or was rewritable into a live smoke (bootstrap/theme/gallery). Nothing asserted a removed product surface as its sole purpose.

---

## 4. Historical failures now green (do not re-open as 1407 work)

These clusters appeared in older baselines (1201 / 1401) and are **not** remaining failures after 1403–1406. Listed so they are not mistaken for archive candidates:

| Historical cluster | Live status (2026-07-09 full suite) |
|---|---|
| Map catalog / graph / inspector text contracts (1201 ×7) | Green (all map suites pass) |
| Operate inspector “Exit Conditions” count / close tap flaky (1201) | Green (`operate_task_detail_inspector_test`) |
| Governance review pressure duplicate lane chip (1201) | Green (`governance_analytics_panels_test` loads & runs) |
| Task projection / TaskLaneParsing parser cluster (historical 8) | Green (inline parser groups); only CWD corpus guard was residual |
| History story/impact modes | Green (`history_story_modes_test`, `history_page_test`) |
| Asset detail / responsive detail / skill-task widgets | Green in full suite (1405 wave) |
| Shell state / deep-link / overview page compile cluster from 1401 inventory | Green in this full run |
| Operate storytelling overflow (1401 F12) | Green in this full run |

> Note: analyzer package debt for residual DS* usage may still exist outside the three test identities; Task 1407 classifies **test failures**, not the full analyzer ledger.

---

## 5. Follow-up tasks required for “keep + fix”

| Keep item | Fix owner | Notes |
|---|---|---|
| F-1407-02 parser CWD | **This task (1407)** | Applied multi-candidate path resolution. |
| F-1407-03 workspace_snapshot page compile + tests | **This task (1407 residual)** | Migrated `lib/features/workspace_snapshot/**` to Prism*. Page suite + full package green. |
| Full product router boot smoke | Optional polish | Snapshot compile no longer blocks `appRouter`; bootstrap suite currently uses isolated theme/gallery smoke (1407 rewrite). |

---

## 6. Archive protocol status

| Item | Status |
|---|---|
| Tests moved to `.archive/tests/` | None |
| Tests marked `// ARCHIVED — reason: …` | None |
| Deleted tests | **None** (protocol: archive, never delete) |

If a future task retires `/workspace-snapshot` from the product router, reclassify F-1407-03 as **archive** and move the suite under `.archive/tests/observatory/workspace_snapshot/` with reason `route removed from product contract`.

---

## 7. Regression verification

### Commands

```bash
# Full package suite (monorepo root)
flutter test apps/observatory/

# Report present
cat docs/reports/warp-prism-observatory-test-retirement-audit.md

# Scoped re-proof for keep/rewrite actions
cd apps/observatory && flutter test \
  test/app/app_bootstrap_test.dart \
  test/data/parsers/workspace_task_projection_parser_test.dart
```

### Live residual after this task’s actions (including Prism residual)

| Outcome | Live result (2026-07-09) |
|---|---|
| Pre-action full suite | **+728 −3** |
| Scoped rewrite/keep fix | `app_bootstrap_test` + `workspace_task_projection_parser_test` → **+32 PASS** |
| Mid-task full suite (before F-1407-03 lib fix) | **+732 −1** |
| Post F-1407-03 Prism migration full suite | **+736 PASS** |
| F-1407-01 rewritten suite | **PASS** |
| F-1407-02 corpus guard from monorepo root | **PASS** |
| F-1407-03 snapshot page suite | **PASS** (`workspace_snapshot/` +29) |
| All other Observatory suites | Green |

Remaining failures after 1407 residual: **none**. Archives: **0**.

---

## 8. Relation to Task 1408

Task 1408 (package import cleanup) independently observed the same four residual identities earlier (`+700 −4` including a responsive-detail load that is green in this full run). 1408 correctly classified DS* / corpus residuals as **EXTERNAL** to import migration. Task 1407 owns the **test retirement/rewrite policy** for those residuals; it does not re-open 1408.

---

## 9. Evidence pointers

| Artifact | Path |
|---|---|
| This audit | `docs/reports/warp-prism-observatory-test-retirement-audit.md` |
| Prior inventory | `docs/reports/observatory-failure-baseline.md` |
| Task file | `docs/tasks/02-doing/1407-warp-prism-legacy-test-retirement-or-rewrite-audit.md` |
| Parser path fix | `apps/observatory/test/data/parsers/workspace_task_projection_parser_test.dart` |
| Bootstrap rewrite | `apps/observatory/test/app/app_bootstrap_test.dart` |
| Snapshot page suite (F-1407-03 resolved) | `apps/observatory/test/features/workspace_snapshot/workspace_snapshot_page_test.dart` |
| Snapshot Prism migration | `apps/observatory/lib/features/workspace_snapshot/**` |
| Live router contract | `apps/observatory/lib/app/router.dart` (`initialLocation: '/overview'`) |
| Local changelog draft | `docs/changelog/2026-07-09-task-1407-workspace-snapshot-prism-migration.md` |

---

## 10. Bottom line

- Observatory test health after Task 1407 residual: **+736 PASS / 0 fails**.
- **Zero archives** — no remaining failure was pure dead-architecture noise.
- **Two keep+fix applied**: F-1407-02 CWD corpus path; F-1407-03 `workspace_snapshot` DS*→Prism* migration.
- **One rewrite applied**: F-1407-01 bootstrap smoke (theme + gallery isolation; full shell covered by `app_shell_smoke_test`).
- **No deferred residual failures.** Optional polish only: expand bootstrap to full `WarpPrismApp` router boot if desired.
