import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// ASW Observatory Molecule - Provenance Pill
///
/// Shows governance/canonicality status with icon and label
class DSProvenancePill extends StatelessWidget {
  final String canonicality;
  final bool showLabel;
  final DSProvenanceSize size;

  const DSProvenancePill({
    super.key,
    required this.canonicality,
    this.showLabel = true,
    this.size = DSProvenanceSize.medium,
  });

  Color get _color => DSColors.forCanonicity(canonicality);

  IconData get _icon => DSIcons.forCanonicity(canonicality);

  String get _label {
    switch (canonicality.toLowerCase()) {
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
        return canonicality;
    }
  }

  double get _height {
    switch (size) {
      case DSProvenanceSize.small:
        return 20;
      case DSProvenanceSize.medium:
        return 24;
      case DSProvenanceSize.large:
        return 28;
    }
  }

  double get _iconSize {
    switch (size) {
      case DSProvenanceSize.small:
        return 12;
      case DSProvenanceSize.medium:
        return 14;
      case DSProvenanceSize.large:
        return 16;
    }
  }

  double get _fontSize {
    switch (size) {
      case DSProvenanceSize.small:
        return 10;
      case DSProvenanceSize.medium:
        return 11;
      case DSProvenanceSize.large:
        return 12;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _getTooltip(),
      child: Container(
        height: _height,
        padding: EdgeInsets.symmetric(horizontal: showLabel ? 8 : 6),
        decoration: BoxDecoration(
          color: _color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(DSRadii.full),
          border: Border.all(color: _color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: _iconSize, color: _color),
            if (showLabel) ...[
              const SizedBox(width: 4),
              Text(
                _label,
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w600,
                  color: _color,
                  height: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTooltip() {
    switch (canonicality.toLowerCase()) {
      case 'parentcanonical':
        return 'Parent-canonical: Authoritative source of truth';
      case 'childlocal':
        return 'Child-local: Local overlay, may diverge from parent';
      case 'generated':
        return 'Generated: Computed from other sources';
      case 'appendonly':
        return 'Append-only: Immutable ledger, new entries only';
      case 'archive':
        return 'Archive: Historical, no longer active';
      case 'mock':
        return 'Mock: Test/demo data';
      default:
        return canonicality;
    }
  }
}

enum DSProvenanceSize { small, medium, large }
