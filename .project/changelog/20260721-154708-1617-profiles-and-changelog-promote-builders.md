---
date: 20260721-154708
timestamp: 20260721-154708
project: "warp-prism"
agent: "builders"
task: "1617"
description: "Promoted docs/changelog (~267) to .changelog; symlink; recovered unique keys after repair pollution; profiles merge 283 residual + collision merge; AGENTS path fix."
is_rebuild_safe: true
---

# Task 1617: profiles-and-changelog-promote

## Summary

Promoted docs/changelog (~267) to .changelog; symlink; recovered unique keys after repair pollution; profiles merge 283 residual + collision merge; AGENTS path fix.

## Changes

- Documented task completion details.

## Verification

- [x] validate entries=267; docs/changelog symlink; _by_lane architects/builders/reviewers
- [x] docs/changelog is symlink to ../.changelog (or migrate-created ledger)
- [x] validate/build green after migration wave 20260721
