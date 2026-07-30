import 'package:flutter/material.dart';

import '../../atoms/atoms.dart';
import '../../molecules/molecules.dart';
import '../../tokens/tokens.dart';
import '../markdown_renderer/ds_markdown_renderer.dart';
import 'ds_agent_message.dart';

/// ASW Observatory Organism — Agent Transcript
///
/// Scrollable multi-role **chat** conversation list for CyberCore / AI
/// harness demos. Renders typed message blocks (text, think, plan, custom)
/// with role badges and optional timestamps.
///
/// ## Boundary (false-gap guard)
///
/// | This organism | Not this organism |
/// | --- | --- |
/// | Multi-role chat turns (user / assistant / system) | EPIC-15 `PrismAgentShellPanel` terminal/session shell |
/// | Typed content blocks (text / think / plan) | [DSLogViewer] severity-filtered event stream |
/// | Fixture / host-provided messages only | Live LLM streaming clients or API keys |
///
/// ## Extension points (Task 1605 / 1606)
///
/// - Use [DSAgentMessageBlock.custom] to embed tool-call cards or status
///   history strips without forking this organism.
/// - Optional [trailingBuilder] per message for host chrome.
/// - Optional [footer] for disabled composer chrome (read-only MVP).
///
/// ## Contract
///
/// - Parent must provide a **bounded height** (uses [ListView] in [Expanded]
///   semantics via unbounded height → intrinsic scroll view fill).
/// - Empty [messages] shows a compact empty placeholder when enabled.
/// - No network, no shell execution, no mutation controls.
class DSAgentTranscript extends StatelessWidget {
  /// Ordered conversation turns (oldest → newest recommended).
  final List<DSAgentMessage> messages;

  /// When true, render [DSAgentMessage.timestamp] when present.
  final bool showTimestamps;

  /// When true, text blocks use [DSMarkdownRenderer]; otherwise plain text.
  final bool renderMarkdown;

  /// Semantic label for the conversation region.
  final String semanticLabel;

  /// Show empty placeholder when [messages] is empty.
  final bool showEmptyPlaceholder;

  /// Empty-state title.
  final String emptyLabel;

  /// Empty-state subtitle.
  final String emptySubtitle;

  /// Optional external scroll controller.
  final ScrollController? scrollController;

  /// Padding around the message list.
  final EdgeInsetsGeometry padding;

  /// Optional trailing slot builder per message (actions, status strip).
  final Widget Function(BuildContext context, DSAgentMessage message)?
  trailingBuilder;

  /// Optional footer under the list (e.g. disabled composer chrome).
  final Widget? footer;

  /// Max bubble width as a fraction of available width (0–1).
  final double maxBubbleWidthFactor;

  const DSAgentTranscript({
    super.key,
    required this.messages,
    this.showTimestamps = true,
    this.renderMarkdown = true,
    this.semanticLabel = 'Agent conversation',
    this.showEmptyPlaceholder = true,
    this.emptyLabel = 'No messages',
    this.emptySubtitle = 'Conversation turns will appear here',
    this.scrollController,
    this.padding = const EdgeInsets.all(DSSpacing.lg),
    this.trailingBuilder,
    this.footer,
    this.maxBubbleWidthFactor = 0.86,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: ColoredBox(
        color: DSColors.obsidianDeep,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: messages.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      key: const Key('agent-transcript-list'),
                      controller: scrollController,
                      padding: padding,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return Padding(
                          key: Key('agent-message-${message.id}'),
                          padding: const EdgeInsets.only(bottom: DSSpacing.md),
                          child: _AgentMessageRow(
                            message: message,
                            showTimestamp: showTimestamps,
                            renderMarkdown: renderMarkdown,
                            maxBubbleWidthFactor: maxBubbleWidthFactor,
                            trailing: trailingBuilder?.call(context, message),
                            // 1-based index for ordered semantics.
                            turnIndex: index + 1,
                          ),
                        );
                      },
                    ),
            ),
            if (footer != null) ...[const DSDivider.subtle(), footer!],
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    if (!showEmptyPlaceholder) {
      return const SizedBox.expand();
    }
    return Center(
      child: Padding(
        padding: padding,
        child: DSStateSurface.empty(
          icon: Icons.forum_outlined,
          title: emptyLabel,
          subtitle: emptySubtitle,
          compact: true,
        ),
      ),
    );
  }
}

class _AgentMessageRow extends StatelessWidget {
  final DSAgentMessage message;
  final bool showTimestamp;
  final bool renderMarkdown;
  final double maxBubbleWidthFactor;
  final Widget? trailing;
  final int turnIndex;

  const _AgentMessageRow({
    required this.message,
    required this.showTimestamp,
    required this.renderMarkdown,
    required this.maxBubbleWidthFactor,
    required this.turnIndex,
    this.trailing,
  });

  Alignment get _alignment => switch (message.role) {
    DSAgentRole.user => Alignment.centerRight,
    DSAgentRole.assistant => Alignment.centerLeft,
    DSAgentRole.system => Alignment.center,
  };

  CrossAxisAlignment get _crossAxis => switch (message.role) {
    DSAgentRole.user => CrossAxisAlignment.end,
    DSAgentRole.assistant => CrossAxisAlignment.start,
    DSAgentRole.system => CrossAxisAlignment.center,
  };

