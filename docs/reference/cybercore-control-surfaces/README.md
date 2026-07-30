# CyberCore Control Surfaces Evidence Packet

> **Status**: Source-backed inventory **available** (DoD primary); `screenshot-backed` **ABSENT / OPTIONAL** (deferred)  
> **Task**: Task 1420 packet + Task 1102 (refreshed 2026-07-09; governance amend same day)  
> **Scope**: Warp Prism local documentation evidence packet

## Packet Decision (2026-07-09)

| Decision | Status | Rationale |
| --- | --- | --- |
| Use this packet as screenshot-backed CyberCore evidence | **ABSENT / OPTIONAL** | No screenshots or screenshot reports in-repo; `/tmp/opencode/cc-ui-screenshots-round2` absent. Deferred follow-up if ever available — do not invent. |
| Use live sibling monorepo as source-backed evidence | **ALLOWED — primary DoD** | Explicit 1102 executor instruction: use parent monorepo at `../cybernetics-core` / `/home/sephiroth/working/ganthritor/cybernetics-core`. |
| In-repo vendored frontend snapshot under this directory | **Not present** | Routes/components are cited by absolute/sibling path in design docs, not copied here. |
| Rebuild Task 1102 inventory from Observatory/ADS | **FORBIDDEN** | Repeats F1 rejection (2026-06-17). |
| Screenshot hard-gate for `ready_for_reviewer` | **OPTIONAL (amend APPLIED)** | 2026-07-09 governance amend reclassifies screenshots optional/deferred; source-backed inventory is DoD. Explicit amend (not silent waiver); F2 silent-substitution risk addressed. |
| Task 1102 ready for reviewer under source DoD | **YES** | Leave in `02-doing/` for formal independent reviewer; do not invent visual claims. |

## Evidence Classifications

| Evidence class | Packet status | Location |
| --- | --- | --- |
| `screenshot-backed` | Absent / optional | `screenshot-evidence-index.md` |
| `source-backed` | Available via live monorepo + design inventory (**primary**) | `source-paths.md`, `route-inventory.md`, `docs/design/component-inventory.md` |
| `unavailable` | Historical `/tmp` screenshots | `evidence-provenance.md` |

## Authoritative Inventory Outputs

| Doc | Role |
| --- | --- |
| `docs/design/component-inventory.md` | Full control-surface inventory (required columns) + §0.5 amend **APPLIED** |
| `docs/design/operational-state-vocabulary.md` | State vocabulary + CC→Prism maps |
| `docs/design/cybercore-pilot-surface-matrix.md` | Pilots A/B/C from live routes |

## Files

- `source-paths.md` — approved/live source provenance + path stamp.
- `route-inventory.md` — route/component evidence index.
- `screenshot-evidence-index.md` — screenshot evidence status (optional/absent).
- `evidence-provenance.md` — unblock decision and constraints.
