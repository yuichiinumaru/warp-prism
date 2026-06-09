/// Prism* Public API Aliases — type aliases for promoted operational components.
///
/// Per `docs/design/token-theme-catalog-policy.md` §2.4, all public widgets
/// exported by `warp_prism_ui` for consumer apps use the `Prism` prefix.
/// These aliases delegate to the DS* implementation classes.
///
/// Consumer apps import:
/// ```dart
/// import 'package:warp_prism_ui/warp_prism_ui.dart';
/// // Use: PrismStatusDot, PrismMetricTile, PrismTaskCard, etc.
/// ```
///
/// What they NEVER see: DSStatusDot, DSMetricTile, DSTaskCard, etc.
library;

import 'atoms/ds_status_dot.dart';
import 'molecules/ds_metric_tile.dart';
import 'molecules/ds_state_surface.dart';
import 'molecules/ds_task_card.dart';
import 'molecules/ds_asset_card.dart';
import 'molecules/ds_search_bar.dart';
import 'molecules/ds_filter_chip_group.dart';
import 'molecules/ds_evidence_row.dart';
import 'molecules/ds_provenance_pill.dart';
import 'molecules/ds_timeline_marker.dart';
import 'organisms/ds_lane_board.dart';
import 'tokens/ds_operational_state.dart';

// =============================================================================
// TOKENS — Operational State
// =============================================================================

/// Public alias for [DSOperationalState].
///
/// The canonical 15-state vocabulary covering lifecycle, health,
/// verification, and governance semantics.
typedef PrismOperationalState = DSOperationalState;

/// Public alias for [DSOperationalSeverity].
typedef PrismOperationalSeverity = DSOperationalSeverity;

/// Public alias for [DSOperationalCategory].
typedef PrismOperationalCategory = DSOperationalCategory;

/// Note: [DSOperationalStateUI] is an extension on [DSOperationalState].
/// Consumer apps access it via `PrismOperationalState.running.color` etc.

// =============================================================================
// ATOMS
// =============================================================================

/// Public alias for [DSStatusDot].
///
/// Supports all 15 operational states via named constructors.
typedef PrismStatusDot = DSStatusDot;

// =============================================================================
// MOLECULES
// =============================================================================

/// Public alias for [DSMetricTile].
///
/// Supports health states via [DSMetricTileHealth].
typedef PrismMetricTile = DSMetricTile;

/// Public alias for [DSMetricTileCompact].
typedef PrismMetricTileCompact = DSMetricTileCompact;

/// Public alias for [DSMetricTileHealth].
typedef PrismMetricTileHealth = DSMetricTileHealth;

/// Public alias for [DSTrend].
typedef PrismTrend = DSTrend;

/// Public alias for [DSStateSurface].
///
/// Supports data-loading states (empty, loading, error) and operational
/// states (disabled, stale, degraded, excluded).
typedef PrismStateSurface = DSStateSurface;

/// Public alias for [DSStateType].
typedef PrismStateType = DSStateType;

/// Public alias for [DSTaskCard].
typedef PrismTaskCard = DSTaskCard;

/// Public alias for [DSAssetCard].
typedef PrismAssetCard = DSAssetCard;

/// Public alias for [DSSearchBar].
typedef PrismSearchBar = DSSearchBar;

/// Public alias for [DSFilterChipGroup].
typedef PrismFilterChipGroup = DSFilterChipGroup;

/// Public alias for [DSFilterOption].
typedef PrismFilterOption = DSFilterOption;

/// Public alias for [DSEvidenceRow].
typedef PrismEvidenceRow = DSEvidenceRow;

/// Public alias for [DSEvidenceIndicator].
typedef PrismEvidenceIndicator = DSEvidenceIndicator;

/// Public alias for [DSEvidenceState].
typedef PrismEvidenceState = DSEvidenceState;

/// Public alias for [DSProvenancePill].
typedef PrismProvenancePill = DSProvenancePill;

/// Public alias for [DSProvenanceSize].
typedef PrismProvenanceSize = DSProvenanceSize;

/// Public alias for [DSTimelineMarker].
typedef PrismTimelineMarker = DSTimelineMarker;

// =============================================================================
// ORGANISMS
// =============================================================================

/// Public alias for [DSLaneBoard].
typedef PrismLaneBoard = DSLaneBoard;

/// Public alias for [DSLane].
typedef PrismLane = DSLane;

/// Public alias for [DSLaneTask].
typedef PrismLaneTask = DSLaneTask;
