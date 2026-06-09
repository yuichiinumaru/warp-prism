---
id: 2025-06-05-T016-topbar-search-integration
date: 2025-06-05
project: asw-observatory
task: T016
type: feature
impact:
  - operate
  - search
  - topbar
skills:
  - design-system-harness
  - frontend-quality-harness
---

# Topbar search integration returned for review

## Why

The topbar search was implemented but returned from review because it did not integrate with the workspace graph. Searching for an asset name should navigate to that asset in the current workspace view, not just filter a flat list.

## Changed

- Connected `DSSearchBar` to the workspace graph model via Riverpod provider.
- Search now matches against asset `name`, `description`, and `tags` fields.
- Selecting a search result updates the detail inspector to show the matched asset.
- Added keyboard shortcut (Ctrl+K) to focus the search bar from anywhere in the shell.

## Evidence

- `assets/mock_workspace/docs/tasks/03-review/T016-review-topbar-search-integration.md` documents the review return and fix.
- `lib/design_system/organisms/ds_topbar.dart` implements the search bar.
