# Task 0019: Warp Prism Preset Workspace Snapshot Starter

> **Review State**: `Ready For Review` — independent S=100 (2026-07-10); promoted to `03-review/`
> **Lane**: `02-doing`
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: `.agents/user/warp-prism2.txt` research + user request for immediate workspace visibility utility
> **Blocks**: Task 0020
> **Depends on**: Task 0011, Task 0017

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0019` when referencing this work from
> later Warp Prism build slices. Lanes such as `02-doing` and `03-review` are
> mutable status, not identity.

---

## Objective

Create the first genuinely useful read-only Warp Prism surface: a route that
scans a preset workspace directory and displays discovered agents, skills,
workflows, tasks, and changelog entries using the existing design system. This
is the "holy shit, this already helps me" moment — a Workspace Snapshot that
works immediately against the Ganthritor root without requiring mock corpus
setup, graph normalization, or EPIC-03 data layer completion.

Completion means a developer can run `flutter run -d linux
--dart-define=ASW_WORKSPACE_ROOT=/home/sephiroth/working/ganthritor` and see a
beautiful read-only dashboard of everything in that workspace.

---

## Background Context

### What already exists

- `warp-prism/pubspec.yaml` declares Flutter, `go_router`, `flutter_riverpod`,
  and the design-system dependencies.
- Design system lives under `packages/warp_prism_ui/` (monorepo).
- Observatory app: `apps/observatory/` (Task 0011 router/shell, Task 0017 gallery).
- `warp-prism/docs/research.md` recommends Phase 1 be "read-only and local:
  scan `.agents/agents`, `.agents/skills`, `.agents/workflows`, `docs/tasks`,
  `docs/changelog`, build a normalized index, expose search/graph/filters."
- `warp-prism/docs/prompt.txt` defines the Overview surface with totals for
  agents, skills, sub-skills, workflows, tasks by lane, changelog entries,
  blockers, review queue, and governance warnings.

### What is missing or broken

- Historical: no route reading a real workspace directory (addressed by this task).
- **2026-07-09 re-review**: claimed symlink-safe scanning was **not** on disk
  (Dart `Directory.list` default `followLinks: true`; no `skippedSymlinks`).
  Path-to-100 work in this session implements the real guardrail.

---

## Test Requirements

- The route MUST read from a configurable workspace root via `--dart-define` or
  equivalent runtime configuration, defaulting to `..` (parent directory) when
  running from `warp-prism/`.
- The scanner MUST detect `.agents/agents/*.md`, `.agents/skills/*/SKILL.md`,
  `.agents/workflows/*.md`, and `docs/tasks/**/*.md` without following
  symlinks into parent-canonical surfaces unless explicitly configured.
- The scanner MUST parse YAML frontmatter when present and gracefully handle
  files without frontmatter.
- The scanner MUST distinguish five task lanes: `00-planning`, `01-open`,
  `02-doing`, `03-review`, `04-completed`.
- The scanner MUST detect `docs/changelog/*.md` files.
- The surface MUST render all discovered assets using DS primitives
  (atoms/molecules/organisms) rather than bespoke widget styling.
- The surface MUST show a workspace root path and scan status
  (loading/success/error/empty).
- The surface MUST remain strictly read-only.

---

## Exit Conditions

- [x] A `WorkspaceSource` abstract interface exists under
  `apps/observatory/lib/data/sources/`.
- [x] A `PresetLocalWorkspaceSource` implementation exists that reads from a
  configurable root path **with `followLinks: false` by default**.
- [x] A `WorkspaceSnapshot` typed aggregate exists under
  `apps/observatory/lib/data/models/` returning agents, skills, workflows, tasks by
  lane, changelog entries, and scan metadata including `skippedSymlinks`.
- [x] A route exists (e.g., `/workspace-snapshot` or integrated as the default
  Overview fallback) that loads the preset source and renders the snapshot.
- [x] The surface shows: workspace root path, scan status, agent count, skill
  count, workflow count, task count by lane, changelog count, and at least one
  card list per asset type.
- [x] Scoped `flutter analyze` / `dart analyze` on production snapshot surfaces
  passes without errors or warnings (0 INFO residual on production lib after
  prefer_const pass).
- [x] Scanner tests pass including symlink-skip default and symlink-follow opt-in.
- [x] Core page state tests pass (loading / loaded / error / empty).
- [x] Local changelog entry added under `warp-prism/docs/changelog/`.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: monorepo observatory sources,
  models, providers, page, router, prior review report, task guardrails.
- [x] Define `WorkspaceSource` abstract interface and `WorkspaceSnapshot`
  aggregate model (pre-existing; extended metadata this session).
- [x] Implement `PresetLocalWorkspaceSource` that scans a root path using
  `dart:io` `Directory`/`File` operations:
  - enumerate `.agents/agents/*.md`
  - enumerate `.agents/skills/*/SKILL.md` and detect sub-skills/workflows
  - enumerate `.agents/workflows/*.md`
  - enumerate `docs/tasks/{00-planning,01-open,02-doing,03-review,04-completed}/*.md`
  - enumerate `docs/changelog/*.md`
  - parse frontmatter from each file
  - return `WorkspaceSnapshot` with typed lists and scan metadata
  - **symlink policy**: `followLinks: false` default; record `skippedSymlinks`
- [x] Wire the source into a Riverpod provider so the UI layer consumes
  async/snapshot states cleanly.
- [x] Create a `WorkspaceSnapshotPage` under
  `apps/observatory/lib/features/workspace_snapshot/` that composes Prism*
  primitives (metric tiles, asset cards, lane summary, scan footer, states).
- [x] Add the route to `apps/observatory/lib/app/router.dart`.
- [x] Support `ASW_WORKSPACE_ROOT` via `--dart-define=ASW_WORKSPACE_ROOT=<path>`,
  defaulting to `..`.
- [x] Add tests: scanner success, empty, missing, multi-asset, lanes, malformed,
  **symlink-skip default**, **symlink-follow opt-in**, **symlink entry skip**;
  page loading/loaded/error/empty.
- [x] **Simplicity pass**: single `_listEntries` helper; no extra frameworks.
- [x] **Regression verification**: run validation commands below (see Completion Evidence).

### Where

| File | Purpose |
| --- | --- |
| `apps/observatory/pubspec.yaml` | Read — package deps |
| `apps/observatory/lib/app/router.dart` | Read/Modify — `/workspace-snapshot` route (pre-existing) |
| `apps/observatory/lib/data/models/workspace_snapshot.dart` | Modify — `skippedSymlinks` on `WorkspaceScanMetadata` |
| `apps/observatory/lib/data/sources/workspace_source.dart` | Read — abstract source interface |
| `apps/observatory/lib/data/sources/preset_local_workspace_source.dart` | Modify — `followLinks` + skip provenance |
| `apps/observatory/lib/data/sources/sources.dart` | Read — barrel |
| `apps/observatory/lib/data/parsers/workspace_markdown_parser.dart` | Read — frontmatter parser reuse |
| `apps/observatory/lib/features/workspace_snapshot/workspace_snapshot_page.dart` | Modify — prefer_const cleanup |
| `apps/observatory/lib/features/workspace_snapshot/workspace_snapshot_provider.dart` | Read — Riverpod + `ASW_WORKSPACE_ROOT` |
| `apps/observatory/lib/features/workspace_snapshot/widgets/*` | Modify — prefer_const cleanup on panels |
| `apps/observatory/test/data/sources/preset_local_workspace_source_test.dart` | Modify — +3 symlink tests |
| `apps/observatory/test/features/workspace_snapshot/workspace_snapshot_page_test.dart` | Read — core page states (shared with 0020 extras) |
| `docs/prompt.txt` | Read — Overview metrics contract |
| `docs/research.md` | Read — Phase 1 read-only recommendation |
| `docs/changelog/2026-07-09-task-0019-symlink-guardrail-path-to-100.md` | Create — this session |
| `docs/reports/review-wave-2026-07-09/task-0019-preset-workspace-snapshot-starter-independent-rereview.md` | Read — S=74 blockers |

### How

1. `WorkspaceSource.load(String rootPath)` → `WorkspaceSnapshot`.
2. `PresetLocalWorkspaceSource({followLinks: false})` lists with
   `Directory.list(followLinks: followLinks)`; skips symlink roots/entries when
   false; records paths on `WorkspaceScanMetadata.skippedSymlinks`.
3. `const String.fromEnvironment('ASW_WORKSPACE_ROOT', defaultValue: '..')`
   in provider.
4. Riverpod `AsyncNotifierProvider` for loading/success/error.
5. Page composes Prism primitives only; read-only.
6. Fixture temp dirs for scanner tests; real `Link.create` for symlink cases.

### Why

Immediate value from a real workspace path before EPIC-03 graph/search depth.
Symlink default-false protects parent-canonical harness mounts under
`warp-prism/.agents/{agents,skills}` from silent merge.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT follow symlinks recursively or resolve parent-canonical surfaces
> unless the scanner is explicitly configured to do so. If `.agents/skills` is
> a symlink to `../../.agents/skills`, the scanner should detect it as a
> symlink and report provenance, not silently merge parent data.

> [!IMPORTANT]
> Keep this task read-only. No scripts, no rebuilds, no mutations. The scanner
> reads files and returns data; the UI displays data.

> [!IMPORTANT]
> Use existing DS primitives for all visual output. Do not create bespoke
> widget styling for this page.

> [!CAUTION]
> Do not follow this task by implementing graph visualization, search/filter,
> or asset detail views. Those belong to Task 0020.

> [!CAUTION]
> **Regression guard**: never claim symlink-safe scanning or invent test counts;
> prove `followLinks` / `skippedSymlinks` on disk before Completion Evidence.

---

## Validation Commands

```bash
cd apps/observatory
dart analyze --format=machine lib/features/workspace_snapshot/ \
  lib/data/sources/ lib/data/models/workspace_snapshot.dart
flutter analyze lib/data/sources/ lib/data/models/workspace_snapshot.dart \
  lib/features/workspace_snapshot/ \
  test/data/sources/preset_local_workspace_source_test.dart \
  test/features/workspace_snapshot/workspace_snapshot_page_test.dart
flutter test test/data/sources/preset_local_workspace_source_test.dart
flutter test test/features/workspace_snapshot/workspace_snapshot_page_test.dart \
  --name 'renders '
```

If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

> [!IMPORTANT]
> Evidence below is from **live** commands on 2026-07-09 (gt-flutter-engineer
> path-to-100 session). Supersedes prior invented symlink claims.

### Files created/modified (this path-to-100 session)

| Path | Change |
| --- | --- |
| `apps/observatory/lib/data/sources/preset_local_workspace_source.dart` | `followLinks` default **false**; `_listEntries` / `_isUsableFile`; records `skippedSymlinks` |
| `apps/observatory/lib/data/models/workspace_snapshot.dart` | `WorkspaceScanMetadata.skippedSymlinks` field |
| `apps/observatory/test/data/sources/preset_local_workspace_source_test.dart` | +3 symlink cases (scan-root skip, follow opt-in, entry skip) |
| `apps/observatory/lib/features/workspace_snapshot/**` | `dart fix` prefer_const (13 fixes) — production lib infos → 0 |
| `docs/changelog/2026-07-09-task-0019-symlink-guardrail-path-to-100.md` | Session changelog |

### Pre-existing surface (not recreated this session; verified present)

- `apps/observatory/lib/data/sources/workspace_source.dart`
- `apps/observatory/lib/features/workspace_snapshot/workspace_snapshot_page.dart`
- `apps/observatory/lib/features/workspace_snapshot/workspace_snapshot_provider.dart`
- `apps/observatory/lib/features/workspace_snapshot/widgets/*`
- `apps/observatory/lib/app/router.dart` — `/workspace-snapshot`
- Historical: `docs/changelog/20260607-214817-0019-2026-06-07-task-0019-preset-workspace-snapshot-starter-repair-bot.md`

### Live proof — symlink API on disk

```text
# rg followLinks|skippedSymlinks|isLink on production scanner/model
preset_local_workspace_source.dart: followLinks field default false
preset_local_workspace_source.dart: Directory.list(followLinks: followLinks)
preset_local_workspace_source.dart: FileSystemEntity.isLink(...)
workspace_snapshot.dart: final List<String> skippedSymlinks
```

### Tests or validation commands (honest counts)

```text
# CWD: apps/observatory — 2026-07-09

dart analyze --format=machine lib/features/workspace_snapshot/ \
  lib/data/sources/ lib/data/models/workspace_snapshot.dart
# → 0 lines (0 INFO / 0 WARNING / 0 ERROR)

flutter analyze lib/data/sources/ lib/data/models/workspace_snapshot.dart \
  lib/features/workspace_snapshot/ \
  test/data/sources/preset_local_workspace_source_test.dart \
  test/features/workspace_snapshot/workspace_snapshot_page_test.dart
# → 2 issues, all INFO prefer_const_literals_to_create_immutables on
#   test fixture data in workspace_snapshot_page_test.dart only
# → 0 WARNING / 0 ERROR

flutter test test/data/sources/preset_local_workspace_source_test.dart
# → 12/12 passed
#   1 empty  2 missing  3 agents  4 skills  5 tasks  6 changelog
#   7 multi-asset  8 malformed  9 five lanes
#   10 symlink scan-root skip + skippedSymlinks
#   11 symlink followLinks:true merges skill
#   12 symlink entry inside real dir skipped

flutter test test/features/workspace_snapshot/workspace_snapshot_page_test.dart \
  --name 'renders '
# → 4/4 passed (loading / metrics+lists / error / empty)
```

**Not claimed for 0019 exit**: full `workspace_snapshot_page_test.dart` file also
contains Task **0020** path-to-100 extras (card tap, deep-link clear, graph node,
graph mode). As of this session, core 0019 `renders *` cases pass; graph node tap
has been intermittently failing in concurrent 0020 work and is **out of 0019
primary exit** — do not treat it as 0019 symlink proof.

**Not claimed**: `workspace_snapshot_enhanced_test.dart` is Task 0020 surface.

### Local changelog entry

- `docs/changelog/2026-07-09-task-0019-symlink-guardrail-path-to-100.md`

### Executor / date

- **Executor**: gt-flutter-engineer (builders lane worker)
- **Completion date (path-to-100)**: 2026-07-09
- **Lane**: remains `docs/tasks/02-doing/` per instruction (no auto-promote to `03-review`)
- **ready_for_reviewer**: yes (blockers F1/F2 addressed with live proof; independent review required)

**Promotion result**: Not moved. Prior independent re-review returned task to
`02-doing/`. This session applies path-to-100 only; reviewer must re-score.

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `74/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0019-preset-workspace-snapshot-starter-independent-rereview.md`
- **Lane outcome**: returned to `02-doing/`
- **Task reference**: Task 0019 (`0019-warp-prism-preset-workspace-snapshot-starter`)

#### Current Open Blockers (status after path-to-100)

| ID | Prior status | After this session |
| --- | --- | --- |
| F1 symlink guardrail / default followLinks | Open High | **Addressed in code** — needs independent re-proof |
| F2 invented Completion Evidence / missing tests | Open High | **Addressed** — evidence rewritten; 12 live scanner tests |
| F4 pre-monorepo Where + unchecked Details | Open Low | **Addressed** in task file |
| F5 production prefer_const infos | Open Low–Mod | **Addressed** — production lib machine analyze 0 lines |

#### Path-to-100 Summary (executed)

1. [x] Implement symlink policy (`followLinks: false` default); record `skippedSymlinks`.
2. [x] Add symlink-skip default + symlink-follow tests; keep empty/missing/multi-asset.
3. [x] Rewrite Completion Evidence to match disk reality only.
4. [x] Clear production prefer_const infos (0 residual on production snapshot lib).
5. [x] Tick Details honestly; refresh monorepo Where paths; re-run analyze + tests.
6. [ ] Independent re-review → promote if S≥90 (not this session).

#### Commands / exits (this path-to-100 session)

- Production snapshot lib machine analyze → **0 issues**
- Scoped flutter analyze (lib+scanner/page tests) → **2 INFO** (test fixtures only)
- Scanner tests **12/12**
- Page core `renders *` **4/4**

### Previous Reports

- `2026-07-09` — `74/100` — `docs/reports/review-wave-2026-07-09/task-0019-preset-workspace-snapshot-starter-independent-rereview.md` (`REJECTED_TO_DOING`)
- `2026-06-17` — `64/100` — `docs/reports/review-wave-cascade/0019-review.md` (`REJECTED_TO_DOING`)
- Historical build-gate — `100/100` — `docs/reports/build-gate-review/0019-warp-prism-preset-workspace-snapshot-starter.md` (superseded; SDK-blocked)
- **Regression guard**: never claim symlink-safe scanning or invent test counts; prove `followLinks`/`skippedSymlinks` on disk

### Builder path-to-100 note (2026-07-09)

- Agent: `gt-flutter-engineer`
- Report of work: implemented F1/F2 fixes; honest evidence; lane left `02-doing`
- Residual note for reviewers: shared page test file has 0020 graph extras not
  owned by 0019 exit matrix; evaluate symlink proof via scanner suite + source
  inspection first.


### Independent path-to-100 re-review — 2026-07-10 (gt-code-quality-reviewer)

- **Date**: 2026-07-10
- **Reviewer**: `gt-code-quality-reviewer` (reviewers profile)
- **Score**: `100/100`
- **Verdict**: `APPROVED_PROMOTE_TO_REVIEW`
- **Lane outcome**: `docs/tasks/03-review/`
- **Cheap live validation**: flutter test test/data/sources/preset_local_workspace_source_test.dart → 12/12 PASS incl. symlink skip/follow
- **Findings**: None blocking. followLinks default false + skippedSymlinks metadata present in production scanner.
- **Wave report**: `docs/reports/review-wave-2026-07-10/path-to-100-mass-rereview.md`
- **No git operations**.

### Independent path-to-100 re-review — 2026-07-10 (independent wave; reviewers)

- **Date**: 2026-07-10
- **Reviewer profile**: `reviewers` (gt-code-quality-reviewer + flutter-harness)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-10/task-0019-path-to-100-independent-rereview.md`
- **Lane outcome**: remains `docs/tasks/03-review/` (no `04-completed`)
- **Live validation**: scanner **12/12** (symlink skip/follow/entry); page `renders *` **4/4**; production snapshot analyze **No issues found**; `followLinks` default false + `skippedSymlinks`
- **Open blockers**: none
- **Regression guard**: never claim symlink-safe scanning without live `followLinks`/`skippedSymlinks` proof
- **No git operations**.
