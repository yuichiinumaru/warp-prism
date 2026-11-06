import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'ds_asset_card.dart';
import 'ds_draggable_card.dart';
import 'ds_drop_target.dart';
import 'ds_state_surface.dart';

// =============================================================================
// DROP-ZONE CARD (Task 1883, F-16 — the single authorized extension)
// =============================================================================
//
// RELOCATION RATIONALE (fixer turn, Task 1883): these two classes were first
// composed at the bottom of `ds_drop_target.dart`, which IS exported by the
// molecules barrel. The generic alias-completeness gate
// (`All public DS declarations have Prism aliases`) therefore demanded
// `Prism*` aliases for them — but the seam is EXPERIMENTAL and must stay out
// of all barrels and aliases until a promotion task wires the public surface
// (Task 1868 `DSActionGate` precedent). Relocating both classes unchanged into
// this dedicated, non-barrel file keeps the single authorized extension with
// the same seam while restoring gate coherence. Do NOT export this file from
// any barrel and do NOT add a `Prism*` alias until promotion.
//
// Convergence composition for the Tempest DropZoneCard donor: [DSDropTarget]
// lane behavior plus [DSAssetCard] metadata chrome. The header card carries
// the labelled field only (label, kind, description, tags); drop mechanics,
// insertion tracking, and payloads are unchanged [DSDropTarget] behavior.
// Requires a bounded height from the parent when not empty (the lane child
// expands into remaining space).

/// Metadata chrome for [DSDropZoneCard] (labelled field only, no domain data).
@immutable
class DSDropZoneMetadata {
  /// Zone display label (rendered as the header card name).
  final String label;

  /// Zone kind label (drives [DSAssetCard] chrome).
  final String kind;

  /// Optional one-line description.
  final String? description;

  /// Optional tag chips.
  final List<String>? tags;

  /// Empty-state guidance shown beneath the header when [DSDropZoneCard.isEmpty].
  final String? emptyHint;

  const DSDropZoneMetadata({
    required this.label,
    required this.kind,
    this.description,
    this.tags,
    this.emptyHint,
  });
}

/// Drop-zone card: [DSDropTarget] with [DSAssetCard] metadata header.
///
/// When [isEmpty], the lane child is replaced by a compact
/// [DSStateSurface.empty] (still inside the drop target so drops land).
/// Otherwise the header renders above the expanded lane child.
class DSDropZoneCard extends StatelessWidget {
  /// Metadata chrome for the header card.
  final DSDropZoneMetadata metadata;

  /// Lane id this drop zone represents.
  final String laneId;

  /// Number of tasks currently in this lane (for index calculation).
  final int taskCount;

  /// The lane child (typically the lane's task list).
  final Widget child;

  /// Estimated height of each task card including padding.
  final double itemHeight;

  /// Whether this lane is currently empty (shows empty state).
  final bool isEmpty;

  /// Callback when a draggable is dropped on this zone.
  final void Function(DSDragPayload payload, int targetIndex)?
  onAcceptWithIndex;

  /// Optional observer for insertion-index changes during hover.
  final ValueChanged<int>? onInsertionIndexChanged;

  const DSDropZoneCard({
    super.key,
    required this.metadata,
    required this.laneId,
    required this.taskCount,
    required this.child,
    this.itemHeight = 100.0,
    this.isEmpty = false,
    this.onAcceptWithIndex,
    this.onInsertionIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Drop zone: ${metadata.label}',
      explicitChildNodes: true,
      child: DSDropTarget(
        laneId: laneId,
        taskCount: taskCount,
        itemHeight: itemHeight,
        isEmpty: isEmpty,
        onAcceptWithIndex: onAcceptWithIndex,
        onInsertionIndexChanged: onInsertionIndexChanged,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DSAssetCard(
              name: metadata.label,
              kind: metadata.kind,
              description: metadata.description,
              tags: metadata.tags,
            ),
            const SizedBox(height: DSSpacing.sm),
            if (isEmpty)
              DSStateSurface.empty(
                title: 'Drop cards here',
                subtitle: metadata.emptyHint,
                compact: true,
              )
            else
              Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
