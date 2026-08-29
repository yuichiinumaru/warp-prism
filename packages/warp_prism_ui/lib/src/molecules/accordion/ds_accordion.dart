import 'package:flutter/material.dart';

import '../../atoms/ds_divider.dart';
import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_icon.dart';
import '../../atoms/ds_text.dart';
import '../../tokens/tokens.dart';
import '../ds_interactive_surface.dart';
import '../ds_state_surface.dart';

/// Single item / section definition for [DSAccordion].
@immutable
class DSAccordionItem {
  /// Optional stable identity for the accordion section.
  final String? id;

  /// Header title label.
  final String title;

  /// Optional subtitle below the title.
  final String? subtitle;

  /// Optional leading icon in header.
  final IconData? icon;

  /// Main body content widget. If null, a compact [DSStateSurface.empty] is shown.
  final Widget? content;

  /// Whether this section starts open in uncontrolled expansion.
  final bool defaultOpen;

  /// Whether this section is disabled and ignores tap events.
  final bool disabled;

  const DSAccordionItem({
    this.id,
    required this.title,
    this.subtitle,
    this.icon,
    this.content,
    this.defaultOpen = false,
    this.disabled = false,
  });

  DSAccordionItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    IconData? icon,
    Widget? content,
    bool? defaultOpen,
    bool? disabled,
  }) {
    return DSAccordionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      content: content ?? this.content,
      defaultOpen: defaultOpen ?? this.defaultOpen,
      disabled: disabled ?? this.disabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSAccordionItem &&
        other.id == id &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.icon == icon &&
        other.content == content &&
        other.defaultOpen == defaultOpen &&
        other.disabled == disabled;
  }

  @override
  int get hashCode =>
      Object.hash(id, title, subtitle, icon, content, defaultOpen, disabled);
}

/// Alias for [DSAccordionItem] for API compatibility.
typedef DSAccordionSection = DSAccordionItem;

/// ASW Observatory Molecule — Accordion / Collapsible Section Panel
///
/// Obsidian-glass styled collapsible accordion widget. Composes
/// [DSInteractiveSurface], [DSGlassPanel], [AnimatedRotation],
/// [AnimatedSize], and [DSDivider].
class DSAccordion extends StatefulWidget {
  /// List of accordion sections / items.
  final List<DSAccordionItem> items;

  /// If true, multiple sections can be expanded simultaneously.
  /// If false (default), expanding one section collapses all others.
  final bool multiExpand;

  /// Fired when a section header is toggled. Emits the index of the section,
  /// or null if a single-expand section was collapsed.
  final ValueChanged<int?>? onSectionToggled;

  /// Fired whenever the set of expanded section indices changes.
  final ValueChanged<Set<int>>? onExpandedIndicesChanged;

  /// Controlled set of expanded indices. When non-null, parent owns expansion.
  final Set<int>? expandedIndices;

  /// Initial set of expanded indices for uncontrolled expansion.
  final Set<int>? initiallyExpandedIndices;

  /// Whether to render a divider between sections (defaults to true).
  final bool showDividers;

  /// Whether to wrap the accordion in [DSGlassPanel] (defaults to true).
  final bool wrapInGlass;

  /// Optional semantic label for the entire accordion region.
  final String semanticLabel;

  /// Duration for open/close size animation (defaults to [DSMotion.normal], 200ms).
  final Duration animationDuration;

  const DSAccordion({
    super.key,
    List<DSAccordionItem>? items,
    List<DSAccordionItem>? sections,
    this.multiExpand = false,
    this.onSectionToggled,
    this.onExpandedIndicesChanged,
    this.expandedIndices,
    this.initiallyExpandedIndices,
    this.showDividers = true,
    this.wrapInGlass = true,
    this.semanticLabel = 'Accordion panel',
    this.animationDuration = DSMotion.normal,
  }) : items = items ?? sections ?? const <DSAccordionItem>[];

  /// Alias getter for items.
  List<DSAccordionItem> get sections => items;

  /// Whether expansion state is parent-controlled.
  bool get isExpansionControlled => expandedIndices != null;

  static Key headerKey(int index) => Key('ds-accordion-header-$index');
  static Key contentKey(int index) => Key('ds-accordion-content-$index');

  static String headerSemanticLabel(
    String title, {
    required bool expanded,
    required bool disabled,
  }) {
    if (disabled) return '$title, disabled';
    return expanded ? '$title, expanded' : '$title, collapsed';
  }

  @override
  State<DSAccordion> createState() => _DSAccordionState();
}

class _DSAccordionState extends State<DSAccordion> {
  late Set<int> _uncontrolledExpanded;

