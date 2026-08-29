# Task 1517: PrismTerminalWorkspace Fixture Shell

> **Review State**: `In 03-review`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1518, Task 1519
> **Depends on**: Task 1500

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1517` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement `PrismTerminalWorkspace` multi-pane sovereign console **shell** with fixture panes (not a real PTY). Layout + chrome for future terminal backends.

---

## Background Context

### Source origin (EPIC-15)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismTerminalWorkspace` |
| **Internal implementation (preferred)** | `DSTerminalWorkspace` + `typedef PrismTerminalWorkspace = DSTerminalWorkspace` in `prism_aliases.dart` (match existing ADS pattern) |
| **Harvest organism ID** | `O-21` |
| **ShadowBroker origin** | `InfonetTerminal/*` multi-module console shell |
| **Osiris origin** | N/A |
| **Wave** | **H** |
| **Action type** | `NEW` |
| **Product consumers (later)** | CyberCore ops console shell; fixture multi-pane |
| **ADS-first rule** | Gallery + fixtures only — **no** Observatory product route rewrite required for exit |

### What already exists

- `DSSplitPane`, `DSTabBar`, `DSLogViewer`, code block.
- Agent shell (Task 1518) will consume this host.

### What is missing or broken

- No multi-pane terminal workspace organism.
- No fixture console gallery for CyberCore.

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell — HUD workspace is an **additional** layout class over a stage slot.
- Do **not** port MapLibre, react-map-gl, force-graph JS, xterm.js, or reference megafiles.
- Do **not** invent domain one-off panels (Shodan/SCM/radio) — prefer generic slots + `PrismConnectorPanel` where applicable.
- Compose existing organisms (`DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSCommandPalette`, toast system, tab bar, split pane) rather than forking them.

### Composition notes (molecules/atoms may derive later)

- Console pane header
- Pane focus indicator

These molecules are **not** required deliverables of this task; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- MUST layout ≥2 panes (tabs or split) from fixtures.
- MUST support pane focus switching.
- MUST NOT embed xterm.js or real PTY.
- Widget tests: switch pane, empty pane, chrome actions.
- A11y labels on pane tabs/controls.
- Gallery fixture workspace.

---

## Exit Conditions

- [x] `PrismTerminalWorkspace` exported.
- [x] Tests + gallery PASS.
- [x] No xterm/PTY dependency.
- [x] Analyze + scoped test PASS.
- [x] Local changelog entry added under `docs/changelog/` (or project changelog engine path used by current Warp Prism closeout).
- [x] Completion Evidence is filled before review handoff.
- [x] After barrel/alias changes, boundary harness remains **7/7 PASS**.
- [x] Pane close disposes per-pane controllers (drain path-to-100 B1).
- [x] Post-frame scroll guarded with `mounted` + map membership (B2).
- [x] Clear/close chrome ≥48×48 (B3).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read EPIC-15, harvests, organisms barrel, prism_aliases, gallery, glass panel, tokens, drain review.
- [x] Define pane model.
- [x] Implement multi-pane shell composing split/tab organisms.
- [x] Fixture pane bodies (log/text).
- [x] Tests + gallery + exports.
- [x] **Lifecycle path-to-100**: `_disposePaneResources` / `_reconcilePaneResources` on close; post-frame guards; 48dp chrome; resource-leak test.
- [x] **Simplicity pass**: fixture-first; no product route coupling; no real PTY.
- [x] **Regression verification**: validation commands.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/terminal_workspace/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/terminal_workspace/ds_terminal_workspace.dart` | Create — implementation |
| `packages/warp_prism_ui/lib/src/organisms/split_pane/ds_split_pane.dart` | Read — compose |
| `packages/warp_prism_ui/lib/src/organisms/tab_bar/` | Read — compose |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/terminal_workspace/` | Create — tests |

### How

1. Compose split/tab into console chrome.
2. Fixture text/log panes only.
3. Export/test/gallery.
4. Evict+dispose controllers when panes leave model.

### Why

CyberCore needs a terminal workspace shell before real agent PTY backends exist.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running the validation commands and
> filling Completion Evidence. Do not claim gallery/catalog registration without
> a navigable section or an explicit deferred note pointing at Task 1519.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. Prefer fixture/mock
> data. No live API keys, no mesh crypto, no MapLibre engine port, no SQLite.

