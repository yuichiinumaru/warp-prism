# Changelog: ganthritor

> **Note**: Auto-generated view for project `ganthritor` from `.changelog/` entries.
> **Do NOT edit manually** - use the changelog skill/subcommands.
> **Last rebuilt**: 2026-09-08 18:09:23 UTC

---

# Task 0017 — Design System Gallery Route Bootstrap (path-to-100)

## Summary

Re-validated the Design System Gallery route bootstrap end-to-end after the
Task 1304 path-to-100 cleanup. Flutter SDK is now available; previous
"BLOCKED: Flutter SDK not installed" exit conditions are now exercised with
real analyzer + test evidence. Required `ds_compat` shim was wired into
seven product pages that still use `DS*` identifiers so the router import
graph can compile under the Prism-only public barrel.

## Changes

- `apps/observatory/lib/features/governance/presentation/governance_overview_page.dart`
  — added `import 'package:warp_prism_observatory/src/ds_compat.dart';`.
- `apps/observatory/lib/features/governance/presentation/widgets/governance_boundary_legend.dart`
  — added `ds_compat` import.
- `apps/observatory/lib/features/governance/presentation/widgets/fan_in_hotspots_panel.dart`
  — added `ds_compat` import.
- `apps/observatory/lib/features/governance/presentation/widgets/governance_issue_filters.dart`
  — added `ds_compat` import.
- `apps/observatory/lib/features/governance/presentation/widgets/governance_issue_group.dart`
  — added `ds_compat` import.
- `apps/observatory/lib/features/governance/presentation/widgets/governance_story_summary.dart`
  — added `ds_compat` import.
- `apps/observatory/lib/features/governance/presentation/widgets/review_pressure_panel.dart`
  — added `ds_compat` import.
- `apps/observatory/lib/features/shell/shell_state_handler.dart` — added
  `ds_compat` import.

No gallery or DS layer code touched. Imports are additive and preserve the
Prism-only public contract via the existing observatory-local compat layer
(unchanged from Task 1408 compat shim).

## Validation (scoped, OOM-safe)

```text
cd packages/warp_prism_ui
flutter analyze lib/src/gallery/ lib/warp_prism_ui.dart lib/src/prism_aliases.dart test/gallery/
  → No issues found! (0 errors, 0 infos)

flutter test test/gallery/design_system_gallery_test.dart
  → 00:19 +13: All tests passed!

cd apps/observatory
flutter analyze lib/app/router.dart lib/app/app.dart lib/main.dart test/app/app_bootstrap_test.dart
  → 1 issue found (prefer_const_constructors in lib/app/app.dart:27:20 — pre-existing info, unrelated to gallery)

flutter test test/app/app_bootstrap_test.dart
  → 00:01 +3: All tests passed!
```

## Exit-condition evidence

- [x] `lib/main.dart`, `lib/app/app.dart`, `lib/app/router.dart` exist from
      Task 0011 and are reused unchanged.
- [x] `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart`
      + `design_system_gallery_sections.dart` linked via
      `lib/warp_prism_ui.dart` public barrel (Prism* names).
- [x] Gallery demonstrates tokens, atoms, molecules, organisms, and templates
      (10 sections in `dsGallerySections` registry).
- [x] `app_bootstrap_test.dart` (3 tests) + `design_system_gallery_test.dart`
      (13 tests) pass under `flutter test`.
- [x] `flutter analyze` passes for the scoped surface (0 errors).
- [x] Changelog note added under `docs/changelog/`.

## Notes for reviewer

- Reviewer agents are unavailable this cycle; the builder applied the
  self-review gate (Law 3.5) and re-checked scope: only `ds_compat` imports
  were added, no semantic or behavioral changes to gallery or DS code.
- The Observatory still uses private `DS*` APIs in product pages via
  `apps/observatory/lib/src/ds_compat.dart`. A full migration to `Prism*`
  is a future task (see `Task 1408`); that migration is out of scope for
  Task 0017.

**Author**: builders

---

# Task 1206: Pre-existing Failure Classification Policy

## Summary

