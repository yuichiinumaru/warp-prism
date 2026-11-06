import 'package:flutter/material.dart';
import '../atoms/atoms.dart';
import '../theme/ds_theme.dart';
import '../tokens/tokens.dart';
import 'ds_sidebar.dart';

/// PrismSidebar section-model extension (ADS presentation, EXPERIMENTAL).
///
/// Task 1873 (F-06): groups [DSSidebarItem] rows into collapsible sections
/// with a kept-row fold, a drag-insertion line affordance, Starred markers,
/// and unread pills. No drag backends, no eligibility evaluation: gated rows
/// arrive as plain data ([DSSidebarRowGateData]) whose `denied` flag the
/// product projects from IDS `availabilityFor` (Task 1868 frozen shape — see
/// the widget test proving the projection). Denied rows render
/// disabled-with-reason, never hidden.
///
/// Lifecycle: EXPERIMENTAL. No barrel export, no `Prism*` alias; import this
/// file directly from `src/` while experimental.
@immutable
class DSSidebarSection {
  /// Stable section identity.
  final String id;

  /// Visible section title. Null renders an untitled group.
  final String? title;

  /// Rows in display order.
  final List<DSSidebarItem> rows;

  /// Whether the section can collapse.
  final bool collapsible;

  /// Whether the section starts collapsed.
  final bool initiallyCollapsed;

  /// Row ids that stay visible when collapsed (kept-row fold).
  final List<String> keptRowIds;

  const DSSidebarSection({
    required this.id,
    this.title,
    this.rows = const [],
    this.collapsible = true,
    this.initiallyCollapsed = false,
    this.keptRowIds = const [],
  });
}

/// Plain-data gate projected from IDS `ActionAvailability` (Task 1868).
///
/// The product maps `allow → (denied: false)`, `constrain → (denied: false,
/// reason: limitation)`, `deny/missing → (denied: true, reason: refusal)`.
/// The mapping proof lives in the widget test; this file never imports IDS.
@immutable
class DSSidebarRowGateData {
  /// Sidebar row id this gate applies to.
  final String rowId;

  /// True when the row must render disabled-with-reason.
  final bool denied;

  /// Human-readable reason shown alongside denied/constrained rows.
  final String? reason;

  const DSSidebarRowGateData({
    required this.rowId,
    this.denied = false,
    this.reason,
  });
}

/// Presentation flags per row: Starred marker + unread pill count.
///
/// Kept separate from [DSSidebarItem] so the base sidebar file stays
/// untouched (parallel Task 1872 writes nearby molecules/atoms).
@immutable
class DSSidebarRowFlags {
  /// True when the row shows a Starred marker.
  final bool starred;

  /// Unread count; 0 or null renders no pill.
  final int? unreadCount;

  const DSSidebarRowFlags({this.starred = false, this.unreadCount});
}

/// Sidebar with sections: kept-row fold, insertion line, Starred, unread.
///
/// - Collapsed sections show only [DSSidebarSection.keptRowIds] rows.
/// - [insertionIndex] draws a single insertion line affordance at that flat
///   row offset (product-local drag backends own the actual reorder).
/// - Unread pills render via [DSBadge.count]; Starred via a star icon.
/// - Denied gated rows render dimmed with their reason announced via
///   semantics and tooltip, never hidden.
class DSSidebarSections extends StatefulWidget {
  /// Sections in display order.
  final List<DSSidebarSection> sections;

  /// Currently selected row id.
  final String? selectedId;

  /// Row tap callback.
  final ValueChanged<String>? onItemTap;

  /// Per-row gates projected from IDS availability (Task 1868 shape).
  final Map<String, DSSidebarRowGateData> gates;

  /// Per-row Starred/unread flags keyed by row id.
  final Map<String, DSSidebarRowFlags> flags;

  /// Flat row offset where the insertion line renders. Null hides it.
  final int? insertionIndex;

  /// Whether the sidebar renders expanded.
  final bool expanded;

  const DSSidebarSections({
    super.key,
    this.sections = const [],
    this.selectedId,
    this.onItemTap,
    this.gates = const {},
    this.flags = const {},
    this.insertionIndex,
    this.expanded = true,
  });

  /// Rows visible after applying kept-row folds, in display order.
  List<DSSidebarItem> visibleRows(Set<String> collapsed) {
    final visible = <DSSidebarItem>[];
    for (final section in sections) {
      if (collapsed.contains(section.id)) {
        for (final row in section.rows) {
          if (section.keptRowIds.contains(row.id)) visible.add(row);
        }
      } else {
        visible.addAll(section.rows);
      }
    }
    return visible;
  }

  @override
  State<DSSidebarSections> createState() => _DSSidebarSectionsState();
}

class _DSSidebarSectionsState extends State<DSSidebarSections> {
  late Set<String> _collapsed;

  @override
  void initState() {
    super.initState();
    _collapsed = {
      for (final section in widget.sections)
        if (section.initiallyCollapsed) section.id,
    };
  }

