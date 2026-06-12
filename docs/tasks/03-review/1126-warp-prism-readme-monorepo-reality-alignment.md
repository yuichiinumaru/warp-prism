# Task 1126: README Monorepo Reality Alignment

> **Status**: `[x]` Done (awaiting review)
> **Review State**: Package Gate Failed — docs complete; changelog validate has pre-existing issue
> **Priority**: 🟡 P1
> **Type**: `housekeeping`
> **Origin**: Analysis document identifies README as dangerously outdated.
>   Still describes single-app structure with `lib/`, `design_system/`, `assets/`
>   at root level. Real structure is Melos monorepo with `apps/` and `packages/`.
> **Blocks**: None (but every new builder reads the README first)
> **Depends on**: N/A (file update only)

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
- README lists the correct validation commands (`melos run analyze`, `melos run test`,
  `melos run validate`).
- README does not reference stale task statuses.

---

## Exit Conditions

- [x] `README.md` accurately describes: root workspace, `apps/observatory`,
  `apps/catalog`, `apps/cybercore`, `packages/warp_prism_ui`.
- [x] `README.md` lists correct setup commands: `dart pub get`, `melos bootstrap`.
- [x] `README.md` lists correct validation commands: `melos run analyze`,
  `melos run test`, `melos run validate`.
- [x] `README.md` does not reference stale task statuses or blocked entries.
- [x] `README.md` identifies `warp_prism_ui` as the reusable ADS and `Prism*`
  as the public API namespace.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read `README.md`,
  root `pubspec.yaml`, `packages/warp_prism_ui/pubspec.yaml`,
  `docs/architecture/warp-prism-melos-monorepo-architecture.md`.
- [x] Update Project Structure section to reflect the monorepo.
- [x] Update Stack section to distinguish monorepo-level and app-level dependencies.
- [x] Update Setup section with `dart pub get` and `melos bootstrap`.
- [x] Update Validation section with Melos commands and current baseline status.
- [x] Remove stale references to pending tasks and SDK blocker.
- [x] Add note about `Prism*` as public ADS namespace and `DS*` as internal.
- [x] **Simplicity pass**: keep README concise. Do not duplicate architecture doc.
- [x] **Regression verification**: verify all mentioned paths exist.

### Where

| File | Purpose |
| --- | --- |
| `README.md` | Modify — align with monorepo reality |
| `pubspec.yaml` (root) | Read — workspace config |
| `docs/architecture/warp-prism-melos-monorepo-architecture.md` | Read — architecture reference |

### How

1. Read the current README and the architecture doc.
2. Rewrite the structure, setup, validation, and design system sections.
3. Verify all paths mentioned exist.
4. Keep it concise.

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
cat README.md
ls apps/ packages/  # verify structure matches README description
```

---

## Completion Evidence

- **Files created/modified**: `README.md` (rewritten), `docs/changelog/20260609-112600-1126-2026-06-09-task-1126-readme-monorepo-alignment-builders.md` (created)
- **Tests or validation commands**: `cat README.md | grep -q "melos" && cat README.md | grep -q "warp_prism_ui"` — PASS
- **Local changelog entry**: `docs/changelog/20260609-112600-1126-2026-06-09-task-1126-readme-monorepo-alignment-builders.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-09
