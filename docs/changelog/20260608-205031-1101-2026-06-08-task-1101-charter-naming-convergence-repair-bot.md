---
date: 20260608-205031
timestamp: 20260608-205031
agent: repair-bot
task: "1101"
description: "Warp Prism charter, naming policy, and RF8 plan established"
is_rebuild_safe: true
id: "2026-06-08-task-1101-charter-naming-convergence"
impact: ""
project: "warp-prism"
skills: ""
type: "governance"
---

# Warp Prism charter, naming policy, and RF8 plan established

Created the first Warp Prism documentation set under `docs/design/`:
charter, naming policy, and RF8 plan.

## Why

No document defined Warp Prism as a child project, established `Prism*`
component naming, marked `Voidframe` as superseded, or separated ADS work
from CyberCore pilot work. Future implementers could have created
`voidframe_*` packages or confused the ADS scope with migration scope.

## Changed

- `docs/design/charter.md`: child-project charter with purpose, scope,
  non-goals, historical context, and first proof target (ADS Gallery).
- `docs/design/naming.md`: naming policy for `warp_prism_*` packages,
  `Prism*` public components, `Voidframe` supersession, and legacy DS-prefix
  transition table.
- `docs/design/rf8-plan.md`: RF8 plan covering Goal through Eval, with
  separate tracks for ADS, product surfaces, and CyberCore pilot.

## Evidence

- All three files validated: `test -f docs/design/charter.md && test -f
  docs/design/naming.md && test -f docs/design/rf8-plan.md` passes.
- Index rebuild and changelog rebuild have pre-existing failures unrelated
  to this task (missing parent-canonical compatibility indexes; one
  changelog file with broken frontmatter).
