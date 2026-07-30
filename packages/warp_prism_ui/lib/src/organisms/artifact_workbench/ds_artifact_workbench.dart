import 'package:flutter/material.dart';

import '../../atoms/atoms.dart';
import '../../molecules/molecules.dart';
import '../../tokens/tokens.dart';
import '../code_block/ds_code_block.dart';
import '../markdown_renderer/ds_markdown_renderer.dart';
import '../split_pane/ds_split_pane.dart';

// =============================================================================
// Models
// =============================================================================

/// Artifact content kind for preview registry routing.
///
/// MVP types only — no mermaid/svg live engines, no network loaders.
enum DSArtifactType {
  /// Source / code fixture → [DSCodeBlock].
  code,

  /// Markdown fixture → [DSMarkdownRenderer].
  markdown,

  /// Plain text fixture → monospace / body text.
  text,

  /// Unregistered / unknown type → safe fallback preview.
  unknown,
}

/// Immutable artifact model for [DSArtifactWorkbench].
///
/// Pure data — fixtures only; no remote URL loading in this package.
@immutable
class DSArtifact {
  /// Stable unique id within a workbench list.
  final String id;

  /// Display title (filename or artifact name).
  final String title;

  /// Content type for the preview registry.
  final DSArtifactType type;

  /// Full artifact body (local fixture content).
  final String content;

  /// Optional language hint for [DSArtifactType.code] previews.
  final String? language;

  /// Optional creation / generation timestamp for list meta.
  final DateTime? timestamp;

  /// Optional secondary label (path, generator, etc.).
  final String? subtitle;

  const DSArtifact({
    required this.id,
    required this.title,
    required this.type,
    required this.content,
    this.language,
    this.timestamp,
    this.subtitle,
  });

  /// Human-readable type badge label.
  String get typeLabel => switch (type) {
    DSArtifactType.code => 'code',
    DSArtifactType.markdown => 'markdown',
    DSArtifactType.text => 'text',
    DSArtifactType.unknown => 'unknown',
  };

  /// Accent color for type badge chrome.
  Color get typeColor => switch (type) {
    DSArtifactType.code => DSColors.accentCyan,
    DSArtifactType.markdown => DSColors.accentViolet,
    DSArtifactType.text => DSColors.accentGold,
    DSArtifactType.unknown => DSColors.textTertiary,
  };

  /// Material icon for the type chip.
  IconData get typeIcon => switch (type) {
    DSArtifactType.code => Icons.code,
    DSArtifactType.markdown => Icons.article_outlined,
    DSArtifactType.text => Icons.notes_outlined,
    DSArtifactType.unknown => Icons.help_outline,
  };

  DSArtifact copyWith({
    String? id,
    String? title,
    DSArtifactType? type,
    String? content,
    String? language,
    DateTime? timestamp,
    String? subtitle,
    bool clearLanguage = false,
    bool clearTimestamp = false,
    bool clearSubtitle = false,
  }) {
    return DSArtifact(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      content: content ?? this.content,
      language: clearLanguage ? null : (language ?? this.language),
      timestamp: clearTimestamp ? null : (timestamp ?? this.timestamp),
      subtitle: clearSubtitle ? null : (subtitle ?? this.subtitle),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSArtifact &&
        other.id == id &&
        other.title == title &&
        other.type == type &&
        other.content == content &&
        other.language == language &&
        other.timestamp == timestamp &&
        other.subtitle == subtitle;
  }

  @override
  int get hashCode =>
      Object.hash(id, title, type, content, language, timestamp, subtitle);
}

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — Artifact Workbench
///
/// Side-panel / workbench for **listing and previewing** agent-generated
/// artifacts (code, markdown, plain text MVP). Distinct from EPIC-15 media
/// detail overlay and from [DSLogViewer].
///
/// ## Preview registry
///
/// | Type | Preview |
/// | --- | --- |
/// | [DSArtifactType.code] | [DSCodeBlock] |
/// | [DSArtifactType.markdown] | [DSMarkdownRenderer] |
/// | [DSArtifactType.text] | Monospace plain body |
/// | [DSArtifactType.unknown] | Safe plain fallback + type notice |
///
/// ## Selection
///
/// - Uncontrolled (default): seed from [initialSelectedId]; organism owns id.
/// - Controlled: pass [selectedId] each rebuild; parent owns selection.
///
/// Fixture/read-only ADS surface — no network artifact loading, no heavy
/// renderers (mermaid/svg), no product-route coupling.
class DSArtifactWorkbench extends StatefulWidget {
  /// Artifacts to list. Empty list → empty-state surface.
  final List<DSArtifact> artifacts;

