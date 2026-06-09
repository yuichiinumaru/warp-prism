---
id: 2026-06-06-T017-metric-tile-trend-indicators
date: 2026-06-06
project: warp-prism
task: T017
type: feature
skills:
  - design-system-harness
  - frontend-quality-harness
workflows:
  - gt-code-review
  - reviewer-orchestration
impact:
  - metrics
  - overview
  - trend-indicators
---

# Metric Tile Trend Indicators

Added trend indicators (up/down/stable arrows) to Overview metric tiles showing 7-day change direction.

## Why

Metric tiles show current values but not whether they are improving or declining. Without trend indicators, users cannot assess workspace health at a glance.

## Changed

- DSMetricTile molecule extended with trend direction and delta value
- Trend arrows: up (green), down (red), stable (gray)
- Delta shows absolute and percentage change
- Overview page renders 6 metric tiles with trend data from mock corpus

## Evidence

- Task T017 in review lane (returned for accessibility audit)
- Metric tiles render with trend indicators
- Color contrast verified for trend arrow colors on obsidian background
