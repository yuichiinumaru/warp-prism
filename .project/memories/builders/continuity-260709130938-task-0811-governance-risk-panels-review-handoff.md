---
type: continuity
title: "task-0811-governance-risk-panels-review-handoff"
agent: builders
created: 2026-07-09T13:09:38
date: 2026-07-09
---

# task-0811-governance-risk-panels-review-handoff

## Task 0811 handoff

**Status**: Promoted to `docs/tasks/03-review/` after builder self-review **100/100**.

### What shipped
- Risk panels: orphan, stale, proof-gap, **changelog-without-task** (not fan-in)
- Service: `_detectChangelogWithoutTaskLink` → `DiagnosticCategory.missingDependency`
- Prism* API on issue group/filter widgets
- Issue rows: asset title + category/severity + explanation (+ optional drilldown)

### Proof
- `flutter test test/features/governance/governance_issue_panels_test.dart test/data/services/workspace_diagnostics_service_test.dart` → 46/46
- Scoped analyze → 0 errors

### Files
- `apps/observatory/lib/features/governance/presentation/widgets/governance_issue_{group,filters}.dart`
- `apps/observatory/lib/data/services/workspace_diagnostics_service.dart`
- `docs/changelog/2026-07-09-task-0811-governance-orphan-stale-proof-panels.md`
- Task: `docs/tasks/03-review/0811-warp-prism-governance-orphan-stale-proof-panels.md`

### Notes
- Fan-in remains Task 0812 (`brokenEdge` / FanInHotspotsPanel)
- Concurrent drilldown hooks on `GovernanceIssueGroup.onDrilldown` preserved
