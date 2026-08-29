import 'package:flutter/material.dart';
import '../../atoms/atoms.dart';
import '../../molecules/molecules.dart';
import '../../tokens/tokens.dart';

/// Represents a single view preset (camera and layer configuration).
@immutable
class DSViewPreset {
  /// Unique identifier for the preset.
  final String id;

  /// Display name of the preset.
  final String name;

  /// Optional description describing the viewpoint or theme.
  final String? description;

  /// Custom payload containing map coordinates, zoom level, layer visibilities, etc.
  final Map<String, dynamic> payload;

  const DSViewPreset({
    required this.id,
    required this.name,
    this.description,
    this.payload = const {},
  });
}

/// A widget that displays a grid of camera/layer preset tiles.
/// Selecting a preset tile triggers [onSelected].
class DSViewPresets extends StatelessWidget {
  /// The list of presets to display.
  final List<DSViewPreset> presets;

  /// Callback when a preset is selected.
  final ValueChanged<DSViewPreset>? onSelected;

  /// Optional grid cross axis count override. Defaults to responsive grid.
  final int? crossAxisCount;

  /// The currently active/selected preset ID, if any, for highlighting.
  final String? activePresetId;

  /// Semantic label for screen readers.
  final String? semanticLabel;

  /// Optional title displayed at the top. Defaults to "View Presets".
  final String? title;

  const DSViewPresets({
    super.key,
    required this.presets,
    this.onSelected,
    this.crossAxisCount,
    this.activePresetId,
    this.semanticLabel,
    this.title = 'View Presets',
  });

  @override
  Widget build(BuildContext context) {
    if (presets.isEmpty) {
      return Semantics(
        label: semanticLabel ?? 'View Presets (Empty)',
        child: const DSStateSurface.empty(
          icon: Icons.grid_view_outlined,
          title: 'No Presets Available',
          subtitle: 'Create a preset to save your current view state.',
        ),
      );
    }

    // Grid layout with responsive column counting if not overridden
    final screenWidth = MediaQuery.of(context).size.width;
    final int cols = crossAxisCount ?? _calculateColumns(screenWidth);

    return Semantics(
      label: semanticLabel ?? title,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null && title!.isNotEmpty) ...[
            DSText.labelLarge(title!, color: DSColors.textSecondary),
            const SizedBox(height: DSSpacing.sm),
          ],
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: presets.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: DSSpacing.md,
              crossAxisSpacing: DSSpacing.md,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final preset = presets[index];
              final isActive = preset.id == activePresetId;

              return _PresetTile(
                preset: preset,
                isActive: isActive,
                onTap: () {
                  if (onSelected != null) {
                    onSelected!(preset);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  int _calculateColumns(double width) {
    if (width < DSBreakpoints.narrow) return 1;
    if (width < DSBreakpoints.timelineDetail) return 2;
    return 3;
  }
}

class _PresetTile extends StatelessWidget {
  final DSViewPreset preset;
  final bool isActive;
  final VoidCallback onTap;

  const _PresetTile({
    required this.preset,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: 'Preset: ${preset.name}. ${preset.description ?? ""}',
      child: DSGlassPanel(
        variant: isActive
            ? DSGlassPanelVariant.elevated
            : DSGlassPanelVariant.subtle,
        borderColor: isActive ? DSColors.accentBlue : DSColors.borderSubtle,
        borderWidth: isActive ? 1.5 : 1.0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DSRadii.card),
          hoverColor: DSColors.accentBlue.withValues(alpha: 0.05),
          focusColor: DSColors.focusRing,
          highlightColor: DSColors.accentBlue.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    DSIcon.small(
                      Icons.bookmarks_outlined,
                      color: isActive
                          ? DSColors.accentBlue
                          : DSColors.textSecondary,
                    ),
                    const SizedBox(width: DSSpacing.xs),
                    Expanded(
                      child: DSText.bodyMedium(
                        preset.name,
                        color: isActive
                            ? DSColors.accentBlue
                            : DSColors.textPrimary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (preset.description != null &&
                    preset.description!.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.xs),
                  DSText.labelSmall(
                    preset.description!,
                    color: DSColors.textTertiary,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
