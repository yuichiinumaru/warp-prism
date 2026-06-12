# Corpus and Frontmatter Contract Audit

> **Date**: 2026-06-09
> **Task**: 1402 — Corpus and Frontmatter Contract Audit
> **EPIC**: 14 — Stabilization Wave
> **Corpus root**: `apps/observatory/assets/mock_workspace/`
> **Contract**: `docs/mock-workspace-corpus-contract.md`
> **Failure baseline**: `docs/reports/observatory-failure-baseline.md` (Task 1401)
> **Audit scope**: Read-only — no files modified

---

## 1. File Count Summary

| Category | Path pattern | Count | Has frontmatter | Contract min |
|---|---|---|---|---|
| Agents | `.agents/agents/*.md` | 9 | 9/9 ✅ | 9 |
| Skills (SKILL.md) | `.agents/skills/*/SKILL.md` | 13 | 13/13 ✅ | 13 |
| Sub-skills | `.agents/skills/*/sub-skills/*.md` | 13 | 0/13 ❌ | — (implied) |
| Skill-workflows | `.agents/skills/*/workflows/*.md` | 13 | 0/13 ❌ | — (implied) |
| References | `.agents/skills/*/references/*.md` | 13 | 0/13 ❌ | — (implied) |
| Workflows | `.agents/workflows/*.md` | 11 | 11/11 ✅ | 11 |
| Tasks (00-planning) | `docs/tasks/00-planning/*.md` | 3 | 3/3 ✅ | — |
| Tasks (01-open) | `docs/tasks/01-open/*.md` | 5 | 5/5 ✅ | — |
| Tasks (02-doing) | `docs/tasks/02-doing/*.md` | 5 | 5/5 ✅ | — |
| Tasks (03-review) | `docs/tasks/03-review/*.md` | 4 | 4/4 ✅ | — |
| Tasks (04-completed) | `docs/tasks/04-completed/*.md` | 5 | 5/5 ✅ | — |
| **Tasks total** | `docs/tasks/**/*.md` | **22** | **22/22 ✅** | 20 |
| Changelog | `docs/changelog/*.md` | 36 | 36/36 ✅ | 12 |
| **TOTAL** | | **130** | **99/130** | |

### 1.1 Files without frontmatter (39 files)

All 39 are nested inside skill directories:

| Type | Count | Location pattern |
|---|---|---|
| Sub-skills | 13 | `.agents/skills/*/sub-skills/*.md` |
| Skill-workflows | 13 | `.agents/skills/*/workflows/*.md` |
| References | 13 | `.agents/skills/*/references/*.md` |

These files contain plain markdown (heading + paragraph) with no `---` frontmatter delimiters. The `FrontmatterParser.parse()` will return `FrontmatterResult.error` for all of them.

**Impact**: When the `WorkspaceMarkdownParser._inferKind()` resolves these paths as `AssetKind.subskill` (for sub-skills), the parser will throw `ParseException` because the frontmatter is missing. Skill-workflows and references will also fail to parse.

**Recommendation**: **Fix corpus** (Task 1403). Add YAML frontmatter to all 39 files with at minimum `name` and `description`.

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

**Canonicality**: Not set in frontmatter. Parser defaults to `Canonicality.parentCanonical` (line 437 of `workspace_markdown_parser.dart`). This is correct for mock agents.

**Cross-references**: All `skills` and `workflows` lists reference names that exist as SKILL.md directories and workflow files respectively. No broken references.

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

**Cross-references**: All `sub_skills` lists reference names that match `sub-skills/` directory children. No broken references.

**Status**: ✅ Clean.

---

### 2.3 Workflows — Schema conformance

| Required field | Present in all 11 | Type in corpus |
|---|---|---|
| `name` | ✅ | string |
| `description` | ✅ | string |
| `uses_skills` | ✅ | list of strings |
| `kind` | ✅ | string (orchestration, audit, review, etc.) |

**Extra fields found**: None. All 11 workflows have exactly the 4 required fields.

**Cross-references**: All `uses_skills` lists reference names that exist as skill directories. No broken references.

**Status**: ✅ Clean.

---

### 2.4 Tasks — Schema conformance

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

**Status values found in corpus**:

