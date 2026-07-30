import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../tokens/tokens.dart';

/// Shared minimum interactive target for relation-card legend chips.
const double kEntityRelationLegendMinTouchTarget = kMinInteractiveDimension;

/// Tappable legend filter chip with 48dp hit target and keyboard activation.
class EntityRelationLegendButton extends StatelessWidget {
  final String type;
  final String label;
  final VoidCallback? onTap;

  const EntityRelationLegendButton({
    super.key,
    required this.type,
    required this.label,
    required this.onTap,
  });

  /// Stable test key for a legend filter of [type].
  static Key legendKey(String type) => Key('ds-relation-legend-$type');

  @override
  Widget build(BuildContext context) {
    final item = EntityRelationLegendItem(type: type, label: label);

    if (onTap == null) {
      return Semantics(label: '$label relation type', child: item);
    }

    return Semantics(
      button: true,
      label: 'Filter by $label relation type',
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onTap?.call();
              return null;
            },
          ),
        },
        child: Builder(
          builder: (context) {
            return GestureDetector(
              key: legendKey(type),
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Focus.of(context).requestFocus();
                onTap?.call();
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: kEntityRelationLegendMinTouchTarget,
                  minHeight: kEntityRelationLegendMinTouchTarget,
                ),
                child: Align(alignment: Alignment.centerLeft, child: item),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Visual legend swatch + label (non-interactive chrome).
class EntityRelationLegendItem extends StatelessWidget {
  final String type;
  final String label;

  const EntityRelationLegendItem({
    super.key,
    required this.type,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = DSColors.forAssetKind(type);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DSRadii.sm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: DSSpacing.xs),
          Text(
            label,
            style: DSTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
