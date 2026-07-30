/// Path-to-100 residual (Task 0410): production [appRouter] / [WarpPrismApp]
/// smoke — not the parallel bootstrap router used by shell smoke tests.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:warp_prism_observatory/app/app.dart';
import 'package:warp_prism_observatory/app/router.dart';
import 'package:warp_prism_observatory/data/providers/workspace_providers.dart';
import 'package:warp_prism_observatory/data/repositories/workspace_load_state.dart';
import 'package:warp_prism_observatory/data/services/workspace_diagnostics_service.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  setUp(() {
    // appRouter is a top-level singleton; reset location between tests.
    appRouter.go('/overview');
  });

  test('production appRouter route table exposes product surfaces', () {
    final paths = <String>{};
    void walk(List<RouteBase> routes) {
      for (final route in routes) {
        if (route is GoRoute && route.path.isNotEmpty) {
          paths.add(route.path);
        }
        walk(route.routes);
        if (route is StatefulShellRoute) {
          for (final branch in route.branches) {
            walk(branch.routes);
          }
        }
      }
    }

    walk(appRouter.configuration.routes);

    for (final path in const [
      '/overview',
      '/map',
      '/operate',
      '/history',
      '/governance',
      '/assets/:assetId',
      '/design-system',
    ]) {
      expect(paths, contains(path), reason: 'missing production route $path');
    }
    // initialLocation contract — currentConfiguration may be empty until pump.
    expect(appRouter.routeInformationProvider.value.uri.path, '/overview');
  });

  testWidgets(
    'production /assets/:assetId deep-link renders unresolved fallback',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workspaceSnapshotAsyncProvider.overrideWith(
              () => _EmptySnapshotNotifier(),
            ),
            workspaceDiagnosticsAsyncProvider.overrideWith(
              () => _EmptyDiagnosticsNotifier(),
            ),
            workspaceGraphAsyncProvider.overrideWith(
              () => _EmptyGraphNotifier(),
            ),
          ],
          child: const WarpPrismApp(),
        ),
      );
      await tester.pump();
      appRouter.go('/assets/unknown-asset');
      await tester.pumpAndSettle();

      expect(find.text('Asset not found'), findsOneWidget);
      expect(
        appRouter.routerDelegate.currentConfiguration.uri.path,
        contains('assets'),
      );
    },
  );

  testWidgets('WarpPrismApp boots on production router landing /overview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workspaceSnapshotAsyncProvider.overrideWith(
            () => _EmptySnapshotNotifier(),
          ),
          workspaceDiagnosticsAsyncProvider.overrideWith(
            () => _EmptyDiagnosticsNotifier(),
          ),
          workspaceGraphAsyncProvider.overrideWith(() => _EmptyGraphNotifier()),
        ],
        child: const WarpPrismApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(PrismShellResponsive), findsOneWidget);
    expect(find.text('Overview'), findsWidgets);
    expect(appRouter.routerDelegate.currentConfiguration.uri.path, '/overview');
  });
}

class _EmptySnapshotNotifier extends WorkspaceSnapshotAsyncNotifier {
  @override
  Future<WorkspaceLoadState> build() async =>
      const WorkspaceLoadState.empty(rootPath: 'test://empty');
}

class _EmptyDiagnosticsNotifier extends WorkspaceDiagnosticsAsyncNotifier {
  @override
  Future<DiagnosticsReport> build() async =>
      const DiagnosticsReport(diagnostics: []);
}

class _EmptyGraphNotifier extends WorkspaceGraphAsyncNotifier {
  @override
  Future<WorkspaceGraphResult> build() async =>
      const WorkspaceGraphResult.empty();
}
