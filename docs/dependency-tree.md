# Dependency Tree & Stabilization Remediation Order

> **Updated**: 2026-06-11
> **Scope**: Warp Prism stabilization backlog and historical dependency graph
> **Primary strategy source**: `docs/reports/warp-prism-stabilization-strategy.md`
> **Review inputs**: builder-orchestrator dependency analysis, architect review, `gt-architect` and `gt-architect-reviewer` read-only plan reviews

---

## 0. Correction Summary

This document was corrected after review. The original draft ranked work mostly by
raw task fan-out, which over-prioritized historical high-fanout tasks such as
`1000`, `0310`, `1101`, and `1102`.

That is not the right execution lens for the current project state. Warp Prism's
active problem is not lack of feature coverage. The active problem is promotion
confidence, failing package gates, stale task states, and review evidence drift.

The corrected remediation order is:

```text
Phase 0 — Truth / lane / evidence reconciliation
Phase 1 — EPIC-12 governance foundation
Phase 2 — EPIC-13 ADS package stabilization
Phase 3 — EPIC-14 Observatory reconciliation
Phase 4 — Historical backlog revalidation
```

Raw fan-out remains useful as structural evidence, but it is no longer the driver
for the first remediation wave.

---

## 1. Corrected Criticality Lens

### 1.1 Rejected primary formula

The first draft used:

```text
criticality = impact / review_quality
impact = fan_out + priority_weight
```

This produced misleading first-wave recommendations because broad historical
foundation tasks outranked active stabilization prerequisites.

### 1.2 Stabilization criticality model

Use this lens instead:

| Factor | Meaning | Priority |
| --- | --- | --- |
| Phase dependency | Whether the task is part of EPIC-12 → EPIC-13 → EPIC-14 sequencing | Highest |
| Gate impact | Whether the task clears known package/app validation failures | Highest |
| Promotion governance | Whether it defines review gates, failure taxonomy, lane truth, or pre-existing failure policy | High |
| Evidence freshness | Whether task state, reports, and Completion Evidence agree with current filesystem evidence | High |
| Package/consumer boundary | Whether the task affects `warp_prism_ui` before downstream apps consume it | Medium |
| Raw fan-out | Number of tasks listed in `Blocks` | Tie-breaker / appendix only |

### 1.3 Corrected priority clusters

#### P0-A — Governance truth layer (EPIC-12)

These define whether work can be promoted honestly:

- `1201` — Test Failure Baseline Inventory
- `1202` — Promotion State Model Definition
- `1203` — Test Gate Matrix per Task Type
- `1204` — Melos Test Script Normalization
- `1205` — Boundary Test Harness
- `1206` — Pre-existing Failure Classification Policy
- `1207` — Review Packet Generator
- `1208` — Existing Task Lane Reconciliation

#### P0-B — ADS package gate stabilization (EPIC-13)

These clear `packages/warp_prism_ui` failures and make downstream app review
meaningful:

- `1304` — Gallery Compile Boundary Cleanup
- `1303` — Component Contract Reconciliation
- `1307` — Accessibility and Semantics Reconciliation
- `1309` — State Vocabulary Surface Reconciliation
- `1302` — Public Barrel Audit
- `1305` — Catalog Contract Expansion
- `1306` — Golden Baseline MVP
- `1301` — Prism Namespace Remediation / verification
- `1308` — Toast Async Lifecycle Stabilization (**already Ready For Review**)

#### P1 — Observatory reconciliation (EPIC-14)

These should follow governance truth and ADS package stabilization because
Observatory consumes `warp_prism_ui`:

- `1401` — Observatory Failure Baseline Inventory
- `1402` — Corpus and Frontmatter Contract Audit
- `1403` — Parser and Task Projection Reconciliation
- `1404` — View Model and Mapper Contract Reconciliation
- `1405` — Detail Variant and Responsive Shell Reconciliation
- `1406` — History and Operate Feature Flow Reconciliation
- `1407` — Legacy Test Retirement or Rewrite Audit
- `1408` — Observatory Package Imports Cleanup

#### P2 — Historical validation backlog

These remain real tasks and should stay in the dependency graph, but they do not
drive the first stabilization wave:

- `000x`, `001x`, `031x`, `041x`, `051x`, `061x`, `071x`, `081x`, `090x`
- `1000`–`1070`
- historical `1101`–`1126` cleanup/revalidation where not already in review

---

## 2. Current Evidence Baseline

### 2.1 Failure baseline

Current available failure report:

- `docs/reports/warp-prism-test-failure-baseline.md`

