/// Path-to-100 residual (Task 0412): OverviewPageShell without forced* flags.
///
/// Proves AsyncValue loading → success/error/empty via repository overrides.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/app/pages/overview_page.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/workspace_snapshot.dart';
import 'package:warp_prism_observatory/data/providers/workspace_providers.dart';
import 'package:warp_prism_observatory/data/repositories/workspace_load_state.dart';
import 'package:warp_prism_observatory/data/services/workspace_diagnostics_service.dart';

void main() {
  Widget wrap({required List<Override> overrides}) {
    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: Scaffold(body: OverviewPageShell())),
    );
  }

  testWidgets('provider path shows loading then empty chrome', (tester) async {
    await tester.pumpWidget(
      wrap(
        overrides: [
          workspaceSnapshotAsyncProvider.overrideWith(
            () => _DelayedEmptySnapshotNotifier(),
          ),
          workspaceDiagnosticsAsyncProvider.overrideWith(
            () => _EmptyDiagnosticsNotifier(),
          ),
        ],
      ),
    );

    // First frame should show loading while the future is pending.
    expect(find.text('Loading workspace...'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('No Overview data'), findsOneWidget);
    expect(find.text('Totals'), findsNothing);
  });

  testWidgets('provider path shows success metrics from snapshot', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        overrides: [
          workspaceSnapshotAsyncProvider.overrideWith(
            () => _SuccessSnapshotNotifier(),
          ),
          workspaceDiagnosticsAsyncProvider.overrideWith(
            () => _EmptyDiagnosticsNotifier(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Totals'), findsOneWidget);
    expect(find.text('Agents'), findsOneWidget);
    expect(find.text('Current Story'), findsOneWidget);
  });

  testWidgets('provider path shows error surface', (tester) async {
    await tester.pumpWidget(
      wrap(
        overrides: [
          workspaceSnapshotAsyncProvider.overrideWith(
            () => _ErrorSnapshotNotifier(),
          ),
          workspaceDiagnosticsAsyncProvider.overrideWith(
            () => _EmptyDiagnosticsNotifier(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Failed to load workspace'), findsOneWidget);
    expect(find.textContaining('boom'), findsOneWidget);
    expect(find.text('Totals'), findsNothing);
  });
}

class _DelayedEmptySnapshotNotifier extends WorkspaceSnapshotAsyncNotifier {
  @override
  Future<WorkspaceLoadState> build() async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return const WorkspaceLoadState.empty(rootPath: 'test://empty');
  }
}

class _SuccessSnapshotNotifier extends WorkspaceSnapshotAsyncNotifier {
  @override
  Future<WorkspaceLoadState> build() async {
    return WorkspaceLoadState.success(
      rootPath: 'test://success',
      snapshot: WorkspaceSnapshot(
        agents: const [
          WorkspaceAsset(
            id: 'agent:a',
            kind: AssetKind.agent,
            name: 'Agent A',
            path: 'a.md',
          ),
        ],
        metadata: WorkspaceScanMetadata(
          rootPath: 'test://success',
          scannedAt: DateTime(2026, 7, 17),
        ),
      ),
    );
  }
}

class _ErrorSnapshotNotifier extends WorkspaceSnapshotAsyncNotifier {
  @override
  Future<WorkspaceLoadState> build() async {
    throw StateError('boom');
  }
}

class _EmptyDiagnosticsNotifier extends WorkspaceDiagnosticsAsyncNotifier {
  @override
  Future<DiagnosticsReport> build() async =>
      const DiagnosticsReport(diagnostics: []);
}
