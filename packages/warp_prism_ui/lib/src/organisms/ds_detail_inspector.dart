import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// ASW Observatory Organism - Detail Inspector
///
/// Side panel for viewing asset details.
/// Supports keyboard-navigable link rows and Semantics throughout.
class DSDetailInspector extends StatelessWidget {
  final String title;
  final String kind;
  final String? subtitle;
  final List<DSDetailSection> sections;
  final VoidCallback? onClose;
  final Widget? headerActions;

  const DSDetailInspector({
    super.key,
    required this.title,
    required this.kind,
    this.subtitle,
    required this.sections,
    this.onClose,
    this.headerActions,
  });

  @override
  Widget build(BuildContext context) {
    final kindColor = DSColors.forAssetKind(kind);

    return Semantics(
      label: 'Detail inspector for $title',
      explicitChildNodes: true,
      child: Container(
        color: DSColors.obsidianBase,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _InspectorHeader(
              title: title,
              kind: kind,
              subtitle: subtitle,
              kindColor: kindColor,
              onClose: onClose,
              actions: headerActions,
            ),

            const DSDivider.subtle(),

            // Sections
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(DSSpacing.lg),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < sections.length - 1 ? DSSpacing.lg : 0,
                    ),
                    child: _InspectorSection(section: sections[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InspectorHeader extends StatelessWidget {
  final String title;
  final String kind;
  final String? subtitle;
  final Color kindColor;
  final VoidCallback? onClose;
  final Widget? actions;

  const _InspectorHeader({
    required this.title,
    required this.kind,
    this.subtitle,
    required this.kindColor,
    this.onClose,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$kind: $title${subtitle != null ? '. $subtitle' : ''}',
      header: true,
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Kind icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kindColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DSRadii.md),
                  ),
                  child: DSIcon(DSIcons.forAssetKind(kind), color: kindColor),
                ),
                const SizedBox(width: DSSpacing.md),

                // Title and kind
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DSText.labelMedium(kind.toUpperCase(), color: kindColor),
                      const SizedBox(height: 2),
                      DSText.headingMedium(title),
                    ],
                  ),
                ),

                // Close button
                if (onClose != null)
                  Semantics(
                    label: 'Close inspector',
                    button: true,
                    child: IconButton(
                      icon: const DSIcon(Icons.close),
                      onPressed: onClose,
                      tooltip: 'Close',
                    ),
                  ),
              ],
            ),

            if (subtitle != null) ...[
              const SizedBox(height: DSSpacing.sm),
              DSText.bodyMedium(subtitle!, color: DSColors.textSecondary),
            ],

            if (actions != null) ...[
              const SizedBox(height: DSSpacing.md),
              actions!,
            ],
          ],
        ),
      ),
    );
  }
}

class _InspectorSection extends StatelessWidget {
  final DSDetailSection section;

  const _InspectorSection({required this.section});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Section: ${section.title}',
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              if (section.icon != null) ...[
                DSIcon.small(section.icon!, color: DSColors.textTertiary),
                const SizedBox(width: DSSpacing.xs),
              ],
              DSText.labelLarge(section.title, color: DSColors.textSecondary),
              if (section.count != null) ...[
                const SizedBox(width: DSSpacing.xs),
                DSBadge.count(section.count!, size: DSBadgeSize.small),
              ],
            ],
          ),

          const SizedBox(height: DSSpacing.sm),

          // Section content
          section.child,
        ],
      ),
    );
  }
}

class DSDetailSection {
  final String title;
  final IconData? icon;
  final int? count;
  final Widget child;

  const DSDetailSection({
    required this.title,
    this.icon,
    this.count,
    required this.child,
  });
}

/// Property row for detail inspector.
/// Label uses textTertiary (WCAG AA compliant since 1010 fix).
class DSPropertyRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  const DSPropertyRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: DSText.labelSmall(label, color: DSColors.textTertiary),
            ),
            Expanded(
              child: DSText.bodySmall(
                value,
                color: valueColor ?? DSColors.textPrimary,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// Link row for detail inspector with keyboard focus support.
class DSLinkRow extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  const DSLinkRow({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.onTap,
  });

  @override
  State<DSLinkRow> createState() => _DSLinkRowState();
}

class _DSLinkRowState extends State<DSLinkRow> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      button: widget.onTap != null,
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space) {
              widget.onTap?.call();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: MouseRegion(
            cursor: widget.onTap != null
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: DSColors.obsidianElevated,
                borderRadius: BorderRadius.circular(DSRadii.sm),
                border: _isFocused
                    ? Border.all(color: DSColors.focusRing, width: 2)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    DSIcon.small(
                      widget.icon!,
                      color: widget.color ?? DSColors.textSecondary,
                    ),
                    const SizedBox(width: DSSpacing.xs),
                  ],
                  Flexible(
                    child: DSText.labelSmall(
                      widget.label,
                      color: widget.color ?? DSColors.textSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