It records:

| Package | Pass | Fail | Status |
| --- | ---: | ---: | --- |
| `warp_prism_ui` | 764 | 24 | Failing package gate |
| `observatory` | 589 | 64 | Failing, classified as pre-existing |
| `cybercore` | 12 | 0 | Green |
| `catalog` | 1 | 0 | Green but weak proof surface |
| **Total** | **1366** | **88** | **94.0% pass rate** |

Important corrections:

- Older strategy documents mention 95 failures.
- After Task `1308`, the current baseline reports 88 failures.
- `1308` fixed 7 toast failures and is now marked `Ready For Review`.

### 2.2 Review backlog snapshot

`docs/reports/warp-prism-review-backlog-snapshot.md` reports:

| Promotion State | Count |
| --- | ---: |
| Ready For Review | 1 |
| Builder Done | 23 |
| Package Gate Failed | 15 |
| Blocked | 46 |
| Open | 6 |
| In Progress | 1 |

Caveats:

- The snapshot classified 92 tasks, while the live `02-doing/` directory has drifted since then.
- Many old task files still say "Flutter SDK not installed". Current reports and local tooling evidence show Flutter tests have since run, so those blocker claims should be treated as stale unless reproduced.
- Do not mass-promote historical tasks merely because Flutter is currently available. The active first-order blockers are governance truth and known package/app test failures.

### 2.3 Known task/report drift that must be reconciled

| Item | Drift |
| --- | --- |
| `1201` | Task expects `docs/reports/warp-prism-failure-baseline-inventory.md`; current report is `docs/reports/warp-prism-test-failure-baseline.md`; task still says `[ ] Open`. |
| `1203` | Backlog snapshot previously called evidence template-only; task should be re-read before promotion. |
| `1308` | Marked `Ready For Review` but still in `02-doing/`; should receive independent review/promotion decision. |
| `1401` | Header has `[x] Builder Done` but Review State says Open/lane mismatch; Completion Evidence is filled. |
| `1070` | Governance task has PASS evidence but stale Review State says Flutter SDK blocked. Treat as optional hygiene, not stabilization root. |

---

## 3. Corrected Dependency Phases

### Phase 0 — Truth / lane / evidence reconciliation

Purpose: align task state, current reports, and lane truth before broad remediation.

Immediate actions:

1. Reconcile `1201` with `docs/reports/warp-prism-test-failure-baseline.md`.
2. Confirm `1202`, `1203`, `1204`, `1208` evidence freshness.
3. Send `1308` to independent review/promotion decision.
4. Treat old "Flutter SDK not installed" claims as stale unless current commands reproduce them.
5. Do not start mass historical revalidation until EPIC-12 gates are coherent.

### Phase 1 — EPIC-12 Governance Foundation

Purpose: make promotion deterministic.

Corrected dependency shape:

```text
1201 → 1202 → 1203
          ↓      ↓
         1208   1204 → 1205 → 1206 → 1207
```

Practical current-state interpretation:

| Task | Role | Treatment |
| --- | --- | --- |
| `1201` | Failure baseline inventory | First reconciliation task; connect task evidence to current failure report. |
| `1202` | Promotion state model | Verify evidence and use as governance source. |
| `1203` | Gate matrix | Verify/complete evidence before broad promotion. |
| `1204` | Melos scripts | Verify commands used by builders/reviewers. |
| `1205` | Boundary harness | Complete/verify after scripts and namespace evidence. |
| `1206` | Pre-existing failure policy | Prevent "pre-existing" from becoming a bypass. |
| `1207` | Review packet generator | Use to scale review loop once gates are defined. |
| `1208` | Lane reconciliation | Treat snapshot as evidence; refresh if stale. |

### Phase 2 — EPIC-13 ADS Package Stabilization

Purpose: make `packages/warp_prism_ui` trustworthy.

Failure evidence from `docs/reports/warp-prism-test-failure-baseline.md` maps to:

| Failure area | Count | Correct task |
| --- | ---: | --- |
| Gallery compile | 7 | `1304` |
| Molecules/templates/operational/atoms contract drift | 13 | `1303` |
| Accessibility/semantics | 3 | `1307` |
| State vocabulary | 1 | `1309` |
| Toast async lifecycle | 7 fixed | `1308` review/promotion |

Corrected order:

```text
1301 / 1302 verification layer
        ↓
1304 gallery compile cleanup
        ↓
1303 component contract reconciliation
        ├── 1307 accessibility / semantics
        ├── 1309 state vocabulary
        ├── 1305 catalog contract expansion
        └── 1306 golden baseline MVP

1308 → independent review now
```

