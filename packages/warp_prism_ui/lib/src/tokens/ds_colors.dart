import 'package:flutter/material.dart';
import 'prism_token_registry.dart';

/// ASW Observatory Design Tokens - Colors
///
/// Visual direction: Black Obsidian theme with controlled blue action accents
/// - Pure black obsidian structural backgrounds (#030506 family)
/// - Low-luminance dark panels and borders
/// - Additive blue accent ladder for action/focus/links (#2F81FF family)
/// - Cyan/violet/gold retained data category accents
abstract class DSColors {
  // === OBSIDIAN BACKGROUNDS ===
  /// The deepest background - true obsidian black
  static Color get obsidianDeep => PrismTokenRegistry.instance.obsidianDeep;

  /// Primary background surface
  static Color get obsidianBase => PrismTokenRegistry.instance.obsidianBase;

  /// Elevated surface (cards, panels)
  static Color get obsidianElevated =>
      PrismTokenRegistry.instance.obsidianElevated;

  /// Hover/interactive surface
  static Color get obsidianHover => PrismTokenRegistry.instance.obsidianHover;

  /// Active/selected surface
  static const Color obsidianActive = Color(0xFF1A1A24);

  /// Glass panel overlay (use with opacity)
  static const Color glassOverlay = Color(0xFF1E1E28);

  // === PRIMARY ACTION ACCENTS ===
  /// Primary action accent - blue energy (Black Obsidian contract)
  static Color get accentBlue => PrismTokenRegistry.instance.accentBlue;
  static Color get accentBlueMuted =>
      PrismTokenRegistry.instance.accentBlueMuted;
  static Color get accentBlueDim => PrismTokenRegistry.instance.accentBlueDim;

  /// High-contrast focus ring outline (2px outline at 50% opacity)
  static Color get focusRing => PrismTokenRegistry.instance.focusRing;

  // === DATA ACCENTS ===
  /// Data accent - cyan energy (retained data-category accent until Task 1806)
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color accentCyanMuted = Color(0xFF0099B8);
  static const Color accentCyanDim = Color(0xFF006680);

  /// Secondary accent - violet energy (protoss influence)
  static const Color accentViolet = Color(0xFF8B5CF6);
  static const Color accentVioletMuted = Color(0xFF6B4CD4);
  static const Color accentVioletDim = Color(0xFF4C3899);

  /// Tertiary accent - gold energy (protoss influence)
  static const Color accentGold = Color(0xFFFFB800);
  static const Color accentGoldMuted = Color(0xFFCC9400);
  static const Color accentGoldDim = Color(0xFF997000);

  // === SEMANTIC STATUS COLORS ===
  /// Success - task complete, proof verified
  static const Color statusSuccess = Color(0xFF10B981);
  static const Color statusSuccessMuted = Color(0xFF059669);
  static const Color statusSuccessDim = Color(0xFF047857);

  /// Warning - needs attention, partial proof
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusWarningMuted = Color(0xFFD97706);
  static const Color statusWarningDim = Color(0xFFB45309);

  /// Error - blocked, failed, conflict
  static const Color statusError = Color(0xFFEF4444);
  static const Color statusErrorMuted = Color(0xFFDC2626);
  static const Color statusErrorDim = Color(0xFFB91C1C);

  /// Info - informational, neutral status
  static const Color statusInfo = Color(0xFF3B82F6);
  static const Color statusInfoMuted = Color(0xFF2563EB);
  static const Color statusInfoDim = Color(0xFF1D4ED8);

  // === GOVERNANCE COLORS ===
  /// Parent canonical - authoritative source
  static const Color governanceCanonical = Color(0xFF10B981);

  /// Child local - local overlay
  static const Color governanceLocal = Color(0xFF3B82F6);

  /// Generated - computed/built
  static const Color governanceGenerated = Color(0xFF8B5CF6);

  /// Append-only - immutable ledger
  static const Color governanceAppendOnly = Color(0xFFFFB800);

  /// Archive - historical
  static const Color governanceArchive = Color(0xFF6B7280);

  /// Mock - test data
  static const Color governanceMock = Color(0xFFEC4899);

  // === TEXT COLORS ===
  /// Primary text - high emphasis
  static const Color textPrimary = Color(0xFFF0F0F5);

  /// Secondary text - medium emphasis
  static const Color textSecondary = Color(0xFFA0A0B0);

  /// Tertiary text - low emphasis
  /// WCAG AA: ~6.0:1 on obsidianDeep (#050508) - passes 4.5:1 threshold
  static const Color textTertiary = Color(0xFF8888A0);

  /// Disabled text
  /// Note: disabled text exempt from WCAG contrast per WCAG 1.4.3
  static const Color textDisabled = Color(0xFF505060);

  /// Inverse text (for light backgrounds)
  static const Color textInverse = Color(0xFF0A0A0F);

  // === BORDER COLORS ===
  /// Subtle border - barely visible
  static const Color borderSubtle = Color(0xFF1E1E28);

