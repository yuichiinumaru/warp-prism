import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';
import '../../atoms/atoms.dart';
import 'ds_log_entry_model.dart';
import 'ds_log_severity.dart';

/// A single log entry row for the [DSLogViewer].
///
/// Displays timestamp, severity indicator, source, and message.
/// Expands to reveal [DSLogEntry.detail] (stack trace / metadata) on tap.
///
/// The row height is fixed (via [itemExtent]) for virtualized list performance
/// unless expanded.
class DSLogEntryWidget extends StatelessWidget {
  final DSLogEntry entry;
  final bool expanded;
  final VoidCallback? onToggleExpand;
  final bool showAbsoluteTime;

  const DSLogEntryWidget({
    super.key,
    required this.entry,
    this.expanded = false,
    this.onToggleExpand,
    this.showAbsoluteTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${entry.severity.label}: ${entry.source}: ${entry.message}',
      explicitChildNodes: true,
      child: Container(
        decoration: BoxDecoration(
          color: expanded
              ? DSColors.obsidianHover
              : DSColors.transparent,
          border: Border(
            left: BorderSide(
              color: entry.severity.color,
              width: expanded ? 3 : 2,
            ),
            bottom: const BorderSide(
              color: DSColors.borderSubtle,
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _LogRow(
              entry: entry,
              expanded: expanded,
              onToggleExpand: onToggleExpand,
              showAbsoluteTime: showAbsoluteTime,
            ),
            if (expanded && entry.hasDetail)
              _ExpandedDetail(detail: entry.detail!),
          ],
        ),
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  final DSLogEntry entry;
  final bool expanded;
  final VoidCallback? onToggleExpand;
  final bool showAbsoluteTime;

  const _LogRow({
    required this.entry,
    required this.expanded,
    this.onToggleExpand,
    required this.showAbsoluteTime,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: entry.hasDetail ? onToggleExpand : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Severity icon
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: DSIcon.small(
                entry.severity.icon,
                color: entry.severity.color,
                semanticLabel: entry.severity.label,
              ),
            ),
            const SizedBox(width: DSSpacing.sm),

            // Timestamp
            SizedBox(
              width: 80,
              child: DSText.labelSmall(
                _formatTimestamp(entry.timestamp),
                color: DSColors.textTertiary,
              ),
            ),
            const SizedBox(width: DSSpacing.sm),

            // Source badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: DSColors.obsidianElevated,
                borderRadius: BorderRadius.circular(DSRadii.chip),
              ),
              child: DSText.labelSmall(
                entry.source,
                color: DSColors.accentCyan,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: DSSpacing.sm),

            // Message
            Expanded(
              child: DSText.bodySmall(
                entry.message,
                color: _messageColor(entry.severity),
                maxLines: expanded ? null : 2,
                overflow: expanded ? null : TextOverflow.ellipsis,
              ),
            ),

            // Expand chevron
            if (entry.hasDetail)
              Padding(
                padding: const EdgeInsets.only(left: DSSpacing.xs),
                child: DSIcon.small(
                  expanded ? DSIcons.collapse : DSIcons.expand,
                  color: DSColors.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime ts) {
    final h = ts.hour.toString().padLeft(2, '0');
    final m = ts.minute.toString().padLeft(2, '0');
    final s = ts.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Color _messageColor(DSLogSeverity severity) {
    switch (severity) {
      case DSLogSeverity.critical:
      case DSLogSeverity.error:
        return DSColors.statusError;
      case DSLogSeverity.warning:
        return DSColors.statusWarning;
      default:
        return DSColors.textPrimary;
    }
  }
}

class _ExpandedDetail extends StatelessWidget {
  final String detail;

  const _ExpandedDetail({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.xxl + DSSpacing.sm,
        0,
        DSSpacing.md,
        DSSpacing.sm,
      ),
      color: DSColors.obsidianDeep,
      child: SelectableText(
        detail,
        style: DSTypography.codeSmall.copyWith(
          color: DSColors.textSecondary,
        ),
      ),
    );
  }
}
