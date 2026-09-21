# Task 1126: README Monorepo Reality Alignment

> **Review State**: Path-to-100 complete after 2026-06-17 rejection (68/100)
> **Priority**: 🟡 P1
> **Type**: `housekeeping`
> **Origin**: Analysis document identifies README as dangerously outdated.
>   Still describes single-app structure with `lib/`, `design_system/`, `assets/`
>   at root level. Real structure is Melos monorepo with `apps/` and `packages/`.
> **Blocks**: None (but every new builder reads the README first)
> **Depends on**: N/A (file update only)
> **Self-score**: 100/100

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1126` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Update `README.md` to reflect the actual Melos monorepo structure. The current
README describes a single-app Flutter project with `lib/` at root, which no
longer exists. A new builder reading this README will act on wrong information.

## Background Context

### What already exists

- `README.md` describes: root `lib/` with `main.dart`, `app/`, `design_system/`,
  `data/`, `assets/`, `test/` — all at root level.
- `README.md` lists Stack as: Flutter, go_router, flutter_riverpod, graphview,
  fl_chart — which is the Observatory app's stack, not the monorepo's.
- `README.md` references Tasks 0010, 0011, 0012 as pending — these are completed.
- `README.md` says "BLOCKER: Flutter SDK is not installed" — this is stale context.

### What the real structure is

```
warp-prism/
  pubspec.yaml              ← Dart 3.12 workspace + Melos 7 (root)
  apps/
    observatory/            ← ASW Observatory (Flutter app)
    catalog/                ← ADS gallery/storybook (Flutter app)
    cybercore/              ← CyberCore pilot (Flutter app)
  packages/
    warp_prism_ui/          ← Reusable ADS package
  docs/
    tasks/                  ← Task governance
    reports/                ← Audit/analysis reports
    changelog/              ← Local changelog
    architecture/           ← Architecture docs
  .agents/
    profiles/               ← Agent continuity
    rules/                  ← Governance rules
    skills/                 ← Parent-canonical skills (symlinked)
    workflows/              ← Local + parent workflows
```

### What is missing or broken

- README does not mention Melos or the monorepo structure.
- README does not mention `apps/` or `packages/`.
- README lists `fl_chart` in the stack but it may not be a monorepo-wide dependency.
- README references pending tasks that are completed.
- README validation section is outdated.

---

## Test Requirements

- README accurately describes the monorepo structure.
- README lists the correct validation commands (`dart run melos run analyze`,
  `dart run melos run test`, `dart run melos run validate`).
- README does not reference stale task statuses.

---

## Exit Conditions

- [x] `README.md` accurately describes: root workspace, `apps/observatory`,
  `apps/catalog`, `apps/cybercore`, `packages/warp_prism_ui`.
- [x] `README.md` lists correct setup commands: `dart pub get`,
  `dart run melos bootstrap`.
- [x] `README.md` lists correct validation commands: `dart run melos run analyze`,
  `dart run melos run test`, `dart run melos run validate`.
- [x] `README.md` does not reference stale task statuses or blocked entries.
- [x] `README.md` identifies `warp_prism_ui` as the reusable ADS and live
  `Prism*` public aliases (`PrismColors`, `PrismTypography`, `PrismSpacing`).
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.
- [x] Path-to-100 rejection findings closed with live stdout (2026-07-09).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read `README.md`,
  root `pubspec.yaml`, `packages/warp_prism_ui/pubspec.yaml`,
  `docs/architecture/warp-prism-melos-monorepo-architecture.md`.
- [x] Update Project Structure section to reflect the monorepo.
- [x] Update Stack section to distinguish monorepo-level and app-level dependencies.
- [x] Update Setup section with `dart pub get` and `dart run melos bootstrap`.
- [x] Update Validation section with repository-local Melos commands.
- [x] Remove stale references to pending tasks and SDK blocker.
- [x] Add note about live `Prism*` public aliases and `DS*` as internal.
- [x] **Simplicity pass**: keep README concise. Do not duplicate architecture doc.
- [x] **Regression verification**: verify all mentioned paths exist.
- [x] **Path-to-100 (2026-07-09)**: close review findings on Melos invocation,
  Prism API, corpus path, and pre-existing failure policy evidence.

### Where

| File | Purpose |
| --- | --- |
| `README.md` | Modify — align with monorepo reality |
| `pubspec.yaml` (root) | Read — workspace config |
| `docs/architecture/warp-prism-melos-monorepo-architecture.md` | Read — architecture reference |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Read — live public API |
| `docs/changelog/` | Create path-to-100 entry |

### How

1. Read the current README and the architecture doc.
2. Rewrite the structure, setup, validation, and design system sections.
3. Verify all paths mentioned exist.
4. Keep it concise.
5. After review rejection, re-verify live commands and API before re-promotion.

### Why

The README is the first file every builder, reviewer, or agent reads. If it
describes a structure that no longer exists, every subsequent action is based
on wrong information. This is a 10-minute fix that prevents hours of confusion.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not delete the README. Modify it in place. Preserve any sections that are
> still accurate (e.g., Mock Workspace Corpus description).

> [!IMPORTANT]
> Do not add information that cannot be verified. If unsure about a dependency
> version, read the actual pubspec.yaml.

---

## Validation Commands

```bash
# Structure
ls apps/ packages/
test -d apps/observatory/assets/mock_workspace && echo OBS_CORPUS_OK
test ! -d assets/mock_workspace && echo ROOT_ASSETS_ABSENT_OK

