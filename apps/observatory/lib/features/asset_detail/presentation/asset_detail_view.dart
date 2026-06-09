/// Universal asset detail dispatcher.
///
/// Routes to the correct kind-specific detail view based on the
/// asset's [AssetKind]. This is the entry point that the shell,
/// map, and operate surfaces use to render asset detail.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../../../data/models/workspace_graph.dart';
import '../domain/asset_detail_descriptor.dart';
import 'skill_detail_view.dart';
import 'task_detail_view.dart';
import 'agent_detail_view.dart';
import 'workflow_detail_view.dart';
import 'changelog_detail_view.dart';
import 'generic_asset_detail_view.dart';

/// Dispatches to the correct detail view based on asset kind.
///
/// This is a pure presentational widget — it receives a fully-built
/// [AssetDetailDescriptor] and routes to the appropriate kind-specific
/// view. All mapping/derivation lives in the application layer.
class AssetDetailView extends StatelessWidget {
  final AssetDetailDescriptor descriptor;
  final VoidCallback? onClose;

  const AssetDetailView({
    super.key,
    required this.descriptor,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final kind = descriptor.asset.kind;

    switch (kind) {
      case AssetKind.skill:
        return SkillDetailView(descriptor: descriptor, onClose: onClose);
      case AssetKind.task:
        return TaskDetailView(descriptor: descriptor, onClose: onClose);
      case AssetKind.agent:
        return AgentDetailView(descriptor: descriptor, onClose: onClose);
      case AssetKind.workflow:
        return WorkflowDetailView(descriptor: descriptor, onClose: onClose);
      case AssetKind.changelog:
        return ChangelogDetailView(descriptor: descriptor, onClose: onClose);
      case AssetKind.subskill:
      case AssetKind.script:
      case AssetKind.reference:
      case AssetKind.rule:
        return GenericAssetDetailView(descriptor: descriptor, onClose: onClose);
    }
  }
}

/// Empty state when no asset is selected for detail inspection.
class AssetDetailEmpty extends StatelessWidget {
  final String? message;

  const AssetDetailEmpty({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DSColors.obsidianBase,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: DSStateSurface.empty(
            icon: Icons.touch_app_outlined,
            title: 'No asset selected',
            subtitle: message ??
                'Select an asset from the catalog or graph to view its details, '
                'relationships, and provenance.',
            compact: true,
          ),
        ),
      ),
    );
  }
}

/// Loading state for asset detail.
class AssetDetailLoading extends StatelessWidget {
  const AssetDetailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DSColors.obsidianBase,
      child: const Center(
        child: CircularProgressIndicator(color: DSColors.accentCyan),
      ),
    );
  }
}

/// Error state for asset detail.
class AssetDetailError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AssetDetailError({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DSColors.obsidianBase,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: DSColors.statusError,
              ),
              const SizedBox(height: DSSpacing.lg),
              DSText.headingMedium(
                'Error loading asset',
                color: DSColors.textSecondary,
              ),
              const SizedBox(height: DSSpacing.sm),
              DSText.bodyMedium(
                message,
                color: DSColors.textTertiary,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: DSSpacing.lg),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
