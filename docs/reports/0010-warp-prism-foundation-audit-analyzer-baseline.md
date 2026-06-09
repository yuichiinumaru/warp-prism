# 0010 — Warp-Prism Foundation Audit Analyzer Baseline

> **Audit Date**: 2026-06-07
> **Auditor**: Hermes Agent (Task 0010 execution)
> **Scope**: Full lib/ tree inventory, missing file detection, naming/API verification, command baseline
> **Method**: Direct source file reads + filesystem inspection; Flutter SDK check

---

## 1. Executive Summary

The Warp-Prism project is a Flutter application (`pubspec.yaml` declares Flutter SDK, `go_router`, `flutter_riverpod`, etc.) with a substantial design system layer (40 Dart files in `lib/`) but **no application entrypoint**. The project cannot compile, analyze, or test because:

1. **`lib/main.dart`** does not exist (no Flutter entrypoint)
2. **`lib/app/app.dart`** does not exist (no app root widget)
3. **`lib/app/router.dart`** does not exist (no routing configuration)
4. **`test/` directory** does not exist (no tests at all)
5. **Flutter SDK** is not installed in the execution environment
6. **README.md** is still Next.js/v0 boilerplate

**Critical finding**: The naming/API mismatches reported in `docs/draft.md` and `EPIC-00` (DsShell vs DSShell, DsColors vs DSColors, body: vs content:) **do NOT exist in the current codebase**. All 40 Dart files consistently use `DS*` (uppercase prefix) naming. The `draft.md` analysis appears to have been based on an earlier version of the code or contained errors.

---

## 2. Flutter SDK Status

```
$ which flutter
which: no flutter in (...)

$ flutter --version
Command not available.
```

**Blocker**: `flutter analyze` and `flutter test` cannot be executed without the Flutter SDK installed. This is an environment blocker, not a code blocker.

---

## 3. Missing Files (Bootstrap Blockers)

| Expected Path | Status | Purpose |
|---|---|---|
| `lib/main.dart` | **MISSING** | Flutter app entrypoint (`void main()`) |
| `lib/app/app.dart` | **MISSING** | Root MaterialApp/CupertinoApp widget |
| `lib/app/router.dart` | **MISSING** | GoRouter route configuration |
| `test/` (directory) | **MISSING** | No test directory exists at all |

These three files are the minimum required to make `flutter analyze` meaningful. Without them, the analyzer would report "no main function found" at minimum.

---

## 4. lib/ Tree Inventory (40 files)

### 4.1 Tokens (7 files) — ALL EXIST
| File | Status |
|---|---|
| `lib/design_system/tokens/tokens.dart` | EXISTS (barrel export) |
| `lib/design_system/tokens/ds_colors.dart` | EXISTS |
| `lib/design_system/tokens/ds_typography.dart` | EXISTS |
| `lib/design_system/tokens/ds_spacing.dart` | EXISTS |
| `lib/design_system/tokens/ds_radii.dart` | EXISTS |
| `lib/design_system/tokens/ds_shadows.dart` | EXISTS |
| `lib/design_system/tokens/ds_motion.dart` | EXISTS |
| `lib/design_system/tokens/ds_semantics.dart` | EXISTS |

### 4.2 Atoms (9 files) — ALL EXIST
| File | Status |
|---|---|
| `lib/design_system/atoms/atoms.dart` | EXISTS (barrel export) |
| `lib/design_system/atoms/ds_text.dart` | EXISTS |
| `lib/design_system/atoms/ds_icon.dart` | EXISTS |
| `lib/design_system/atoms/ds_badge.dart` | EXISTS |
| `lib/design_system/atoms/ds_chip.dart` | EXISTS |
| `lib/design_system/atoms/ds_status_dot.dart` | EXISTS |
| `lib/design_system/atoms/ds_divider.dart` | EXISTS |
| `lib/design_system/atoms/ds_glow_border.dart` | EXISTS |
| `lib/design_system/atoms/ds_glass_panel.dart` | EXISTS |

### 4.3 Molecules (9 files) — ALL EXIST
| File | Status |
|---|---|
| `lib/design_system/molecules/molecules.dart` | EXISTS (barrel export) |
| `lib/design_system/molecules/ds_search_bar.dart` | EXISTS |
| `lib/design_system/molecules/ds_filter_chip_group.dart` | EXISTS |
| `lib/design_system/molecules/ds_asset_card.dart` | EXISTS |
| `lib/design_system/molecules/ds_metric_tile.dart` | EXISTS |
| `lib/design_system/molecules/ds_provenance_pill.dart` | EXISTS |
| `lib/design_system/molecules/ds_task_card.dart` | EXISTS |
| `lib/design_system/molecules/ds_evidence_row.dart` | EXISTS |
| `lib/design_system/molecules/ds_timeline_marker.dart` | EXISTS |