# Repository-local Melos (no global binary required)
dart pub get
dart run melos bootstrap
dart run melos --version
dart run melos run test-boundaries

# Public API truth
rg -n "typedef PrismColors|typedef PrismTypography|typedef PrismSpacing|PrismTokens" packages/warp_prism_ui/lib --type dart

# README claim checks
rg -n "dart run melos|PrismColors|mock_workspace|PrismTokens" README.md
```

---

## Completion Evidence

### Historical (2026-06-09 initial delivery)

- **Files created/modified**: `README.md` (rewritten), `docs/changelog/20260609-112600-1126-2026-06-09-task-1126-readme-monorepo-alignment-builders.md` (created)
- **Tests or validation commands**: `cat README.md | grep -q "melos" && cat README.md | grep -q "warp_prism_ui"` — PASS
- **Local changelog entry**: `docs/changelog/20260609-112600-1126-2026-06-09-task-1126-readme-monorepo-alignment-builders.md`
- **Executor**: builders
- **Completion date**: 2026-06-09

### **2026-07-09 Path-to-100 Refresh**

- **Files created/modified**:
  - `README.md` — surgical monorepo reality alignment (authorized by this task)
  - `docs/changelog/20260709-151714-1126-readme-path-to-100-builders.md` — path-to-100 changelog
  - this task file — evidence + policy classification
- **Executor**: builders (parent agentID)
- **Completion date**: 2026-07-09

#### Live command output (exact)

```text
command -v melos
→ (no output)
→ global_melos_exit:1

dart run melos --version
→ 7.8.1
→ There is a new version of melos available (8.2.0).

dart pub get
→ Got dependencies!
→ 15 packages have newer versions incompatible with dependency constraints.
→ pubget_exit:0

dart run melos bootstrap
→ Running "flutter pub get" in workspace...
→   > SUCCESS
→ Generating IntelliJ IDE files...
→   > SUCCESS
→  -> 4 packages bootstrapped
→ bootstrap_exit:0

dart run melos run test-boundaries
→ Boundary Test Harness (pure Dart)
→ Checks: 7/7 PASS
→ [PASS] CyberCore contains zero DS* references
→ [PASS] Consumer apps do not import warp_prism_ui src/ paths
→ [PASS] warp_prism_ui does not import Riverpod or GoRouter
→ [PASS] warp_prism_ui does not import app-specific packages
→ [PASS] All public DS declarations have Prism aliases
→ [PASS] Public barrel hides DS* names from consumers
→ Boundary harness: 7/7 PASS, 0 FAIL, 0 violation(s)

Path existence:
→ EXISTS: apps/observatory
→ EXISTS: apps/catalog
→ EXISTS: apps/cybercore
→ EXISTS: packages/warp_prism_ui
→ EXISTS: apps/observatory/assets/mock_workspace
→ EXISTS: packages/warp_prism_ui/lib/src/prism_aliases.dart
→ ROOT_ASSETS_ABSENT: OK

