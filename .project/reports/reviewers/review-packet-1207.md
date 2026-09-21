# Review Packet: Task 1207 — Review Packet Generator

> **Date**: 2026-06-09
> **Executor**: builders
> **Promotion State**: Ready For Review
> **Task Type**: Governance

## 1. Summary

Created a standard review packet format for Warp Prism tasks. The packet
summarizes task identity, files changed, gates run, pass/fail, known failures,
classification, and risk notes. This enables reviewers to make 2-minute
decisions without re-reading entire task files.

## 2. Files Changed

| Status | File Path | Purpose |
|--------|-----------|---------|
| Created | `docs/tasks/review-packet-template.md` | Review packet template |
| Created | `.agents/workflows/generate-review-packet.md` | Workflow for generating packets |
| Created | `docs/changelog/2026-06-09-task-1207-review-packet-generator.md` | Changelog entry |
| Modified | `docs/tasks/02-doing/1207-warp-prism-review-packet-generator.md` | Task completion evidence |

## 3. Gate Results

| Gate | Command | Result | Classification |
|------|---------|--------|----------------|
| Local Proof | `cat docs/tasks/review-packet-template.md` | PASS | N/A |
| Local Proof | `grep "review packet" .agents/rules/promotion-state-model.md` | PASS | N/A |
| File Check | `test -f docs/tasks/review-packet-template.md && test -f .agents/workflows/generate-review-packet.md` | PASS | N/A |

## 4. Known Failures

None.

## 5. Risk Notes

- The template includes examples converted from Task 1107 and Task 1201.
- The promotion state model (`.agents/rules/promotion-state-model.md`) already required review packets; this task provides the template and workflow.
- The template is optimized for reviewer consumption: scannable in under 2 minutes.

## 6. Recommendation

**Ready For Review**

All deliverables complete. Template, workflow, and examples are in place. The promotion state model references are verified.
