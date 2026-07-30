# Corpus and Frontmatter Contract Audit

> **Date**: 2026-06-09 (original audit)
> **Live re-verification**: 2026-07-09 (builder fixer pass after independent re-review S=41)
> **Task**: 1402 — Corpus and Frontmatter Contract Audit
> **EPIC**: 14 — Stabilization Wave
> **Corpus root**: `apps/observatory/assets/mock_workspace/`
> **Contract**: `docs/mock-workspace-corpus-contract.md`
> **Failure baseline**: `docs/reports/observatory-failure-baseline.md` (Task 1401)
> **Audit scope**: Read-only for Task 1402 — no corpus/parser mutation in this task.
> **Downstream remediation**: Task 1403 owns corpus writes; parser `fromStatus` already fixed earlier.

---

## 0. Live Re-verification Summary — 2026-07-09 (fixer)

### 0.1 Measured counts (filesystem, this session)

| Phase | When | TOTAL | WITH_FM | WITHOUT | Nested missing FM |
|---|---|---:|---:|---:|---:|
| **Pre-remediation scan (session start)** | before Task 1403 write | 130 | **91** | **39** | **39** |
| **Post-remediation scan (after Task 1403)** | after real frontmatter write | 130 | **130** | **0** | **0** |

> [!CAUTION]
> A prior 2026-07-09 builder claim of live `WITH_FM=130 WITHOUT=0` was **rejected**
> as phantom (independent re-review measured **91/39** while 1403 was still open).
> This refresh records **both** the honest pre-fix measurement and the
> post-Task-1403 measurement after files were actually rewritten on disk.

### 0.2 Live post-1403 checks

| Check | Live result (post-1403 write) |
|---|---|
| Total `*.md` under mock workspace | **130** |
| Files with YAML frontmatter (`---` opener) | **130/130** |
| Files without frontmatter | **0** |
| Nested skill files (sub-skills / skill-workflows / references) | **39/39** have `name` + `description` |
| Agents / skills / workflows / tasks / changelog schema | **0 schema issues** against required fields |
| Task status vocabulary | `planning=3`, `open=5`, `doing=5`, `review=4`, `completed=5` |
| Live `TaskLaneParsing.fromStatus()` | **Maps bare status words** (verified in `task_contracts.dart`) |
| Broken cross-references | **0** (original audit; structure unchanged) |
| Duplicate YAML keys | **0** |

**Historical vs measured counts:**

| Metric | Original audit 2026-06-09 | Session pre-1403 (true) | Session post-1403 (true) |
|---|---|---|---|
| Total markdown | 130 | 130 | 130 |
| With frontmatter | 91 (arithmetic) / false claim 99 | **91** | **130** |
| Without frontmatter | 39 nested skill files | **39** | **0** |
| `fromStatus` pass-through bug | Present in code | **Already fixed in code** | **Fixed** |

> [!NOTE]
> Task 1402 remains an **audit** task. Corpus mutations are Task 1403. This report
> documents mismatches with correct **actual** columns for each measurement phase.

---

## 1. File Count Summary