  Color get _roleColor => switch (message.role) {
    DSAgentRole.user => DSColors.accentViolet,
    DSAgentRole.assistant => DSColors.accentCyan,
    DSAgentRole.system => DSColors.textTertiary,
  };

  Color get _bubbleFill => switch (message.role) {
    DSAgentRole.user => DSColors.accentViolet.withValues(alpha: 0.10),
    DSAgentRole.assistant => DSColors.obsidianElevated,
    DSAgentRole.system => DSColors.obsidianBase,
  };

  Color get _bubbleBorder => switch (message.role) {
    DSAgentRole.user => DSColors.accentViolet.withValues(alpha: 0.35),
    DSAgentRole.assistant => DSColors.borderSubtle,
    DSAgentRole.system => DSColors.borderSubtle.withValues(alpha: 0.6),
  };

  IconData get _roleIcon => switch (message.role) {
    DSAgentRole.user => Icons.person_outline,
    DSAgentRole.assistant => Icons.smart_toy_outlined,
    DSAgentRole.system => Icons.info_outline,
  };

  @override
  Widget build(BuildContext context) {
    final timeLabel = showTimestamp && message.timestamp != null
        ? _formatTimestamp(message.timestamp!)
        : null;

    final semanticsLabel = StringBuffer()
      ..write('Turn $turnIndex, ${message.displayAuthor}');
    if (timeLabel != null) {
      semanticsLabel.write(', $timeLabel');
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticsLabel.toString(),
      child: Align(
        alignment: _alignment,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth * maxBubbleWidthFactor;
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: _crossAxis,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MessageMeta(
                    author: message.displayAuthor,
                    roleLabel: message.roleLabel,
                    roleColor: _roleColor,
                    roleIcon: _roleIcon,
                    timestampLabel: timeLabel,
                    alignEnd: message.role == DSAgentRole.user,
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: _bubbleFill,
                      borderRadius: BorderRadius.circular(DSRadii.lg),
                      border: Border.all(color: _bubbleBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(DSSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < message.blocks.length; i++) ...[
                            if (i > 0) const SizedBox(height: DSSpacing.sm),
                            _MessageBlockView(
                              block: message.blocks[i],
                              renderMarkdown: renderMarkdown,
                              roleColor: _roleColor,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(height: DSSpacing.xs),
                    trailing!,
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static String _formatTimestamp(DateTime ts) {
    final local = ts.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    final s = local.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _MessageMeta extends StatelessWidget {
  final String author;
  final String roleLabel;
  final Color roleColor;
  final IconData roleIcon;
  final String? timestampLabel;
  final bool alignEnd;

  const _MessageMeta({
    required this.author,
    required this.roleLabel,
    required this.roleColor,
    required this.roleIcon,
    required this.alignEnd,
    this.timestampLabel,
  });

  @override
  Widget build(BuildContext context) {
    final badge = DSBadge(
      label: roleLabel,
      color: roleColor,
      size: DSBadgeSize.small,
      semanticLabel: 'Role $roleLabel',
    );

    final authorText = DSText.labelSmall(author, color: DSColors.textSecondary);

    final timeText = timestampLabel == null
        ? null
        : DSText.labelSmall(timestampLabel!, color: DSColors.textTertiary);

    final children = <Widget>[
      Icon(roleIcon, size: 14, color: roleColor),
      const SizedBox(width: DSSpacing.xs),
      authorText,
      const SizedBox(width: DSSpacing.sm),
      badge,
      if (timeText != null) ...[const SizedBox(width: DSSpacing.sm), timeText],
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: alignEnd ? children.reversed.toList() : children,
    );
  }
}

class _MessageBlockView extends StatelessWidget {
  final DSAgentMessageBlock block;
  final bool renderMarkdown;
  final Color roleColor;

  const _MessageBlockView({
    required this.block,
    required this.renderMarkdown,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    return switch (block.type) {
      DSAgentMessageBlockType.text => _buildText(),
      DSAgentMessageBlockType.think => _StubBlock(
        icon: Icons.psychology_outlined,
        title: block.label ?? 'Thinking',
        body: block.text ?? '',
        accent: DSColors.accentViolet,
      ),
      DSAgentMessageBlockType.plan => _StubBlock(
        icon: Icons.route_outlined,
        title: block.label ?? 'Plan',
        body: block.text ?? '',
        accent: DSColors.accentGold,
      ),
      DSAgentMessageBlockType.custom => block.child ?? const SizedBox.shrink(),
    };
  }

  Widget _buildText() {
    final data = block.text ?? '';
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }
    if (renderMarkdown) {
      return DSMarkdownRenderer(data: data);
    }
    return DSText.bodyMedium(data, color: DSColors.textPrimary);
  }
}

/// Collapsed-chrome stub for think / plan blocks (Task 1604 MVP).
class _StubBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color accent;

  const _StubBlock({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title block',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(DSRadii.md),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: accent),
                  const SizedBox(width: DSSpacing.xs),
                  DSText.labelSmall(title, color: accent),
                ],
              ),
              if (body.isNotEmpty) ...[
                const SizedBox(height: DSSpacing.xs),
                DSText.bodySmall(body, color: DSColors.textSecondary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
