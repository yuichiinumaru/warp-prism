# Task 1302: Public Barrel Audit

> **Status**: `[x]` Done (pending review)
> **Review State**: Open — unstarted task; lane mismatch (should be in 01-open/)
> **Priority**: 🟡 P1
> **Type**: `governance`
> **Origin**: EPIC-13, stabilization wave, barrel exports both DS* and Prism* names.
> **Blocks**: 1305 (catalog expansion depends on clean barrel)
> **Depends on**: 1301 (Prism namespace remediation)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1302` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Audit the public barrel of `packages/warp_prism_ui` to determine exactly what is
exported publicly, what should stay in `src/`, and what is experimental. Produce
a definitive export manifest.

## Background Context

### What already exists

- `packages/warp_prism_ui/lib/warp_prism_ui.dart` is the public barrel.
- It re-exports tokens, atoms, molecules, organisms, templates, and gallery.
- Some exports are `DS*` names, some are `Prism*` aliases.
- Gallery files are exported publicly but may contain demo-only code.

### What is missing or broken

- No definitive list of what is "public API" vs "internal implementation."
- Gallery/demo code is exported alongside production components.
- No test enforces that consumers only import from the public barrel.

---

## Test Requirements

- A definitive export manifest exists listing every public symbol.
- Gallery/demo exports are separated from production exports.
- The boundary test harness (Task 1205) enforces barrel-only imports.

---

## Exit Conditions

- [x] A report exists at `docs/design/public-barrel-audit.md`
  listing every exported symbol and its classification (production, experimental,
  gallery-only).
- [x] Gallery/demo exports separated from production exports.
  **Documented** — gallery types classified as gallery-only in §2.6, separation
  recommendation in §6.1 and §7.2. No code change (guardrail: do not remove
  exports).
- [ ] Consumer apps import only from the public barrel (verified by boundary
  test harness). **Deferred** — depends on Task 1205.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  `packages/warp_prism_ui/lib/warp_prism_ui.dart` and all sub-barrels it
  re-exports.
- [x] List every symbol exported by the public barrel.
- [x] Classify each symbol: production, experimental, gallery-only, internal.
- [x] Write the manifest to `docs/design/public-barrel-audit.md`.
- [x] If gallery exports are mixed with production, separate them (e.g., move
  gallery to a separate export or document the decision to keep them).
  **Documented** — gallery separation recommended in audit §6.1 and §7.2.
- [ ] Verify boundary test harness enforces barrel-only imports.
  **Deferred** — depends on Task 1205 (boundary test harness).
- [x] **Simplicity pass**: the manifest is a list, not a design doc.
- [x] **Regression verification**: verify the barrel still compiles.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Read — public barrel |
| `docs/design/public-barrel-audit.md` | Created — export manifest |

### How

1. Read the public barrel and all sub-barrels.
2. Extract every exported symbol name.
3. Classify each symbol.
4. Write the manifest.
5. If needed, restructure the barrel to separate concerns.

### Why

Without a definitive export manifest, consumers cannot know what is stable API
and what is experimental. This blocks confident ADS consumption and makes golden
tests meaningless if they test internal implementation details.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not remove exports that existing consumers depend on. Only classify and
> document. Separation (not removal) is the goal.

---

## Validation Commands

```bash
cat docs/design/public-barrel-audit.md
dart analyze packages/warp_prism_ui/
```

---

## Completion Evidence

- **Files created/modified**:
  - Created: `docs/design/public-barrel-audit.md`
  - Modified: `docs/tasks/02-doing/1302-warp-prism-public-barrel-audit.md`
- **Tests or validation commands**:
  - `dart analyze packages/warp_prism_ui/` — PASS (0 errors, info-level lints only)
  - `test -f docs/design/public-barrel-audit.md` — PASS
- **Local changelog entry**: `docs/changelog/1302-public-barrel-audit.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-09