| Category | Path pattern | Count | Has FM (pre-1403 session) | Has FM (post-1403 live) | Contract min |
|---|---|---|---|---|---|
| Agents | `.agents/agents/*.md` | 9 | 9/9 ✅ | 9/9 ✅ | 9 |
| Skills (SKILL.md) | `.agents/skills/*/SKILL.md` | 13 | 13/13 ✅ | 13/13 ✅ | 13 |
| Sub-skills | `.agents/skills/*/sub-skills/*.md` | 13 | **0/13** ❌ | 13/13 ✅ | — |
| Skill-workflows | `.agents/skills/*/workflows/*.md` | 13 | **0/13** ❌ | 13/13 ✅ | — |
| References | `.agents/skills/*/references/*.md` | 13 | **0/13** ❌ | 13/13 ✅ | — |
| Workflows | `.agents/workflows/*.md` | 11 | 11/11 ✅ | 11/11 ✅ | 11 |
| Tasks (00-planning) | `docs/tasks/00-planning/*.md` | 3 | 3/3 ✅ | 3/3 ✅ | — |
| Tasks (01-open) | `docs/tasks/01-open/*.md` | 5 | 5/5 ✅ | 5/5 ✅ | — |
| Tasks (02-doing) | `docs/tasks/02-doing/*.md` | 5 | 5/5 ✅ | 5/5 ✅ | — |
| Tasks (03-review) | `docs/tasks/03-review/*.md` | 4 | 4/4 ✅ | 4/4 ✅ | — |
| Tasks (04-completed) | `docs/tasks/04-completed/*.md` | 5 | 5/5 ✅ | 5/5 ✅ | — |
| **Tasks total** | `docs/tasks/**/*.md` | **22** | **22/22 ✅** | **22/22 ✅** | 20 |
| Changelog | `docs/changelog/*.md` | 36 | 36/36 ✅ | 36/36 ✅ | 12 |
| **TOTAL** | | **130** | **91/130** | **130/130** | |

### 1.1 Arithmetic note (reviewer finding closed)

The original 2026-06-09 draft inconsistently claimed **99/130** frontmatter files
while the category table summed to **91** with-frontmatter rows
(`9+13+11+22+36 = 91`) and **39** without (`13+13+13`). Independent re-review and
this session's **pre-1403** scan both confirm **91 with / 39 without** as the
honest pre-remediation truth. **Post-1403** live scan is **130 with / 0 without**
only after Task 1403 actually wrote nested frontmatter.

### 1.2 Historical mismatch class: nested files missing frontmatter (remediated in 1403)

