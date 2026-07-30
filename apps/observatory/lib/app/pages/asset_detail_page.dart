/// Asset Detail page — universal detail view for any workspace asset.
///
/// Deep-links through `/assets/:assetId` resolve against the normalized
/// workspace graph via [assetDetailDescriptorProvider], then render
/// [AssetDetailView] with mapper-produced sections. Unresolved or empty
/// IDs keep the shell-level fallback surface.
///
/// Selection sync: on open, the page mirrors the route asset into
/// [AssetSelectionController] with origin `deep-link` so consumers that
/// watch selection state stay coherent with the URL path.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../asset_selection_controller.dart';
import '../../data/providers/workspace_providers.dart';
import '../../features/asset_detail/application/asset_detail_controller.dart';
import '../../features/asset_detail/presentation/asset_detail_view.dart';
import '../../features/shell/shell_state_handler.dart';

/// Asset detail page with deep-link fallback handling.
///
/// When [assetId] is empty or matches a known-unresolvable pattern,
/// the page renders [ShellStateHandler.buildUnresolvedAssetFallback]
/// instead of pretending the asset exists. Otherwise it watches the
/// graph-backed descriptor provider and dispatches to [AssetDetailView].
class AssetDetailPage extends ConsumerStatefulWidget {
  /// The asset ID from the route parameter.
  final String assetId;

  /// Optional override used by tests or callers that already know
  /// resolution failed (e.g., pre-route guards). When false, the
  /// shell unresolved fallback is shown without graph lookup.
  final bool resolved;

  const AssetDetailPage({
    super.key,
    required this.assetId,
    this.resolved = true,
  });

  @override
  ConsumerState<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends ConsumerState<AssetDetailPage> {
  String? _syncedSelectionId;

  void _syncSelectionFromDeepLink() {
    final assetId = widget.assetId;
    if (assetId.isEmpty || assetId == 'unknown' || !widget.resolved) {
      return;
    }
    if (_syncedSelectionId == assetId) {
      return;
    }

    final graphAsync = ref.read(workspaceGraphAsyncProvider);
    final graph = graphAsync.valueOrNull;
    if (graph == null) {
      return;
    }

    final selection = ref.read(assetSelectionControllerProvider);
    if (selection.assetId == assetId &&
        selection.origin == 'deep-link' &&
        selection.status != AssetSelectionStatus.idle) {
      _syncedSelectionId = assetId;
      return;
    }

    _syncedSelectionId = assetId;
    ref
        .read(assetSelectionControllerProvider.notifier)
        .select(assetId, origin: 'deep-link', graph: graph);
  }

  @override
  Widget build(BuildContext context) {
    final assetId = widget.assetId;

    // Keep selection controller aligned with deep-link route after graph loads.
    ref.listen(workspaceGraphAsyncProvider, (previous, next) {
      next.whenData((_) {
        if (!mounted) return;
        _syncSelectionFromDeepLink();
      });
    });
    // Also try immediately when graph is already available.
    _syncSelectionFromDeepLink();

    if (assetId.isEmpty || assetId == 'unknown' || !widget.resolved) {
      return _buildShellFallback(context);
    }

    final detailAsync = ref.watch(assetDetailDescriptorProvider(assetId));

    return Scaffold(
      backgroundColor: PrismColors.obsidianDeep,
      appBar: AppBar(
        backgroundColor: PrismColors.obsidianBase,
        foregroundColor: PrismColors.textPrimary,
        elevation: 0,
        title: const PrismText.headingMedium('Asset Detail'),
        leading: IconButton(
          icon: const PrismIcon(Icons.arrow_back),
          onPressed: () {
            ref.read(assetSelectionControllerProvider.notifier).clear();
            context.go('/overview');
          },
          tooltip: 'Back to Overview',
        ),
      ),
      body: detailAsync.when(
        loading: () => const AssetDetailLoading(),
        error: (error, _) => AssetDetailError(
          message: error.toString(),
          onRetry: () => ref.invalidate(assetDetailDescriptorProvider(assetId)),
        ),
        data: (result) {
          if (!result.resolved) {
            return ShellStateHandler.buildUnresolvedAssetFallback(
              assetId: assetId,
              onNavigateHome: () {
                ref.read(assetSelectionControllerProvider.notifier).clear();
                context.go('/overview');
              },
            );
          }
          return AssetDetailView(
            descriptor: result.descriptor,
            onClose: () {
              ref.read(assetSelectionControllerProvider.notifier).clear();
              context.go('/overview');
            },
          );
        },
      ),
    );
  }

  Widget _buildShellFallback(BuildContext context) {
    return Scaffold(
      backgroundColor: PrismColors.obsidianDeep,
      appBar: AppBar(
        backgroundColor: PrismColors.obsidianBase,
        foregroundColor: PrismColors.textPrimary,
        elevation: 0,
        title: const PrismText.headingMedium('Asset Detail'),
        leading: IconButton(
          icon: const PrismIcon(Icons.arrow_back),
          onPressed: () => context.go('/overview'),
          tooltip: 'Back to Overview',
        ),
      ),
      body: ShellStateHandler.buildUnresolvedAssetFallback(
        assetId: widget.assetId.isEmpty ? '(empty)' : widget.assetId,
        onNavigateHome: () => context.go('/overview'),
      ),
    );
  }
}