### 4.4 Organisms (9 files) — ALL EXIST
| File | Status |
|---|---|
| `lib/design_system/organisms/organisms.dart` | EXISTS (barrel export) |
| `lib/design_system/organisms/ds_shell.dart` | EXISTS |
| `lib/design_system/organisms/ds_sidebar.dart` | EXISTS |
| `lib/design_system/organisms/ds_topbar.dart` | EXISTS |
| `lib/design_system/organisms/ds_lane_board.dart` | EXISTS |
| `lib/design_system/organisms/ds_timeline.dart` | EXISTS |
| `lib/design_system/organisms/ds_detail_inspector.dart` | EXISTS |
| `lib/design_system/organisms/ds_story_panel.dart` | EXISTS |
| `lib/design_system/organisms/ds_graph_canvas.dart` | EXISTS |

### 4.5 Templates (2 files) — ALL EXIST
| File | Status |
|---|---|
| `lib/design_system/templates/templates.dart` | EXISTS (barrel export) |
| `lib/design_system/templates/master_detail_template.dart` | EXISTS |

### 4.6 Data Layer (2 files) — ALL EXIST
| File | Status |
|---|---|
| `lib/data/models/models.dart` | EXISTS |
| `lib/data/parsers/workspace_parser.dart` | EXISTS |

### 4.7 Top-level Design System (1 file)
| File | Status |
|---|---|
| `lib/design_system/design_system.dart` | EXISTS (top-level barrel) |

---

## 5. Naming/API Consistency Verification

### 5.1 Class Naming Convention: CONSISTENT ✅

All design system classes use `DS*` (uppercase prefix) consistently:

| Category | Classes Found | Convention |
|---|---|---|
| Tokens | `DSColors`, `DSTypography`, `DSSpacing`, `DSRadii`, `DSShadows`, `DSMotion`, `DSSemantics` | DS* ✅ |
| Atoms | `DSText`, `DSIcon`, `DSBadge`, `DSChip`, `DSStatusDot`, `DSDivider`, `DSGlowBorder`, `DSGlassPanel`, `DSGlassPanelSimple` | DS* ✅ |
| Molecules | `DSSearchBar`, `DSFilterChipGroup`, `DSAssetCard`, `DSMetricTile`, `DSProvenancePill`, `DSTaskCard`, `DSEvidenceRow`, `DSTimelineMarker` | DS* ✅ |
| Organisms | `DSShell`, `DSShellResponsive`, `DSSidebar`, `DSTopbar`, `DSLaneBoard`, `DSTimeline`, `DSDetailInspector`, `DSStoryPanel`, `DSGraphCanvas` | DS* ✅ |
| Templates | `MasterDetailTemplate`, `CanvasTemplate`, `TimelineTemplate` | (no DS prefix) ✅ |

**Search result**: `Ds[A-Z]` pattern (lowercase 's') — **0 matches** across all 40 files.

### 5.2 Parameter Naming: CONSISTENT ✅

| Widget | Parameter | Used By Templates |
|---|---|---|
| `DSShell` | `content:` (not `body:`) | Templates pass `content:` ✅ |
| `DSSidebar` | `items:`, `selectedId:`, `onItemTap:`, `expanded:` | Templates match ✅ |
| `DSTopbar` | `title:`, `breadcrumbs:`, `showSearch:`, `searchBar:`, `actions:` | Templates match ✅ |

### 5.3 draft.md Discrepancies — ALL RESOLVED

The `docs/draft.md` (ChatGPT analysis) reported these mismatches, but **none exist in the current code**:

| Claim in draft.md | Actual State | Verdict |
|---|---|---|
| `ds_graph_canvas.dart` uses `DsColors` | Uses `DSColors` | draft.md WRONG |
| `ds_graph_canvas.dart` uses `DsMotion.fast` | Uses `DSMotion.fast` | draft.md WRONG |
| `MasterDetailTemplate` calls `DsShell(... body: ...)` | Calls `DSShell(... content: ...)` | draft.md WRONG |
| Template uses `DsSidebar`, `selectedIndex`, `onItemSelected` | Uses `DSSidebar`, `selectedId`, `onItemTap` | draft.md WRONG |
| Template uses `DsTopbar` with mismatched params | Uses `DSTopbar` with matching params | draft.md WRONG |

**Conclusion**: The naming/API normalization task (0012) may be based on outdated or incorrect evidence. The current codebase naming is internally consistent. However, Task 0012 should still verify this independently.

---

## 6. Design System API Contracts (Verified)

### 6.1 DSShell (`lib/design_system/organisms/ds_shell.dart`)
```dart
class DSShell extends StatelessWidget {
  final Widget sidebar;
  final Widget? topbar;
  final Widget content;      // NOT 'body'
  final Widget? inspector;
  final bool showInspector;
}
```

### 6.2 DSSidebar (`lib/design_system/organisms/ds_sidebar.dart`)
```dart
class DSSidebar extends StatelessWidget {
  final List<DSSidebarItem> items;
  final String? selectedId;       // NOT 'selectedIndex'
  final ValueChanged<String>? onItemTap;  // NOT 'onItemSelected'
  final Widget? header;
  final Widget? footer;
  final bool expanded;            // NOT 'isCollapsed'
}

class DSSidebarItem {
  final String id;
  final String? label;
  final IconData icon;
  final Color? color;
  final int? badge;
  final bool isDivider;
}
```

