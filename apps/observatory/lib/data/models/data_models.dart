/// Barrel export for the Warp-Prism data model layer.
///
/// The canonical backbone contract is in [workspace_graph.dart].
/// Kind-specific metadata lives in [task_contracts.dart],
/// [changelog_contracts.dart], and [governance_diagnostics.dart].
///
/// The legacy [models.dart] is retained for backward compatibility with
/// existing parsers but is superseded by the backbone contract. New code
/// should import from this barrel and target the normalized types.
library;

export 'workspace_graph.dart';
export 'workspace_snapshot.dart';
export 'task_contracts.dart';
export 'changelog_contracts.dart';
export 'governance_diagnostics.dart';
