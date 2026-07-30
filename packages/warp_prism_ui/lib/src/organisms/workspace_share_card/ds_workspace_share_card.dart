import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../atoms/atoms.dart';
import '../../tokens/tokens.dart';
import '../ds_detail_inspector.dart'; // For DSPropertyRow reuse

/// Represents a read-only snapshot or metadata package for a workspace.
@immutable
class DSWorkspaceShareSummary {
  /// Unique identifier of the shared workspace.
  final String workspaceId;

  /// Display name of the workspace.
  final String workspaceName;

  /// Display name of the active camera/layer preset, if any.
  final String? activePresetName;

  /// List of active layer display names.
  final List<String> activeLayers;

  /// Formatted center coordinates (e.g. "Lat: 34.052, Lng: -118.243").
  final String? cameraCenter;

  /// Camera zoom level.
  final double? cameraZoom;

  /// Number of active agents in the workspace.
  final int? agentCount;

  /// Number of tasks tracked in the workspace.
  final int? taskCount;

  /// The generated web URL to access this shared workspace layout.
  final String shareUrl;

  const DSWorkspaceShareSummary({
    required this.workspaceId,
    required this.workspaceName,
    this.activePresetName,
    this.activeLayers = const [],
    this.cameraCenter,
    this.cameraZoom,
    this.agentCount,
    this.taskCount,
    required this.shareUrl,
  });
}

/// A read-only shareable view-state summary card organism.
///
/// Displays key metadata about the workspace and provides copies
/// of the share URL to the clipboard.
class DSWorkspaceShareCard extends StatefulWidget {
  /// The workspace share summary data.
  final DSWorkspaceShareSummary summary;

  /// Callback when the share link is copied or shared.
  final ValueChanged<String>? onShare;

  /// Semantic label for screen readers.
  final String? semanticLabel;

  /// Optional card title displayed in header. Defaults to "Workspace Handoff".
  final String? title;

  const DSWorkspaceShareCard({
    super.key,
    required this.summary,
    this.onShare,
    this.semanticLabel,
    this.title = 'Workspace Handoff',
  });

  @override
  State<DSWorkspaceShareCard> createState() => _DSWorkspaceShareCardState();
}

class _DSWorkspaceShareCardState extends State<DSWorkspaceShareCard> {
  bool _copied = false;
  Timer? _copiedTimer;

  @override
  void dispose() {
    _copiedTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleCopy() async {
    try {
      Clipboard.setData(
        ClipboardData(text: widget.summary.shareUrl),
      ).catchError((_) {
        // Safe fallback
      });
    } catch (_) {
      // Safe fallback for environments/headless tests without clipboard support
    }
    if (!mounted) return;

    setState(() {
      _copied = true;
    });

    _copiedTimer?.cancel();
    _copiedTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });

    if (widget.onShare != null) {
      widget.onShare!(widget.summary.shareUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final layersString = summary.activeLayers.isEmpty
        ? 'None'
        : summary.activeLayers.join(', ');

    return Semantics(
      label: widget.semanticLabel ?? widget.title,
      explicitChildNodes: true,
      child: DSGlassPanel(
        variant: DSGlassPanelVariant.elevated,
        borderColor: DSColors.borderSubtle,
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  const DSIcon(
                    Icons.share_outlined,
                    color: DSColors.accentCyan,
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: DSText.bodyMedium(
                      widget.title ?? 'Workspace Handoff',
                      color: DSColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DSSpacing.sm),
              const Divider(color: DSColors.borderSubtle, height: 1),
              const SizedBox(height: DSSpacing.sm),

              // Summary fields
              DSPropertyRow(label: 'Workspace', value: summary.workspaceName),
              DSPropertyRow(
                label: 'Active Preset',
                value: summary.activePresetName ?? 'None',
              ),
              DSPropertyRow(label: 'Layers', value: layersString),
              if (summary.cameraCenter != null)
                DSPropertyRow(
                  label: 'Coordinates',
                  value: summary.cameraCenter!,
                ),
              if (summary.cameraZoom != null)
                DSPropertyRow(
                  label: 'Zoom Level',
                  value: summary.cameraZoom!.toStringAsFixed(1),
                ),
              if (summary.agentCount != null)
                DSPropertyRow(
                  label: 'Agents',
                  value: summary.agentCount!.toString(),
                ),
              if (summary.taskCount != null)
                DSPropertyRow(
                  label: 'Tasks',
                  value: summary.taskCount!.toString(),
                ),

              const SizedBox(height: DSSpacing.md),
              const Divider(color: DSColors.borderSubtle, height: 1),
              const SizedBox(height: DSSpacing.sm),

              // Action Row / URL copying
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DSSpacing.sm,
                        vertical: DSSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: DSColors.obsidianDeep,
                        borderRadius: BorderRadius.circular(DSRadii.sm),
                        border: Border.all(color: DSColors.borderSubtle),
                      ),
                      child: DSText.labelSmall(
                        summary.shareUrl,
                        color: DSColors.textTertiary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Semantics(
                    button: true,
                    label: _copied ? 'Copied' : 'Copy workspace share link',
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _copied
                            ? DSColors.statusSuccess
                            : DSColors.obsidianHover,
                        foregroundColor: DSColors.textPrimary,
                        minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.sm,
                          vertical: DSSpacing.sm,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DSRadii.sm),
                          side: BorderSide(
                            color: _copied
                                ? DSColors.statusSuccess
                                : DSColors.accentCyan.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      onPressed: _handleCopy,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DSIcon.small(
                            _copied ? Icons.check : Icons.copy,
                            color: DSColors.textPrimary,
                          ),
                          const SizedBox(width: DSSpacing.xs),
                          DSText.labelSmall(
                            _copied ? 'Copied' : 'Copy',
                            color: DSColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