  /// Default border - low-luminance neutral/blue-gray (Black Obsidian contract)
  static Color get borderDefault => PrismTokenRegistry.instance.borderDefault;

  /// Strong border - emphasis
  static const Color borderStrong = Color(0xFF3A3A4A);

  /// Luminous border - energy glow
  static const Color borderGlow = Color(0xFF00D4FF);

  // === LANE COLORS (for task lanes) ===
  static const Color lanePlanning = Color(0xFF8B5CF6); // Violet
  static const Color laneOpen = Color(0xFF3B82F6); // Blue
  static const Color laneDoing = Color(0xFFFFB800); // Gold
  static const Color laneReview = Color(0xFFEC4899); // Pink
  static const Color laneCompleted = Color(0xFF10B981); // Green

  // === ASSET KIND COLORS ===
  static const Color assetAgent = Color(0xFF00D4FF); // Cyan
  static const Color assetSkill = Color(0xFF8B5CF6); // Violet
  static const Color assetSubskill = Color(0xFFA78BFA); // Light violet
  static const Color assetWorkflow = Color(0xFFFFB800); // Gold
  static const Color assetTask = Color(0xFF3B82F6); // Blue
  static const Color assetChangelog = Color(0xFF10B981); // Green
  static const Color assetScript = Color(0xFFEC4899); // Pink
  static const Color assetReference = Color(0xFF6B7280); // Gray
  static const Color assetRule = Color(0xFFF97316); // Orange

  // === OPERATIONAL STATE COLORS ===
  /// Semantic aliases mapping each [DSOperationalState] to its canonical color.
  ///
  /// No new hex values — all tokens reuse the existing palette.
  /// See `docs/design/operational-state-vocabulary.md` §6.

  /// Pending/unverified — muted neutral
  static const Color statusPending = textTertiary; // #8888A0

  /// Running — active gold
  static const Color statusRunning = accentGold; // #FFB800

  /// Approved/healthy — success green
  static const Color statusApproved = statusSuccess; // #10B981

  /// Rejected/operational error — error red
  static const Color statusRejected = statusError; // #EF4444

  /// Promoted — energy cyan
  static const Color statusPromoted = accentCyan; // #00D4FF

  /// Archived/operational disabled/excluded — disabled gray
  static const Color statusArchived = textDisabled; // #505060

  /// Healthy — success green (alias of statusApproved)
  static const Color statusHealthy = statusSuccess; // #10B981

  /// Degraded/stale — warning amber
  static const Color statusDegraded = statusWarning; // #F59E0B

  /// Operational error — error red (alias of statusRejected)
  static const Color statusOpError = statusError; // #EF4444

  /// Disabled — disabled gray (alias of statusArchived)
  static const Color statusDisabled = textDisabled; // #505060

  /// Unverified — muted neutral (alias of statusPending)
  static const Color statusUnverified = textTertiary; // #8888A0

  /// Unknown/indeterminate — muted neutral (alias of statusPending).
  ///
  /// Task 1869 (EXPERIMENTAL): fail-closed rendering for withheld
  /// determination. No new hex — deliberately not success, warning,
  /// error, or action-blue. Non-animated by contract.
  static const Color statusUnknown = textTertiary; // #8888A0

  /// Exposed — error red
  static const Color statusExposed = statusError; // #EF4444

  /// Redacted — violet accent
  static const Color statusRedacted = accentViolet; // #8B5CF6

  /// Stale — warning amber (alias of statusDegraded)
  static const Color statusStale = statusWarning; // #F59E0B

  /// Excluded — disabled gray (alias of statusArchived)
  static const Color statusExcluded = textDisabled; // #505060

  // === UTILITY ===
  static const Color transparent = Colors.transparent;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  /// Get color for asset kind
  static Color forAssetKind(String kind) {
    switch (kind.toLowerCase()) {
      case 'agent':
        return assetAgent;
      case 'skill':
        return assetSkill;
      case 'subskill':
        return assetSubskill;
      case 'workflow':
        return assetWorkflow;
      case 'task':
        return assetTask;
      case 'changelog':
        return assetChangelog;
      case 'script':
        return assetScript;
      case 'reference':
        return assetReference;
      case 'rule':
        return assetRule;
      default:
        return textSecondary;
    }
  }

  /// Get color for task lane
  static Color forLane(String lane) {
    switch (lane.toLowerCase()) {
      case '00-planning':
        return lanePlanning;
      case '01-open':
        return laneOpen;
      case '02-doing':
        return laneDoing;
      case '03-review':
        return laneReview;
      case '04-completed':
        return laneCompleted;
      default:
        return textSecondary;
    }
  }

  /// Get color for governance status
  static Color forCanonicity(String canonicity) {
    switch (canonicity.toLowerCase()) {
      case 'parentcanonical':
        return governanceCanonical;
      case 'childlocal':
        return governanceLocal;
      case 'generated':
        return governanceGenerated;
      case 'appendonly':
        return governanceAppendOnly;
      case 'archive':
        return governanceArchive;
      case 'mock':
        return governanceMock;
      default:
        return textSecondary;
    }
  }
}
