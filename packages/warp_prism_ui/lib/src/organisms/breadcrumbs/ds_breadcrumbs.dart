import 'package:flutter/material.dart';
import '../../atoms/atoms.dart';
import '../../molecules/molecules.dart';
import '../../tokens/tokens.dart';

/// Item representation for [DSBreadcrumbs].
class DSBreadcrumbItem {
  /// Display text label.
  final String label;

  /// Optional route path or target URL (null indicates current active page).
  final String? href;

  /// Optional icon displayed to the left of [label].
  final IconData? icon;

  /// Optional click handler.
  final VoidCallback? onTap;

  const DSBreadcrumbItem({
    required this.label,
    this.href,
    this.icon,
    this.onTap,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DSBreadcrumbItem &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          href == other.href &&
          icon == other.icon;

  @override
  int get hashCode => Object.hash(label, href, icon);
}

/// ASW Observatory Organism — Breadcrumbs
///
/// Hierarchical navigation path display component supporting custom separators,
/// active item highlight, click callbacks, optional route auto-derivation,
/// and middle-item collapse/truncation.
class DSBreadcrumbs extends StatelessWidget {
  /// Explicit breadcrumb hierarchy.
  final List<DSBreadcrumbItem> items;

  /// Separator icon rendered between items. Defaults to [Icons.chevron_right].
  final IconData separator;

  /// Optional custom separator widget replacing [separator] icon.
  final Widget? separatorWidget;

  /// Optional max number of visible items before middle items collapse to a "..." button.
  final int? maxItems;

  /// Optional callback invoked when a breadcrumb item is tapped.
  final ValueChanged<DSBreadcrumbItem>? onItemTap;

  /// Auto-derive breadcrumbs from route location when [items] is empty.
  final bool autoDerive;

  const DSBreadcrumbs({
    super.key,
    this.items = const [],
    this.separator = Icons.chevron_right,
    this.separatorWidget,
    this.maxItems,
    this.onItemTap,
    this.autoDerive = false,
  });

  // Keys for testing
  static const Key regionKey = Key('ds_breadcrumbs_region');
  static Key itemKey(int index) => Key('ds_breadcrumbs_item_$index');
  static const Key overflowKey = Key('ds_breadcrumbs_overflow');

  List<DSBreadcrumbItem> _resolveItems(BuildContext context) {
    if (items.isNotEmpty) return items;
    if (!autoDerive) return const [];

    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName == null || routeName.isEmpty || routeName == '/') {
      return const [DSBreadcrumbItem(label: 'Home', href: '/')];
    }

    final segments = routeName.split('/').where((s) => s.isNotEmpty).toList();
    final derived = <DSBreadcrumbItem>[
      const DSBreadcrumbItem(label: 'Home', href: '/'),
    ];

    var pathAcc = '';
    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      pathAcc += '/$seg';
      final formattedLabel = seg.isEmpty
          ? ''
          : seg[0].toUpperCase() + seg.substring(1);
      final isLast = i == segments.length - 1;
      derived.add(
        DSBreadcrumbItem(label: formattedLabel, href: isLast ? null : pathAcc),
      );
    }
    return derived;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveItems = _resolveItems(context);
    if (effectiveItems.isEmpty) return const SizedBox.shrink();

    return Semantics(
      label:
          'Breadcrumb navigation: ${effectiveItems.map((e) => e.label).join(' > ')}',
      explicitChildNodes: true,
      child: KeyedSubtree(
        key: regionKey,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildBreadcrumbList(effectiveItems),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBreadcrumbList(List<DSBreadcrumbItem> list) {
    final widgets = <Widget>[];

    if (maxItems != null && maxItems! >= 2 && list.length > maxItems!) {
      final firstItem = list.first;
      final lastCount = (maxItems! - 2).clamp(1, list.length - 2);
      final collapsedItems = list.sublist(1, list.length - lastCount);
      final tailItems = list.sublist(list.length - lastCount);

      widgets.add(_buildItemWidget(firstItem, index: 0, isLast: false));
      widgets.add(_buildSeparator());
      widgets.add(_buildOverflowButton(collapsedItems));

      for (int i = 0; i < tailItems.length; i++) {
        final originalIndex = list.length - lastCount + i;
        final item = tailItems[i];
        final isLast = originalIndex == list.length - 1;

        widgets.add(_buildSeparator());
        widgets.add(
          _buildItemWidget(item, index: originalIndex, isLast: isLast),
        );
      }
    } else {
      for (int i = 0; i < list.length; i++) {
        final item = list[i];
        final isLast = i == list.length - 1;

        if (i > 0) {
          widgets.add(_buildSeparator());
        }
        widgets.add(_buildItemWidget(item, index: i, isLast: isLast));
      }
    }

    return widgets;
  }

  Widget _buildSeparator() {
    if (separatorWidget != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
        child: separatorWidget!,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
      child: DSIcon.small(separator, color: DSColors.textTertiary),
    );
  }

  Widget _buildItemWidget(
    DSBreadcrumbItem item, {
    required int index,
    required bool isLast,
  }) {
    final textColor = isLast ? DSColors.textPrimary : DSColors.textSecondary;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.icon != null) ...[
          DSIcon.small(item.icon!, color: textColor),
          const SizedBox(width: DSSpacing.xs),
        ],
        DSText.labelMedium(item.label, color: textColor),
      ],
    );

    if (isLast) {
      return Container(
        key: itemKey(index),
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.xs,
          vertical: 2,
        ),
        child: content,
      );
    }

    return KeyedSubtree(
      key: itemKey(index),
      child: DSInteractiveSurface(
        semanticLabel: 'Navigate to ${item.label}',
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.xs,
          vertical: 2,
        ),
        onTap: () {
          item.onTap?.call();
          onItemTap?.call(item);
        },
        child: content,
      ),
    );
  }

  Widget _buildOverflowButton(List<DSBreadcrumbItem> collapsed) {
    return PopupMenuButton<DSBreadcrumbItem>(
      key: overflowKey,
      tooltip: 'Show middle breadcrumbs',
      color: DSColors.obsidianElevated,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSRadii.md),
        side: const BorderSide(color: DSColors.borderSubtle),
      ),
      onSelected: (item) {
        item.onTap?.call();
        onItemTap?.call(item);
      },
      itemBuilder: (context) {
        return collapsed.map((item) {
          return PopupMenuItem<DSBreadcrumbItem>(
            value: item,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.icon != null) ...[
                  DSIcon.small(item.icon!, color: DSColors.textSecondary),
                  const SizedBox(width: DSSpacing.sm),
                ],
                DSText.labelMedium(item.label, color: DSColors.textPrimary),
              ],
            ),
          );
        }).toList();
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: DSSpacing.xs, vertical: 2),
        child: DSIcon.small(Icons.more_horiz, color: DSColors.textSecondary),
      ),
    );
  }
}