Created `.agents/rules/pre-existing-failure-policy.md` as the short
builder-facing source rule and kept `docs/governance/pre-existing-failure-policy.md`
as the canonical governance policy. Updated
`.agents/rules/promotion-state-model.md` and `docs/governance/promotion-state-model.md`
to reference both surfaces, and reconciled Task 1206 to use the actual baseline
path `docs/reports/warp-prism-test-failure-baseline.md`.

## Changes

- **Created**: `.agents/rules/pre-existing-failure-policy.md` — short builder-facing source rule with teeth: unrelated pre-existing failures do not block, related pre-existing failures block unless explicitly justified by the reviewer, and caused regressions always block.
- **Created**: `docs/governance/pre-existing-failure-policy.md` — full canonical policy with classification decision tree, promotion rules, evidence requirements, reviewer checklist, anti-gaming rules, and current baseline reference (64 Observatory pre-existing failures, 24 UI wave4-regressions).
- **Modified**: `.agents/rules/promotion-state-model.md` — added references to the builder source rule and canonical policy in Rule 2, Failure Taxonomy table, and Reference section.
- **Modified**: `docs/governance/promotion-state-model.md` — added matching canonical references to the builder source rule and canonical policy.
- **Modified**: `docs/tasks/02-doing/1206-warp-prism-pre-existing-failure-classification-policy.md` — reconciled Where table, validation commands, status metadata, and completion evidence; no lane move performed.

## Verification

- `cat .agents/rules/pre-existing-failure-policy.md` → PASS; builder source rule exists and is readable.
- `grep -n "pre-existing" .agents/rules/promotion-state-model.md` → PASS; Rule 2, Failure Taxonomy row, and Reference section reference the source rule and canonical policy.
- `grep -n "pre-existing" docs/governance/promotion-state-model.md` → PASS; canonical governance reference is aligned with the builder source rule.
- `test -f .agents/rules/pre-existing-failure-policy.md` → PASS (exit 0; no stdout).
- `test -f docs/governance/pre-existing-failure-policy.md` → PASS (exit 0; no stdout).
- `test -f docs/reports/warp-prism-test-failure-baseline.md` → PASS (exit 0; no stdout).
- `dart format --set-exit-if-changed docs/governance/pre-existing-failure-policy.md .agents/rules/pre-existing-failure-policy.md .agents/rules/promotion-state-model.md` → N/A applicability probe because all three inputs are Markdown; exact tool output recorded in Task 1206 completion evidence.

---

# Task 1126: README Monorepo Reality Alignment

## Summary

Rewrote `README.md` to match the actual Melos monorepo structure. The previous
README described a single-app Flutter project with `lib/` at root, pending
Tasks 0011-0012, and a stale SDK blocker — none of which reflected reality.

## Changes

| File | Action | Detail |
|------|--------|--------|
| `README.md` | Rewritten | Monorepo structure, Melos commands, package table, `Prism*` naming, quick start, validation commands, documentation links |
| `docs/changelog/20260609-...task-1126-...md` | Created | This changelog entry |

### What was removed

- Root `lib/` project structure (no longer exists)
- References to pending Tasks 0011-0012
- "BLOCKER: Flutter SDK is not installed" section
- Validation baseline referencing nonexistent files
- `DS*` class listing as the primary naming convention

### What was added

- Monorepo structure diagram (`packages/`, `apps/`, `docs/`, `.agents/`)
- Package table (warp_prism_ui, observatory, catalog, cybercore) with roles
- Stack table broken down by package/app (not monolithic)
- `Prism*` naming convention summary with `DS*` as legacy aliases
- Melos quick start: `dart pub get` → `melos bootstrap` → `cd apps/observatory && flutter run`
- Validation: `melos run analyze`, `melos run test`, `melos run validate`
- Documentation links to charter, naming policy, architecture ADR

## Verification

```bash
cat README.md | grep -q "melos" && cat README.md | grep -q "warp_prism_ui" && echo PASS
# PASS
```

All paths mentioned in the README verified to exist on disk:
`apps/observatory/`, `apps/catalog/`, `apps/cybercore/`,
`packages/warp_prism_ui/`, `docs/tasks/`, `docs/reports/`,
`docs/architecture/`, `docs/design/`, `docs/changelog/`.

---
