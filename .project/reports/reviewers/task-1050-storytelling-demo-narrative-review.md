# Review Report: Task 1050 — Storytelling Demo Narrative Pass — 2026-07-09

## Review Lineage

- **Current task**: Task 1050 (`docs/tasks/02-doing/1050-warp-prism-storytelling-demo-narrative-pass.md`)
- **Role**: `gt-code-quality-reviewer`
- **Previous reports**:
  - `docs/reports/build-gate-review/1050-review.md` — historical 100/100 (stale)
  - `docs/reports/review-wave-2026-06-19/task-1050-epic-10-demo-narrative-rereview.md` — 54/100 REJECTED
- **Related**: Task 1000 now in `03-review` (Ready For Review); Task 1060 still depends on 1050

## Score And Verdict

- **Score**: `52/100`
- **Verdict**: `NEEDS FIX` / `REJECTED_TO_DOING`
- **Lane**: remains `02-doing` (not promoted; promotion only at 100)

## Delta Since 2026-06-19

| Item | Status |
| --- | --- |
| Scoped tests `story_panel_narrative_test.dart` | **Reconfirmed** `+14` All tests passed (Flutter 3.44.1) |
| Task Where paths monorepo-qualified | **Improved** (`packages/warp_prism_ui/...`) |
| Task 1000 dependency | **Improved** — Task 1000 is `03-review` / Ready For Review (no longer rejected in doing) |
| Stale SDK blocker on task header | **Cleared** in task evidence |
| Demo script live-surface accuracy (F1) | **Open / unchanged** |
| Demo script stale factual claims (F2) | **Open / unchanged** |
| Public `PrismInsightRiskLevel` export (F4) | **Open / unchanged** |
| Narrative fields rendered by `DSStoryPanel` | **Open / newly emphasized** |
| `ready_for_reviewer: yes` after evidence-only pass | **New governance inflation** |

The 2026-07-09 executor pass modified **only** the task markdown and re-ran validation. It did **not** rewrite `docs/demo/epic-10-demo-script.md` or change product code. Prior path-to-100 items 1–4 remain incomplete.

## Findings

### F1 — CRITICAL — Demo script anti-hallucination notes contradict live app

**Evidence**:
- Script status table marks Map/Operate/History/Governance as `⛔ No page` (`docs/demo/epic-10-demo-script.md:16-20`)
- Anti-hallucination note: "No live page, route, or app shell exists" (`:24`)
- Beat 2 claims `main.dart`, `app.dart`, `router.dart` absent and Flutter SDK missing (`:92-103`)
- Fallback notes still assert no app shell / no SDK / no pages (`:257-261`)
- Live app: `apps/observatory/lib/main.dart`, `apps/observatory/lib/app/router.dart` routes `/map`, `/operate`, `/history`, `/governance`, plus page shells under `apps/observatory/lib/app/pages/` and feature hosts

**Impact**: Primary task deliverable violates its own anti-hallucination guardrail and mislabels live routes as blocked. EPIC 10 demo coherence cannot be audited from this script.

**Fix**: Rewrite script against live monorepo routes and host maturity (real page vs placeholder). Remove obsolete SDK/main.dart/shell blockers.

### F2 — HIGH — Script hardcodes stale historical “facts” as demo truth

**Evidence**:
- README “stale Next.js boilerplate” (`epic-10-demo-script.md:159-163`) vs live Flutter monorepo README
- Counts and DS paths under root `lib/design_system/`, `lib/data/models/` (`:41-60`, `:125-136`, `:167-184`) not re-proven from current packages/apps/fixtures
- Test fixtures still encode “No main.dart exists” / “README is stale” as sample narrative (`packages/warp_prism_ui/test/story_panel_narrative_test.dart:94-97`, `:117-120`)

**Impact**: Demo and tests teach false product state; downstream Task 1060 acceptance will inherit fiction.

**Fix**: Prove counts/risks from live fixtures or label as historical/aspirational. Update sample strings to current monorepo reality.

### F3 — MEDIUM — Narrative contract fields are model-only; panel does not render them