  @override
  void didUpdateWidget(DSSidebarSections oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sections != widget.sections) {
      _collapsed = {
        for (final section in widget.sections)
          if (section.initiallyCollapsed) section.id,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    var flatIndex = 0;
    return Semantics(
      label: 'Navigation sidebar sections',
      explicitChildNodes: true,
      child: Container(
        width: widget.expanded
            ? DSSpacing.sidebarExpanded
            : DSSpacing.sidebarCollapsed,
        decoration: BoxDecoration(
          color: DSColors.obsidianBase,
          border: const Border(
            right: BorderSide(color: DSColors.borderSubtle, width: 1),
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
          children: [
            for (final section in widget.sections) ...[
              _SectionHeader(
                section: section,
                collapsed: _collapsed.contains(section.id),
                expanded: widget.expanded,
                onToggle: section.collapsible
                    ? () => setState(() {
                        if (_collapsed.contains(section.id)) {
                          _collapsed.remove(section.id);
                        } else {
                          _collapsed.add(section.id);
                        }
                      })
                    : null,
              ),
              for (final row in _rowsFor(section))
                ..._rowWithInsertion(row, flatIndex++),
            ],
          ],
        ),
      ),
    );
  }

  List<DSSidebarItem> _rowsFor(DSSidebarSection section) {
    if (!_collapsed.contains(section.id)) return section.rows;
    return section.rows
        .where((row) => section.keptRowIds.contains(row.id))
        .toList(growable: false);
  }

  List<Widget> _rowWithInsertion(DSSidebarItem row, int index) {
    final widgets = <Widget>[];
    if (widget.insertionIndex == index) {
      widgets.add(const _InsertionLine());
    }
    widgets.add(
      _SectionRow(
        item: row,
        isSelected: row.id == widget.selectedId,
        expanded: widget.expanded,
        gate: widget.gates[row.id],
        flags: widget.flags[row.id] ?? const DSSidebarRowFlags(),
        onTap: widget.onItemTap == null
            ? null
            : () => widget.onItemTap!.call(row.id),
      ),
    );
    return widgets;
  }
}

class _SectionHeader extends StatelessWidget {
  final DSSidebarSection section;
  final bool collapsed;
  final bool expanded;
  final VoidCallback? onToggle;

  const _SectionHeader({
    required this.section,
    required this.collapsed,
    required this.expanded,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (section.title == null) return const SizedBox.shrink();
    final label = section.title!;
    final subtitle = collapsed ? 'collapsed' : 'expanded';
    return Semantics(
      label: '$label section, $subtitle',
      header: true,
      button: onToggle != null,
      child: GestureDetector(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.xs,
          ),
          child: Row(
            children: [
              if (onToggle != null)
                DSIcon(
                  collapsed ? Icons.chevron_right : Icons.expand_more,
                  color: DSColors.textTertiary,
                  iconSize: DSIconSize.small,
                ),
              if (expanded)
                Expanded(
                  child: DSText.labelSmall(
                    label.toUpperCase(),
                    color: DSColors.textTertiary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  final DSSidebarItem item;
  final bool isSelected;
  final bool expanded;
  final DSSidebarRowGateData? gate;
  final DSSidebarRowFlags flags;
  final VoidCallback? onTap;

  const _SectionRow({
    required this.item,
    required this.isSelected,
    required this.expanded,
    required this.gate,
    required this.flags,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final denied = gate?.denied ?? false;
    final accent = item.color ?? DSTheme.accentOf(context);
    final bgColor = isSelected
        ? accent.withValues(alpha: 0.15)
        : DSColors.transparent;
    final textColor = denied
        ? DSColors.textTertiary
        : (isSelected ? accent : DSColors.textSecondary);
    final semanticLabel =
        '${item.label ?? item.id}${flags.starred ? ', starred' : ''}'
        '${(flags.unreadCount ?? 0) > 0 ? ', ${flags.unreadCount} unread' : ''}'
        '${denied ? ', disabled: ${gate?.reason ?? 'unavailable'}' : ''}';
    final unread = flags.unreadCount ?? 0;

    return Semantics(
      label: semanticLabel,
      button: true,
      selected: isSelected,
      enabled: !denied,
      explicitChildNodes: true,
      child: Tooltip(
        message: denied
            ? (gate?.reason ?? 'Unavailable')
            : (item.label ?? item.id),
        child: GestureDetector(
          onTap: denied ? null : onTap,
          child: Opacity(
            opacity: denied ? 0.55 : 1,
            child: AnimatedContainer(
              duration: DSMotion.fast,
              margin: EdgeInsets.symmetric(
                horizontal: expanded ? DSSpacing.sm : DSSpacing.xs,
                vertical: 2,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: expanded ? DSSpacing.md : 0,
                vertical: DSSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(DSRadii.md),
                border: isSelected
                    ? Border.all(color: accent.withValues(alpha: 0.3), width: 1)
                    : null,
              ),
              child: Row(
                mainAxisAlignment: expanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  DSIcon(
                    item.icon,
                    color: denied ? DSColors.textTertiary : textColor,
                    iconSize: DSIconSize.medium,
                  ),
                  if (expanded) ...[
                    const SizedBox(width: DSSpacing.sm),
                    Expanded(
                      child: DSText.labelMedium(
                        item.label ?? item.id,
                        color: textColor,
                      ),
                    ),
                    if (flags.starred)
                      const DSIcon(
                        Icons.star,
                        color: DSColors.textTertiary,
                        iconSize: DSIconSize.small,
                      ),
                    if (unread > 0)
                      DSBadge.count(
                        unread,
                        color: accent,
                        size: DSBadgeSize.small,
                      )
                    else if (item.badge != null)
                      DSBadge.count(
                        item.badge!,
                        color: accent,
                        size: DSBadgeSize.small,
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InsertionLine extends StatelessWidget {
  const _InsertionLine();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Row insertion point',
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
        decoration: BoxDecoration(
          color: DSTheme.accentOf(context).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