Prism API (live):
→ packages/warp_prism_ui/lib/src/prism_aliases.dart:261:typedef PrismColors = DSColors;
→ packages/warp_prism_ui/lib/src/prism_aliases.dart:267:typedef PrismSpacing = DSSpacing;
→ packages/warp_prism_ui/lib/src/prism_aliases.dart:273:typedef PrismTypography = DSTypography;
→ (no PrismTokens symbol in packages/warp_prism_ui/lib)

Changelog validate (child-local ledger):
→ GANTHRITOR_CHANGELOG_DIR=docs/changelog bash .agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate
→ ERROR: Missing 'timestamp' in 1302-public-barrel-audit.md
```

#### README claim corrections applied

| Rejection finding | Fix |
|---|---|
| Global `melos` / `dart pub global activate melos` | Documented repository-local `dart run melos bootstrap` and `dart run melos run <script>` only |
| Fabricated `PrismTokens.*` | Documented live `PrismColors`, `PrismTypography`, `PrismSpacing` with real fields (`obsidianDeep`, `md`, `displayLarge`) |
| Root `assets/mock_workspace/` | Corrected to `apps/observatory/assets/mock_workspace/`; root path explicitly absent |
| Workspace glob contamination blocking `dart pub get` | Live re-check: `dart pub get` exit 0; nested cache contamination no longer present under `apps/observatory/tmp/` |
| Fabricated template alias risk | Documented that `MasterDetailTemplate` exists under `src/templates/` but is **not** a `Prism*` public alias yet |

#### Pre-existing failure classification (`.agents/rules/pre-existing-failure-policy.md`)

| Failure | Classification | Evidence |
|---|---|---|
| `Missing 'timestamp' in 1302-public-barrel-audit.md` under `GANTHRITOR_CHANGELOG_DIR=docs/changelog ... validate` | **Pre-existing (unrelated)** | Failing file is `docs/changelog/1302-public-barrel-audit.md` (Task 1302). Task 1126 touch set is only `README.md`, this task file, and the 1126 changelog entries. No Task 1126 edit touches 1302. Before/after diagnostic is identical (`Missing 'timestamp' in 1302-public-barrel-audit.md`). Broader child changelog hygiene debt: 48 ledger files missing timestamp/frontmatter contract among ~127 total. |
| `dart run melos run analyze` package analyzer issues (`warp_prism_ui` / `warp_prism_observatory`) | **Pre-existing (unrelated)** | Analyzer/test debt inventory under `docs/reports/warp-prism-test-failure-baseline.md`. Task 1126 is documentation-only and did not touch package source. Documented analyze command remains the correct repository-local invocation; execution is no longer blocked by workspace-resolution failure. |
| Regression count | **NONE** | Documentation-only remediation |

#### Local changelog entries

- Historical: `docs/changelog/20260609-112600-1126-2026-06-09-task-1126-readme-monorepo-alignment-builders.md`
- Path-to-100: `docs/changelog/20260709-151714-1126-readme-path-to-100-builders.md`

---

## Review Ledger

| Date | Reviewer | Score | Disposition | Report |
|------|----------|-------|-------------|--------|
| 2026-06-17 | reviewers / Wave 0 triage | 68/100 | REJECT — moved to `02-doing/` | `docs/reports/build-gate-review/1126-review.md` |
| 2026-07-09 | builders (self-score, pre-review) | 100/100 | Path-to-100 complete — promote to `03-review/` | this Completion Evidence block |

**Rejection rationale** (historical 2026-06-17):

- `README.md` documented global `melos` commands, but live `melos --version` failed (`command not found`); root `pubspec.yaml` declares repository-local Melos and scripts use `dart run melos`.
- `dart pub get` / Melos dispatch historically failed because workspace globs included nested `apps/observatory/tmp/pub-cache/...` packages lacking `resolution: workspace`.
- `README.md` documented nonexistent `PrismTokens.*`; live public aliases are `PrismColors`, `PrismTypography`, and `PrismSpacing`.
- `README.md` pointed to nonexistent root `assets/mock_workspace/`; live corpus is `apps/observatory/assets/mock_workspace/`.
- Changelog validation failed with `Missing 'timestamp' in 1302-public-barrel-audit.md` without policy-compliant pre-existing classification.

**Path to 100** (historical request → 2026-07-09 disposition):

| Requested action | Status |
|---|---|
| Correct README to repository-local Melos workflow | DONE — `dart run melos …` throughout |
| Fix/verify workspace glob contamination so setup commands execute | DONE — live `dart pub get` + `dart run melos bootstrap` exit 0 |
| Replace fabricated `PrismTokens` with exported symbols | DONE — live typedefs documented |
| Correct corpus path | DONE — `apps/observatory/assets/mock_workspace/` |
| Record policy-compliant pre-existing failure evidence | DONE — see classification table above |
| Rerun every documented setup/validation/path/API check with live output | DONE — exact stdout captured in Path-to-100 Refresh |

> **STATUS**: Ready for independent review. All exit conditions met with live evidence. Documentation-only task; protected `README.md` edits are explicitly authorized by this task's objective and `Where` table.

## Post-Promotion Evidence — 2026-07-09

```text
test -f docs/tasks/03-review/1126-warp-prism-readme-monorepo-reality-alignment.md && echo IN_REVIEW: OK
→ IN_REVIEW: OK