At audit time (and at this session's start), all 39 nested skill markdown files
lacked frontmatter. Task 1403 added minimal valid frontmatter (`name`,
`description`) to every row below. Per-file mismatch inventory is in **§3.2**.

---

## 2. Frontmatter Schema Per Type

### 2.1 Agents — Schema conformance

| Required field | Present in all 9 | Type in corpus |
|---|---|---|
| `name` | ✅ | string |
| `model` | ✅ | string (e.g., `omniroute/architect`) |
| `mode` | ✅ | string (`primary` or `specialized`) |
| `description` | ✅ | string |
| `skills` | ✅ | list of strings |
| `workflows` | ✅ | list of strings |

**Extra fields found**: None. All 9 agents have exactly the 6 required fields.

**Canonicality**: Not set in frontmatter. Parser defaults to
`Canonicality.parentCanonical`. Correct for mock agents.

**Cross-references**: All `skills` and `workflows` lists reference names that
exist as SKILL.md directories and workflow files respectively. No broken references.

**Status**: ✅ Clean.

---

### 2.2 Skills (SKILL.md) — Schema conformance

| Required field | Present in all 13 | Type in corpus |
|---|---|---|
| `name` | ✅ | string |
| `description` | ✅ | string |
| `triggers` | ✅ | list of strings |
| `sub_skills` | ✅ | list of strings |
| `canonicality` | ✅ | string (all `parentCanonical`) |
| `tags` | ✅ | list of strings |

**Extra fields found**: None. All 13 skills have exactly the 6 required fields.

**Cross-references**: All `sub_skills` lists reference names that match
`sub-skills/` directory children. No broken references.

**Status**: ✅ Clean.

---

### 2.3 Nested skill files (sub-skills / skill-workflows / references)

| Required field (post-1403 minimum) | Present in all 39 | Type in corpus |
|---|---|---|
| `name` | ✅ | string (file stem) |
| `description` | ✅ | quoted string |

**Live sample** (`agent-cli-delegation/sub-skills/tool-execution.md`):

```yaml
---
name: tool-execution
description: "Sub-skill of `agent-cli-delegation`. Provides detailed rules and templates for tool-execution operations."
---
```

**Status**: ✅ Clean after Task 1403 remediation (was ❌ missing frontmatter at audit time).

---

### 2.4 Workflows — Schema conformance

| Required field | Present in all 11 | Type in corpus |
|---|---|---|
| `name` | ✅ | string |
| `description` | ✅ | string |
| `uses_skills` | ✅ | list of strings |
| `kind` | ✅ | string (orchestration, audit, review, etc.) |

**Extra fields found**: None. All 11 workflows have exactly the 4 required fields.

**Cross-references**: All `uses_skills` lists reference names that exist as skill
directories. No broken references.

**Status**: ✅ Clean.

---

### 2.5 Tasks — Schema conformance

| Required field | Present in all 22 | Type in corpus |
|---|---|---|
| `id` | ✅ | string (e.g., `T001`, `T022`) |
| `title` | ✅ | quoted string |
| `status` | ✅ | string |
| `priority` | ✅ | string (high/medium/low) |
| `owner` | ✅ | string (agent name) |
| `created` | ✅ | quoted date string |
| `updated` | ✅ | quoted date string |
| `skills` | ✅ | list of strings |
| `workflows` | ✅ | list of strings |
| `depends_on` | ✅ | list of strings |
| `proof_state` | ✅ | string (none/partial/complete) |
| `review_score` | ✅ | number or `n/a` |

**Status values found in corpus (live):**

| Value | Count | Expected lane | Live `fromStatus` maps? |
|---|---|---|---|
| `planning` | 3 | planning | ✅ |
| `open` | 5 | open | ✅ |
| `doing` | 5 | doing | ✅ |
| `review` | 4 | review | ✅ |
| `completed` | 5 | completed | ✅ |

**Extra fields found**: None.

**Cross-references**: All `depends_on` entries reference task IDs that exist in
the corpus. No broken references.

**Status**: ✅ Frontmatter schema clean; status vocabulary now recognized by live
parser (see §3.1 historical finding + live fix).

---

### 2.6 Changelog — Schema conformance

| Required field | Present in all 36 | Type in corpus |
|---|---|---|
| `id` | ✅ | string (e.g., `2025-03-15-T001-workspace-onboarding`) |
| `date` | ✅ | date string |
| `project` | ✅ | string |
| `task` | ✅ | string (e.g., `T001`) |
| `type` | ✅ | string (feature/remediation/audit/refactor/fix/chore) |
| `impact` | ✅ | list of strings |
| `skills` | ✅ | list of strings |

**Extra fields found**: `workflows` — present in some entries, absent in others.
Optional; does not cause parser failure.

**Body sections**: All 36 files contain `## Why`, `## Changed`, and `## Evidence`
headings ✅.

**Dual-era entries**: 15 tasks have two changelog entries — one with
`project: asw-observatory` (2025 dates) and one with `project: warp-prism`
(2026 dates). Intentional corpus breadth, not duplication.

**Status**: ✅ Clean.

---

## 3. Critical Mismatches (audit findings + live disposition)

### 3.1 CRITICAL (historical): `TaskLaneParsing.fromStatus()` pass-through bug

**Severity at audit time**: 🔴 Critical — root cause of 8+ test failures (Task 1401)
**Live disposition (2026-07-09)**: ✅ **FIXED by Task 1403**

**Location**: `apps/observatory/lib/data/models/task_contracts.dart`

**Audit-time buggy code (historical record only)**:
```dart
static TaskLane fromStatus(String status) {
  return fromDirectoryPrefix(status);  // BUG: pass-through
}
```

**Live code (verified 2026-07-09)**:
```dart
static TaskLane fromStatus(String status) {
  switch (status.toLowerCase().trim()) {
    case 'planning':
      return TaskLane.planning;
    case 'open':
      return TaskLane.open;
    case 'doing':
      return TaskLane.doing;
    case 'review':
      return TaskLane.review;
    case 'completed':
      return TaskLane.completed;
    default:
      return fromDirectoryPrefix(status);
  }
}
```

| Field | Expected by parser (live) | Actual in corpus | Recommendation |
|---|---|---|---|
| `status` | bare lane words OR directory prefixes | bare words (`planning`…`completed`) | Keep corpus; parser fixed |

**Diagnosis**: At audit time the **parser was wrong**, not the corpus.
**Action taken under Task 1403**: parser fixed as recommended.
**Task 1402 action**: document only (no parser mutation in audit task).

---

### 3.2 HIGH: Nested skill files missing frontmatter (39 files)

**Severity at audit time / session pre-1403**: 🟠 High — no YAML frontmatter
**Session pre-1403 actual**: **missing** on all 39 nested files (measured)
**Live disposition (post Task 1403 write, same day)**: ✅ **FIXED** — 39/39 have frontmatter

#### Per-file mismatch rows

For every file below, the mismatch class was identical until Task 1403 wrote FM:

| Field | Expected by parser | Actual (pre-1403 measured) | Actual (post-1403 measured) | Recommendation |
|---|---|---|---|---|
| *(document)* | starts with `---` YAML frontmatter | plain markdown body only | present | **Fix corpus** (Task 1403) — done |
| `name` | string present | missing | present (file stem) | Add `name: <file-stem>` — done |
| `description` | string present | missing | present (first prose / quoted) | Add description — done |

##### Sub-skills (13)

| # | File | Field | Expected | Actual (audit) | Actual (live 2026-07-09) | Recommendation / disposition |
|---|---|---|---|---|---|---|
| 1 | `.agents/skills/agent-cli-delegation/sub-skills/tool-execution.md` | frontmatter | present | missing | present (`name=tool-execution`) | Fix corpus → **done 1403** |
| 2 | `.agents/skills/agent-wiki/sub-skills/decision-log.md` | frontmatter | present | missing | present (`name=decision-log`) | Fix corpus → **done 1403** |
| 3 | `.agents/skills/browser-harness/sub-skills/page-navigation.md` | frontmatter | present | missing | present (`name=page-navigation`) | Fix corpus → **done 1403** |
| 4 | `.agents/skills/code-quality-harness/sub-skills/deterministic-checks.md` | frontmatter | present | missing | present (`name=deterministic-checks`) | Fix corpus → **done 1403** |
| 5 | `.agents/skills/coding-execution-harness/sub-skills/code-generation.md` | frontmatter | present | missing | present (`name=code-generation`) | Fix corpus → **done 1403** |
| 6 | `.agents/skills/design-system-harness/sub-skills/token-management.md` | frontmatter | present | missing | present (`name=token-management`) | Fix corpus → **done 1403** |
| 7 | `.agents/skills/development-methodologies/sub-skills/rf8-decomposition.md` | frontmatter | present | missing | present (`name=rf8-decomposition`) | Fix corpus → **done 1403** |
| 8 | `.agents/skills/external-intelligence/sub-skills/source-management.md` | frontmatter | present | missing | present (`name=source-management`) | Fix corpus → **done 1403** |
| 9 | `.agents/skills/frontend-quality-harness/sub-skills/component-quality.md` | frontmatter | present | missing | present (`name=component-quality`) | Fix corpus → **done 1403** |
| 10 | `.agents/skills/harness-architecture/sub-skills/create-agent.md` | frontmatter | present | missing | present (`name=create-agent`) | Fix corpus → **done 1403** |
| 11 | `.agents/skills/indexing-skills/sub-skills/agent-index.md` | frontmatter | present | missing | present (`name=agent-index`) | Fix corpus → **done 1403** |
| 12 | `.agents/skills/project-management/sub-skills/task-creation.md` | frontmatter | present | missing | present (`name=task-creation`) | Fix corpus → **done 1403** |
| 13 | `.agents/skills/remediation-harness/sub-skills/issue-routing.md` | frontmatter | present | missing | present (`name=issue-routing`) | Fix corpus → **done 1403** |

##### Skill-workflows (13)

| # | File | Field | Expected | Actual (audit) | Actual (live 2026-07-09) | Recommendation / disposition |
|---|---|---|---|---|---|---|
| 14 | `.agents/skills/agent-cli-delegation/workflows/tool-chain-workflow.md` | frontmatter | present | missing | present (`name=tool-chain-workflow`) | Fix corpus → **done 1403** |
| 15 | `.agents/skills/agent-wiki/workflows/knowledge-capture-workflow.md` | frontmatter | present | missing | present (`name=knowledge-capture-workflow`) | Fix corpus → **done 1403** |
| 16 | `.agents/skills/browser-harness/workflows/web-research-workflow.md` | frontmatter | present | missing | present (`name=web-research-workflow`) | Fix corpus → **done 1403** |
| 17 | `.agents/skills/code-quality-harness/workflows/review-gate-workflow.md` | frontmatter | present | missing | present (`name=review-gate-workflow`) | Fix corpus → **done 1403** |
| 18 | `.agents/skills/coding-execution-harness/workflows/implementation-loop-workflow.md` | frontmatter | present | missing | present (`name=implementation-loop-workflow`) | Fix corpus → **done 1403** |
| 19 | `.agents/skills/design-system-harness/workflows/component-creation-workflow.md` | frontmatter | present | missing | present (`name=component-creation-workflow`) | Fix corpus → **done 1403** |
| 20 | `.agents/skills/development-methodologies/workflows/rf8-pipeline-workflow.md` | frontmatter | present | missing | present (`name=rf8-pipeline-workflow`) | Fix corpus → **done 1403** |
| 21 | `.agents/skills/external-intelligence/workflows/research-execution-workflow.md` | frontmatter | present | missing | present (`name=research-execution-workflow`) | Fix corpus → **done 1403** |
| 22 | `.agents/skills/frontend-quality-harness/workflows/component-review-workflow.md` | frontmatter | present | missing | present (`name=component-review-workflow`) | Fix corpus → **done 1403** |
| 23 | `.agents/skills/harness-architecture/workflows/create-agent-workflow.md` | frontmatter | present | missing | present (`name=create-agent-workflow`) | Fix corpus → **done 1403** |
| 24 | `.agents/skills/indexing-skills/workflows/index-rebuild-workflow.md` | frontmatter | present | missing | present (`name=index-rebuild-workflow`) | Fix corpus → **done 1403** |
| 25 | `.agents/skills/project-management/workflows/task-lifecycle-workflow.md` | frontmatter | present | missing | present (`name=task-lifecycle-workflow`) | Fix corpus → **done 1403** |
| 26 | `.agents/skills/remediation-harness/workflows/fix-routing-workflow.md` | frontmatter | present | missing | present (`name=fix-routing-workflow`) | Fix corpus → **done 1403** |

##### References (13)

| # | File | Field | Expected | Actual (audit) | Actual (live 2026-07-09) | Recommendation / disposition |
|---|---|---|---|---|---|---|
| 27 | `.agents/skills/agent-cli-delegation/references/governance-rules.md` | frontmatter | present | missing | present (`name=governance-rules`) | Fix corpus → **done 1403** |
| 28 | `.agents/skills/agent-wiki/references/governance-rules.md` | frontmatter | present | missing | present (`name=governance-rules`) | Fix corpus → **done 1403** |
| 29 | `.agents/skills/browser-harness/references/governance-rules.md` | frontmatter | present | missing | present (`name=governance-rules`) | Fix corpus → **done 1403** |
| 30 | `.agents/skills/code-quality-harness/references/governance-rules.md` | frontmatter | present | missing | present (`name=governance-rules`) | Fix corpus → **done 1403** |
| 31 | `.agents/skills/coding-execution-harness/references/governance-rules.md` | frontmatter | present | missing | present (`name=governance-rules`) | Fix corpus → **done 1403** |
| 32 | `.agents/skills/design-system-harness/references/governance-rules.md` | frontmatter | present | missing | present (`name=governance-rules`) | Fix corpus → **done 1403** |
| 33 | `.agents/skills/development-methodologies/references/governance-rules.md` | frontmatter | present | missing | present (`name=governance-rules`) | Fix corpus → **done 1403** |
| 34 | `.agents/skills/external-intelligence/references/governance-rules.md` | frontmatter | present | missing | present (`name=governance-rules`) | Fix corpus → **done 1403** |
| 35 | `.agents/skills/frontend-quality-harness/references/governance-rules.md` | frontmatter | present | missing | present (`name=governance-rules`) | Fix corpus → **done 1403** |
| 36 | `.agents/skills/harness-architecture/references/governance-rules.md` | frontmatter | present | missing | present (`name=governance-rules`) | Fix corpus → **done 1403** |
| 37 | `.agents/skills/indexing-skills/references/governance-rules.md` | frontmatter | present | missing | present (`name=governance-rules`) | Fix corpus → **done 1403** |
| 38 | `.agents/skills/project-management/references/governance-rules.md` | frontmatter | present | missing | present (`name=governance-rules`) | Fix corpus → **done 1403** |
| 39 | `.agents/skills/remediation-harness/references/governance-rules.md` | frontmatter | present | missing | present (`name=governance-rules`) | Fix corpus → **done 1403** |

**Impact at audit time**:
- 13 sub-skills, 13 skill-workflows, 13 references invisible / unparseable
- `EdgeInferenceService` could not build reliable `contains` edges for nested assets

**Corpus vs Parser**: The **corpus was wrong** at audit time for these 39 files.
**Action taken under Task 1403**: corpus fixed as recommended.

---

### 3.3 MEDIUM: Task priority values use words, parser normalizes to P-levels

**Severity**: 🟡 Medium — no test failures, values are transformed

**Location**: All 22 task files

| Field | Expected by parser | Actual in corpus | Recommendation |
|---|---|---|---|
| `priority` | accepts words; normalizes to P-levels | `high` / `medium` / `low` | None — parser handles correctly |

**Status**: ⚠️ Informational. No fix needed.

---

### 3.4 LOW: Changelog `workflows` field is inconsistent

**Severity**: 🟢 Low — optional field, no parser failure

| Field | Expected by parser | Actual in corpus | Recommendation |
|---|---|---|---|
| `workflows` | optional | present in some, absent in others | None |

**Status**: Informational. No fix needed.

---

## 4. Cross-Reference Integrity

### 4.1 Agent → Skill references

All 9 agents reference skills that exist as `SKILL.md` directories. **0 broken references**.

### 4.2 Agent → Workflow references

All 9 agents reference workflows that exist as `.agents/workflows/*.md` files. **0 broken references**.

### 4.3 Workflow → Skill references

All 11 workflows reference skills via `uses_skills` that exist. **0 broken references**.

### 4.4 Task → Task dependencies

All `depends_on` entries reference task IDs that exist in the corpus:

- T001 → [] (no deps)
- T002 → [T001] ✅
- T003 → [T001] ✅
- T004 → [T003] ✅
- T005 → [T001] ✅
- T006 → [T003] ✅
- T007 → [T002, T003] ✅
- T008 → [T003, T006] ✅
- T009 → [T003, T006] ✅
- T010 → [T003] ✅
- T011 → [T005] ✅
- T012 → [T010, T007] ✅
- T013 → [T010] ✅
- T014 → [T009] ✅
- T015 → [T009, T012] ✅
- T016 → [T009] ✅
- T017 → [T009] ✅
- T018 → [] ✅
- T019 → [T018] ✅
- T020 → [T018] ✅
- T021 → [T018, T019] ✅
- T022 → [] ✅

**0 broken references.** No circular dependencies detected.

### 4.5 Changelog → Task references

All 36 changelog entries reference task IDs that exist. **0 broken references.**

---

## 5. Consistency Checks

### 5.1 Duplicate YAML keys

**Result**: ✅ No duplicate keys found in any file.

### 5.2 Status value vocabulary (tasks) — live

| Status | Used in corpus | Live parser recognizes | Match |
|---|---|---|---|
| `planning` | ✅ | ✅ via `fromStatus` | **MATCH** |
| `open` | ✅ | ✅ via `fromStatus` | **MATCH** |
| `doing` | ✅ | ✅ via `fromStatus` | **MATCH** |
| `review` | ✅ | ✅ via `fromStatus` | **MATCH** |
| `completed` | ✅ | ✅ via `fromStatus` | **MATCH** |

Historical note: at 2026-06-09 audit time, bare words were unrecognized because
`fromStatus` only delegated to `fromDirectoryPrefix`. That is no longer true.

### 5.3 Canonicality values

| Value | Used | Parser recognizes |
|---|---|---|
| `parentCanonical` | ✅ (13 skills) | ✅ |
| (not set) | ✅ (9 agents, 11 workflows, 22 tasks) | ✅ (defaults to `parentCanonical`) |
| `appendOnly` | — (set by parser for changelog) | ✅ |

### 5.4 Date format consistency

All `created` and `updated` fields use ISO date format (`YYYY-MM-DD`). Parser
handles this correctly via `DateTime.tryParse()`. ✅

### 5.5 Review score format

| Value | Count | Parser behavior |
|---|---|---|
| `n/a` | 9 | `_parseDouble` returns `null` for `"n/a"` ✅ |
| numeric | 13 | Parsed correctly ✅ |

---

## 6. Failure Baseline Correlation (Task 1401)

### 6.1 Corpus-caused failures

| Task 1401 Failure | Root cause | Corpus or Parser? | Live disposition |
|---|---|---|---|
| #25-29, #31 | `fromStatus` pass-through | **Parser** — corpus values correct | Fixed in Task 1403 |
| #33 | `WorkspaceAsset` equality | **Parser/Model** | Out of Task 1402 scope |
| #34, #64 | Edge inference mismatch | **Parser/Model** | Out of Task 1402 scope |
| #30 | `hasCompletionEvidence` logic | **Parser** | Out of Task 1402 scope |

**Result**: At audit time, **0 of 64 failures** were caused by schema drift in
the 91 files that already had frontmatter. Nested 39 files were a real corpus
defect but were not yet covered by the failing tests (parser `tryParse` dropped them).

### 6.2 Nested corpus contribution (historical)

The 39 files without frontmatter (§3.2) were not exercised by the Task 1401
failure set because the parser silently dropped them via `tryParse()`. They
were still a contract defect and were fixed in Task 1403.

---

## 7. Fixes Needed vs Fixes Applied

### Audit-time fix list (Task 1403 scope at original write)

| # | Issue | Fix target | Severity | Live disposition |
|---|---|---|---|---|
| 1 | `TaskLaneParsing.fromStatus()` pass-through | **Parser** (`task_contracts.dart`) | 🔴 Critical | ✅ Fixed in Task 1403 |
| 2 | 39 nested files missing frontmatter | **Corpus** (39 files) | 🟠 High | ✅ Fixed in Task 1403 |
| 3 | Task priority word→P-level normalization | None (handled correctly) | 🟢 Low | No change needed |
| 4 | Inconsistent `workflows` in changelog | None (optional field) | 🟢 Low | No change needed |

### Fixes applied in Task 1402 itself

**None to corpus/parser.** This is an audit-only task per anti-hallucination
guardrails. Report + changelog + task evidence only.

### Report refresh applied in this Task 1402 path-to-100 pass (2026-07-09)

- Corrected frontmatter arithmetic (91 historical / 130 live).
- Marked §3.1 / §3.2 as historical findings with live fixed disposition.
- Added per-file mismatch rows for all 39 nested files.
- Re-quoted live `fromStatus` implementation.

---

## 8. Recommendations (historical Task 1403 handoff — retained)

1. **Fix `TaskLaneParsing.fromStatus()`** — map bare status strings. ✅ Done in 1403.
2. **Add frontmatter to 39 nested skill files** — minimum `name` + `description`. ✅ Done in 1403.
3. **Do NOT change corpus task status values** — they were correct. ✅ Preserved.
4. **Do NOT change changelog entries** for schema reasons. ✅ Preserved.

---

## 9. Verification Commands (live 2026-07-09)

```bash
# Report exists
test -f docs/reports/corpus-frontmatter-audit.md && echo PASS

# File counts
python3 - <<'PY'
from pathlib import Path
root = Path('apps/observatory/assets/mock_workspace')
mds = sorted(root.rglob('*.md'))
with_fm = 0
for p in mds:
    t = p.read_text(encoding='utf-8', errors='replace').lstrip('\ufeff')
    if t.startswith('---\n') or t.startswith('---\r\n'):
        with_fm += 1
print(f'TOTAL={len(mds)} WITH_FM={with_fm} WITHOUT={len(mds)-with_fm}')
PY
# Expected live: TOTAL=130 WITH_FM=130 WITHOUT=0

# Nested skill frontmatter presence
python3 - <<'PY'
from pathlib import Path
root = Path('apps/observatory/assets/mock_workspace/.agents/skills')
nested = [p for p in root.rglob('*.md') if p.name != 'SKILL.md']
print(f'NESTED={len(nested)}')
missing = 0
for p in nested:
    t = p.read_text(encoding='utf-8', errors='replace').lstrip('\ufeff')
    if not (t.startswith('---\n') or t.startswith('---\r\n')):
        missing += 1
print(f'NESTED_MISSING_FM={missing}')
PY
# Expected live: NESTED=39 NESTED_MISSING_FM=0

# Live fromStatus is not a pass-through
rg -n "static TaskLane fromStatus" -A20 apps/observatory/lib/data/models/task_contracts.dart
# Expected: switch on planning/open/doing/review/completed
```

**Captured live outputs (2026-07-09):**

```text
TOTAL=130 WITH_FM=130 WITHOUT=0
NESTED=39
NESTED_MISSING_FM=0
```

`fromStatus` live implementation maps bare status words (see §3.1 live code quote).

---

## 10. Evidence

### Original audit (2026-06-09)

- **Read**: `docs/mock-workspace-corpus-contract.md`
- **Read**: `docs/reports/observatory-failure-baseline.md` (Task 1401)
- **Read**: parsers under `apps/observatory/lib/data/parsers/`
- **Read**: `apps/observatory/lib/data/models/task_contracts.dart`
- **Scanned**: All 130 `.md` files in `apps/observatory/assets/mock_workspace/`
- **No corpus/parser files modified** in Task 1402

### Live re-verification (2026-07-09)

- Re-scanned all 130 mock markdown files → **130/130 frontmatter**
- Verified nested 39 files each expose `name` + `description`
- Verified task status distribution still `3/5/5/4/5`
- Re-read live `TaskLaneParsing.fromStatus()` — bare-word mapping present
- Correlated with Task 1403 changelog
  `docs/changelog/2026-07-09-task-1403-nested-skill-frontmatter-corpus-fix.md`
- Report arithmetic corrected; per-file mismatch appendix completed
- Task 1402 still audit-only: no corpus/parser mutation in this refresh

---

## 11. Exit-condition mapping (Task 1402)

| Exit condition | Evidence |
|---|---|
| Report exists at `docs/reports/corpus-frontmatter-audit.md` | This file |
| Each mismatch specifies file, field, expected, actual, recommendation | §3.1 + §3.2 per-file tables (39 rows) + §3.3/§3.4 |
| Local changelog under `docs/changelog/` | `2026-06-09-task-1402-corpus-frontmatter-audit.md` + refresh notes |
| Completion Evidence filled | Task file Completion Evidence + Path-to-100 refresh entries |

**Author**: builders
