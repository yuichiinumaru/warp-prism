# Drain Analysis 2026-06-20 — Batch 3b CyberCore / Components

> Source: `gt-mechanical-investigator` task `ses_11c8e3422ffef1x9GtDWryUhpZ`.
> Scope: `02-doing/1104-1115`.
> Status: PARTIAL-COMPLETE — subagent read all 12 scoped tasks plus key review reports but hit step limit before writing the full schema. This preserves returned summary evidence.

## Task Status Summary

| Task | Type | Priority | Current Lane | Latest Score | Key Blocker |
| --- | --- | --- | --- | ---: | --- |
| `1104` | architecture/governance | P0 | `02-doing` | 82 rejected | Lane-state defect, missing `melos.yaml`, changelog validator fails on unrelated file. |
| `1105` | architecture/design-system | P0 | `02-doing` | 68 rejected | Policy documents nonexistent `PrismTokens` API; depends on rejected `1104`, `1101`, `1102`. |
| `1106` | feature/design-system | P1 | `02-doing` | 34 rejected | All 8 exit conditions unchecked; workspace resolution broken by `tmp/pub-cache`; dependencies rejected. |
| `1107` | feature/remediation | P0 | `02-doing` | 24 rejected | No `melos.yaml` exists despite exit condition; workspace globs include `tmp/pub-cache`; depends on `1104`. |
| `1108` | architecture/verification | P0 | `02-doing` | 58 rejected | Depends on rejected `1102`; substituted backend docs for frontend route inventory; validation mismatch. |
| `1109` | architecture/verification | P0 | `02-doing` | 62 rejected | Depends on rejected `1108`; missing per-contract source citations; inherits invalid route selection. |
| `1110` | feature | P1 | `02-doing` | 55 rejected | Upstream dependencies rejected; workspace resolution broken; route/non-happy-state proof weak; fixture path mismatch. |
| `1111` | verification/governance | P0 | `02-doing` | 68 rejected | Depends on rejected `1106/1107/1108/1109/1110`; evaluation stale against live code. |
| `1112` | feature/design-system | P0 | `02-doing` | 48 rejected | Hard gate invalid because `1102` rejected; workspace broken; accessibility gaps; filtering not first-class. |
| `1113` | feature/design-system | P0 | `02-doing` | 46 rejected | Hard gate invalid because `1102` rejected; workspace broken; mounted guard and accessibility gaps. |
| `1114` | feature/design-system | P0 | `02-doing` | 50 rejected | Hard gate invalid because `1102` rejected; workspace broken; accessibility gaps; 10K+ virtualization unproven. |
| `1115` | feature/design-system | P1 | `02-doing` | 42 rejected | Hard gate invalid because `1102` rejected; workspace broken; `DSErrorBoundary` globally overrides `FlutterError.onError` unsafely; shimmer needs reduced-motion. |

## Critical Systemic Blockers

1. **Workspace resolution broken**: root `pubspec.yaml` globs `apps/**` and `packages/**`, capturing repo-local nested `apps/observatory/tmp/pub-cache/.../pubspec.yaml` files and breaking `dart pub get`, Melos commands, and Flutter analyzer/test commands. This is the largest shared blocker.
2. **Missing `melos.yaml`**: `1107` requires it; completion evidence is false/stale.
3. **Invalid hard promotion gate**: `1112-1115` require `1102` output, but `1102` is rejected/blocked.
4. **CyberCore evidence domain drift**: `1108/1109/1110/1111` depend on a reliable frontend control-surface inventory that is currently not approved.

## Suggested Routing

- First resolve workspace contamination / glob issue with a specialized repo hygiene or Flutter infra task before broad validation.
- Do not promote `1112-1115` until `1102` is repaired or the hard gate is formally revised.
- `1107` likely needs a dedicated builder to create/align Melos configuration or explicitly revise obsolete task exit conditions.
- CyberCore tasks should be serialized: `1102 -> 1108 -> 1109 -> 1110 -> 1111`.

## Caveat

This report lacks full per-task `Where` table and collision details due step limit. Read individual task files and review reports before implementation dispatch.