  /// Controlled selection id. When non-null, parent drives selection.
  final String? selectedId;

  /// Seed selection for uncontrolled mode. When null, first artifact is selected.
  final String? initialSelectedId;

  /// Called when the user selects a row (id may be null if list cleared).
  final ValueChanged<DSArtifact?>? onSelectionChanged;

  /// Panel header title.
  final String title;

  /// Optional subtitle under the title.
  final String? subtitle;

  /// Semantic label for the workbench region.
  final String semanticLabel;

  /// Semantic label for the artifact list region.
  final String listSemanticLabel;

  /// Semantic label for the preview region.
  final String previewSemanticLabel;

  /// Empty-list title.
  final String emptyLabel;

  /// Empty-list subtitle.
  final String emptySubtitle;

  /// Preview empty (no selection) title.
  final String noSelectionLabel;

  /// Preview empty subtitle.
  final String noSelectionSubtitle;

  /// When true, host layout uses [DSSplitPane]; otherwise a fixed list width.
  final bool useSplitPane;

  /// List pane width when not using split pane. Defaults to 280.
  final double listWidth;

  /// Initial split ratio for list (leading) pane when [useSplitPane] is true.
  final double splitInitialRatio;

  /// Whether to wrap the panel in glass chrome. Defaults to true.
  final bool wrapInGlass;

  /// Show timestamps on list rows when present.
  final bool showTimestamps;

  /// Max height for code block previews.
  final double? codePreviewMaxHeight;

  const DSArtifactWorkbench({
    super.key,
    required this.artifacts,
    this.selectedId,
    this.initialSelectedId,
    this.onSelectionChanged,
    this.title = 'Artifacts',
    this.subtitle,
    this.semanticLabel = 'Artifact workbench',
    this.listSemanticLabel = 'Artifact list',
    this.previewSemanticLabel = 'Artifact preview',
    this.emptyLabel = 'No artifacts',
    this.emptySubtitle = 'Generated outputs will appear here',
    this.noSelectionLabel = 'No selection',
    this.noSelectionSubtitle = 'Select an artifact to preview',
    this.useSplitPane = true,
    this.listWidth = 280,
    this.splitInitialRatio = 0.34,
    this.wrapInGlass = true,
    this.showTimestamps = true,
    this.codePreviewMaxHeight = 360,
  });

  /// Stable keys for tests and semantic tooling.
  static const Key panelKey = Key('ds-artifact-workbench');
  static const Key listKey = Key('ds-artifact-workbench-list');
  static const Key previewKey = Key('ds-artifact-workbench-preview');
  static const Key emptyStateKey = Key('ds-artifact-workbench-empty');
  static const Key noSelectionKey = Key('ds-artifact-workbench-no-selection');
  static const Key unknownPreviewKey = Key(
    'ds-artifact-workbench-unknown-preview',
  );

  /// Row key by artifact id.
  static Key rowKey(String artifactId) =>
      Key('ds-artifact-workbench-row-$artifactId');

  /// Type badge key by artifact id.
  static Key typeBadgeKey(String artifactId) =>
      Key('ds-artifact-workbench-type-$artifactId');

  @override
  State<DSArtifactWorkbench> createState() => _DSArtifactWorkbenchState();
}

class _DSArtifactWorkbenchState extends State<DSArtifactWorkbench> {
  String? _uncontrolledSelectedId;

  @override
  void initState() {
    super.initState();
    _uncontrolledSelectedId = _resolveInitialSelection();
  }

  @override
  void didUpdateWidget(DSArtifactWorkbench oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedId != null) return;

    // Keep uncontrolled selection valid when the list changes.
    final ids = widget.artifacts.map((a) => a.id).toSet();
    if (_uncontrolledSelectedId != null &&
        !ids.contains(_uncontrolledSelectedId)) {
      _uncontrolledSelectedId = _resolveInitialSelection();
    } else if (_uncontrolledSelectedId == null && widget.artifacts.isNotEmpty) {
      _uncontrolledSelectedId = _resolveInitialSelection();
    }
  }

