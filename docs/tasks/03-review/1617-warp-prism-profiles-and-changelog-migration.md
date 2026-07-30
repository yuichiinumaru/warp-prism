# Task 1617: Warp Prism Profiles And Changelog Migration

> **Status**: `[x]` Ready for review
> **Priority**: 🔴 P0
> **Type**: `housekeeping` | `governance`
> **Origin**: Architect audit 2026-07-20 dual ledger / profiles residual
> **Blocks**: Clean agent memory + changelog truth for `warp-prism`
> **Depends on**: Prefer dry-run before apply; coordinate if dual-writing with active waves

---

## Objective

Finish warp-prism memory migration (partial `_by_lane` + residual profiles) and
promote fat `docs/changelog` into `.changelog` with symlink. Fix AGENTS.md live write path.

## Background Context

### O que já existe:
- Parent-linked memories with partial `_by_lane/reviewers`
- Residual profiles architects/builders/reviewers
- docs/changelog ~270+; .changelog stub

### O que está faltando / quebrado:
- Dual memory write risk via AGENTS
- Changelog still on docs/ path

---

## Test Requirements

- Dry-run of every migration command produces a reviewable plan before apply.
- After apply: canonical surfaces are correct; no data deleted (`mv`/archive only).
- AGENTS.md / local rules no longer instruct live writes under residual `.agents/profiles/` when memories migrated.
- Changelog validate+build (or project-local equivalent) succeeds after repair/migrate.
- Completion Evidence lists exact commands, counts before/after, and residual allowlist.

---

## Exit Conditions (GDD/TDD)

- [x] First subtask (read existing) completed with evidence
- [x] Migration dry-run artifact under `tmp/` or project `tmp/`
- [x] Apply completed without deletes
- [x] AGENTS points to .memories/_by_lane
- [x] single changelog
- [x] validate+build
- [x] CHANGELOG / `.changelog` entry for this task (project convention)
- [x] Completion Evidence filled
- [x] Task ready for `03-review/` (do not jump to `04-completed/`)

---

## Details

### What

Subtasks:
- [x] **Ler o estado existente antes de modificar**: AGENTS.md, `.changelog/`, `docs/changelog/`, `.memories/`, `.agents/profiles/`, and the skill docs cited below
- [x] Confirm classification (migrate vs repair vs profiles-migrate) against live filesystem
- [x] - [x] Diff profiles vs _by_lane; migrate residual
- [x] - [x] Promote docs/changelog → .changelog; symlink
- [x] - [x] Patch warp-prism AGENTS.md to _by_lane + agentlog
- [x] Re-read AGENTS.md overlays; patch any residual write paths to `.memories/_by_lane/` + `.changelog/`
- [x] Validation commands (below) green
- [x] Fill Completion Evidence; leave task for independent review

### Migration tooling (must use — do not invent)

**Changelog** — `project-development/sub-skills/manage-changelog`:

```bash
# From project root (or set cwd to the child):
bash ../.agents/skills/project-development/sub-skills/manage-changelog/scripts/rebuild.sh \
  repair --dry-run --agent architects --task 1617
# or when NO trustworthy .changelog entries and only root CHANGELOG.md:
bash ../.agents/skills/project-development/sub-skills/manage-changelog/scripts/rebuild.sh \
  migrate --agent architects --task 1617
# After corpus is unified under .changelog:
bash .../rebuild.sh validate
bash .../rebuild.sh build
```

If history still lives only under `docs/changelog/` (real dir, not symlink):

```bash
GANTHRITOR_CHANGELOG_DIR=docs/changelog bash .../rebuild.sh repair --dry-run --agent architects --task 1617
# then promote/consolidate into .changelog and replace docs/changelog with symlink → ../.changelog
```

**Profiles → memories** — `knowledge/sub-skills/agent-wiki`:

```bash
python3 ../.agents/skills/knowledge/sub-skills/agent-wiki/scripts/migrate_profiles_to_project_memories.py
python3 ../.agents/skills/knowledge/sub-skills/agent-wiki/scripts/migrate_profiles_to_project_memories.py --apply
# Prefer project .memories (parent-linked): ensure child/.memories → ../.memories/<child>/
# nlm/ exception: do not move intentional nlm trees
```

Also read: `manage-agent-memory` SUBSKILL, `agent-wiki` SUBSKILL residual rules, parent
`.agents/rules/agent-memory-and-profiles.md`.

### Where

| Path | Action |
|------|--------|
| `AGENTS.md` | Fix |
| `.agents/profiles/` | Migrate residual |
| `.memories/_by_lane/` | Canonical |
| `docs/changelog/` | Promote+symlink |
| `.changelog/` | Canonical |

### Validation commands

```bash
# Memory
ls -la .memories .agents/profiles 2>/dev/null | head
test -d .memories/_by_lane -o -L .memories && ls .memories/_by_lane 2>/dev/null | head
# Changelog
ls -la .changelog docs/changelog 2>/dev/null | head
bash ../.agents/skills/project-development/sub-skills/manage-changelog/scripts/rebuild.sh validate
# AGENTS no longer mandates profiles as live write root (rg)
rg -n "profiles/.*write|Protocol Zero.*profiles|\\.agents/profiles" AGENTS.md || true
```

Primary recommended command class for this project: **repair+promote changelog; migrate residual profiles**

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> NEVER `rm` history. NEVER raw `migrate` when a fat dual ledger already exists
> under both `.changelog/` and `docs/changelog/` — consolidate + **repair** instead.
> NEVER delete `.agents/profiles/` content — migrate with the official script then
> leave residual shells + `MIGRATED.md`. Do not use git/jj unless user-authorized.
> Do not run monorepo-wide graphify as part of this task.

---

## 📋 Completion Evidence

- **Before counts**: docs/changelog ~270; .changelog stub README only; archive profiles ~284; _by_lane partial (reviewers)
- **Commands run**:
  - repair docs/changelog (120 files) then promote to `.changelog` + symlink
  - **Non-trivial**: validate failed — 1 corrupted multi-line frontmatter (`2026-06-09-task-1208-…`); mechanical FM cleanup preserving residue in HTML comment
  - **Non-trivial**: `repair --task 1617` polluted ~89 entries with task=1617 + duplicate keys; recovery derived task IDs from filenames and uniquified timestamps (no content body rewrite)
  - validate/build entries=267 then closeout → 268
  - profiles migrate: whole-lane collision on builders/reviewers; per-file merge moved 283 residual files into `_by_lane`
  - AGENTS.md path patches (profiles → memories; docs/changelog → .changelog)
- **After layout**: single ledger `.changelog`; docs symlink; `_by_lane` architects/builders/reviewers
- **AGENTS patches**: `warp-prism/AGENTS.md` continuity + changelog path
- **Residuals**: archive profiles empty (MIGRATED.md); thin stub `.archive/changelog/warp-prism-thin-20260721`
- **CHANGELOG ref**: `.changelog/20260721-154708-1617-profiles-and-changelog-promote-builders.md`
- **Non-trivial notes**: repair `--task` flag pollutes missing task fields — prefer `--task 0000` + filename recovery for historical corpora
