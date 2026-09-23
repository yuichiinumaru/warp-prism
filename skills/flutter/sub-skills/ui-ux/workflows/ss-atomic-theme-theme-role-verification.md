---
name: ss-atomic-theme-theme-role-verification
description: Theme-change test matrix over token domains and roles — layout-affecting construction, interactive states, semantic mapping, data roles, and host-propagation smoke.
---

# Theme-Role Verification Matrix

> Provenance (2026-09-23): merged from
> `.agents/skills/frontend-quality/sub-skills/atomic-theme/workflows/ss-atomic-theme-theme-role-verification.md`
> into the flutter harness (`flutter/sub-skills/ui-ux/workflows/`), Flutter-adapted, per operator
> authorization. Adopted: full 6-phase matrix. Modified: web-only hooks removed (CSS custom
> properties), cross-reference repointed at the local `ui-ux` SUBSKILL. Rejected for this copy:
> nothing structural — Storybook/host-smoke boundary statements kept verbatim.

## When To Run

Run when a change edits, adds, or removes a dynamic theme entry — a semantic
alias or component token that components resolve at runtime — or any theme
API surface that resolves them (`ThemeData`/`ThemeExtension` hooks).

Do NOT run for static primitive token changes with no dynamic consumers, or
for app-local themes not declared in the shared model.

## Phase 1 — Layout-Affecting Construction

1. Identify the domain and primary role of every touched entry (contract:
   `../SUBSKILL.md` Token Domain × Role Contract block; color
   role set = structural/interactive/semantic/data).
2. Entries whose DOMAIN is layout, spacing, elevation, or shape — and
   color entries whose color-role is structural — carry layout/structure
   meaning: assert layout invariants (constraints, sizing, elevation,
   shape) under both theme modes across representative viewports.
3. Layout must not shift across modes beyond the delta the token declares;
   unexpected cross-mode layout drift is a failure, not a visual note.

## Phase 2 — Interactive States

4. For every entry whose color-role is interactive, exercise the full state
   set at minimum: hover, focus, pressed, disabled.
5. Focus state must be visible and focusable-to (actually focus traversal,
   not just a snapshot); disabled must be non-interactive in evaluation.
6. State changes must not move layout: interactive color drives state color
   and elevation deltas only. Any interactive-driven layout change is the
   role-misuse class the token lint flags (L2, annotation spec) — caught
   here as a matrix failure regardless of lint phase.

## Phase 3 — Semantic Mapping

7. For every entry whose color-role is semantic, verify the meaning mapping
   end-to-end: token → alias → component consumption → rendered result
   across modes.
8. Status colors (success/warning/error/info) must resolve to the declared
   semantic alias — never a raw primitive — in every mode.
   Usage audit confirms the alias is what's actually consumed.

9. This phase is about *rendered meaning*, not palette beauty: if mode-toggle
   leaves a stale status color visible, that is a Phase-3 failure even when
   every test suite stays green.

## Phase 4 — Data Roles

10. For entries whose color-role is data (series, category palettes, heat
    scales), assert category distinctness and mode parity: same categories,
    distinct colors, dark/light parity of meaning.
11. Charts in non-declared modes must fall back to the declared data
    palette, not raw primitives, not accidental mode-local colors.

## Phase 5 — Host-Propagation Smoke (real-host-composition rung)

12. Host smoke is REQUIRED for: any change to an entry whose domain is
    layout/spacing/elevation/shape or whose color-role is structural; any
    theme-API change; any new entry gaining a domain+role declaration. It
    boots the real consumer app shell (or declared canonical shell) with
    real routing/DI wiring, visits representative routes, toggles both
    modes, asserts no framework errors, and asserts theme values change on
    every visited route.
13. Gate classification and required evidence follow the flutter wave's
    consumer-graph matrix (TOKENS / THEME_API trigger rows); route list is
    PROJECT-SPECIFIC and owned by the repo, never this skill.

## Phase 6 — Evidence & Completion

14. Record per role class: entries touched, phases run, pass/fail verdicts,
    viewport set, shell identity, route list, and mode toggles exercised.
    Verdict semantics: no-stages-passed ≠ partial ≠ complete. Partial matrix
    coverage must be labeled partial, never reported as complete.
15. Completion signal: per-domain×role coverage verified with labeled
    evidence for every touched entry, host smoke attached when triggered,
    and lint annotations valid per the token-role annotation spec.

## Negative Scope

- No mandate to test every component against every mode × viewport × route
  permutation (Decision §C overengineering guard). Run the matrix over
  touched entries and their direct consumers.
- Storybook stories are NOT the structural host-smoke substitute: see the
  `atomic-storybook` scope in `frontend-quality` for what Storybook
  does own — state/theme/variant visual evidence, not host propagation.
- This workflow does not define the token model, domain axis, or role
  vocabulary — that is the atomic-token rule (AMEND-1 domain×role form),
  now owned at `../SUBSKILL.md`. It executes the matrix.