  @override
  void initState() {
    super.initState();
    _uncontrolledExpanded = _seedExpanded(widget);
  }

  @override
  void didUpdateWidget(covariant DSAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isExpansionControlled &&
        (oldWidget.items != widget.items || oldWidget.isExpansionControlled)) {
      _uncontrolledExpanded = _seedExpanded(widget);
    }
  }

  static Set<int> _seedExpanded(DSAccordion widget) {
    if (widget.initiallyExpandedIndices != null) {
      return {...widget.initiallyExpandedIndices!};
    }
    final seeded = <int>{};
    for (var i = 0; i < widget.items.length; i++) {
      if (widget.items[i].defaultOpen && !widget.items[i].disabled) {
        seeded.add(i);
        if (!widget.multiExpand) break;
      }
    }
    return seeded;
  }

  Set<int> get _expanded => widget.expandedIndices ?? _uncontrolledExpanded;

  void _toggleSection(int index) {
    if (index < 0 || index >= widget.items.length) return;
    final item = widget.items[index];
    if (item.disabled) return;

    final currentlyExpanded = _expanded.contains(index);
    final next = Set<int>.from(_expanded);

    if (currentlyExpanded) {
      next.remove(index);
      widget.onSectionToggled?.call(null);
    } else {
      if (widget.multiExpand) {
        next.add(index);
      } else {
        next.clear();
        next.add(index);
      }
      widget.onSectionToggled?.call(index);
    }

    if (!widget.isExpansionControlled) {
      setState(() => _uncontrolledExpanded = next);
    }
    widget.onExpandedIndicesChanged?.call(Set<int>.unmodifiable(next));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      const emptyWidget = Padding(
        padding: EdgeInsets.all(DSSpacing.md),
        child: DSStateSurface.empty(title: 'No sections', compact: true),
      );
      return widget.wrapInGlass
          ? const DSGlassPanel.elevated(child: emptyWidget)
          : emptyWidget;
    }

    final children = <Widget>[];

    for (var i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final isExpanded = _expanded.contains(i);

      if (i > 0 && widget.showDividers) {
        children.add(const DSDivider.subtle());
      }

      children.add(
        _DSAccordionSectionWidget(
          index: i,
          item: item,
          expanded: isExpanded,
          animationDuration: widget.animationDuration,
          onToggle: () => _toggleSection(i),
        ),
      );
    }

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );

    final wrapped = widget.wrapInGlass
        ? DSGlassPanel.elevated(padding: EdgeInsets.zero, child: body)
        : body;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: wrapped,
    );
  }
}

class _DSAccordionSectionWidget extends StatelessWidget {
  final int index;
  final DSAccordionItem item;
  final bool expanded;
  final Duration animationDuration;
  final VoidCallback onToggle;

  const _DSAccordionSectionWidget({
    required this.index,
    required this.item,
    required this.expanded,
    required this.animationDuration,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final interactive = !item.disabled;
    final labelColor = item.disabled
        ? DSColors.textDisabled
        : expanded
        ? DSColors.textPrimary
        : DSColors.textSecondary;

    final header = KeyedSubtree(
      key: DSAccordion.headerKey(index),
      child: Semantics(
        button: interactive,
        enabled: interactive,
        expanded: expanded,
        label: DSAccordion.headerSemanticLabel(
          item.title,
          expanded: expanded,
          disabled: item.disabled,
        ),
        excludeSemantics: true,
        child: DSInteractiveSurface(
          semanticLabel: item.title,
          onTap: interactive ? onToggle : null,
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
          child: Opacity(
            opacity: item.disabled ? 0.5 : 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 32),
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    DSIcon(item.icon!, size: 18, color: labelColor),
                    const SizedBox(width: DSSpacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DSText.labelLarge(item.title, color: labelColor),
                        if (item.subtitle != null)
                          DSText.labelSmall(
                            item.subtitle!,
                            color: DSColors.textTertiary,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0.0,
                    duration: animationDuration,
                    curve: DSMotion.standard,
                    child: DSIcon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: interactive
                          ? (expanded
                                ? DSColors.accentBlue
                                : DSColors.textSecondary)
                          : DSColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final contentWidget =
        item.content ??
        const Padding(
          padding: EdgeInsets.all(DSSpacing.sm),
          child: DSStateSurface.empty(title: 'No content', compact: true),
        );

    final body = ClipRect(
      child: AnimatedSize(
        duration: animationDuration,
        curve: DSMotion.standard,
        alignment: Alignment.topCenter,
        child: expanded
            ? KeyedSubtree(
                key: DSAccordion.contentKey(index),
                child: Padding(
                  padding: const EdgeInsets.all(DSSpacing.md),
                  child: contentWidget,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [header, body],
    );
  }
}
