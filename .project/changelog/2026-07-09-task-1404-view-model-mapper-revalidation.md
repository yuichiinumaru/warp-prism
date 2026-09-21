---
date: 20260709-061508
timestamp: 20260709-061508
agent: builders
task: "1404"
description: "Task 1404 — View-model / Mapper Revalidation (2026-07-09)"
is_rebuild_safe: true
---

# Task 1404 — View-model / Mapper Revalidation (2026-07-09)

> **Date**: 2026-07-09
> **Executor**: builders
> **Scope**: `apps/observatory/lib/features/overview/`, `apps/observatory/test/data/`, `apps/observatory/test/features/overview/`

## Summary

Revalidated Task 1404 after Task 1403 nested-frontmatter remediation landed in
`03-review/`. Data-layer view-model/mapper contracts remain green. Fixed the
overview page consumer to use the public `Prism*` design-system API so overview
widget tests load and pass.

## Changes

### Overview page — Prism public API consumer

**File**: `apps/observatory/lib/features/overview/overview_page.dart`

Replaced internal `DS*` symbols (`DSColors`, `DSSpacing`, `DSText`,
`DSMetricTile`, `DSStoryPanel`, `DSStoryInsight`) with public `Prism*` aliases
exported by `package:warp_prism_ui/warp_prism_ui.dart`. Applied `const` on
static heading widgets.

### Overview provider — import hygiene

**File**: `apps/observatory/lib/features/overview/overview_provider.dart`

Removed redundant `governance_diagnostics.dart` import (already re-exported by
`data_models.dart`). Prior empty-asset governance warning counting fix retained.

## Validation

| Command | Result |
| --- | --- |
| `flutter test test/data/` | 189/189 PASS |
| `flutter test test/data/providers/` + repositories + services | PASS |
| `flutter test test/features/overview/` | 14/14 PASS |
| Combined overview + data providers/repos/services | 78/78 PASS |
| `dart analyze lib/features/overview/ lib/data/providers/ lib/data/repositories/ lib/data/services/` | No issues found |

## Honesty boundary

Package-wide residual `DS*` compile failures in other feature surfaces remain
**external** to Task 1404 and are not claimed fixed.
