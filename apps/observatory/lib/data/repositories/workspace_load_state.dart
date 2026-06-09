/// Load state model for the workspace repository.
///
/// Explicitly models the three outcomes of a repository load operation:
/// success (with data), empty (no data found), and error (load failure).
/// This prevents UI code from inventing ad-hoc state distinctions.
library;

import 'package:flutter/foundation.dart';
import '../models/workspace_snapshot.dart';

/// The outcome state of a workspace repository load operation.
enum WorkspaceLoadStatus {
  /// Data was loaded successfully (may be empty or populated).
  success,

  /// The workspace root exists but contains no recognized assets.
  empty,

  /// The load operation failed due to missing directory, permission
  /// error, or unrecoverable parse failure.
  error,

  /// A load operation is in progress.
  loading,
}

/// Typed result of a workspace repository load operation.
///
/// Carries the snapshot on success, or an error message on failure.
/// UI code pattern-matches on [status] to render the correct state.
@immutable
class WorkspaceLoadState {
  /// The current load status.
  final WorkspaceLoadStatus status;

  /// The loaded snapshot (non-null when [status] is [WorkspaceLoadStatus.success]).
  final WorkspaceSnapshot? snapshot;

  /// Error message (non-null when [status] is [WorkspaceLoadStatus.error]).
  final String? errorMessage;

  /// The root path that was loaded.
  final String rootPath;

  const WorkspaceLoadState._({
    required this.status,
    required this.rootPath,
    this.snapshot,
    this.errorMessage,
  });

  /// Successful load with a populated or empty snapshot.
  const WorkspaceLoadState.success({
    required WorkspaceSnapshot snapshot,
    required String rootPath,
  }) : this._(
          status: WorkspaceLoadStatus.success,
          snapshot: snapshot,
          rootPath: rootPath,
        );

  /// The workspace root exists but contains no assets.
  const WorkspaceLoadState.empty({required String rootPath})
      : this._(
          status: WorkspaceLoadStatus.empty,
          rootPath: rootPath,
        );

  /// The load operation failed.
  const WorkspaceLoadState.error({
    required String message,
    required String rootPath,
  }) : this._(
          status: WorkspaceLoadStatus.error,
          errorMessage: message,
          rootPath: rootPath,
        );

  /// A load operation is in progress.
  const WorkspaceLoadState.loading({required String rootPath})
      : this._(
          status: WorkspaceLoadStatus.loading,
          rootPath: rootPath,
        );

  /// Whether the load was successful (with or without assets).
  bool get isSuccess =>
      status == WorkspaceLoadStatus.success ||
      status == WorkspaceLoadStatus.empty;

  /// Whether the load encountered an error.
  bool get isError => status == WorkspaceLoadStatus.error;

  /// Whether a load is in progress.
  bool get isLoading => status == WorkspaceLoadStatus.loading;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspaceLoadState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          rootPath == other.rootPath;

  @override
  int get hashCode => Object.hash(status, rootPath);

  @override
  String toString() => 'WorkspaceLoadState(${status.name}, root: $rootPath'
      '${errorMessage != null ? ', error: $errorMessage' : ''})';
}
