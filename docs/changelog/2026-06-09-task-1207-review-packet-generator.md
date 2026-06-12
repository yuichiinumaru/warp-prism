# Task 1207: Review Packet Generator — Completed

> **Date**: 2026-06-09
> **Executor**: builders

## Summary

Created a standard review packet format for Warp Prism tasks. The packet
summarizes task identity, files changed, gates run, pass/fail, known failures,
classification, and risk notes. This enables reviewers to make 2-minute
decisions without re-reading entire task files.

## Deliverables

- **Template**: `docs/tasks/review-packet-template.md`
- **Workflow**: `.agents/workflows/generate-review-packet.md`
- **Examples**: Converted Task 1107 (Melos migration) and Task 1201 (failure baseline) to new format

## Notes

- The template is optimized for reviewer consumption: scannable in under 2 minutes.
- The workflow includes step-by-step instructions for builders to generate packets.
- The promotion state model (`.agents/rules/promotion-state-model.md`) already requires review packets for `Ready For Review` status (Rule 5).