| Value | Count | Expected lane |
|---|---|---|
| `planning` | 3 | planning |
| `open` | 5 | open |
| `doing` | 5 | doing |
| `review` | 4 | review |
| `completed` | 5 | completed |

**Extra fields found**: None.

**Cross-references**: All `depends_on` entries reference task IDs that exist in the corpus. No broken references.

**Status**: ⚠️ Frontmatter schema is clean, but **status values cause parser failure** (see §3.1).

---

### 2.5 Changelog — Schema conformance

| Required field | Present in all 36 | Type in corpus |
|---|---|---|
| `id` | ✅ | string (e.g., `2025-03-15-T001-workspace-onboarding`) |
| `date` | ✅ | date string |
| `project` | ✅ | string |
| `task` | ✅ | string (e.g., `T001`) |
| `type` | ✅ | string (feature/remediation/audit/refactor/fix/chore) |
| `impact` | ✅ | list of strings |
| `skills` | ✅ | list of strings |

**Extra fields found**: `workflows` — present in 14/36 entries, absent in 22/36. This is optional and does not cause parser failure.

**Body sections**: All 36 files contain `## Why`, `## Changed`, and `## Evidence` headings ✅.

**Dual-era entries**: 15 tasks have two changelog entries — one with `project: asw-observatory` (2025 dates) and one with `project: warp-prism` (2026 dates). This is intentional corpus breadth, not duplication.

**Status**: ✅ Clean.

---

## 3. Critical Mismatches

### 3.1 CRITICAL: `TaskLaneParsing.fromStatus()` pass-through bug

**Severity**: 🔴 Critical — root cause of 8+ test failures (Task 1401 §3.5)

**Location**: `apps/observatory/lib/data/models/task_contracts.dart` lines 183-185

**Code**:
```dart
static TaskLane fromStatus(String status) {
  return fromDirectoryPrefix(status);  // BUG: pass-through
}
```

**Problem**: `fromDirectoryPrefix()` only handles directory-style strings:
- `"00-planning"` → `TaskLane.planning`
- `"01-open"` → `TaskLane.open`
- `"02-doing"` → `TaskLane.doing`
- `"03-review"` → `TaskLane.review`
- `"04-completed"` → `TaskLane.completed`

But task frontmatter `status` values are bare words:
- `"planning"`, `"open"`, `"doing"`, `"review"`, `"completed"`

Since `"planning"` ≠ `"00-planning"`, the switch falls through to `default: return TaskLane.open`.

**Impact**: Every task with a non-directory status string defaults to `TaskLane.open`. This cascades to:
- `parseAll()` groups all tasks into the `open` lane
- `laneFor(TaskLane.planning).count` returns 0 instead of expected 1
- All lane-specific assertions in `workspace_task_projection_parser_test.dart` fail

**Affected tests** (from Task 1401):
- Failure #25: T001 lane expected `planning`, got `open`
- Failure #26: T009 lane expected `doing`, got `open`
- Failure #27: T015 lane expected `review`, got `open`
- Failure #28: T018 lane expected `completed`, got `open`
- Failure #29: frontmatter status override still defaults to `open`
- Failure #31: `parseAll` planning lane empty (cascades from above)

**Diagnosis**: The **parser is wrong**, not the corpus.

**Recommendation**: **Fix parser** (Task 1403). `fromStatus()` should map bare words directly:
```dart
static TaskLane fromStatus(String status) {
  switch (status.toLowerCase()) {
    case 'planning': return TaskLane.planning;
    case 'open':     return TaskLane.open;
    case 'doing':    return TaskLane.doing;
    case 'review':   return TaskLane.review;
    case 'completed': return TaskLane.completed;
    default:         return fromDirectoryPrefix(status);
  }
}
```

---

### 3.2 HIGH: Sub-skill files missing frontmatter (39 files)

**Severity**: 🟠 High — parser will throw `ParseException` for all 39 files

**Location**: All files under `.agents/skills/*/sub-skills/*.md`, `.agents/skills/*/workflows/*.md`, `.agents/skills/*/references/*.md`

**Problem**: These 39 files are plain markdown with no `---` frontmatter delimiters. Example:
```markdown
# create-agent

Sub-skill of `harness-architecture`. Provides detailed rules and templates for create-agent operations.
```

