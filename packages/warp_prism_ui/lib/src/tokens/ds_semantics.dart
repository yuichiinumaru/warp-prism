import 'package:flutter/material.dart';
import 'ds_colors.dart';
import 'ds_typography.dart';

/// ASW Observatory Design Tokens - Semantic Styles
///
/// Pre-composed semantic styles combining colors, typography, and meaning
abstract class DSSemantics {
  // === STATUS TEXT STYLES ===
  static TextStyle statusSuccess = DSTypography.labelMedium.copyWith(
    color: DSColors.statusSuccess,
  );

  static TextStyle statusWarning = DSTypography.labelMedium.copyWith(
    color: DSColors.statusWarning,
  );

  static TextStyle statusError = DSTypography.labelMedium.copyWith(
    color: DSColors.statusError,
  );

  static TextStyle statusInfo = DSTypography.labelMedium.copyWith(
    color: DSColors.statusInfo,
  );

  // === GOVERNANCE TEXT STYLES ===
  static TextStyle governanceCanonical = DSTypography.labelSmall.copyWith(
    color: DSColors.governanceCanonical,
    fontWeight: FontWeight.w600,
  );

  static TextStyle governanceLocal = DSTypography.labelSmall.copyWith(
    color: DSColors.governanceLocal,
    fontWeight: FontWeight.w600,
  );

  static TextStyle governanceGenerated = DSTypography.labelSmall.copyWith(
    color: DSColors.governanceGenerated,
    fontWeight: FontWeight.w600,
  );

  static TextStyle governanceAppendOnly = DSTypography.labelSmall.copyWith(
    color: DSColors.governanceAppendOnly,
    fontWeight: FontWeight.w600,
  );

  // === ASSET KIND TEXT STYLES ===
  static TextStyle assetAgent = DSTypography.labelMedium.copyWith(
    color: DSColors.assetAgent,
    fontWeight: FontWeight.w500,
  );

  static TextStyle assetSkill = DSTypography.labelMedium.copyWith(
    color: DSColors.assetSkill,
    fontWeight: FontWeight.w500,
  );

  static TextStyle assetWorkflow = DSTypography.labelMedium.copyWith(
    color: DSColors.assetWorkflow,
    fontWeight: FontWeight.w500,
  );

  static TextStyle assetTask = DSTypography.labelMedium.copyWith(
    color: DSColors.assetTask,
    fontWeight: FontWeight.w500,
  );

  static TextStyle assetChangelog = DSTypography.labelMedium.copyWith(
    color: DSColors.assetChangelog,
    fontWeight: FontWeight.w500,
  );

  // === LANE TEXT STYLES ===
  static TextStyle lanePlanning = DSTypography.labelMedium.copyWith(
    color: DSColors.lanePlanning,
    fontWeight: FontWeight.w500,
  );

  static TextStyle laneOpen = DSTypography.labelMedium.copyWith(
    color: DSColors.laneOpen,
    fontWeight: FontWeight.w500,
  );

  static TextStyle laneDoing = DSTypography.labelMedium.copyWith(
    color: DSColors.laneDoing,
    fontWeight: FontWeight.w500,
  );

  static TextStyle laneReview = DSTypography.labelMedium.copyWith(
    color: DSColors.laneReview,
    fontWeight: FontWeight.w500,
  );

  static TextStyle laneCompleted = DSTypography.labelMedium.copyWith(
    color: DSColors.laneCompleted,
    fontWeight: FontWeight.w500,
  );

  // === PROOF STATE STYLES ===
  static TextStyle proofComplete = DSTypography.labelSmall.copyWith(
    color: DSColors.statusSuccess,
  );

  static TextStyle proofPartial = DSTypography.labelSmall.copyWith(
    color: DSColors.statusWarning,
  );

  static TextStyle proofMissing = DSTypography.labelSmall.copyWith(
    color: DSColors.statusError,
  );

  static TextStyle proofPending = DSTypography.labelSmall.copyWith(
    color: DSColors.textTertiary,
  );

  /// Get style for asset kind
  static TextStyle forAssetKind(String kind) {
    switch (kind.toLowerCase()) {
      case 'agent':
        return assetAgent;
      case 'skill':
        return assetSkill;
      case 'subskill':
        return assetSkill;
      case 'workflow':
        return assetWorkflow;
      case 'task':
        return assetTask;
      case 'changelog':
        return assetChangelog;
      default:
        return DSTypography.labelMedium.copyWith(color: DSColors.textSecondary);
    }
  }

  /// Get style for lane
  static TextStyle forLane(String lane) {
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
        return DSTypography.labelMedium.copyWith(color: DSColors.textSecondary);
    }
  }

  /// Get style for proof state
  static TextStyle forProofState(String? state) {
    switch (state?.toLowerCase()) {
      case 'complete':
        return proofComplete;
      case 'partial':
        return proofPartial;
      case 'missing':
        return proofMissing;
      default:
        return proofPending;
    }
  }
}