> [!WARNING]
> ADS-first delivery: fixtures + design-system gallery are sufficient. Do **not**
> rewrite Observatory Map/Operate/History routes unless a separate integration
> task exists. Do not touch unrelated Ganthritor child projects.

> [!CAUTION]
> No xterm.js port. No mesh crypto. Fixture shell only.

---

## Validation Commands

```bash
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/terminal_workspace/
cd ../..
melos run test-boundaries
# fallback:
# dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
```

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/lib/src/organisms/terminal_workspace/ds_terminal_workspace.dart`
  - `packages/warp_prism_ui/lib/src/organisms/terminal_workspace/terminal_workspace.dart`
  - `packages/warp_prism_ui/lib/src/organisms/organisms.dart`
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart`
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
  - `packages/warp_prism_ui/test/organisms/terminal_workspace/ds_terminal_workspace_test.dart`
  - `docs/changelog/2026-07-15-task1517-terminal-workspace-fixture-shell.md`
  - `docs/changelog/20260718-052900-1517-terminal-workspace-lifecycle-path-to-100-gt-flutter-engineer.md`
- **Public API**: `PrismTerminalWorkspace`, `PrismTerminalPane`, `PrismTerminalLayoutMode`, `PrismTerminalWorkspaceController`
- **Lifecycle fix (drain B1–B3)**:
  - `_disposePaneResources` / `_reconcilePaneResources` on controller listener
  - post-frame `if (!mounted) return` + map re-lookup
  - clear/close `SizedBox.square(dimension: 48)` + IconButton 48 constraints
  - test: close pane → `debugOwnedPaneResourceCount` drops; reopen clean
- **Tests or validation commands** (2026-07-18T05:28Z):
  - `dart analyze` owned surfaces → **No issues found**
  - `flutter test test/organisms/terminal_workspace/ --concurrency=1 --no-pub` → **10/10 PASS**
  - `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` → **7/7 PASS**
- **Boundary harness**: 7/7 PASS
- **Local changelog entry**: `docs/changelog/20260718-052900-1517-terminal-workspace-lifecycle-path-to-100-gt-flutter-engineer.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: gt-flutter-engineer (under parent builder-orchestrator)
- **Completion date**: 2026-07-18
- **Lane**: left in `02-doing` per builder compact (no promote)

### Changelog Draft

```yaml
task: "1517"
agent: gt-flutter-engineer
project: warp-prism
title: "Terminal workspace fixture shell + lifecycle path-to-100"
description: "Multi-pane fixture console; dispose pane controllers on close; 48dp chrome"
summary: >
  DSTerminalWorkspace with tabs/split, focus, fixture logs; controller reconcile
  on pane close; post-frame mounted guards; 10 widget tests; boundaries 7/7.
verification: >
  dart analyze clean; flutter test terminal_workspace 10/10;
  boundary harness 7/7 PASS; no xterm/PTY
