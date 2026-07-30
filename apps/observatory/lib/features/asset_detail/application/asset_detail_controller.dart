/// Controller for the universal asset detail view.
///
/// Exposes [AssetDetailDescriptor] from normalized workspace data.
/// This is the bridge between the data/projection layer and the
/// kind-specific detail views.
///
/// Provides both:
/// - [buildDescriptorFromSnapshot]: for pre-loaded asset data
/// - [resolveAssetDetail]: for ID-based lookup with fallback
/// - [assetDetailDescriptorProvider]: Riverpod family over graph state
/// - [selectedAssetDetailDescriptorProvider]: selection-synced descriptor
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warp_prism_observatory/app/asset_selection_controller.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/providers/workspace_providers.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph.dart';
import '../domain/asset_detail_descriptor.dart';
import 'asset_detail_mapper.dart';

// ---------------------------------------------------------------------------
// Sync builder from pre-loaded data
// ---------------------------------------------------------------------------

/// Builds an [AssetDetailDescriptor] synchronously from pre-loaded data.
///
/// Use this when you already have the asset, its edges, and an
/// asset-name map (e.g., from a Riverpod provider or test fixture).
AssetDetailDescriptor buildDescriptorFromSnapshot({
  required WorkspaceAsset asset,
  required List<WorkspaceEdge> allEdges,
  required Map<String, String> assetNames,
}) {
  final incoming = allEdges.where((e) => e.targetId == asset.id).toList();
  final outgoing = asset.edges.isNotEmpty
      ? asset.edges
      : allEdges.where((e) => e.sourceId == asset.id).toList();

  return buildAssetDetailDescriptor(
    asset: asset,
    incoming: incoming,
    outgoing: outgoing,
    assetNames: assetNames,
  );
}

// ---------------------------------------------------------------------------
// Async resolver from asset ID
// ---------------------------------------------------------------------------

/// Async result of resolving an asset detail descriptor.
@immutable
class AssetDetailResult {
  /// The resolved descriptor (fallback if asset not found).
  final AssetDetailDescriptor descriptor;

  /// Whether the asset was successfully resolved from the graph.
  final bool resolved;

  /// Error message if resolution failed (distinct from fallback).
  final String? error;

  const AssetDetailResult({
    required this.descriptor,
    this.resolved = false,
    this.error,
  });

  /// Convenience: whether this is a fallback result.
  bool get isFallback => descriptor.isFallback;

  /// Convenience: the asset ID.
  String get assetId => descriptor.asset.id;

  @override
  String toString() =>
      'AssetDetailResult(${descriptor.asset.id}, resolved: $resolved, '
      'fallback: ${descriptor.isFallback})';
}

/// Resolves an asset ID into an [AssetDetailResult] by looking it up
/// in the normalized graph and mapping it through the descriptor mapper.
///
/// This function is pure — it takes all dependencies as parameters,
/// making it easy to test without mocking providers.
AssetDetailResult resolveAssetDetail({
  required String assetId,
  required Map<String, WorkspaceAsset> assetIndex,
  required List<WorkspaceEdge> allEdges,
}) {
  if (assetId.isEmpty || assetId == 'unknown') {
    final placeholder = WorkspaceAsset(
      id: assetId.isEmpty ? '(empty)' : assetId,
      kind: AssetKind.agent,
      name: assetId.isEmpty ? '(empty)' : assetId,
      path: '',
    );
    final descriptor = AssetDetailDescriptor.fallback(
      asset: placeholder,
      message: 'No valid asset ID provided',
    );
    return AssetDetailResult(descriptor: descriptor, resolved: false);
  }

  final asset = assetIndex[assetId];

  if (asset == null) {
    final placeholder = WorkspaceAsset(
      id: assetId,
      kind: AssetKind.agent,
      name: assetId,
      path: '',
    );
    final descriptor = AssetDetailDescriptor.fallback(
      asset: placeholder,
      message: 'Asset not found or kind not supported',
    );
    return AssetDetailResult(descriptor: descriptor, resolved: false);
  }

  // Compute incoming/outgoing edges for this asset
  final incoming = allEdges.where((e) => e.targetId == assetId).toList();
  final outgoing = allEdges.where((e) => e.sourceId == assetId).toList();

  // Build a name lookup for related assets
  final assetNames = <String, String>{
    for (final a in assetIndex.values) a.id: a.name,
  };

  final descriptor = buildAssetDetailDescriptor(
    asset: asset,
    incoming: incoming,
    outgoing: outgoing,
    assetNames: assetNames,
  );

  return AssetDetailResult(
    descriptor: descriptor,
    // Graph resolution succeeded even when the kind uses partial fallback.
    resolved: true,
  );
}

/// Resolves an [AssetDetailResult] from a full [WorkspaceGraphResult].
AssetDetailResult resolveAssetDetailFromGraph({
  required String assetId,
  required WorkspaceGraphResult graph,
}) {
  return resolveAssetDetail(
    assetId: assetId,
    assetIndex: graph.assetsById,
    allEdges: graph.edges,
  );
}

/// Builds an asset index from a flat list of assets.
Map<String, WorkspaceAsset> buildAssetIndex(List<WorkspaceAsset> assets) {
  return {for (final a in assets) a.id: a};
}

// ---------------------------------------------------------------------------
// Riverpod providers — async descriptor surface for screens/inspector
// ---------------------------------------------------------------------------

/// Family provider: resolve a descriptor for any asset ID from the live graph.
///
/// Consumers see [AsyncValue]<[AssetDetailResult]>:
/// - loading while the workspace graph is loading
/// - error when graph load fails
/// - data with resolved/fallback descriptor semantics
final assetDetailDescriptorProvider =
    Provider.family<AsyncValue<AssetDetailResult>, String>((ref, assetId) {
      final graphAsync = ref.watch(workspaceGraphAsyncProvider);
      return graphAsync.when(
        data: (graph) => AsyncValue.data(
          resolveAssetDetailFromGraph(assetId: assetId, graph: graph),
        ),
        loading: () => const AsyncValue.loading(),
        error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
      );
    });

/// Selection-synced descriptor for the active asset detail surface.
///
/// Returns `null` data when selection is idle. Otherwise maps the current
/// [assetSelectionControllerProvider] assetId through the graph-backed
/// descriptor family so route, inspector, and selection stay coherent.
final selectedAssetDetailDescriptorProvider =
    Provider<AsyncValue<AssetDetailResult?>>((ref) {
      final selection = ref.watch(assetSelectionControllerProvider);
      final assetId = selection.assetId;
      if (assetId == null || assetId.isEmpty) {
        return const AsyncValue.data(null);
      }
      final detail = ref.watch(assetDetailDescriptorProvider(assetId));
      return detail.when(
        data: (result) => AsyncValue.data(result),
        loading: () => const AsyncValue.loading(),
        error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
      );
    });