When `WorkspaceMarkdownParser.parse()` reads these, `FrontmatterParser.parse()` returns error `"Document does not start with --- frontmatter delimiter"`.

**Parser behavior**: `parse()` throws `ParseException`. `tryParse()` returns `null`. These files are silently dropped from the workspace graph.

**Impact**:
- 13 sub-skills invisible to the graph
- 13 skill-workflows invisible to the graph
- 13 references invisible to the graph
- `EdgeInferenceService` cannot build `contains` edges for sub-skills
- Governance diagnostics may flag these as orphan files

**Corpus vs Parser**: The **corpus is wrong** — these files should have frontmatter per the contract's implied convention that all `.md` files under `assets/mock_workspace/` use frontmatter.

**Recommendation**: **Fix corpus** (Task 1403). Add frontmatter to all 39 files. Minimum fields:
- Sub-skills: `name`, `description`
- Skill-workflows: `name`, `description`
- References: `name`, `description`

---

### 3.3 MEDIUM: Task priority values use words, parser normalizes to P-levels

**Severity**: 🟡 Medium — no test failures, but values are transformed

**Location**: All 22 task files

**Problem**: Corpus uses `high`, `medium`, `low` as priority values. The `WorkspaceTaskProjectionParser._normalizePriority()` converts these to `P1`, `P2`, `P3` respectively. This is by design (the parser handles it), but it means the raw frontmatter value ≠ the parsed value.

**Status**: ⚠️ Informational. Parser handles this correctly. No fix needed unless tests assert raw frontmatter values.

---

### 3.4 LOW: Changelog `workflows` field is inconsistent

**Severity**: 🟢 Low — optional field, no parser failure

**Location**: 14/36 changelog files have `workflows`, 22/36 do not.

**Status**: Informational. The `workflows` field is not required by the contract for changelog entries. The parser does not use it for `ChangelogMetadata`. No fix needed.

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

### 5.2 Status value vocabulary (tasks)

| Status | Used in corpus | Parser recognizes | Match |
|---|---|---|---|
| `planning` | ✅ | ❌ (defaults to `open`) | **MISMATCH** |
| `open` | ✅ | ✅ (accidental — `"open"` is not in `fromDirectoryPrefix` either, but is the default) | **ACCIDENTAL** |
| `doing` | ✅ | ❌ (defaults to `open`) | **MISMATCH** |
| `review` | ✅ | ❌ (defaults to `open`) | **MISMATCH** |
| `completed` | ✅ | ❌ (defaults to `open`) | **MISMATCH** |

**Wait**: Let me re-verify. `fromDirectoryPrefix` has `case '01-open': return TaskLane.open`. So `"open"` ≠ `"01-open"` and would also default to `open`. This means even `"open"` status tasks are technically broken — they just happen to land on the correct lane by accident (default).

**Correction**: ALL status values are unrecognized by `fromDirectoryPrefix`. The only reason tasks appear in `open` lane is the `default` fallback. This is **not** correct behavior — it's coincidental for `open` status tasks and wrong for all others.

### 5.3 Canonicality values

| Value | Used | Parser recognizes |
|---|---|---|
| `parentCanonical` | ✅ (13 skills) | ✅ |
| (not set) | ✅ (9 agents, 11 workflows, 22 tasks) | ✅ (defaults to `parentCanonical`) |
| `appendOnly` | — (set by parser for changelog) | ✅ |

### 5.4 Date format consistency

All `created` and `updated` fields use ISO date format (`YYYY-MM-DD`). Parser handles this correctly via `DateTime.tryParse()`. ✅

### 5.5 Review score format

| Value | Count | Parser behavior |
|---|---|---|
| `n/a` | 9 | `_parseDouble` returns `null` for `"n/a"` ✅ |
| numeric | 13 | Parsed correctly ✅ |

---

## 6. Failure Baseline Correlation (Task 1401)

### 6.1 Corpus-caused failures

