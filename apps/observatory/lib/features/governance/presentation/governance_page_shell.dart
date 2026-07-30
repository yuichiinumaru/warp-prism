/// Governance workspace shell — wires Task 0314 providers into
/// [GovernanceOverviewPage].
///
/// Watches [workspaceGraphAsyncProvider] and
/// [workspaceDiagnosticsAsyncProvider], maps six-class canonicality
/// tallies + diagnostics into [CanonicalityBoundarySummary], and
/// handles loading/error like Overview/History shells.
///
/// Product route `/governance` must use this shell so the live surface
/// never permanently renders the empty state with a null summary.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/providers/workspace_providers.dart';
import 'package:warp_prism_observatory/data/services/workspace_diagnostics_service.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph.dart';
import '../../shell/shell_state_handler.dart';
import 'governance_overview_page.dart';
import 'widgets/governance_drilldown_controller.dart';

/// Builds [CanonicalityBoundarySummary] from Task 0314 graph + diagnostics.
///
/// Counts are tallied from each asset's [Canonicality] — never hardcoded
/// in the widget tree. Diagnostics attach as-is for issue panels,
/// fan-in, review pressure, and risk storytelling.
CanonicalityBoundarySummary buildCanonicalityBoundarySummary({
  required WorkspaceGraphResult graph,
  required List<GovernanceDiagnostic> diagnostics,
}) {
  final counts = <String, int>{for (final c in Canonicality.values) c.name: 0};
  for (final asset in graph.assetsById.values) {
    final key = asset.canonicality.name;
    counts[key] = (counts[key] ?? 0) + 1;
  }

  return CanonicalityBoundarySummary(
    counts: counts,
    totalAssets: graph.nodeCount,
    diagnostics: diagnostics,
  );
}

/// Governance page shell — loads graph + diagnostics and hosts the surface.
class GovernancePageShell extends ConsumerWidget {
  /// Optional pre-built summary for widget tests (skips provider watches).
  final CanonicalityBoundarySummary? forcedSummary;

  /// Optional forced error message for widget tests.
  final String? forcedError;

  /// When true, renders the loading surface regardless of provider state.
  final bool forceLoading;

  /// Optional drill-down override (tests / custom hosts).
  final void Function(GovernanceDrilldownTarget target)? onDrilldown;

  const GovernancePageShell({
    super.key,
    this.forcedSummary,
    this.forcedError,
    this.forceLoading = false,
    this.onDrilldown,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (forceLoading) {
      return ShellStateHandler.buildLoading(
        title: 'Loading governance...',
        subtitle: 'Computing boundary metrics and diagnostics',
      );
    }

    if (forcedError != null) {
      return ShellStateHandler.buildError(
        title: 'Failed to load governance',
        errorMessage: forcedError!,
      );
    }

    if (forcedSummary != null) {
      return GovernanceOverviewPage(
        summary: forcedSummary,
        onDrilldown: onDrilldown,
      );
    }

    final graphAsync = ref.watch(workspaceGraphAsyncProvider);
    final diagnosticsAsync = ref.watch(workspaceDiagnosticsAsyncProvider);

    if (graphAsync.isLoading || diagnosticsAsync.isLoading) {
      return ShellStateHandler.buildLoading(
        title: 'Loading governance...',
        subtitle: 'Computing boundary metrics and diagnostics',
      );
    }

    if (graphAsync.hasError) {
      return ShellStateHandler.buildError(
        title: 'Failed to load governance',
        errorMessage: graphAsync.error.toString(),
        onRetry: () {
          ref.invalidate(workspaceGraphAsyncProvider);
          ref.invalidate(workspaceDiagnosticsAsyncProvider);
        },
      );
    }

    if (diagnosticsAsync.hasError) {
      return ShellStateHandler.buildError(
        title: 'Failed to load governance diagnostics',
        errorMessage: diagnosticsAsync.error.toString(),
        onRetry: () {
          ref.invalidate(workspaceDiagnosticsAsyncProvider);
        },
      );
    }

    final graph = graphAsync.requireValue;
    final report =
        diagnosticsAsync.asData?.value ?? const DiagnosticsReport.empty();
    final summary = buildCanonicalityBoundarySummary(
      graph: graph,
      diagnostics: report.diagnostics,
    );

    return GovernanceOverviewPage(summary: summary, onDrilldown: onDrilldown);
  }
}
