/// Abstract source interface for loading workspace data.
///
/// Implementations provide workspace data from different backends:
/// - [PresetLocalWorkspaceSource] scans a real filesystem directory.
/// - Mock or asset-bundle sources for testing and demo purposes.
///
/// The source contract is intentionally narrow: load a snapshot or fail.
/// No mutation, no streaming, no partial updates. This keeps the data
/// flow predictable and testable.
library;

import '../models/workspace_snapshot.dart';

/// A contract for loading a [WorkspaceSnapshot] from a data source.
///
/// Implementations must be stateless and side-effect-free. Each call to
/// [load] produces an independent snapshot without caching or mutation.
abstract class WorkspaceSource {
  /// Load a workspace snapshot from the given [rootPath].
  ///
  /// Returns a [WorkspaceSnapshot] on success. The snapshot may be
  /// empty (zero assets) if the source directory exists but contains
  /// no recognized assets.
  ///
  /// Throws [WorkspaceSourceException] on critical failures such as
  /// missing directories, permission errors, or unrecoverable parse
  /// failures.
  Future<WorkspaceSnapshot> load(String rootPath);
}

/// Exception thrown by [WorkspaceSource] implementations when loading fails.
class WorkspaceSourceException implements Exception {
  /// Human-readable error message.
  final String message;

  /// The root path that was being loaded when the failure occurred.
  final String? rootPath;

  /// The underlying cause, if any.
  final Object? cause;

  const WorkspaceSourceException(this.message, {this.rootPath, this.cause});

  @override
  String toString() =>
      'WorkspaceSourceException: $message'
      '${rootPath != null ? ' (root: $rootPath)' : ''}';
}
