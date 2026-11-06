import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import 'ds_icon.dart';

/// Provenance Badge — atom-scale canonicity marker (Task 1872, EXPERIMENTAL).
///
/// Companion to the [DSProvenancePill] molecule: same canonicity vocabulary
/// (`parentcanonical`, `childlocal`, `generated`, `appendonly`, `archive`,
/// `mock`), same token colors via [DSColors.forCanonicity], same icons via
/// [DSIcons.forCanonicity] — at atom density for inline lineage and witness
/// rows. Display only: no hashing, fingerprinting, or verification logic.
///
/// EXPERIMENTAL: no layer-barrel export, no `Prism` alias (promotion defers
/// to the STABLE task, which must update the boundary harness).
class DSProvenanceBadge extends StatelessWidget {
  /// Canonicity key (case-insensitive). Unknown keys render honestly with
  /// the raw key as label and a neutral token — never a success claim.
  final String canonicality;

  /// Whether to render the text label beside the icon.
  final bool showLabel;

  /// Atom density.
  final DSProvenanceBadgeSize size;

  const DSProvenanceBadge({
    super.key,
    required this.canonicality,
    this.showLabel = true,
    this.size = DSProvenanceBadgeSize.medium,
  });

  /// Token color for a canonicity key (pill-consistent).
  Color colorFor(String key) => DSColors.forCanonicity(key);

  /// Icon for a canonicity key (pill-consistent).
  IconData iconFor(String key) => DSIcons.forCanonicity(key);

  /// Human-readable label for a canonicity key (pill-consistent).
  String labelFor(String key) {
    switch (key.toLowerCase()) {
      case 'parentcanonical':
        return 'Canonical';
      case 'childlocal':
        return 'Local';
      case 'generated':
        return 'Generated';
      case 'appendonly':
        return 'Append-Only';
      case 'archive':
        return 'Archive';
      case 'mock':
        return 'Mock';
      default:
        return key;
    }
  }

  double get _height {
    switch (size) {
      case DSProvenanceBadgeSize.small:
        return 16;
      case DSProvenanceBadgeSize.medium:
        return 20;
      case DSProvenanceBadgeSize.large:
        return 24;
    }
  }

  double get _iconSize {
    switch (size) {
      case DSProvenanceBadgeSize.small:
        return 10;
      case DSProvenanceBadgeSize.medium:
        return 12;
      case DSProvenanceBadgeSize.large:
        return 14;
    }
  }

  double get _fontSize {
    switch (size) {
      case DSProvenanceBadgeSize.small:
        return 9;
      case DSProvenanceBadgeSize.medium:
        return 10;
      case DSProvenanceBadgeSize.large:
        return 11;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(canonicality);
    return Semantics(
      label: 'Provenance: ${labelFor(canonicality)}',
      child: Container(
        height: _height,
        padding: EdgeInsets.symmetric(horizontal: showLabel ? 6 : 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(DSRadii.full),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconFor(canonicality), size: _iconSize, color: color),
            if (showLabel) ...[
              const SizedBox(width: 3),
              Text(
                labelFor(canonicality),
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w600,
                  color: color,
                  height: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Atom densities for [DSProvenanceBadge].
enum DSProvenanceBadgeSize { small, medium, large }
