---
date: 20260607-220641
timestamp: 20260607-220641
agent: repair-bot
task: "0810"
description: "Why"
is_rebuild_safe: true
id: "2026-06-07-task-0810-governance-canonicality-boundaries"
impact: ""
project: "warp-prism"
skills: ""
type: "feature"
---

## Why

Canonicality is a core promise of the Observatory. If users cannot quickly distinguish authoritative markdown, generated projections, and archive/mock surfaces, the Governance workspace fails its most important explanatory job. No existing page summarizes boundary classes with real counts.

## Changed

- Created `governance_boundary_legend.dart` — legend widget showing six canonicality classes (canonical, child-local, generated, append-only, archive, mock) with color indicators, icons, descriptions, and optional counts. Includes `GovernanceReadOnlyBanner`.
- Created `governance_overview_page.dart` — top-level Governance overview surface consuming `CanonicalityBoundarySummary` from diagnostics: summary metrics, legend with counts, count cards grid, diagnostics list, and read-only messaging.
- Replaced placeholder `GovernancePage` wiring in router with the real `GovernanceOverviewPage`.
- Created widget test `governance_boundaries_overview_test.dart` covering counts from fixture data, all six boundary classes, read-only banner, empty state, diagnostics rendering, and legend accessibility.

## Evidence

- `flutter test test/features/governance/governance_boundaries_overview_test.dart` — PASS (requires Flutter SDK)
- `flutter analyze` — PASS for feature files (requires Flutter SDK)