test ! -f docs/tasks/02-doing/1126-warp-prism-readme-monorepo-reality-alignment.md && echo NOT_IN_DOING: OK
→ NOT_IN_DOING: OK
```

- Header/status: Done / path-to-100 complete; ready for independent review (review lane).
- Tasklist: child Warp Prism lane move only; no parent `rebuild-tasklist.sh` required for this local namespace promotion.
- Changelog validation run separately from tasklist (see Path-to-100 Refresh): fails only on pre-existing unrelated `1302-public-barrel-audit.md` missing timestamp.
- Generated indexes: not affected (docs/README only; no skill/agent index mutation).
- Older `02-doing` lane proofs and 2026-06-09 completion evidence remain historical/superseded by the 2026-07-09 Path-to-100 Refresh + this post-promotion block.

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `94/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-1126-readme-monorepo-reality-alignment-independent-rereview.md`
- **Lane outcome**: remains in review
- **Task reference**: Task 1126 (`warp-prism-readme-monorepo-reality-alignment`)

#### Current Open Blockers

- None blocking. Residual note: residual baseline table overstates WARNING (live package analyze is INFO-only, 0 WARNING, 0 ERROR).

#### Path-to-100 Summary

1. Soften residual WARNING wording if still accurate at edit time.
2. Optional corpus-count approximate disclaimer.

### Previous Reports

- `2026-06-17` — `68/100` — `docs/reports/build-gate-review/1126-review.md`
  - **Carried forward**: none functional
  - **Resolved since**: repository-local Melos, live Prism API, corpus path, policy-classified changelog failure
  - **Regression guard**: never reintroduce global `melos` prerequisite, fabricated `PrismTokens`, or root `assets/mock_workspace/`
---


---

### 2026-07-17 — drain independent re-review (reviewers)
- **Score**: `91/100`
- **Verdict**: `ACCEPTED_PATH_TO_100` → **Promoted** to `docs/tasks/04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1126-drain-review.md`
- **Prior**: 94/100 (draft; revalidated live)
- **Top residual / path-to-100**: README residual table refreshed to live 7/7 and INFO class (24 lib / 52 observatory as of 2026-07-17)
- **Lane outcome**: `04-completed/`


### 2026-07-18 path-to-100 batch4 (builders)
- Residual table/CE boundary cardinality **6/6 → 7/7**; aligns with live harness + README.
- Report notes: `docs/reports/path-to-100-wave-2026-07-17/batch4-notes.md`
- Lane: left in `03-review/` (no self-promote)

---

### 2026-07-18 — independent path-to-100 re-review (reviewers, batch R4)
- **Score**: `99/100`
- **Verdict**: `ACCEPTED_PATH_TO_100` → **Promoted** to `docs/tasks/04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-18/task-1126-path100-rereview.md`
- **path100_applied**: yes — residual table 6→7 closed by batch4; re-read README live
- **Live exits**: README packages/apps map; melos via dart run; boundary 7/7; no greenwashed full test claim
- **Top residual**: none material — README boundary 7/7 and package map current
- **Lane outcome**: `03-review/` → `04-completed/`
- **No git / no tasklist**
