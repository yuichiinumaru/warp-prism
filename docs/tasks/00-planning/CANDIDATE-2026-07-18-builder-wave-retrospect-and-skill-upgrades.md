# CANDIDATE — Builder Wave Retrospect & Skill Upgrades (2026-07-18)

> **Type**: Planning candidate (not executable)  
> **Owner lane later**: architect-orchestrator  
> **Source wave**: builder drain of warp-prism `01-open` + `02-doing` (23 tasks) → all formal **100/100** in `03-review/`

## Wave Outcome

| Metric | Result |
| --- | --- |
| Tasks drained | **23** (3 claimed from open + 20 doing) |
| Final lane | all in `docs/tasks/03-review/` |
| Formal scores | **100/100** (1514/1517 needed second reviewer path-to-100 from 99) |
| Independent `04-completed` | **not** used (correct — independent reviewer lane owns that) |

## What Caused Review Ping-Pong (Historical + This Wave)

### Recurring failure classes (pre-wave, drained this session)

1. **Stale evidence vs live code** — drain scores 74–88 while code already fixed; inventory counters (+808 vs +810, barrel 263 vs 274).
2. **A11y 48dp / semantics** — chips, icon hits, tabs, watchlist pin/unpin nesting under `excludeSemantics`.
3. **Lifecycle hygiene** — controller maps without dispose-on-close; post-frame without `mounted`; listener setState without mount guard.
4. **Package-wide gates mis-owned** — organism tasks rejected for package analyzer/format drift outside Where table.
5. **Phantom completion / ledger honesty** — Builder Done with unchecked melos boxes; “Ready for Review” while still `02-doing`.
6. **Format gate as sole reject** — red `dart format --set-exit-if-changed` after otherwise solid work.

### This-wave process learnings

| Issue | Impact | Mitigation adopted mid-wave |
| --- | --- | --- |
| 13 parallel Flutter engineers | TUI crash / zram thrash | Cap ~5 concurrent; packs of **4–5 same-area** tasks |
| Per-task analyze/test | RAM + dart AO memory | **Gates once at end of pack** |
| Session death | Lost subagent resume IDs | Redispatch from live disk; prefer resume when IDs alive |
| Reviewer left S=99 in 03-review | Protocol gap | Parent forced path-to-100 resume before accepting wave |

## What Would Hit 100 First-Pass More Often

1. **Evidence re-stamp checklist** before any self-score: suite counts, analyzer issue count, barrel freeze lock, deep-import DEEP=0.
2. **Organism Definition of Done mini-gate**: 48dp interactive, dispose inventory, gallery case, alias+barrel, scoped tests, format clean — in coding-execution or flutter-harness.
3. **Shared-surface owner** for `organisms.dart` / `prism_aliases.dart` / gallery registry in multi-agent waves (single appender or serialize).
4. **Score routing hard rule in reviewer prompt**: never promote/hold at 90–99 without applying path-to-100 in the same turn.

## Proposed Skill / Workflow Upgrades

> Convert to executable tasks via architect-orchestrator if accepted.

### U1 — `flutter-harness`: Organism path-to-100 checklist subskill

**Problem**: Repeated −10..−20 from a11y/lifecycle/format.  
**Proposal**: Subskill `organism-exit-gate` with binary checks + commands (`format`, scoped analyze, organism test dir, boundary harness).  
**Trigger**: EPIC-15/16 organism tasks, ADS work.

### U2 — `code-quality-harness`: Evidence currency axiom

**Problem**: Reviews fail on stale inventory numbers while product is green.  
**Proposal**: Axiom or verification-gate step: “re-count live metrics before scoring; delta from prior report must be classified RESOLVED/REGRESSION/EVIDENCE_GAP”.  
**Applies**: governance inventories, barrel audits, failure baselines.

### U3 — `coding-execution-harness`: Host-constrained pack mode

**Problem**: Max-parallel Flutter waves OOM host with concurrent Go/Next.  
**Proposal**: Document default for heavy Flutter: ≤5 agents, 4–5 tasks/same-area, gates at pack end; resume-before-redispatch.  
**Link**: builder-orchestration.md Phase 2–3.

### U4 — `gt-subagent-review` / parallel-review-builder: S∈[90,100) force-fix

**Problem**: Reviewer moved 1514/1517 at 99 without patch.  
**Proposal**: Explicit step: if 90≤S<100, **must** apply path-to-100 patches in-session before lane move; cannot leave HELD_IN_REVIEW_PATH_TO_100 in 03-review.

### U5 — `project-management` builder-orchestration: shared barrel serialization

**Problem**: Parallel organism writers race on barrels/gallery.  
**Proposal**: Wave planner rule: one “export owner” subagent or post-wave export reconcile task when >3 organism workers.

### U6 — Flutter + memory ops note (ops, not skill)

**Problem**: Crash correlated with Flutter analyze/test + full zram.  
**Proposal**: Parent ops doc: prefer file swap on btrfs carefully; raise zram; stagger `flutter test --concurrency=1` under load. Optional later root-cause note (dart AO RSS).

## Suggested Follow-On Executable Task Seeds

| Seed | Title |
| --- | --- |
| T-A | Add flutter organism-exit-gate subskill + wire into gt-flutter-engineer profile |
| T-B | Patch gt-parallel-review-builder score routing for mandatory 90–99 fix-before-promote |
| T-C | Evidence-currency step in verification-gate for inventory/barrel tasks |
| T-D | Builder pack-mode defaults in builder-orchestration.md |

## Non-Goals

- Do not auto-promote these candidates to `01-open` without architect pass.
- Do not move any of the 23 tasks to `04-completed` from this builder wave.
