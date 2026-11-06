# HOLD-warp-prism-component-registry-schema (EPIC-B S1)

> **Planning Status**: Strategically Deferred
> **Promotion Gate**: program acceptance (PLAN doc) + active catalog hardening (1840/1843) resolved or explicitly sequenced (shared `apps/catalog` + gallery writeset).
> **Reason held**: strategic sequencing — the gallery registry files are under active remediation; designing the projection against a moving target forces rework. The ivisa shape is stable reference, so the design half is well-bounded when the writeset frees.
> **Promotion target**: `01-open` when gate met AND §3.1 readiness holds.
> **Type**: `feature` (spec) | **Origin**: Phase 1 inventory G3 + review PASS `ses_edbfcec4dffeX44ZMBOaLDsRWR`
> **Depends on**: Phase 1 PASS (met); sequences after 1840/1843 | **Blocks**: `HOLD-warp-prism-registry-harvest-verify-loop`

---

## Objective

Design the machine-readable component/contract registry schema for Warp Prism: a JSON projection of the existing Dart const gallery registry (`dsGallerySections`, 25 sections per F16 amendment) plus contract entries for the four runtime contracts — field-for-field mapped from the proven ivisa shape, with every React-specific field either dropped or replaced by a Dart/Prism equivalent, and an explicit non-replacement clause (the Dart const registry stays the source of truth; the JSON is a derived projection).

## Background Context

### What already exists

- `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart` — Dart const `DSGallerySectionSpec` list (25 entries): stable `id`, `title`, `subtitle`, `builder`; consumed by gallery page + drift-guard tests.
- ivisa `packages/ui/component-registry.json` (6017 lines): `{version, lastUpdated, components[{id,name,type,description,filePath,importPath,props[{name,type,required,description,defaultValue}],dependencies,usageExamples}]}`.
- ADS taxonomy tokens→atoms→molecules→organisms→templates→gallery (§5 inventory) — the registry must describe this taxonomy, not rename it.

### What is missing

- No JSON projection; no contract entries (runtime contracts undescribed); no versioning/staleness field; no decision on prop-type representation for Dart (string metadata vs analyzer-derived).

## Test Requirements

- Every ivisa field has a disposition: keep / adapt (with Dart equivalent) / drop (with reason).
- The schema covers all five ADS levels + the four runtime contracts + proof-lab sections.
- A worked example entry (one organism + one contract) validates the schema by construction.
- The non-replacement clause is mechanical (projection regenerable; const registry authoritative), not prose.

## Exit Conditions

- [ ] Schema + field-disposition table + two worked examples completed (`## Specification`).
- [ ] Cited-path sweep passes.
- [ ] No `warp_prism_ui` source renamed or restructured (taxonomy additive-only).
- [ ] No 03-review/02-doing writeset touched (1840/1843/1846 disjoint — verify before writing).
- [ ] Completion Evidence filled.

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: `design_system_gallery_registry.dart` (full const list), `design_system_gallery_sections.dart` (section shape), `prism_aliases.dart` (public surface), ivisa `component-registry.json` (shape reference via `references/...` route), Phase 1 inventory §1.3 + §5.
- [ ] Write the field-disposition table (ivisa field → keep/adapt/drop + reason).
- [ ] Write the Prism schema (JSON shape for components + contracts + taxonomy level + proof pointers).
- [ ] Write two worked examples (one organism, one runtime contract) and validate them against the schema by hand.
- [ ] Write the non-replacement clause (projection direction, regeneration rule, staleness field).
- [ ] **Simplicity pass**: drop every field no consumer of the registry needs.
- [ ] **Regression verification**: cited-path sweep; gallery tests untouched.

### Where

| File | Purpose |
|---|---|
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart` | Read — source of truth to project |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Read — section shape |
| `references/secondary-yuichiinumaru-ivisa-tamagui/ivisa-tamagui/packages/ui/component-registry.json` | Read — shape reference (bounded reads only; never wholesale) |
| `.project/tasks/02-doing/` (1840/1843 files) | Read — writeset to avoid |
| This file (`## Specification`) | Create — schema + examples live here |

### How

1. Read the const registry fully before designing anything (projection, not invention).
2. Decide prop-type representation from evidence (analyzer-derived vs string metadata) — record the decision with reason.
3. Keep the schema versioned from day one (`version`, `lastUpdated` equivalents).

### Why

Without a machine-readable registry, the catalog is undiscoverable outside Dart, verification loops stay hand-maintained, and agents consume Prism by hallucination — the exact failure the ivisa prior art solves.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not rename/restructure any `warp_prism_ui` source. Do not copy ivisa content (shape only). Do not touch 1840/1843/1846 writesets.

---

## Validation Commands

```bash
ls packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart .project/reports/architects/future-capability-program-inventory-2026-10-10.md .project/tasks/00-planning/PLAN-warp-prism-future-capability-program.md
```

Code gates do not apply to this prose spec; on promotion the executor adds package-appropriate exits for any shipped projection code.

---

## Specification

*(To be written on promotion-approach: field-disposition table, Prism schema, two worked examples, non-replacement clause.)*

---

## Completion Evidence

- **Files created/modified**: (executor fills)
- **Tests or validation commands**: (commands + PASS/FAIL)
- **Local changelog entry**: (path)
- **Executor**: —
- **Completion date**: —
