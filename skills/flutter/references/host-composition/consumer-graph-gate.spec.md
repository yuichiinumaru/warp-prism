# Affected-Consumer Derivation & Targeted Host-Smoke Reference

This is a reference contract for deciding **which real Flutter consumers need
host-composition evidence after a shared change**.

It is not an active deterministic gate until a project/harness implements and
calibrates the mechanism.

## Problem

A shared package can pass all package tests while one or more applications that
embed it are broken.

Running every app's full E2E suite after every change is also wasteful.

The intended mechanism is:

```text
classify changed shared surface
→ derive affected consumer apps from the package/dependency graph
→ run targeted real-host smoke only where the claim can propagate
```

Evidence vocabulary comes from:

`../../sub-skills/testing/SUBSKILL.md`

## Coarse Change Classes

Start coarse. Symbol/AST-level impact analysis is optional later.

| Category | Typical matches |
|---|---|
| `TOKENS` | shared design tokens |
| `THEME_API` | `ThemeData`, `ColorScheme`, typography/component themes |
| `CORE_WIDGET` | shared scaffold/nav/app-bar/modal/shell components |
| `DS_PUBLIC_API` | design-system/public package exports or behavior |
| `ROUTING` | route tables/router wrappers/deep-link handling |
| `APP_THEME_WIRING` | host `MaterialApp`, theme providers/modes |
| `HOST_ONLY_VIEW` | app-local view with no shared-package blast radius |

## Evidence Selection

Examples, subject to the active project's actual topology:

| Category | Typical required evidence |
|---|---|
| `TOKENS` | token/unit + affected widget/package proof + host smoke for consumers importing the affected theme/token path |
| `THEME_API` | theme/package proof + host smoke for affected consumers |
| `CORE_WIDGET` | package integration + host smoke for actual consumers/routes using it |
| `DS_PUBLIC_API` | package proof + host smoke for consumers whose contract is affected |
| `ROUTING` | host boot/navigation smoke for the affected app; e2e only when the claim requires true platform/user-flow behavior |
| `APP_THEME_WIRING` | host smoke across the affected route/layout/theme surfaces |
| `HOST_ONLY_VIEW` | app-local widget/host proof according to blast radius |

"Small diff" is not itself evidence that a consumer cannot be affected.

## Derivation

Prefer the repo's real package graph:

- Melos/package workspace metadata;
- `dart pub` / `flutter pub` dependency information;
- manifest/path dependencies;
- explicit app-package ownership maps.

Compute direct and transitive consumer apps for the changed shared package.
Narrowing by symbol usage can be added later when it is reliable enough to reduce
cost without hiding consumers.

## Host-Smoke Shape

A targeted host smoke is intentionally smaller than full E2E:

- boot the real app/root composition;
- navigate to the representative affected surface;
- perform the semantic interaction relevant to the change;
- keep framework/runtime error visibility active;
- use representative constraints/viewport/theme only where the claim depends on
  them;
- emit reproducible evidence.

Full E2E/device matrices are reserved for claims/milestones that need them.

## Project-Specific Inputs

The skill must not invent universal values for:

- canonical app shells;
- supported consumer apps;
- representative routes;
- representative viewports/constraints;
- theme modes;
- graph snapshot location/cadence.

Use explicit project policy or derive the minimal affected set from source reality.
If required inputs are unknown, state the evidence limitation instead of silently
choosing arbitrary defaults.

## Mechanization Boundary

A future script may:
- classify changed paths;
- build the dependency graph;
- emit affected consumer candidates;
- launch configured smoke commands.

Such a script emits evidence/targets. It does not independently grant task PASS.

## Scope Guard

Do not turn this reference into:
- full E2E on every PR;
- every widget × every shell × every viewport;
- a second remediation router;
- a second review/acceptance engine.