  String? _resolveInitialSelection() {
    if (widget.artifacts.isEmpty) return null;
    final seed = widget.initialSelectedId;
    if (seed != null && widget.artifacts.any((a) => a.id == seed)) {
      return seed;
    }
    return widget.artifacts.first.id;
  }

  String? get _effectiveSelectedId =>
      widget.selectedId ?? _uncontrolledSelectedId;

  DSArtifact? get _selectedArtifact {
    final id = _effectiveSelectedId;
    if (id == null) return null;
    for (final a in widget.artifacts) {
      if (a.id == id) return a;
    }
    return null;
  }

  void _select(DSArtifact artifact) {
    if (widget.selectedId == null) {
      setState(() => _uncontrolledSelectedId = artifact.id);
    }
    widget.onSelectionChanged?.call(artifact);
  }

  @override
  Widget build(BuildContext context) {
    final body = widget.artifacts.isEmpty
        ? _buildEmptyWorkbench()
        : _buildListAndPreview();

    final content = Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: Column(
        key: DSArtifactWorkbench.panelKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WorkbenchHeader(
            title: widget.title,
            subtitle: widget.subtitle,
            count: widget.artifacts.length,
          ),
          const DSDivider.subtle(),
          Expanded(child: body),
        ],
      ),
    );

    if (!widget.wrapInGlass) {
      return ColoredBox(color: DSColors.obsidianBase, child: content);
    }

    return DSGlassPanelSimple(
      backgroundColor: DSColors.obsidianBase.withValues(alpha: 0.95),
      borderColor: DSColors.borderSubtle,
      padding: EdgeInsets.zero,
      child: content,
    );
  }

  Widget _buildEmptyWorkbench() {
    return Center(
      key: DSArtifactWorkbench.emptyStateKey,
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: DSStateSurface.empty(
          icon: Icons.inventory_2_outlined,
          title: widget.emptyLabel,
          subtitle: widget.emptySubtitle,
          compact: true,
        ),
      ),
    );
  }

  Widget _buildListAndPreview() {
    final list = _ArtifactListPane(
      artifacts: widget.artifacts,
      selectedId: _effectiveSelectedId,
      showTimestamps: widget.showTimestamps,
      semanticLabel: widget.listSemanticLabel,
      onSelect: _select,
    );

    final preview = _ArtifactPreviewPane(
      artifact: _selectedArtifact,
      semanticLabel: widget.previewSemanticLabel,
      noSelectionLabel: widget.noSelectionLabel,
      noSelectionSubtitle: widget.noSelectionSubtitle,
      codePreviewMaxHeight: widget.codePreviewMaxHeight,
    );

    if (widget.useSplitPane) {
      return DSSplitPane(
        axis: Axis.horizontal,
        initialRatio: widget.splitInitialRatio,
        leadingMinExtent: 160,
        trailingMinExtent: 200,
        leading: list,
        trailing: preview,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: widget.listWidth, child: list),
        const DSDivider.subtle(vertical: true),
        Expanded(child: preview),
      ],
    );
  }
}

// =============================================================================
// Header
// =============================================================================

class _WorkbenchHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int count;

  const _WorkbenchHeader({
    required this.title,
    required this.subtitle,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: '$title, $count artifacts',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: DSColors.accentCyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(DSRadii.md),
              ),
              child: const DSIcon.small(
                Icons.folder_special_outlined,
                color: DSColors.accentCyan,
              ),
            ),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DSText.labelLarge(title, color: DSColors.textPrimary),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    DSText.bodySmall(subtitle!, color: DSColors.textTertiary),
                  ],
                ],
              ),
            ),
            DSBadge(
              label: '$count',
              color: DSColors.accentCyan,
              size: DSBadgeSize.small,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// List pane
// =============================================================================

class _ArtifactListPane extends StatelessWidget {
  final List<DSArtifact> artifacts;
  final String? selectedId;
  final bool showTimestamps;
  final String semanticLabel;
  final ValueChanged<DSArtifact> onSelect;

  const _ArtifactListPane({
    required this.artifacts,
    required this.selectedId,
    required this.showTimestamps,
    required this.semanticLabel,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: ColoredBox(
        color: DSColors.obsidianDeep.withValues(alpha: 0.55),
        child: ListView.separated(
          key: DSArtifactWorkbench.listKey,
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
          itemCount: artifacts.length,
          separatorBuilder: (_, __) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: DSSpacing.md),
            child: DSDivider.subtle(),
          ),
          itemBuilder: (context, index) {
            final artifact = artifacts[index];
            final selected = artifact.id == selectedId;
            return _ArtifactListRow(
              artifact: artifact,
              selected: selected,
              showTimestamp: showTimestamps,
              onTap: () => onSelect(artifact),
            );
          },
        ),
      ),
    );
  }
}

