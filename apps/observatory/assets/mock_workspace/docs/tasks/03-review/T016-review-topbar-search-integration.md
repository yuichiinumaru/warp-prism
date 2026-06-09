---
id: T016
title: "Review topbar search integration"
status: review
priority: medium
owner: reviewer-orchestrator
created: "2026-06-03"
updated: "2026-06-06"
skills:
  - frontend-quality-harness
  - design-system-harness
workflows:
  - reviewer-orchestration
  - gt-code-review
depends_on:
  - T009
proof_state: partial
review_score: 7.5
---

# Review Topbar Search Integration

## Goal
Review the DSTopbar search integration where DSSearchBar is wired into the topbar via the searchBar widget parameter, ensuring search state is lifted correctly via Riverpod.

## Scope
- Verify DSSearchBar state management uses Riverpod providers
- Confirm search results update the main content area
- Check that search is keyboard-accessible (Cmd+K / Ctrl+K shortcut)

## Exit Conditions
- [ ] Search state flows through Riverpod provider, not local setState
- [ ] Keyboard shortcut activates search bar
- [ ] Search results filter the visible workspace assets
- [ ] Widget test covers search input, results, and keyboard shortcut

## Verification Commands
```bash
flutter test test/features/shell/topbar_search_test.dart
```

## Completion Evidence
*Under review. Riverpod provider integration verified. Keyboard shortcut test coverage added in latest commit.*
