# Task 1410: Warp Prism Changelog Engine Metadata Normalization

> **Status**: `[x]` Ready For Review
> **Review State**: Ready For Review
> **Priority**: 🔴 P0
> **Type**: `governance`
> **Origin**: user request and changelog ledger audit
> **Blocks**: Task 1101/1102/1104/1105/1106/1107/1126 changelog validation gates
> **Depends on**: N/A

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1410` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Normalize Warp Prism `docs/changelog/` source-ledger metadata enough that the
child changelog engine can validate entries without misclassifying Warp Prism
work as `legacy-unclassified`, `unspecified`, or parent `ganthritor` work.
Completion means source entries with clear Warp Prism provenance have valid,
minimal frontmatter and task/project metadata, while ambiguous historical entries
are documented rather than guessed.

## Background Context

### What already exists

- `docs/changelog/README.md` defines the local ledger as one Markdown file per
  meaningful Warp Prism change.
- `docs/changelog/000-template.md` defines the engine-style frontmatter shape,
  but currently shows `project: ganthritor` even inside the child project.
- The parent-canonical changelog engine is available through the symlinked
  `.agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh`.
- Generated changelog surfaces exist at `docs/changelog/index.md` and
  `docs/changelog/views/`, but they are projections and must not be manually
  edited.
- Sample source-ledger inspection found valid modern entries such as
  `docs/changelog/1302-public-barrel-audit.md` with `project: warp-prism`.

### What is missing or broken

- Generated `docs/changelog/index.md` contains many `legacy-unclassified` rows,
  indicating older source entries lack project metadata or were classified by a
  legacy fallback.
- `docs/changelog/views/unspecified.md` contains a generated view for project
  `unspecified`, and `docs/changelog/20260608-184953-1109-cybercore-api-contracts-builders.md`
  has `project: "unspecified"` despite being Warp Prism child work.
- Several inspected repair-bot source entries, including Task 1121, Task 1122,
  Task 1105, Task 0412, and Task 0019 notes, have frontmatter without a
  `project` field.
- Some source entries use task metadata that does not match the visible body
  title, for example filename/body references to Task 1121 while frontmatter says
  `task: "1045"`.
- Review ledgers repeatedly cite changelog validation as a blocker or evidence
  gap, so this is not a cosmetic cleanup.

---

## Test Requirements

- The executor MUST inventory all non-generated source entries under
  `docs/changelog/*.md`, excluding `README.md`, `000-template.md`, `index.md`,
  `views/**`, and `.changelog.lock`.
- The executor MUST classify each issue as missing `project`, explicit
  `project: unspecified`, likely wrong child-local `project: ganthritor`, task-id
  mismatch, missing required timestamp/date/agent/description, or ambiguous.
- The executor MUST only normalize entries where Warp Prism provenance is
  mechanically clear from filename, body title, task path, or adjacent evidence.
- The executor MUST preserve historical body text and validation claims except
  when adding a short correction note is required to explain a metadata-only
  repair.
- The executor MUST produce a compact report listing every changed entry and any
  unresolved ambiguous entry.
- The executor MUST NOT manually edit generated changelog projections.

---

## Exit Conditions

- [x] All source-ledger entries with unambiguous Warp Prism provenance have
      `project: warp-prism` in YAML frontmatter.
- [x] The explicit `project: "unspecified"` source entry is either corrected to
      `warp-prism` with evidence or documented as ambiguous with rationale.
- [x] The child `docs/changelog/000-template.md` no longer tells future agents to
      use `project: ganthritor` for child-local Warp Prism notes.
- [x] Task-id mismatches that are mechanically obvious are corrected in
      frontmatter without changing historical body prose.
- [x] Ambiguous entries are listed in a report and are not guessed.
- [x] `bash ../.agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate`
      passes from the `warp-prism/` root, or the remaining failure is documented
      with exact file/path and why it is intentionally out of scope.
- [x] No child tasklist rebuild, changelog `build`, changelog `closeout`, or
      generated `docs/changelog/index.md` / `docs/changelog/views/**` mutation is
      performed in this task unless a reviewer explicitly expands scope.
- [x] Local changelog source entry added under `docs/changelog/` for Task 1410.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `AGENTS.md`,
      `.agents/rules/project-boundaries.md`, `.agents/rules/task-governance.md`,
      `docs/tasks/000-template.md`, `docs/changelog/README.md`,
      `docs/changelog/000-template.md`, the sampled invalid source entries named
      in this task, and the changelog engine validation help before editing.
- [x] Build a source-only inventory of `docs/changelog/*.md` entries, excluding
      generated projections and templates from repair candidates.
- [x] Classify metadata defects by exact file and exact field.
- [x] Normalize only the mechanically safe source entries: add or correct
      `project`, correct unambiguous `task`, and preserve all body content.
- [x] Update the child changelog template so it uses `project: warp-prism` for
      child-local work.
- [x] Create `docs/reports/changelog-metadata-normalization.md` with changed
      files, unresolved entries, and validation output.
- [x] Add a Task 1410 local changelog source note with valid frontmatter.
- [x] **Simplicity pass**: remove any ad-hoc scripts unless they are explicitly
      recorded as reusable validation artifacts.
- [x] **Regression verification**: run the source-only audit command and the
      changelog engine `validate` command listed below.

### Where

| File | Purpose |
| --- | --- |
| `AGENTS.md` | Read — child governance and changelog boundary. |
| `.agents/rules/task-governance.md` | Read — local executable task and review-state requirements. |
| `.agents/rules/project-boundaries.md` | Read — child-only mutation boundary. |
| `docs/tasks/000-template.md` | Read — task closeout and validation requirements. |
| `docs/changelog/README.md` | Read/Modify only if local ledger rules need a narrow metadata clarification. |
| `docs/changelog/000-template.md` | Read/Modify — child template should use `project: warp-prism`. |
| `docs/changelog/*.md` | Read/Modify selected source ledger entries with safe metadata defects only. |
| `docs/changelog/index.md` | Read only — generated projection used as audit evidence, not a mutation target. |
| `docs/changelog/views/unspecified.md` | Read only — generated projection used as audit evidence, not a mutation target. |
| `docs/reports/changelog-metadata-normalization.md` | Create — report of repairs and unresolved ambiguous entries. |
| `.agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh` | Read/Run validate only — source ledger validation command. |

### How

1. Inventory source entries first; do not edit while discovering the full defect
   class.
2. Treat generated views as evidence of classification drift, not as editable
   truth.
3. Prefer mechanical corrections: missing `project` becomes `warp-prism` only
   when the entry is clearly about this child project.
4. For task-id mismatches, correct the frontmatter only when the title/body and
   filename agree on the same task number.
5. For `project: ganthritor` inside the child ledger, distinguish true
   parent-significant harness work from ordinary Warp Prism governance work.
6. Leave unresolved entries in the report rather than inventing metadata.
7. Validate the resulting source ledger without rebuilding generated projections.

### Why

The changelog source ledger is part of Warp Prism's evidence chain. If metadata
stays invalid or unclassified, reviewers cannot trust task closeout claims, the
History surface receives polluted project facets, and generated summaries can
hide child work under `legacy-unclassified` or `unspecified`. A dedicated task is
warranted because the inspected defects span many entries and broad mechanical
normalization should happen with its own inventory, report, and validation proof.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not run broad generated-surface rebuilds as part of this task. The target is
> source-ledger metadata normalization plus validation, not projection refresh.

> [!CAUTION]
> Do not guess project or task metadata for ambiguous historical entries. If a
> file cannot be classified from local evidence, list it in the report and leave
> the source unchanged.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. This task is docs and
> governance metadata only; it must not change product runtime behavior.

---

## Validation Commands

Run from `warp-prism/`:

```bash
python3 - <<'PY'
from pathlib import Path
root = Path('docs/changelog')
issues = []
for path in sorted(root.glob('*.md')):
    if path.name in {'README.md', '000-template.md', 'index.md'}:
        continue
    text = path.read_text(encoding='utf-8')
    if not text.startswith('---\n'):
        issues.append((path, 'missing-frontmatter'))
        continue
    fm = text.split('---', 2)[1]
    for field in ('date:', 'timestamp:', 'project:', 'agent:', 'task:', 'description:'):
        if field not in fm:
            issues.append((path, f'missing-{field[:-1]}'))
    if 'project: "unspecified"' in fm or 'project: unspecified' in fm:
        issues.append((path, 'project-unspecified'))
print('\n'.join(f'{path}: {issue}' for path, issue in issues))
raise SystemExit(1 if issues else 0)
PY
bash ../.agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate
```

If the validation command reports an unrelated pre-existing failure, record the
exact output in Completion Evidence and do not mark the corresponding exit
condition as passed.

---

## Completion Evidence

- **Files created/modified**:
  - `docs/tasks/02-doing/1410-warp-prism-changelog-engine-metadata-normalization.md` — task status, checklist, and evidence.
  - `docs/changelog/000-template.md` — changed template project metadata to `warp-prism`.
  - `docs/changelog/20260619-120000-1410-changelog-engine-metadata-normalization-architect.md` — Task 1410 local changelog source entry.
  - `docs/reports/changelog-metadata-normalization.md` — inventory, changed entries, unresolved ambiguity notes, validation output, changelog draft, and independent-review follow-up evidence.
  - Metadata-only repairs to source entries listed in `docs/reports/changelog-metadata-normalization.md`; generated `docs/changelog/index.md`, `docs/changelog/views/**`, `CHANGELOG.md`, and `CHANGELOG-FULL.md` were not edited.
  - Independent review follow-up corrected two additional unambiguous Warp Prism changelog entries flagged by review: `docs/changelog/20260609-112600-1126-2026-06-09-task-1126-readme-monorepo-alignment-builders.md` and `docs/changelog/20260609-160654-1206-pre-existing-failure-policy-builders.md` now use `project: warp-prism`.
- **Tests or validation commands**:
  - PASS — source-only audit command from this task returned no output and exit status 0.
  - PASS — `bash ../.agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate` returned `Changelog valid: issues=0 entries=83`.
  - PASS — independent review follow-up reran the source-only audit after correcting the two flagged entries; command returned no output and exit status 0.
  - PASS — independent review follow-up reran `bash ../.agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate`; command returned `Changelog valid: issues=0 entries=83`.
- **Local changelog entry**: `docs/changelog/20260619-120000-1410-changelog-engine-metadata-normalization-architect.md`
- **Agent-wiki / docs institutionalization**: N/A — explicitly skipped per user instruction; parent owns shared generated surfaces.
- **Executor**: architect
- **Completion date**: 2026-06-19

---

## Review Ledger

- **2026-06-19 — independent re-review (architect)**: PASS, score 100/100. Re-read task and normalization report, inspected flagged source entries (`1109`, `1126`, `1206`, Task 1410 entry) plus the child changelog template, confirmed no remaining `project: unspecified` or `project: ganthritor` source entries under `docs/changelog/*.md`, and reran the permitted validation from `warp-prism/`: source-only audit exited 0 with no findings; `bash ../.agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate` returned `Changelog valid: issues=0 entries=83`. No generated changelog build surfaces, tasklist rebuild, git, or jj were used.
