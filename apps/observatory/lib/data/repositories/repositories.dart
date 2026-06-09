/// Barrel export for the Warp-Prism repository layer.
///
/// The canonical interface is [WorkspaceRepository]. The mock-workspace
/// implementation is [MockWorkspaceRepository] which loads from
/// `assets/mock_workspace/`.
///
/// The history read model is [HistoryRepository] which provides a typed
/// timeline with filter facets and story-mode groupings.
library;

export 'workspace_repository.dart';
export 'workspace_load_state.dart';
export 'mock_workspace_repository.dart';
export 'history_repository.dart';