**Evidence**:
- `DSStoryNarrativeInsight` adds `evidence`, `riskLevel`, `connection` (`ds_story_panel.dart:193-211`)
- `_InsightRow.build` only paints `text` / `detail` / `value` (`ds_story_panel.dart:101-148`) — never branches on `DSStoryNarrativeInsight`
- Tests only construct models / pass lists to constructors; no `pumpWidget` / semantic assertions for the three narrative layers (`story_panel_narrative_test.dart`)

**Impact**: Exit claim “contrato narrativo ajustado para suportar insights” is structurally true but not presentation-true. Hosts cannot show risk/evidence/connection via the panel without custom footers.

**Fix**: Either render the three layers in `_InsightRow` (or an explicit narrative row) and cover with widget tests, or narrow the task claim to “data model only” and document that hosts must render extras themselves.

### F4 — MEDIUM — Public API incomplete for consumer construction

**Evidence**:
- `typedef PrismStoryNarrativeInsight = DSStoryNarrativeInsight` exists (`prism_aliases.dart:620-621`)
- No `PrismInsightRiskLevel` (or other public alias) for `InsightRiskLevel`
- Focused test imports `package:warp_prism_ui/src/organisms/ds_story_panel.dart` internals, not `package:warp_prism_ui/warp_prism_ui.dart`

**Impact**: Documented public consumers cannot construct typed risk insights without leaking DS internals.

**Fix**: Export `PrismInsightRiskLevel` (and preferably cover construction through the public barrel).

### F5 — MEDIUM — Phantom ready-for-review after evidence-only refresh

**Evidence**:
- Task claims `ready_for_reviewer: yes` and Builder Done (`1050-...md:2-4`, `:129`)
- Completion evidence explicitly: “No product/code changes this pass”; only task markdown updated (`:111-113`)
- Prior open findings F1–F4 still open in live artifacts

**Impact**: Inflates promotion readiness; confuses Task 1060 and reviewers.

**Fix**: Keep `ready_for_reviewer: no` until path-to-100 closed; do not claim Builder Done for unfixed contract deliverables.

### F6 — LOW — Focused analyzer info-only noise on task-owned file

**Evidence**: `flutter analyze` on `ds_story_panel.dart` + narrative test → 4 info (`withOpacity`×3, `prefer_const_constructors`×1); exit non-zero for infos; **0 errors**

**Impact**: Non-blocking for correctness if package policy treats infos as soft; still should not be claimed as clean analyze without qualification.

## What Passes

- Narrative **data model** exists: `InsightRiskLevel`, `DSStoryNarrativeInsight` four-layer fields
- Scoped automated tests exist and **reproduce** `+14` green
- Demo script file exists at `docs/demo/epic-10-demo-script.md` with five beats and workspace mapping skeleton
- Changelog engine entry exists (historical): `docs/changelog/20260607-212540-1050-...md`
- Task Where table is monorepo-aligned (partial F3 fix from prior review)

## Commands Re-run (2026-07-09, this review)

```text
cd packages/warp_prism_ui
flutter test test/story_panel_narrative_test.dart --reporter expanded
# → +14 All tests passed

flutter analyze lib/src/organisms/ds_story_panel.dart test/story_panel_narrative_test.dart
# → 4 info issues, 0 errors
```

## Path To 100

1. Rewrite `docs/demo/epic-10-demo-script.md` against live routes: `/map`, `/operate`, `/history`, `/governance`, `/overview`, `/design-system`, `/workspace-snapshot`; label true maturity (real vs placeholder).
2. Delete stale blockers: missing SDK, missing `main.dart`/router/shell/pages, Next.js README claim.
3. Re-source or label all counts/risks from live monorepo evidence; fix test fixture strings that encode dead product state.
4. Render or explicitly demote narrative layers (`evidence`/`risk`/`connection`) and add widget-level proof if rendering is claimed.
5. Add `PrismInsightRiskLevel` public alias; optionally assert public-barrel construction in tests.
6. Set `ready_for_reviewer: no` until above done; then regenerate review packet / promotion state per EPIC-12 if required.

## Lane Action

- **No promotion** to `03-review` (score ≠ 100).
- Task file left under `docs/tasks/02-doing/`.
- No git operations performed.
