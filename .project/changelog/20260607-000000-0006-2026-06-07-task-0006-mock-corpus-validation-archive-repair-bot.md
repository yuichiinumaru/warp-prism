---
date: 20260607-000000
timestamp: 20260607-000000
agent: repair-bot
task: "0006"
description: "Mock Corpus Validation and Legacy Archive"
is_rebuild_safe: true
---

# Task 0006 — Mock Corpus Validation and Legacy Archive

## Summary

Finalized EPIC 02 by validating the mock workspace corpus against its
manifest and archiving the legacy YAML-first corpus.

## Changes

- Created `tool/validate_mock_workspace.py` — automated corpus validator
