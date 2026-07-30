/// History workspace shell — wires [historyTimelineAsyncProvider]
/// into [HistoryWorkspacePage].
///
/// Mirrors Map/Operate shell pattern: loading/error/empty from the
/// async provider, success maps [HistoryTimeline] → [HistoryState].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/workspace_providers.dart';
import '../../features/history/presentation/history_controller.dart';
import '../../features/history/presentation/history_page.dart';
import '../../features/shell/shell_state_handler.dart';

/// History page shell — loads the history timeline and hosts the surface.
class HistoryPageShell extends ConsumerWidget {
  /// Optional forced state for widget tests (skips provider watches).
  final HistoryState? forcedState;

  /// Optional forced error message for widget tests.
  final String? forcedError;

  /// When true, renders the loading surface regardless of provider state.
  final bool forceLoading;

  const HistoryPageShell({
    super.key,
    this.forcedState,
    this.forcedError,
    this.forceLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (forceLoading) {
      return const HistoryWorkspacePage(
        initialState: HistoryState(isLoading: true),
      );
    }

    if (forcedError != null) {
      return HistoryWorkspacePage(
        initialState: HistoryState(error: forcedError),
      );
    }

    if (forcedState != null) {
      return HistoryWorkspacePage(initialState: forcedState);
    }

    final timelineAsync = ref.watch(historyTimelineAsyncProvider);

    return timelineAsync.when(
      loading: () => const HistoryWorkspacePage(
        initialState: HistoryState(isLoading: true),
      ),
      error: (error, _) => HistoryWorkspacePage(
        initialState: HistoryState(error: error.toString()),
      ),
      data: (timeline) {
        if (timeline.isEmpty) {
          // Still render the workspace page with empty entries so filter
          // chrome and empty timeline state stay consistent.
          return HistoryWorkspacePage(
            initialState: HistoryState.fromTimeline(timeline),
          );
        }
        return HistoryWorkspacePage(
          initialState: HistoryState.fromTimeline(timeline),
        );
      },
    );
  }
}

/// Convenience re-export for shell-level empty/error when needed by tests.
Widget historyShellError({required String message, VoidCallback? onRetry}) {
  return ShellStateHandler.buildError(
    title: 'Failed to load history',
    errorMessage: message,
    onRetry: onRetry,
  );
}