class _ArtifactListRow extends StatelessWidget {
  final DSArtifact artifact;
  final bool selected;
  final bool showTimestamp;
  final VoidCallback onTap;

  const _ArtifactListRow({
    required this.artifact,
    required this.selected,
    required this.showTimestamp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ts = artifact.timestamp;
    final timeLabel = (showTimestamp && ts != null)
        ? _formatTimestamp(ts)
        : null;

    return Semantics(
      button: true,
      selected: selected,
      label:
          '${artifact.title}, ${artifact.typeLabel}${timeLabel != null ? ', $timeLabel' : ''}',
      child: Material(
        color: selected
            ? DSColors.accentCyan.withValues(alpha: 0.10)
            : Colors.transparent,
        child: InkWell(
          key: DSArtifactWorkbench.rowKey(artifact.id),
          onTap: onTap,
          hoverColor: DSColors.obsidianHover.withValues(alpha: 0.6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    artifact.typeIcon,
                    size: 18,
                    color: selected
                        ? artifact.typeColor
                        : DSColors.textTertiary,
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DSText.labelMedium(
                          artifact.title,
                          color: selected
                              ? DSColors.textPrimary
                              : DSColors.textSecondary,
                        ),
                        if (artifact.subtitle != null) ...[
                          const SizedBox(height: 2),
                          DSText.bodySmall(
                            artifact.subtitle!,
                            color: DSColors.textTertiary,
                          ),
                        ],
                        if (timeLabel != null) ...[
                          const SizedBox(height: 2),
                          DSText.bodySmall(
                            timeLabel,
                            color: DSColors.textDisabled,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  DSBadge(
                    key: DSArtifactWorkbench.typeBadgeKey(artifact.id),
                    label: artifact.typeLabel,
                    color: artifact.typeColor,
                    size: DSBadgeSize.small,
                    variant: DSBadgeVariant.outlined,
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

// =============================================================================
// Preview pane
// =============================================================================

class _ArtifactPreviewPane extends StatelessWidget {
  final DSArtifact? artifact;
  final String semanticLabel;
  final String noSelectionLabel;
  final String noSelectionSubtitle;
  final double? codePreviewMaxHeight;

  const _ArtifactPreviewPane({
    required this.artifact,
    required this.semanticLabel,
    required this.noSelectionLabel,
    required this.noSelectionSubtitle,
    required this.codePreviewMaxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final selected = artifact;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: ColoredBox(
        key: DSArtifactWorkbench.previewKey,
        color: DSColors.obsidianElevated.withValues(alpha: 0.4),
        child: selected == null
            ? Center(
                key: DSArtifactWorkbench.noSelectionKey,
                child: Padding(
                  padding: const EdgeInsets.all(DSSpacing.lg),
                  child: DSStateSurface.empty(
                    icon: Icons.preview_outlined,
                    title: noSelectionLabel,
                    subtitle: noSelectionSubtitle,
                    compact: true,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PreviewHeader(artifact: selected),
                  const DSDivider.subtle(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(DSSpacing.lg),
                      child: _buildPreviewBody(selected),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPreviewBody(DSArtifact artifact) {
    return switch (artifact.type) {
      DSArtifactType.code => DSCodeBlock(
        source: artifact.content,
        language: artifact.language,
        showLineNumbers: true,
        showCopyButton: true,
        maxHeight: codePreviewMaxHeight,
      ),
      DSArtifactType.markdown => DSMarkdownRenderer(data: artifact.content),
      DSArtifactType.text => _PlainTextPreview(content: artifact.content),
      DSArtifactType.unknown => _UnknownTypePreview(artifact: artifact),
    };
  }
}

class _PreviewHeader extends StatelessWidget {
  final DSArtifact artifact;

  const _PreviewHeader({required this.artifact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSText.labelLarge(artifact.title, color: DSColors.textPrimary),
                if (artifact.subtitle != null) ...[
                  const SizedBox(height: 2),
                  DSText.bodySmall(
                    artifact.subtitle!,
                    color: DSColors.textTertiary,
                  ),
                ],
              ],
            ),
          ),
          DSBadge(
            label: artifact.typeLabel,
            color: artifact.typeColor,
            size: DSBadgeSize.small,
          ),
          if (artifact.language != null) ...[
            const SizedBox(width: DSSpacing.sm),
            DSBadge(
              label: artifact.language!,
              color: DSColors.textTertiary,
              size: DSBadgeSize.small,
              variant: DSBadgeVariant.outlined,
            ),
          ],
        ],
      ),
    );
  }
}

class _PlainTextPreview extends StatelessWidget {
  final String content;

  const _PlainTextPreview({required this.content});

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return const DSText.bodySmall('No content', color: DSColors.textTertiary);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: DSColors.obsidianDeep.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(DSRadii.md),
        border: Border.all(color: DSColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.md),
        child: SelectableText(
          content,
          style: DSTypography.codeMedium.copyWith(
            color: DSColors.textSecondary,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _UnknownTypePreview extends StatelessWidget {
  final DSArtifact artifact;

  const _UnknownTypePreview({required this.artifact});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: DSArtifactWorkbench.unknownPreviewKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DSStateSurface(
          stateType: DSStateType.empty,
          icon: Icons.help_outline,
          title: 'Unknown artifact type',
          subtitle:
              'No registered preview for this type. Showing plain content fallback.',
          compact: true,
        ),
        const SizedBox(height: DSSpacing.md),
        _PlainTextPreview(content: artifact.content),
      ],
    );
  }
}

// =============================================================================
// Helpers + fixtures
// =============================================================================

String _formatTimestamp(DateTime ts) {
  final local = ts.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
}

/// Minimal gallery / test fixture set (≥2 artifacts, multi-type).
List<DSArtifact> dsArtifactWorkbenchFixtures() {
  return [
    DSArtifact(
      id: 'art-code-1',
      title: 'health_check.dart',
      type: DSArtifactType.code,
      language: 'dart',
      subtitle: 'generated/tools',
      timestamp: DateTime.utc(2026, 7, 10, 14, 32),
      content: r'''
/// Fixture health probe — no live network.
Map<String, Object?> healthCheck(String provider) {
  return {
    'provider': provider,
    'status': 'healthy',
    'latencyMs': 42,
  };
}
''',
    ),
    DSArtifact(
      id: 'art-md-1',
      title: 'run-summary.md',
      type: DSArtifactType.markdown,
      subtitle: 'session/notes',
      timestamp: DateTime.utc(2026, 7, 10, 14, 35),
      content: '''
# Run summary

- Provider: **openai / main-prod**
- Result: healthy (fixture)
- Artifacts: 3

```json
{ "ok": true }
```
''',
    ),
    DSArtifact(
      id: 'art-text-1',
      title: 'stdout.log',
      type: DSArtifactType.text,
      subtitle: 'execution',
      timestamp: DateTime.utc(2026, 7, 10, 14, 36),
      content: '''
[14:36:01] probe start
[14:36:01] provider=openai
[14:36:02] status=healthy
[14:36:02] done
''',
    ),
  ];
}

/// Single unknown-type fixture for fallback tests / gallery edge case.
DSArtifact dsArtifactUnknownFixture({String id = 'art-unknown-1'}) {
  return DSArtifact(
    id: id,
    title: 'diagram.mermaid',
    type: DSArtifactType.unknown,
    subtitle: 'unsupported preview',
    timestamp: DateTime.utc(2026, 7, 10, 14, 40),
    content: 'graph TD;\n  A-->B;\n  (fixture — no mermaid engine)',
  );
}
