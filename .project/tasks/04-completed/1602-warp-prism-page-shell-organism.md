# Task 1602: PrismPageShell Organism

> **Review State**: `Ready For Review`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-16 (`docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md`) + harvest reports `docs/reports/ads-harvest-session-synthesis-2026-07-10.md`, `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md`, `docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md`, `docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md`
> **Blocks**: Task 1613 (soft until registration wave)
> **Depends on**: Task 1600

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1602` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement **`PrismPageShell`** — content-page chrome (icon + title + subtitle + actions + optional toolbar) for CyberCore/admin-style pages. Distinct from app chrome `DSShell`/`DSTopbar`/`DSSidebar`. Public `Prism*` + internal `DS*` + alias; minimal gallery case; fixture-first.

## Background Context

### Source origin (EPIC-16)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismPageShell` |
| **Internal implementation (preferred)** | `DSPageShell` + `typedef PrismPageShell = DSPageShell` in `prism_aliases.dart` |
| **Harvest organism ID** | **C-01** |
| **Origin** | OmniRoute visual-ref page chrome; CyberCore AdminPageShell pattern |
| **Wave** | **J** (Content chrome) |
| **Action type** | `NEW` |
| **Product consumers (later)** | CyberCore admin pages; catalog demos |
| **ADS-first rule** | Gallery + fixtures only — no Observatory product route rewrite for exit |

### What already exists

- App shell: `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart`, `ds_topbar.dart`, `ds_sidebar.dart`.
- Glass/panel atoms: `ds_glass_panel.dart`, spacing/typography tokens.
- Gallery registry under `packages/warp_prism_ui/lib/src/gallery/`.
- Prism alias pattern: `packages/warp_prism_ui/lib/src/prism_aliases.dart`.

### What is missing or broken

- No **in-content** page header organism (title/subtitle/actions/toolbar) separate from app shell.
- CyberCore admin pages lack a reusable ADS page chrome contract.

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell.
- Do **not** rebrand Observatory to OmniRoute teal; keep WP cyan/violet/gold tokens.
- Do **not** port MapLibre/Recharts/Widgetbook.
- Do **not** recreate EPIC-15 Map HUD workspace organisms.

### Composition notes (molecules/atoms may derive later)

- Page title row, action button strip, optional filter toolbar slot.

These molecules are **not** required deliverables; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- MUST render title, optional subtitle, optional leading icon, actions slot, optional toolbar slot, and body/child content.
- MUST support empty actions and no-toolbar states without layout crash.
- Widget tests: default header, with actions, with toolbar, long title overflow/ellipsis policy documented in test.
- A11y: page header region / semantics label for title.
- Minimal gallery case with fixture page (e.g. “Providers” demo).
- Public export: `PrismPageShell` via barrel/aliases; consumers use `package:warp_prism_ui/warp_prism_ui.dart`.

---

## Exit Conditions

- [x] `PrismPageShell` exported (alias + organisms barrel).
- [x] Widget tests + minimal gallery case PASS.
- [x] No app-shell fork; no teal rebrand; no product route rewrite.
- [x] `dart analyze` + scoped `flutter test` PASS on touched paths.
- [x] After barrel/alias changes, `melos run test-boundaries` remains **6/6 PASS**.
- [x] Local changelog entry under `docs/changelog/`.
- [x] Completion Evidence filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md`, `docs/reports/ads-harvest-session-synthesis-2026-07-10.md`, `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md`, Task 1600 brief if present, `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart`, `packages/warp_prism_ui/lib/src/organisms/ds_topbar.dart`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_typography.dart`.
- [x] Define `DSPageShell` API: title, subtitle, leading, actions, toolbar, child.
- [x] Implement layout using existing tokens/atoms; desktop-first.
- [x] Wire exports + `PrismPageShell` alias.
- [x] Widget tests + minimal gallery case.
- [x] **Simplicity pass**: no routing, no prefs, no product coupling.
- [x] **Regression verification**: run validation commands; paste into Completion Evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/page_shell/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/page_shell/ds_page_shell.dart` | Create — implementation |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — `PrismPageShell` alias |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Read — confirm public surface |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — minimal gallery case |
| `packages/warp_prism_ui/test/organisms/page_shell/` | Create — tests |
| `docs/changelog/` | Create — changelog note |

### How

1. Contrast API against `DSShell` so responsibilities stay non-overlapping.
2. Implement header band + body; slots only (no built-in navigation stack).
3. Export, test, minimal gallery fixture page.
4. Run boundaries after alias touch.

### Why

CyberCore admin and ops pages need consistent content chrome without overloading app shell. OmniRoute visual-ref harvest marks this GOLD for EPIC-16 Wave J.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark complete without validation commands and Completion Evidence.
> Do not claim full catalog registration without Task 1613 matrix (minimal case OK).

> [!IMPORTANT]
> Preserve read-only mock-observatory semantics. Prefer fixtures. No live keys,
> no MapLibre/Recharts, no Observatory teal rebrand.

> [!WARNING]
> ADS-first: gallery + fixtures sufficient. Do not rewrite Observatory routes.
> Do not touch unrelated Ganthritor child projects.

---

## Validation Commands

```bash
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/page_shell/
# If path not yet created, use:
# flutter test test/organisms/

