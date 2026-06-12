/// Provider for the Map workspace feature.
///
/// Manages [MapWorkspaceState] mutations and exposes a stream of
/// state changes for the page to consume. The provider is designed
/// to be testable: it accepts initial state and does not depend on
/// Flutter or the filesystem.
///
/// The catalog extension adds methods for loading asset data,
/// updating search queries, toggling filters, and clearing all
/// filters. Follow-up tasks (graph, inspector) can extend this
/// provider by adding methods that mutate [MapWorkspaceState] and
/// push new values through [stateStream].
library;

import 'dart:async';
import '../../data/models/workspace_graph.dart';
import 'map_workspace_state.dart';
import 'graph/map_graph_mode.dart';

/// Manages Map workspace state and notifies listeners of changes.
///
/// Usage:
/// ```dart
/// final provider = MapWorkspaceProvider();
/// provider.changeSubview(MapSubview.skills);
/// provider.updateQuery('harness');
/// provider.loadAssets(assets);
/// ```
class MapWorkspaceProvider {
  /// Current state snapshot.
  MapWorkspaceState _state;

  /// Stream controller for state changes.
  final _controller = StreamController<MapWorkspaceState>.broadcast();

  MapWorkspaceProvider({MapWorkspaceState? initialState})
    : _state = initialState ?? const MapWorkspaceState();

  /// Current state (synchronous access).
  MapWorkspaceState get state => _state;

  /// Stream of state changes.
  Stream<MapWorkspaceState> get stateStream => _controller.stream;

  /// Change the active subview/tab.
  void changeSubview(MapSubview subview) {
    if (_state.activeSubview == subview) return;
    _emit(
      _state.copyWith(
        activeSubview: subview,
        clearSelectedAsset: true,
        clearError: true,
      ),
    );
  }

  /// Update the search query.
  void updateQuery(String query) {
    _emit(_state.copyWith(query: query));
  }

  /// Toggle a filter tag.
  void toggleFilter(String filter) {
    final next = Set<String>.from(_state.activeFilters);
    if (next.contains(filter)) {
      next.remove(filter);
    } else {
      next.add(filter);
    }
    _emit(_state.copyWith(activeFilters: next));
  }

  /// Clear all filters.
  void clearFilters() {
    _emit(_state.copyWith(activeFilters: const {}, query: ''));
  }

  /// Select an asset by id.
  void selectAsset(String assetId) {
    _emit(_state.copyWith(selectedAssetId: assetId));
  }

  /// Deselect the current asset.
  void deselectAsset() {
    _emit(_state.copyWith(clearSelectedAsset: true));
  }

  /// Set loading state.
  void setLoading(bool loading) {
    _emit(_state.copyWith(isLoading: loading));
  }

  /// Set error state.
  void setError(String error) {
    _emit(_state.copyWith(error: error));
  }

  /// Clear error state.
  void clearError() {
    _emit(_state.copyWith(clearError: true));
  }

  /// Change the active graph mode for the Graph subview.
  void changeGraphMode(MapGraphMode mode) {
    if (_state.activeGraphMode == mode) return;
    _emit(_state.copyWith(activeGraphMode: mode));
  }

  /// Load catalog assets into the state.
  ///
  /// This replaces the entire asset collection. The provider does
  /// not own the data source — assets are injected from outside.
  void loadAssets(List<WorkspaceAsset> assets) {
    _emit(
      _state.copyWith(
        catalogAssets: assets,
        isLoading: false,
        clearError: true,
      ),
    );
  }

  /// Update additional state (extension point for follow-up tasks).
  void updateAdditionalState(Map<String, dynamic> additional) {
    _emit(
      _state.copyWith(
        additionalState: {..._state.additionalState, ...additional},
      ),
    );
  }

  void _emit(MapWorkspaceState next) {
    _state = next;
    _controller.add(next);
  }

  /// Dispose of the stream controller.
  void dispose() {
    _controller.close();
  }
}