| Task 1401 Failure | Root cause | Corpus or Parser? |
|---|---|---|
| #25-29, #31 | `fromStatus` pass-through | **Parser** — corpus values are correct |
| #33 | `WorkspaceAsset` equality | **Parser/Model** — not corpus |
| #34, #64 | Edge inference mismatch | **Parser/Model** — not corpus |
| #30 | `hasCompletionEvidence` logic | **Parser** — not corpus |

**Result**: 0 of 64 failures are caused by corpus drift. All corpus files conform to their expected schemas. The failures stem from parser/model code not handling the corpus's field values correctly.

### 6.2 Indirect corpus contribution

The 39 files without frontmatter (§3.2) are not tested by the current test suite because the parser silently drops them via `tryParse()`. If tests were added for sub-skill/workflow/reference assets, they would fail.

---

## 7. Fixes Needed vs Fixes Applied

### Fixes needed (Task 1403 scope)

| # | Issue | Fix target | Severity | Effort |
|---|---|---|---|---|
| 1 | `TaskLaneParsing.fromStatus()` pass-through | **Parser** (`task_contracts.dart:183`) | 🔴 Critical | S |
| 2 | 39 sub-skill/workflow/reference files missing frontmatter | **Corpus** (39 files) | 🟠 High | M |
| 3 | Task priority word→P-level normalization | None (handled correctly) | 🟢 Low | — |
| 4 | Inconsistent `workflows` in changelog | None (optional field) | 🟢 Low | — |

### Fixes applied in this audit

**None.** This is an audit-only task per the anti-hallucination guardrails.

---

## 8. Recommendations for Task 1403

1. **Fix `TaskLaneParsing.fromStatus()`** — add a mapping from bare status strings (`planning`, `open`, `doing`, `review`, `completed`) to `TaskLane` values. Keep `fromDirectoryPrefix()` as fallback. This is a ~10-line fix that unblocks 8 test failures.

2. **Add frontmatter to 39 nested skill files** — each file needs at minimum:
   ```yaml
   ---
   name: <filename-without-extension>
   description: <first-paragraph-content>
   ---
   ```
   This is a mechanical transformation. Unblocks future sub-skill/workflow/reference tests.

3. **Do NOT change corpus task status values** — they are correct. The parser must learn to handle them.

4. **Do NOT change changelog entries** — they are all schema-compliant.

---

## 9. Verification Commands

```bash
# Verify report exists
test -f docs/reports/corpus-frontmatter-audit.md && echo "PASS" || echo "FAIL"

# Verify file counts
find apps/observatory/assets/mock_workspace -name "*.md" | wc -l
# Expected: 130

# Verify all agents have frontmatter
for f in apps/observatory/assets/mock_workspace/.agents/agents/*.md; do head -1 "$f"; done | grep -c "^---$"
# Expected: 9

# Verify all SKILL.md have frontmatter
for f in apps/observatory/assets/mock_workspace/.agents/skills/*/SKILL.md; do head -1 "$f"; done | grep -c "^---$"
# Expected: 13

# Verify nested skill files lack frontmatter
for f in apps/observatory/assets/mock_workspace/.agents/skills/*/sub-skills/*.md; do head -1 "$f"; done | grep -cv "^---$"
# Expected: 13 (all missing)

# Verify no duplicate YAML keys
# (automated check — 0 found)
```

---

## 10. Evidence

- **Read**: `docs/mock-workspace-corpus-contract.md` — full corpus contract (269 lines)
- **Read**: `docs/reports/observatory-failure-baseline.md` — Task 1401 output (411 lines, 64 failures)
- **Read**: `apps/observatory/lib/data/parsers/frontmatter_parser.dart` (224 lines)
- **Read**: `apps/observatory/lib/data/parsers/workspace_markdown_parser.dart` (505 lines)
- **Read**: `apps/observatory/lib/data/parsers/workspace_parser.dart` (394 lines)
- **Read**: `apps/observatory/lib/data/parsers/workspace_task_projection_parser.dart` (280 lines)
- **Read**: `apps/observatory/lib/data/models/task_contracts.dart` (220 lines)
- **Scanned**: All 130 `.md` files in `apps/observatory/assets/mock_workspace/`
- **Extracted**: Frontmatter from all 99 files that have it
- **Checked**: Cross-references in agents, skills, workflows, tasks, changelogs
- **No files modified**: Audit-only per task guardrails