```

### Entrypoint Chain Proof

- **Claim**: helper/library-only ADS organism (fixture shell)
- **Classification**: `helper/library-only` — no product route wiring required
- **Helper**: `DSTerminalWorkspace` / controller
- **Regression test**: close-pane resource count + chrome 48dp tests

## Independent Review Ledger — 2026-08-23 — reviewers

- **Score:** 96/100
- **Verdict:** `ACCEPTED_WITH_NOTE`
- **Full report:** `docs/reports/review/independent-2026-08-23-task-1517.md`
- **Lane outcome:** remains `docs/tasks/03-review/`
- **Live proof:** organism analyzer clean; focused suite 11/11; boundary 7/7; lifecycle guards and 48dp chrome verified in source.
- **Note (non-blocking):** terminal test imports the internal `src/` path and mirrors Prism typedefs locally instead of proving the public barrel contract directly.

## Independent Live Review Ledger — Third Batch — 2026-08-23

- **Score:** 94/100
- **Verdict:** `ACCEPTED_WITH_NOTE`
- **Full report:** `docs/reports/review/independent-2026-08-23-third-batch-task-1517.md`
- **Lane outcome:** remains `docs/tasks/03-review/`
- **Fresh proof:** native-assets launch blocker repaired non-destructively; Chrome focused suite 11/11; boundary 7/7; gallery 22/22; scoped analyzer clean.
- **Open notes:** focused test still bypasses public barrel with local typedef mirrors; non-mutating formatter reports `ds_terminal_workspace.dart` changed. Package analyzer exit 0 with 218 info-level findings, not claimed clean/no-output.

## Self-Close Re-review — 2026-08-24 — builders

- **Score:** 100/100
- **Verdict:** `ACCEPT`
- **Full report:** `docs/reports/review/20260824-task-1517-prism-terminal-workspace-review.md`
- **Lane outcome:** remains `docs/tasks/02-doing/1517-warp-prism-terminal-workspace-fixture-shell.md` (no lane move)
- **Fresh proof:** format clean, public barrel `warp_prism_ui.dart` imports directly tested, local typedef mirrors removed, 11/11 tests PASS, boundary 7/7 PASS.

## Independent Bundled Review — 2026-08-24 — reviewers

- **Score:** **100/100**
- **Verdict:** `ACCEPTED_100`
- **Full report:** `docs/reports/review/20260824-builders-tasks-1706-1707-1517-independent-review.md`
- **Lane outcome:** `docs/tasks/03-review/1517-warp-prism-terminal-workspace-fixture-shell.md` — moved and verified collision-safely.
- **Fresh proof:** focused 11/11, scoped analyzer clean, gallery 22/22, non-mutating formatter clean, boundary 7/7; public-barrel imports and lifecycle source guards re-read.
- **Open score-relevant findings:** none. Future unmount/post-frame regression coverage is informational only.

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review

- **Date**: 2026-07-18
- **Reviewer profile**: `gt-flutter-code-reviewer` (formal path-to-100 under builders)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review/formal-2026-07-18-task-1517.md`
- **Lane outcome**: remains `03-review/`
- **Task reference**: Task 1517 (`1517-warp-prism-terminal-workspace-fixture-shell`)

#### Current Open Blockers

- none

#### Prior Open Blockers (closed this path-to-100)

- ~~I1 `mounted` guard in `_onControllerModelChanged`~~ → `if (!mounted) return` before setState; 11/11 tests; analyze clean

### Previous Reports

| Date | Reviewer | Score | Verdict | Report |
| --- | --- | --- | --- | --- |
| 2026-07-16 | reviewers | **97** | **PASS** (narrow patch recommended) | `docs/reports/review/1517-terminal-workspace-fixture-shell-review-2026-07-16.md` |
| 2026-07-17 | independent (drain) | **86** | **REJECT — lifecycle** | `docs/reports/review-wave-2026-07-17/task-1517-drain-review.md` |
| 2026-07-18 | gt-flutter-expert | **100** (before residual **93**) | **ACCEPTED_100** — lane stays `02-doing` | `docs/reports/review/expert-2026-07-18-task-1517.md` |
| 2026-07-18 | gt-flutter-code-reviewer | **99→100** | **ACCEPTED_100** (path-to-100) | `docs/reports/review/formal-2026-07-18-task-1517.md` |

### Path-to-100 residual (addressed)

- [x] Pane close disposes Scroll/Text/Focus controllers
- [x] Post-frame mounted + map-key guard
- [x] 48×48 clear/close chrome
- [x] Auto-scroll only on history growth (no focus thrash) + test (expert 2026-07-18)
- [x] Models/controller extracted to `ds_terminal_workspace_models.dart`
- [x] Format + re-run organism suite + boundaries

#### Regression Guards

- `debugOwnedPaneResourceCount` drops on pane close
- Clear/close chrome 48×48
- Focus change does not force-scroll; history growth does


## Review/Fix Ledger — 2026-08-24 Wave 4 (BUILDER_CONTEXT; parent `builders`)

- **Engineer session/task ID**: `ses_fcdddc95affeg7uzxV6evqck15`
- **Execution outcome**: drain-drift reconciliation + fresh gates + self-close score-only PASS
- **Next routing**: independent BUILDER_CONTEXT re-review dispatched by parent
