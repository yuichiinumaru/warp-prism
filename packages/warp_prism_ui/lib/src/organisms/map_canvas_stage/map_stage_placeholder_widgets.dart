import 'package:flutter/material.dart';

import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_icon.dart';
import '../../atoms/ds_text.dart';
import '../../tokens/tokens.dart';
import 'map_stage_contracts.dart';

/// Shared minimum interactive target for map-stage controls (WCAG / Material).
const double kMapStageMinTouchTarget = kMinInteractiveDimension;

// =============================================================================
// Status strip
// =============================================================================

/// Compact layer/selection status chrome for the placeholder stage.
class MapStageStatusStrip extends StatelessWidget {
  final List<DSMapStageLayerEntry> layers;
  final DSMapStageFeature? selected;
  final VoidCallback onClearSelection;
  final Key? statusStripKey;
  final Key? clearSelectionKey;

  const MapStageStatusStrip({
    super.key,
    required this.layers,
    required this.selected,
    required this.onClearSelection,
    this.statusStripKey,
    this.clearSelectionKey,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCount = layers.where((l) => l.visible).length;
    final selectionLabel = selected != null
        ? 'Selected: ${selected!.label}'
        : 'No selection';
    return KeyedSubtree(
      key: statusStripKey,
      child: Container(
        constraints: const BoxConstraints(minHeight: kMapStageMinTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
        decoration: const BoxDecoration(
          color: DSColors.obsidianElevated,
          border: Border(
            bottom: BorderSide(color: DSColors.borderSubtle, width: 1),
          ),
        ),
        child: Row(
          children: [
            DSIcon(
              Icons.layers_outlined,
              size: 16,
              color: DSColors.accentCyan.withValues(alpha: 0.8),
            ),
            const SizedBox(width: DSSpacing.xs),
            DSText.labelSmall(
              'Layers $visibleCount/${layers.length}',
              color: DSColors.textSecondary,
            ),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: DSText.labelSmall(
                selectionLabel,
                color: selected != null
                    ? DSColors.accentCyan
                    : DSColors.textTertiary,
              ),
            ),
            if (selected != null)
              Semantics(
                button: true,
                label: 'Clear selection',
                child: InkWell(
                  key: clearSelectionKey,
                  onTap: onClearSelection,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: kMapStageMinTouchTarget,
                      minHeight: kMapStageMinTouchTarget,
                    ),
                    child: const Center(
                      child: DSText.labelSmall(
                        'Clear',
                        color: DSColors.accentViolet,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Feature marker
// =============================================================================

/// Interactive fixture marker with a 48dp hit target and smaller visual glyph.
class MapStageFeatureMarker extends StatelessWidget {
  final DSMapStageFeature feature;
  final Size stageSize;
  final bool selected;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;
  final Key? markerKey;
  final String semanticLabel;

  /// Visual glyph diameter (inside the 48dp hit box).
  static const double visualSizeUnselected = 32.0;
  static const double visualSizeSelected = 40.0;

  /// Hit-test / layout size — always Material minimum interactive dimension.
  static const double hitSize = kMapStageMinTouchTarget;

  const MapStageFeatureMarker({
    super.key,
    required this.feature,
    required this.stageSize,
    required this.selected,
    required this.accent,
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.markerKey,
  });

  @override
  Widget build(BuildContext context) {
    final visualSize = selected ? visualSizeSelected : visualSizeUnselected;
    final left = feature.position.dx * stageSize.width - hitSize / 2;
    final top = feature.position.dy * stageSize.height - hitSize / 2;

    return Positioned(
      left: left.clamp(0.0, stageSize.width - hitSize),
      top: top.clamp(0.0, stageSize.height - hitSize),
      width: hitSize,
      height: hitSize,
      child: Semantics(
        button: true,
        selected: selected,
        label: semanticLabel,
        child: Tooltip(
          message: feature.label,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: markerKey,
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Center(
                child: AnimatedContainer(
                  duration: DSMotion.fast,
                  width: visualSize,
                  height: visualSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? accent.withValues(alpha: 0.35)
                        : DSColors.obsidianElevated.withValues(alpha: 0.9),
                    border: Border.all(
                      color: selected ? accent : accent.withValues(alpha: 0.6),
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.45),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: selected ? 20 : 16, color: accent),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Default popup chrome
// =============================================================================

/// Default glass popup for a selected fixture feature.
class MapStageDefaultPopup extends StatelessWidget {
  final DSMapStageFeature feature;
  final DSMapStageLayerEntry? layer;
  final VoidCallback dismiss;
  final String dismissSemanticLabel;
  final Key? dismissKey;

  const MapStageDefaultPopup({
    super.key,
    required this.feature,
    required this.layer,
    required this.dismiss,
    required this.dismissSemanticLabel,
    this.dismissKey,
  });

  @override
  Widget build(BuildContext context) {
    final kind = feature.properties['kind']?.toString();
    final status =
        feature.properties['status']?.toString() ??
        feature.properties['severity']?.toString();

    return DSGlassPanel.elevated(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: DSText.labelLarge(
                  feature.label,
                  color: DSColors.textPrimary,
                ),
              ),
              Semantics(
                button: true,
                label: dismissSemanticLabel,
                child: InkWell(
                  key: dismissKey,
                  onTap: dismiss,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: kMapStageMinTouchTarget,
                      minHeight: kMapStageMinTouchTarget,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: DSColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (layer != null) ...[
            const SizedBox(height: DSSpacing.xxs),
            DSText.labelSmall(layer!.label, color: DSColors.textSecondary),
          ],
          if (kind != null || status != null) ...[
            const SizedBox(height: DSSpacing.xs),
            DSText.bodySmall(
              [if (kind != null) kind, if (status != null) status].join(' · '),
              color: DSColors.textTertiary,
            ),
          ],
          const SizedBox(height: DSSpacing.xs),
          const DSText.labelSmall(
            'Fixture popup — not MapLibre',
            color: DSColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Background clear target + grid painter
// =============================================================================

/// Full-stage clear-on-tap target with explicit semantics when interactive.
///
/// When [hasSelection] is false, the surface still accepts pointer clears but
/// is **not** exposed as a button so assistive tech is not flooded with a
/// no-op clear action. Status-strip Clear remains the primary labeled control
/// when a selection is active.
class MapStageBackgroundClearTarget extends StatelessWidget {
  final bool enabled;
  final bool hasSelection;
  final VoidCallback onClear;
  final bool showGrid;
  final String semanticLabel;

  const MapStageBackgroundClearTarget({
    super.key,
    required this.enabled,
    required this.onClear,
    required this.showGrid,
    this.hasSelection = true,
    this.semanticLabel = 'Clear map selection',
  });

  @override
  Widget build(BuildContext context) {
    final paint = CustomPaint(
      painter: MapStageGridPainter(showGrid: showGrid),
      child: const SizedBox.expand(),
    );

    if (!enabled) {
      return paint;
    }

    final target = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onClear,
      child: ExcludeSemantics(child: paint),
    );

    // Only advertise the clear action when there is something to clear.
    if (!hasSelection) {
      return target;
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onClear,
      child: target,
    );
  }
}

/// Fixture grid painter — not a tile basemap.
class MapStageGridPainter extends CustomPainter {
  final bool showGrid;

  const MapStageGridPainter({required this.showGrid});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = DSColors.obsidianBase;
    canvas.drawRect(Offset.zero & size, bg);

    // Subtle radial wash for depth (fixture aesthetic only).
    final wash = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.1, -0.2),
        radius: 1.1,
        colors: [
          DSColors.accentCyan.withValues(alpha: 0.05),
          DSColors.obsidianDeep.withValues(alpha: 0.0),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, wash);

    if (!showGrid) return;

    final gridPaint = Paint()
      ..color = DSColors.borderSubtle.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    const step = 40.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Center crosshair (fixture, not CRS).
    final cross = Paint()
      ..color = DSColors.accentCyan.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      cross,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      cross,
    );
  }

  @override
  bool shouldRepaint(covariant MapStageGridPainter oldDelegate) {
    return oldDelegate.showGrid != showGrid;
  }
}
