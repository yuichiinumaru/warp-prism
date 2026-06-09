# Warp Prism

**ASW Observatory** — Agent System Workspace visibility console built with Flutter.

Warp Prism is a Flutter application that provides a visual console for inspecting and navigating an agent-based workspace. It renders agents, skills, workflows, tasks, and changelog entries from a markdown-frontmatter corpus, presenting them through a design-system-driven UI with lane boards, graph visualization, and detail inspectors.

## Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart SDK >=3.0.0 <4.0.0) |
| Routing | go_router ^14.0.0 |
| State Management | flutter_riverpod ^2.5.0 |
| Graph Visualization | graphview ^1.2.0 |
| Charts | fl_chart ^0.68.0 |
| Data Format | YAML frontmatter in markdown files |

## Project Structure

```
warp-prism/
  lib/
    main.dart                   ← app entrypoint (Task 0011 — pending)
    app/
      app.dart                  ← root widget (Task 0011 — pending)
      router.dart               ← GoRouter config (Task 0011 — pending)
    design_system/
      tokens/                   ← DSColors, DSTypography, DSSpacing, DSRadii, DSShadows, DSMotion, DSSemantics
      atoms/                    ← DSText, DSIcon, DSBadge, DSChip, DSStatusDot, DSDivider, DSGlowBorder, DSGlassPanel
      molecules/                ← DSSearchBar, DSFilterChipGroup, DSAssetCard, DSMetricTile, DSProvenancePill, DSTaskCard, DSEvidenceRow, DSTimelineMarker
      organisms/                ← DSShell, DSSidebar, DSTopbar, DSLaneBoard, DSTimeline, DSDetailInspector, DSStoryPanel, DSGraphCanvas
      templates/                ← MasterDetailTemplate
    data/
      models/                   ← data models
      parsers/                  ← workspace and frontmatter parsers
  assets/
    mock_workspace/             ← markdown-frontmatter corpus (agents, skills, workflows, tasks, changelog)
  test/                         ← test directory (pending Task 0011 bootstrap)
  docs/
    tasks/                      ← real task tracking (not mock)
    reports/                    ← audit and analysis reports
```

## Setup

```bash
# From the warp-prism/ directory:

# 1. Install dependencies
flutter pub get

# 2. Run the app
flutter run
```

**Prerequisites**: Flutter SDK must be installed. See [flutter.dev](https://flutter.dev/docs/get-started/install) for installation instructions.

## Validation

These are the canonical validation commands for this project. Run them from the `warp-prism/` directory.

```bash
# Static analysis
flutter analyze

# Run tests
flutter test
```

### Validation Baseline

> **BLOCKER**: Flutter SDK is not installed in the current execution environment.
> `flutter analyze` and `flutter test` cannot be executed until the SDK is available.
> The baseline below is based on source inspection only (Task 0010 audit).

**Expected state after Tasks 0011-0012 complete**:

| Command | Expected State | Notes |
|---------|---------------|-------|
| `flutter analyze` | PASS (zero errors) | After `main.dart`, `app.dart`, `router.dart` are created by Task 0011 |
| `flutter test` | PASS (zero failures) | After test directory is created and initial tests added |

**Known blockers before baseline can close**:
1. `lib/main.dart` does not exist — no Flutter entrypoint (Task 0011)
2. `lib/app/app.dart` does not exist — no root widget (Task 0011)
3. `lib/app/router.dart` does not exist — no routing (Task 0011)
4. `test/` directory does not exist — no tests at all
5. Flutter SDK not installed in current environment

**Current code quality**: Source inspection (Task 0010) confirmed that all 40 Dart files in `lib/` use consistent `DS*` naming conventions. No `Ds*` (lowercase) naming was found. Parameter naming (`content:`, `selectedId:`, `onItemTap:`) is consistent across organisms and templates.

### What is NOT in scope

- The compile gate does **not** verify that application screens are complete or functional
- The compile gate does **not** verify visual correctness or accessibility
- The compile gate does **not** require full test coverage — only that `flutter test` passes with zero failures

## Design System

The project follows an atomic design system hierarchy:

- **Tokens**: `DSColors`, `DSTypography`, `DSSpacing`, `DSRadii`, `DSShadows`, `DSMotion`, `DSSemantics`
- **Atoms**: `DSText`, `DSIcon`, `DSBadge`, `DSChip`, `DSStatusDot`, `DSDivider`, `DSGlowBorder`, `DSGlassPanel`
- **Molecules**: `DSSearchBar`, `DSFilterChipGroup`, `DSAssetCard`, `DSMetricTile`, `DSProvenancePill`, `DSTaskCard`, `DSEvidenceRow`, `DSTimelineMarker`
- **Organisms**: `DSShell`, `DSSidebar`, `DSTopbar`, `DSLaneBoard`, `DSTimeline`, `DSDetailInspector`, `DSStoryPanel`, `DSGraphCanvas`
- **Templates**: `MasterDetailTemplate`

All design system classes use the `DS` prefix (uppercase). The main shell uses `content:` parameter (not `body:`). Sidebar uses `selectedId:` and `onItemTap:` (not `selectedIndex:` / `onItemSelected:`).

## Mock Workspace Corpus

The `assets/mock_workspace/` directory contains a markdown-frontmatter corpus used by the app to render workspace data:

- **9 agents** — orchestrator and reviewer roles
- **13 skills** — organized as super-skills with sub-skills, workflows, references, and scripts
- **11 workflows** — orchestration and governance pipelines
- **20+ tasks** — distributed across 5 lanes (planning, open, doing, review, completed)
- **12+ changelog entries** — with frontmatter metadata and evidence sections

See `docs/mock-workspace-corpus-contract.md` for the full corpus specification.

## Documentation

- `docs/mock-workspace-corpus-contract.md` — mock workspace corpus migration contract
- `docs/reports/0010-warp-prism-foundation-audit-analyzer-baseline.md` — foundation audit report
- `docs/tasks/` — real task tracking (not the mock corpus)