Notes:

- `1304` and `1303` are more important first ADS code fixes than historical
  high-fanout tasks because they map directly to current package failures.
- `1301` is important but appears largely implemented; treat it as verification/review unless fresh evidence says otherwise.
- `1302` supports public export correctness and should run near the start of ADS stabilization.

### Phase 3 — EPIC-14 Observatory Reconciliation

Purpose: make `apps/observatory` green or classify residual failures.

Corrected dependency shape:

```text
1401 → 1402 → 1403 → 1404 → 1405 → 1406 → 1407
                                  └──── 1408 parallel cleanup after 1403
```

Notes:

- `1401` has high fan-out but should not outrank EPIC-12/13.
- Observatory currently has 64 failures classified as pre-existing.
- Because Observatory imports the ADS package, Phase 3 should start after ADS package stabilization is mostly credible.
- `1402` already has `docs/reports/corpus-frontmatter-audit.md`; it may need evidence refresh rather than implementation from scratch.

### Phase 4 — Historical backlog revalidation

Purpose: retain the full graph without confusing historical fan-out for current
stabilization priority.

| Domain | Tasks |
| --- | --- |
| Mock corpus | `0001`–`0006` |
| Foundation / DS historical tasks | `0010`–`0020` |
| Data backbone | `0310`–`0315` |
| Shell / Overview | `0410`–`0413` |
| Map | `0510`–`0514` |
| Operate | `0610`–`0613` |
| History | `0710`–`0713` |
| Governance surfaces | `0810`–`0813` |
| Asset detail | `0901`–`0905` |
| Polish | `1000`–`1070` |
| Older ADS / CyberCore wave | `1101`–`1126` |

Revalidate these after promotion governance and package gates are trustworthy.

---

## 4. Corrected First Wave

### 4.1 Immediate reviewer wave

| Task | Action | Reason |
| --- | --- | --- |
| `1308` | Independent review / promotion decision | Only explicitly `Ready For Review` task; tests pass 3x; fixed 7 toast failures. |

Review caveat: `1308` Completion Evidence includes changes to protected/broad files
(`AGENTS.md`, `.gitignore`). Review should inspect whether those changes were
explicitly justified and compliant.

### 4.2 Immediate governance reconciliation wave

These are builder/governance repair tasks, not product feature expansion:

| Task | Action | Reason |
| --- | --- | --- |
| `1201` | Reconcile task status/evidence with `docs/reports/warp-prism-test-failure-baseline.md` | Establishes current failure truth. |
| `1202` | Verify promotion state model evidence | Defines lifecycle states used by all later promotions. |
| `1203` | Verify/complete gate matrix evidence | Prevents promotion without gate criteria. |
| `1204` | Verify Melos script normalization | Defines runnable validation commands. |
| `1205` | Complete/verify boundary harness | Prevents package-boundary regressions. |
| `1206` | Verify pre-existing failure policy evidence | Makes "pre-existing" auditable, not a bypass. |
| `1208` | Refresh lane reconciliation snapshot if stale | Gives builders/reviewers lane truth. |

### 4.3 First ADS fix wave after governance truth

| Task | Action | Reason |
| --- | --- | --- |
| `1304` | Fix gallery compile failures | Directly maps to current UI package failures. |
| `1303` | Fix component contract drift | Directly maps to molecule/template/operational/atom failures. |
| `1307` | Fix accessibility/semantics drift | Directly maps to current semantics failures. |
| `1309` | Fix state vocabulary drift | Directly maps to current DSStateSurface failure. |
| `1302` | Public barrel audit | Supports export correctness. |
| `1301` | Verify/review namespace remediation | Supports package/app boundary stability. |
| `1305` | Catalog proof expansion | Strengthens weak catalog proof surface. |
| `1306` | Golden baseline MVP | Adds visual regression confidence. |

### 4.4 Not first-wave

| Task | Corrected treatment |
| --- | --- |
| `1000` | Historical polish/audit backlog; not active stabilization root. |
| `0310` | Historical data backbone validation; not first stabilization blocker. |
| `1101` | Older governance/docs task; not current package-gate root. |
| `1102` | Older inventory/docs task; not current package-gate root. |
| `1401` | Phase 3 Observatory inventory; important, but after EPIC-12/13 unless run as non-blocking prep. |
| `1070` | Optional governance hygiene / historical namespace proof; not package/test stabilization blocker. |

---

## 5. Structural Dependency Appendix

