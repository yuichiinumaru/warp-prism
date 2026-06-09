/// Barrel export for the Warp-Prism data sources layer.
///
/// The canonical interface is [WorkspaceSource]. The filesystem-based
/// implementation is [PresetLocalWorkspaceSource] which scans a real
/// directory using `dart:io`.
library;

export 'workspace_source.dart';
export 'preset_local_workspace_source.dart';
