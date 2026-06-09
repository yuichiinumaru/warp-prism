/// Read-only workspace repository interface.
///
/// Defines the contract for loading a [WorkspaceSnapshot] from a
/// configured data source. Implementations are strictly read-only:
/// they load, parse, and aggregate data without writing, repairing,
/// or mutating the underlying corpus.
///
/// The repository is the boundary between file/data storage and app
/// logic. Downstream consumers (graph services, UI providers, search)
/// should depend on this interface rather than accessing files directly.
library;

import 'workspace_load_state.dart';

/// Contract for loading a workspace snapshot from a data source.
///
/// Implementations:
/// - [MockWorkspaceRepository] loads from bundled `assets/mock_workspace/`.
/// - (Future) real repository loads from a live workspace directory.
abstract class WorkspaceRepository {
  /// The root path this repository loads from.
  String get rootPath;

  /// Load the workspace and return a typed [WorkspaceLoadState].
  ///
  /// The result carries the snapshot on success, or an error message
  /// on failure. Empty corpus (no recognized assets) returns
  /// [WorkspaceLoadState.empty] rather than an error.
  ///
  /// This method is read-only. It must not write, move, or repair
  /// any corpus files.
  Future<WorkspaceLoadState> load();
}