This appendix preserves raw fan-out evidence from the builder analysis. It should
inform later backlog revalidation but must not drive the first stabilization wave.

### 5.1 Highest fan-out tasks

| Task | Fan-out | Blocked Tasks | Corrected interpretation |
| --- | ---: | --- | --- |
| `1000` | 6 | `1010`, `1020`, `1030`, `1040`, `1050`, `1060` | Historical polish chain; later validation backlog. |
| `1401` | 6 | `1402`, `1403`, `1404`, `1405`, `1406`, `1407` | Important Phase 3 root, but after EPIC-12/13. |
| `0310` | 5 | `0311`, `0312`, `0313`, `0314`, `0315` | Historical data backbone chain; not first stabilization root. |
| `1101` | 5 | `1102`, `1103`, `1104`, `1105`, `1106` | Older docs/governance foundation; cleanup later. |
| `1102` | 5 | `1103`, `1104`, `1105`, `1106`, `1108` | Older inventory foundation; cleanup later. |
| `0001` | 5 | `0002`, `0003`, `0004`, `0005`, `0006` | Already in `03-review`; dependency satisfied for later historical backlog. |
| `1104` | 5 | `1103`, `1105`, `1106`, `1107`, `1110` | Already in `03-review`; dependency mostly satisfied. |
| `1301` | 4 | `1303`, `1304`, `1305`, `1205` | Relevant EPIC-13 support task; verify evidence. |
| `0014` | 4 | `0015`, `0016`, `0017`, `0018` | Historical DS chain; later validation backlog. |
| `0510` | 4 | `0511`, `0512`, `0513`, `0514` | Historical Map chain; later validation backlog. |
| `0311` | 4 | `0312`, `0313`, `0314`, `0315` | Historical data chain; later validation backlog. |

### 5.2 Historical dependency chains

```text
Data backbone: 0310 → 0311 → 0312 → 0313 → 0314 → 0315
Polish: 1000 → 1010/1020/1030/1040/1050 → 1060
Older ADS/CyberCore: 1101 → 1102 → 1104/1105 → 1106/1107 → 1108/1109 → 1110 → 1111
Namespace: 1301 → 1303 → 1304 → 1305 → 1306
Observatory: 1401 → 1402 → 1403 → 1404 → 1405 → 1406 → 1407
```

Corrected interpretation:

- Historical chains are retained for traceability.
- Active remediation should follow the stabilization phases above.
- Promote no task solely because it has high historical fan-out.

---

## 6. Visual Stabilization Map

```text
┌─────────────────────────────────────────────┐
│ Phase 0 — Truth / lane / evidence reconcile │
│ 1201 report status, 1208 snapshot, 1308 RFR │
└─────────────────────┬───────────────────────┘
                      │
┌─────────────────────▼───────────────────────┐
│ Phase 1 — EPIC-12 Governance Foundation     │
│ 1201 → 1202 → 1203 → 1204/1205 → 1206/1207  │
└─────────────────────┬───────────────────────┘
                      │
┌─────────────────────▼───────────────────────┐
│ Phase 2 — EPIC-13 ADS Stabilization         │
│ 1304 → 1303 → 1307/1309 → 1305/1306         │
│ 1301/1302 support, 1308 review              │
└─────────────────────┬───────────────────────┘
                      │
┌─────────────────────▼───────────────────────┐
│ Phase 3 — EPIC-14 Observatory Reconciliation│
│ 1401 → 1402 → 1403 → 1404 → 1405 → 1406     │
│ → 1407, with 1408 cleanup                   │
└─────────────────────┬───────────────────────┘
                      │
┌─────────────────────▼───────────────────────┐
│ Phase 4 — Historical backlog revalidation   │
│ 000x, 001x, 031x, 041x, 051x, 061x, etc.    │
└─────────────────────────────────────────────┘
```

---

## 7. Bottom Line

Do **not** launch the first remediation wave from raw fan-out tasks:

```text
1000, 1401, 0310, 1101, 1102, 1301
```

Launch from stabilization truth instead:

1. Review `1308` immediately.
2. Reconcile/complete EPIC-12 governance truth (`1201`, `1202`, `1203`, `1204`, `1205`, `1206`, `1208`).
3. Start EPIC-13 ADS package fixes (`1304`, `1303`, `1307`, `1309`, with `1301/1302` support).
4. Defer EPIC-14 execution until ADS is stable, with `1401` allowed only as non-blocking preparation if capacity exists.
5. Move historical high-fanout chains into Phase 4 backlog revalidation.