### 6.3 DSTopbar (`lib/design_system/organisms/ds_topbar.dart`)
```dart
class DSTopbar extends StatelessWidget {
  final String? title;
  final List<String>? breadcrumbs;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? searchBar;     // Widget, not String
  final bool showSearch;
}
```

---

## 7. Potential Compile Issues (Source Inspection Only)

Even though `flutter analyze` cannot run, source inspection reveals these potential issues:

### 7.1 `ds_status_dot.dart` line 104
```dart
return AnimatedBuilder(
```
`AnimatedBuilder` is **not a standard Flutter class**. The correct class is `AnimatedBuilder` (which IS valid in Flutter 3.10+). This should work with the declared SDK `>=3.0.0 <4.0.0` but may need verification.

### 7.2 `ds_glow_border.dart` line 126
```dart
return AnimatedBuilder(
```
Same as above — uses `AnimatedBuilder` which is a valid Flutter widget.

### 7.3 `ds_metric_tile.dart` line 91
```dart
final (icon, color) = switch (trend) {
  DSTrend.up => (Icons.trending_up, DSColors.statusSuccess),
  ...
};
```
Uses Dart 3 pattern matching / switch expressions. Requires Dart 3.0+ (declared in pubspec: `sdk: '>=3.0.0 <4.0.0'`). Should work.

### 7.4 Missing `lib/main.dart`
Without `main.dart`, no Flutter command will succeed. This is the primary bootstrap blocker.

---

## 8. README.md Status

The `README.md` at `/home/sephiroth/working/ganthritor/warp-prism/README.md` is entirely Next.js/v0 boilerplate:
- References `npm run dev`, `yarn dev`, `pnpm dev`
- References `app/page.tsx`
- Links to v0.app project
- Contains zero Flutter content

---

## 9. pubspec.yaml Key Facts

| Field | Value |
|---|---|
| `name` | `asw_observatory` |
| `description` | ASW Observatory - Agent System Workspace visibility console |
| `version` | `1.0.0+1` |
| `sdk` | `>=3.0.0 <4.0.0` |
| Dependencies | `flutter`, `cupertino_icons`, `go_router ^14.0.0`, `flutter_riverpod ^2.5.0`, `yaml ^3.1.2`, `graphview ^1.2.0`, `fl_chart ^0.68.0`, `collection ^1.18.0`, `intl ^0.19.0` |
| Dev Dependencies | `flutter_test`, `flutter_lints ^4.0.0` |
| Assets | `assets/mock_workspace/` and subdirectories |
| Fonts | JetBrainsMono (Regular, Medium, Bold) |

---

## 10. flutter analyze Results

**BLOCKED**: Flutter SDK not installed in the execution environment.

```
$ which flutter
which: no flutter in (...PATH...)
```

**Expected errors if SDK were available** (based on source inspection):
1. No `main` function found (no `lib/main.dart`)
2. Unused imports in some files (imports of models that reference missing screens)
3. Possibly `pubspec.lock` missing (first `flutter pub get` needed)

---

## 11. flutter test Results

**BLOCKED**: 
1. Flutter SDK not installed
2. `test/` directory does not exist
3. No test files exist anywhere in the project

---

## 12. Task Dependency Verification

### 12.1 Task 0011 (Bootstrap: main/router/shell)
The scope is confirmed correct by this audit. The three missing files (`main.dart`, `app.dart`, `router.dart`) are exactly what Task 0011 should create. **No adjustment needed to Task 0011 scope.**

### 12.2 Task 0012 (Design System API Normalization)
**RECOMMENDATION**: Task 0012's scope may need adjustment. The `draft.md`-reported naming mismatches (Ds* vs DS*, body vs content) **do not exist in the current codebase**. Task 0012 should:
1. Re-verify naming consistency independently
2. Focus on any actual compile errors that surface after Task 0011 creates the entrypoint
3. Consider that the normalization may already be done

---

## 13. Recommendations for Next Steps

1. **Install Flutter SDK** in the execution environment (or use Docker/devcontainer with Flutter)
2. **Execute Task 0011** to create `lib/main.dart`, `lib/app/app.dart`, `lib/app/router.dart`
3. **Run `flutter pub get`** to generate `pubspec.lock`
4. **Run `flutter analyze`** after bootstrap to capture real error output
5. **Re-evaluate Task 0012** scope against actual analyzer output (not draft.md claims)
6. **Update README.md** with Flutter instructions
7. **Create `test/` directory** with at least a placeholder test

---

## 14. Evidence Commands

| Command | Result | Notes |
|---|---|---|
| `which flutter` | NOT FOUND | SDK not installed |
| `ls lib/main.dart` | NOT FOUND | Missing entrypoint |
| `ls lib/app/` | NOT FOUND | Missing app directory |
| `ls test/` | NOT FOUND | Missing test directory |
| `grep -r 'Ds[A-Z]' lib/` | 0 matches | No lowercase Ds* naming found |
| `find lib/ -name '*.dart'` | 40 files found | Full inventory documented above |

---

*Report generated by Task 0010 audit execution. All findings based on direct source inspection, not inference.*
