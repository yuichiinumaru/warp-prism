import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1515: PrismOpsControlCluster widget tests
///
/// Covers: N launchers, callbacks, disabled state, a11y labels, fixtures.
void main() {
  List<PrismOpsLauncher> fixtureLaunchers() => List<PrismOpsLauncher>.from(
    PrismOpsControlClusterFixtures.defaultLaunchers,
  );

  Widget harness({
    List<PrismOpsLauncher>? launchers,
    ValueChanged<PrismOpsLauncher>? onLauncherActivated,
    String? selectedId,
    Axis direction = Axis.horizontal,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: PrismOpsControlCluster(
            launchers: launchers ?? fixtureLaunchers(),
            onLauncherActivated: onLauncherActivated,
            selectedId: selectedId,
            direction: direction,
          ),
        ),
      ),
    );
  }

  group('PrismOpsControlCluster', () {
    testWidgets('renders N launchers from fixture catalog', (tester) async {
      await tester.pumpWidget(harness());

      expect(find.byType(PrismOpsControlCluster), findsOneWidget);
      expect(
        find.byKey(PrismOpsControlCluster.clusterRegionKey),
        findsOneWidget,
      );

      const launchers = PrismOpsControlClusterFixtures.defaultLaunchers;
      expect(launchers.length, greaterThanOrEqualTo(3));
      for (final launcher in launchers) {
        expect(
          find.byKey(PrismOpsControlCluster.launcherKey(launcher.id)),
          findsOneWidget,
        );
      }
    });

    testWidgets('invokes callback when enabled launcher is tapped', (
      tester,
    ) async {
      PrismOpsLauncher? activated;
      await tester.pumpWidget(
        harness(onLauncherActivated: (l) => activated = l),
      );

      await tester.tap(
        find.byKey(PrismOpsControlCluster.launcherKey('console')),
      );
      await tester.pump();

      expect(activated, isNotNull);
      expect(activated!.id, 'console');
      expect(activated!.label, 'Console');
    });

    testWidgets('disabled launcher does not fire callback', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(
        harness(onLauncherActivated: (l) => events.add(l.id)),
      );

      await tester.tap(
        find.byKey(PrismOpsControlCluster.launcherKey('deploy')),
      );
      await tester.pump();

      expect(events, isEmpty);
    });

    testWidgets('minimal fixture exposes one enabled and one disabled', (
      tester,
    ) async {
      final events = <String>[];
      await tester.pumpWidget(
        harness(
          launchers: PrismOpsControlClusterFixtures.minimalLaunchers,
          onLauncherActivated: (l) => events.add(l.id),
        ),
      );

      expect(
        find.byKey(PrismOpsControlCluster.launcherKey('console')),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismOpsControlCluster.launcherKey('settings')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(PrismOpsControlCluster.launcherKey('settings')),
      );
      await tester.pump();
      expect(events, isEmpty);

      await tester.tap(
        find.byKey(PrismOpsControlCluster.launcherKey('console')),
      );
      await tester.pump();
      expect(events, equals(['console']));
    });

    testWidgets('keyboard activate works for enabled launcher', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(
        harness(onLauncherActivated: (l) => events.add(l.id)),
      );

      final focus = tester
          .widgetList<Focus>(find.byType(Focus))
          .cast<Focus>()
          .where((f) => f.focusNode?.debugLabel == 'ops-launcher-console')
          .first;
      focus.focusNode!.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(events, equals(['console']));
    });

    testWidgets('exposes a11y labels on cluster and launchers', (tester) async {
      await tester.pumpWidget(harness(selectedId: 'console'));

      expect(
        tester.getSemantics(find.byType(PrismOpsControlCluster)).label,
        contains('Ops control cluster'),
      );

      final consoleNode = tester.getSemantics(
        find.byKey(PrismOpsControlCluster.launcherKey('console')),
      );
      expect(consoleNode.label, contains('Console'));
      expect(consoleNode.label, contains('selected'));

      final deployNode = tester.getSemantics(
        find.byKey(PrismOpsControlCluster.launcherKey('deploy')),
      );
      expect(deployNode.label, contains('Deploy'));
      expect(deployNode.label, contains('disabled'));
      expect(deployNode.flagsCollection.isButton, isTrue);

      final alertsNode = tester.getSemantics(
        find.byKey(PrismOpsControlCluster.launcherKey('alerts')),
      );
      expect(alertsNode.label, contains('Alerts'));
      expect(alertsNode.label, contains('2 notifications'));
    });

    testWidgets('empty launchers list still renders cluster region', (
      tester,
    ) async {
      await tester.pumpWidget(harness(launchers: const []));

      expect(
        find.byKey(PrismOpsControlCluster.clusterRegionKey),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismOpsControlCluster.launcherKey('console')),
        findsNothing,
      );
    });

    testWidgets('vertical direction lays out without throwing', (tester) async {
      await tester.pumpWidget(
        harness(
          launchers: PrismOpsControlClusterFixtures.minimalLaunchers,
          direction: Axis.vertical,
        ),
      );

      expect(find.byType(PrismOpsControlCluster), findsOneWidget);
      expect(
        find.byKey(PrismOpsControlCluster.launcherKey('console')),
        findsOneWidget,
      );
    });

    testWidgets('launcher hit targets are at least 48dp (including dense)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PrismOpsControlCluster(
                launchers: PrismOpsControlClusterFixtures.minimalLaunchers,
                dense: true,
              ),
            ),
          ),
        ),
      );

      for (final launcher in PrismOpsControlClusterFixtures.minimalLaunchers) {
        final size = tester.getSize(
          find.byKey(PrismOpsControlCluster.launcherKey(launcher.id)),
        );
        expect(
          size.width,
          greaterThanOrEqualTo(48.0),
          reason: '${launcher.id} width ${size.width} < 48',
        );
        expect(
          size.height,
          greaterThanOrEqualTo(48.0),
          reason: '${launcher.id} height ${size.height} < 48',
        );
      }
    });
  });

  group('PrismOpsLauncher model', () {
    test('copyWith and equality', () {
      const a = PrismOpsLauncher(
        id: 'x',
        icon: Icons.terminal_outlined,
        label: 'X',
        badgeCount: 1,
      );
      final b = a.copyWith(label: 'Y', clearBadgeCount: true);
      expect(b.label, 'Y');
      expect(b.badgeCount, isNull);
      expect(a == a.copyWith(), isTrue);
      expect(a.hasBadge, isTrue);
      expect(b.hasBadge, isFalse);
    });
  });
}
