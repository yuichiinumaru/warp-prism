import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1501: PrismMapHudWorkspace widget tests
///
/// Covers: default regions visible, hide chrome, restore chrome,
/// empty optional slots, stage never disposed on hide.
void main() {
  Widget harness({
    required Widget stage,
    Widget? leftHud,
    Widget? rightHud,
    Widget? bottomChrome,
    Widget? topChrome,
    bool? hudVisible,
    ValueChanged<bool>? onToggleHudVisibility,
    bool showHudToggle = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 1200,
          height: 800,
          child: PrismMapHudWorkspace(
            stage: stage,
            leftHud: leftHud,
            rightHud: rightHud,
            bottomChrome: bottomChrome,
            topChrome: topChrome,
            hudVisible: hudVisible,
            onToggleHudVisibility: onToggleHudVisibility,
            showHudToggle: showHudToggle,
          ),
        ),
      ),
    );
  }

  group('PrismMapHudWorkspace', () {
    testWidgets('renders stage and all provided HUD regions by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          stage: const Text('STAGE'),
          leftHud: const Text('LEFT'),
          rightHud: const Text('RIGHT'),
          bottomChrome: const Text('BOTTOM'),
          topChrome: const Text('TOP'),
        ),
      );

      expect(find.text('STAGE'), findsOneWidget);
      expect(find.text('LEFT'), findsOneWidget);
      expect(find.text('RIGHT'), findsOneWidget);
      expect(find.text('BOTTOM'), findsOneWidget);
      expect(find.text('TOP'), findsOneWidget);

      expect(find.byKey(PrismMapHudWorkspace.stageRegionKey), findsOneWidget);
      expect(find.byKey(PrismMapHudWorkspace.leftHudRegionKey), findsOneWidget);
      expect(
        find.byKey(PrismMapHudWorkspace.rightHudRegionKey),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismMapHudWorkspace.bottomChromeRegionKey),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismMapHudWorkspace.topChromeRegionKey),
        findsOneWidget,
      );
    });

    testWidgets('omits optional null slots without error', (tester) async {
      await tester.pumpWidget(harness(stage: const Text('STAGE_ONLY')));

      expect(find.text('STAGE_ONLY'), findsOneWidget);
      expect(find.byKey(PrismMapHudWorkspace.stageRegionKey), findsOneWidget);
      expect(find.byKey(PrismMapHudWorkspace.leftHudRegionKey), findsNothing);
      expect(find.byKey(PrismMapHudWorkspace.rightHudRegionKey), findsNothing);
      expect(
        find.byKey(PrismMapHudWorkspace.bottomChromeRegionKey),
        findsNothing,
      );
      expect(find.byKey(PrismMapHudWorkspace.topChromeRegionKey), findsNothing);
    });

    testWidgets('hide chrome removes HUD regions but keeps stage', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          stage: const Text('STAGE_PERSIST'),
          leftHud: const Text('LEFT'),
          rightHud: const Text('RIGHT'),
          bottomChrome: const Text('BOTTOM'),
          topChrome: const Text('TOP'),
        ),
      );

      expect(find.text('LEFT'), findsOneWidget);
      expect(find.byKey(PrismMapHudWorkspace.hudToggleKey), findsOneWidget);

      await tester.tap(find.byKey(PrismMapHudWorkspace.hudToggleKey));
      await tester.pumpAndSettle();

      expect(find.text('STAGE_PERSIST'), findsOneWidget);
      expect(find.byKey(PrismMapHudWorkspace.stageRegionKey), findsOneWidget);
      expect(find.text('LEFT'), findsNothing);
      expect(find.text('RIGHT'), findsNothing);
      expect(find.text('BOTTOM'), findsNothing);
      expect(find.text('TOP'), findsNothing);
      expect(find.byKey(PrismMapHudWorkspace.leftHudRegionKey), findsNothing);

      // Toggle label flips to restore after hide.
      final restoreHandle = tester.getSemantics(
        find.byKey(PrismMapHudWorkspace.hudToggleKey),
      );
      expect(restoreHandle.label, PrismMapHudWorkspace.restoreHudSemanticLabel);
    });

    testWidgets('restore chrome brings HUD regions back', (tester) async {
      await tester.pumpWidget(
        harness(
          stage: const Text('STAGE'),
          leftHud: const Text('LEFT'),
          rightHud: const Text('RIGHT'),
        ),
      );

      await tester.tap(find.byKey(PrismMapHudWorkspace.hudToggleKey));
      await tester.pumpAndSettle();
      expect(find.text('LEFT'), findsNothing);

      await tester.tap(find.byKey(PrismMapHudWorkspace.hudToggleKey));
      await tester.pumpAndSettle();

      expect(find.text('STAGE'), findsOneWidget);
      expect(find.text('LEFT'), findsOneWidget);
      expect(find.text('RIGHT'), findsOneWidget);

      final hideHandle = tester.getSemantics(
        find.byKey(PrismMapHudWorkspace.hudToggleKey),
      );
      expect(hideHandle.label, PrismMapHudWorkspace.hideHudSemanticLabel);
    });

    testWidgets('controlled hudVisible=false starts with chrome hidden', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          stage: const Text('STAGE'),
          leftHud: const Text('LEFT'),
          hudVisible: false,
        ),
      );

      expect(find.text('STAGE'), findsOneWidget);
      expect(find.text('LEFT'), findsNothing);
      final restoreHandle = tester.getSemantics(
        find.byKey(PrismMapHudWorkspace.hudToggleKey),
      );
      expect(restoreHandle.label, PrismMapHudWorkspace.restoreHudSemanticLabel);
    });

    testWidgets('onToggleHudVisibility reports next value', (tester) async {
      final values = <bool>[];
      await tester.pumpWidget(
        harness(
          stage: const Text('STAGE'),
          leftHud: const Text('LEFT'),
          onToggleHudVisibility: values.add,
        ),
      );

      await tester.tap(find.byKey(PrismMapHudWorkspace.hudToggleKey));
      await tester.pumpAndSettle();

      expect(values, equals([false]));
    });

    testWidgets('workspace and toggle have a11y labels', (tester) async {
      await tester.pumpWidget(
        harness(stage: const Text('STAGE'), leftHud: const Text('LEFT')),
      );

      expect(find.byKey(PrismMapHudWorkspace.hudToggleKey), findsOneWidget);

      final toggleHandle = tester.getSemantics(
        find.byKey(PrismMapHudWorkspace.hudToggleKey),
      );
      expect(toggleHandle.label, PrismMapHudWorkspace.hideHudSemanticLabel);
      expect(toggleHandle.flagsCollection.isButton, isTrue);

      // Workspace container label is present in the semantics tree.
      expect(
        tester.getSemantics(find.byType(PrismMapHudWorkspace)).label,
        contains(PrismMapHudWorkspace.workspaceSemanticLabel),
      );
    });

    testWidgets('public Prism alias constructs and mounts', (tester) async {
      await tester.pumpWidget(harness(stage: const SizedBox.shrink()));
      expect(find.byType(PrismMapHudWorkspace), findsOneWidget);
    });

    testWidgets('stage StatefulWidget survives hide/restore without remount', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          stage: const _StageSurvivalProbe(key: Key('stage-probe')),
          leftHud: const Text('LEFT'),
        ),
      );

      final state = tester.state<_StageSurvivalProbeState>(
        find.byKey(const Key('stage-probe')),
      );
      final mountCountBefore = state.mountCount;
      expect(find.text('STAGE_SURVIVE'), findsOneWidget);
      expect(mountCountBefore, 1);

      await tester.tap(find.byKey(PrismMapHudWorkspace.hudToggleKey));
      await tester.pumpAndSettle();
      expect(find.text('LEFT'), findsNothing);
      expect(find.text('STAGE_SURVIVE'), findsOneWidget);
      expect(state.mountCount, mountCountBefore);

      await tester.tap(find.byKey(PrismMapHudWorkspace.hudToggleKey));
      await tester.pumpAndSettle();
      expect(find.text('LEFT'), findsOneWidget);
      expect(find.text('STAGE_SURVIVE'), findsOneWidget);
      expect(
        state.mountCount,
        mountCountBefore,
        reason: 'stage State must not remount across hide/restore',
      );
    });
  });
}

/// Counts initState invocations so hide/restore stage survival is observable.
class _StageSurvivalProbe extends StatefulWidget {
  const _StageSurvivalProbe({super.key});

  @override
  State<_StageSurvivalProbe> createState() => _StageSurvivalProbeState();
}

class _StageSurvivalProbeState extends State<_StageSurvivalProbe> {
  int mountCount = 0;

  @override
  void initState() {
    super.initState();
    mountCount++;
  }

  @override
  Widget build(BuildContext context) => const Text('STAGE_SURVIVE');
}