cd ../..
melos run test-boundaries
```

If Flutter tooling is unavailable, record the exact tooling failure and do not
claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - Created `packages/warp_prism_ui/lib/src/organisms/page_shell/ds_page_shell.dart`
  - Created `packages/warp_prism_ui/lib/src/organisms/page_shell/page_shell.dart`
  - Created `packages/warp_prism_ui/test/organisms/page_shell/ds_page_shell_test.dart`
  - Created `docs/changelog/2026-07-10-task-1602-page-shell-organism.md`
  - Created `docs/reviews/review-packet-1602.md`
  - Modified `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (export)
  - Modified `packages/warp_prism_ui/lib/src/prism_aliases.dart` (`typedef PrismPageShell = DSPageShell`)
  - Modified `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (Providers fixture)
- **Public API name verified**: `PrismPageShell` via `package:warp_prism_ui/warp_prism_ui.dart` → `src/prism_aliases.dart` → `DSPageShell`
- **Tests or validation commands**:
  ```bash
  cd packages/warp_prism_ui
  dart analyze lib test
  # exit 0 — pre-existing infos only; zero issues on page_shell paths
  flutter test test/organisms/page_shell/
  # 00:01 +9: All tests passed!
  cd ../..
  dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
  # Boundary harness: 6/6 PASS, 0 FAIL, 0 violation(s)
  ```
- **Boundary harness**: **6/6 PASS** (includes “All public DS declarations have Prism aliases”)
- **Local changelog entry**: `docs/changelog/2026-07-10-task-1602-page-shell-organism.md`
- **Review packet**: `docs/reviews/review-packet-1602.md`
- **Agent-wiki / docs institutionalization**: N/A (organism implementation; brief already locked in Task 1600)
- **Executor**: gt-flutter-engineer (builders)
- **Completion date**: 2026-07-10

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review

- **Date**: 2026-07-16
- **Reviewer profile**: `reviewers` (independent adversarial gatekeeper)
- **Score**: `100/100`
- **Verdict**: `PERFECT`
- **Full report**: `docs/reports/review/1602-page-shell-independent-rereview-2026-07-16.md`
- **Lane outcome**: stays in `docs/tasks/03-review/` (100 band; never `04-completed`)
- **Task reference**: Task 1602
- **Live prove (this re-review)**: organism suite **9/9 PASS**; scoped analyze **No issues found**; boundaries **7/7 PASS**; gallery Content Chrome section renders; lifecycle audit 0/0/0/0/0 controllers/subscriptions (pure StatelessWidget)
- **Delta**: prior I1 (actions overflow policy) PERSISTENT as optional polish — desktop-first design intent, documented, no crash; no deduction at ceiling

#### Current Open Blockers

- none

#### Path-to-100 Summary

- At ceiling. Optional future polish: add overflow test for 6+ dense action widgets at 320px width; implement Wrap/trailing menu if overflow confirmed. Not a blocker.

### Previous Reports

- `docs/reports/review-wave-2026-07-11/task-1602-independent-review.md` — initial independent review 2026-07-11 (S=97)

### Regression Guards

- Re-run organism-scoped `flutter test test/organisms/<module>/` after any organism/alias/gallery edit.
- Re-run `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` (or `dart run melos run test-boundaries`) after public DS/Prism surface changes — must stay **6/6 PASS**.
- Consumers must import `package:warp_prism_ui/warp_prism_ui.dart` (Prism* aliases); do not expose raw DS* via public barrel.

---

## Review Ledger — 2026-07-17 Drain Wave (Batch 9)

| Field | Value |
| --- | --- |
| **Score** | 98/100 |
| **Verdict** | PASS |
| **Lane** | 04-completed |
| **Report** | `docs/reports/review-wave-2026-07-17/task-1602-drain-review.md` |
| **Top finding** | Format residual |
| **Reviewer** | independent (parent agentID=reviewers) |
| **Prior treated as** | draft — live re-proved |
