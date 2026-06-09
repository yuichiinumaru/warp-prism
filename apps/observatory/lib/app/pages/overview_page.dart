/// Overview dashboard — wired to the feature module.
///
/// This page demonstrates the shell-level state contract:
/// it shows loading → data → empty/error transitions using
/// [ShellStateHandler] for consistent fallback rendering.
///
/// The page simulates a load cycle (loading state → data) to prove
/// that the shell distinguishes loading from empty from error.
library;

import 'package:flutter/material.dart';
import '../../features/overview/overview.dart';
import '../../features/shell/shell_state_handler.dart';

/// Overview dashboard with shell-level state handling.
///
/// Demonstrates three distinct states:
/// 1. **Loading**: shown during initial data fetch
/// 2. **Data**: rendered by [OverviewPage] when metrics are available
/// 3. **Empty**: shown when workspace has no assets
/// 4. **Error**: shown when a load/parse failure occurs
class OverviewPageShell extends StatefulWidget {
  /// Pre-set load state for testing. When null, simulates a load cycle.
  final _ShellDemoState? forcedState;

  const OverviewPageShell({super.key, this.forcedState});

  @override
  State<OverviewPageShell> createState() => _OverviewPageShellState();
}

enum _ShellDemoState { loading, data, empty, error }

class _OverviewPageShellState extends State<OverviewPageShell> {
  static const _provider = OverviewProvider();

  _ShellDemoState _state = _ShellDemoState.loading;
  OverviewMetrics? _metrics;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.forcedState != null) {
      _state = widget.forcedState!;
      if (_state == _ShellDemoState.data) {
        _metrics = _provider.compute(assets: const []);
      }
    } else {
      _simulateLoad();
    }
  }

  /// Simulates an async load cycle to demonstrate state transitions.
  Future<void> _simulateLoad() async {
    setState(() => _state = _ShellDemoState.loading);

    // Simulate network/parse delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    // Compute metrics from empty data (workspace loader not yet wired).
    // This produces the "empty workspace" story from OverviewProvider.
    final metrics = _provider.compute(assets: const []);

    setState(() {
      _metrics = metrics;
      _state = metrics.totalAssets == 0
          ? _ShellDemoState.empty
          : _ShellDemoState.data;
    });
  }

  void _retry() {
    _simulateLoad();
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case _ShellDemoState.loading:
        return ShellStateHandler.buildLoading(
          title: 'Loading workspace...',
          subtitle: 'Parsing repository data and computing metrics',
        );

      case _ShellDemoState.empty:
        // Even when empty, we render OverviewPage with zero metrics
        // so the user sees the full dashboard structure with zeros.
        // The story panel communicates "no data" narratively.
        if (_metrics != null) {
          return OverviewPage(metrics: _metrics!);
        }
        return ShellStateHandler.buildEmpty(
          surfaceName: 'Overview',
          subtitle: 'Load mock workspace data to see derived metrics.',
        );

      case _ShellDemoState.data:
        return OverviewPage(metrics: _metrics!);

      case _ShellDemoState.error:
        return ShellStateHandler.buildError(
          title: 'Failed to load workspace',
          errorMessage: _errorMessage ?? 'An unexpected error occurred.',
          onRetry: _retry,
        );
    }
  }
}
