---
id: 2025-06-06-T017-metric-tile-trend-indicators
date: 2025-06-06
project: asw-observatory
task: T017
type: remediation
impact:
  - operate
  - metrics
  - dashboard
skills:
  - design-system-harness
  - frontend-quality-harness
---

# Metric tile trend indicators returned for fix

## Why

`DSMetricTile` displayed static values but had no trend indicator showing whether a metric was increasing, decreasing, or stable. The review cycle returned this task because the Operate dashboard needs trend context to answer "what matters now?"

## Changed

- Added `trend` field to `DSMetricTile` with values: `up`, `down`, `stable`, `unknown`.
- Implemented trend arrow icon with color coding: green for positive trends, red for negative, grey for stable.
- Added `trendLabel` field for accessible text description of the trend.
- Connected trend data to the workspace graph: task counts per lane derive trend from historical snapshots.

## Evidence

- `assets/mock_workspace/docs/tasks/03-review/T017-review-returned-metric-tile-trend-indicators.md` documents the review return.
- `lib/design_system/molecules/ds_metric_tile.dart` implements the trend indicator.
