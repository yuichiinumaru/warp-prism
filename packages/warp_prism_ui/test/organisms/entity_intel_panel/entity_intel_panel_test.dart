import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1505: PrismEntityIntelPanel widget tests
///
/// Covers: multi-type registry, body switch on selection change,
/// unknown type fallback, null selection empty state, pin/close a11y.
void main() {
  const agentBodyKey = Key('fixture-agent-body');
  const regionBodyKey = Key('fixture-region-body');

  Map<String, PrismEntityIntelBodyBuilder> registry() => {
    'agent': (context, selection) => KeyedSubtree(
      key: agentBodyKey,
      child: Text('Agent body: ${selection.title}'),
    ),
    'region': (context, selection) => KeyedSubtree(
      key: regionBodyKey,
      child: Text('Region body: ${selection.title}'),
    ),
  };

  Widget harness({
    PrismEntitySelection? selection,
    Map<String, PrismEntityIntelBodyBuilder>? bodyBuilders,
    List<PrismEntityIntelDossier>? dossiers,
    VoidCallback? onClose,
    ValueChanged<bool>? onPinChanged,
    bool pinned = false,
    bool showPin = false,
    bool wrapInGlass = true,
    bool composeDetailInspector = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 360,
          height: 520,
          child: PrismEntityIntelPanel(
            selection: selection,
            bodyBuilders: bodyBuilders ?? registry(),
            dossiers: dossiers ?? const [],
            onClose: onClose,
            onPinChanged: onPinChanged,
            pinned: pinned,
            showPin: showPin,
            wrapInGlass: wrapInGlass,
            composeDetailInspector: composeDetailInspector,
          ),
        ),
      ),
    );
  }

  group('PrismEntityIntelPanel', () {
    testWidgets('renders type A (agent) body from registry', (tester) async {
      await tester.pumpWidget(
        harness(selection: PrismEntityIntelFixtures.agent),
      );

      expect(find.byKey(PrismEntityIntelPanel.panelKey), findsOneWidget);
      expect(find.byKey(agentBodyKey), findsOneWidget);
      expect(find.byKey(regionBodyKey), findsNothing);
      expect(find.text('Agent body: recon-agent'), findsOneWidget);
      expect(find.byKey(PrismEntityIntelPanel.bodyKey), findsOneWidget);
      expect(find.byKey(PrismEntityIntelPanel.emptyStateKey), findsNothing);
      expect(find.byKey(PrismEntityIntelPanel.unknownStateKey), findsNothing);
    });

    testWidgets('renders type B (region) body from registry', (tester) async {
      await tester.pumpWidget(
        harness(selection: PrismEntityIntelFixtures.region),
      );

      expect(find.byKey(regionBodyKey), findsOneWidget);
      expect(find.byKey(agentBodyKey), findsNothing);
      expect(find.text('Region body: APAC · Southeast'), findsOneWidget);
    });

    testWidgets('updates body when selection type changes', (tester) async {
      PrismEntitySelection? current = PrismEntityIntelFixtures.agent;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          current = PrismEntityIntelFixtures.region;
                        });
                      },
                      child: const Text('select-region'),
                    ),
                    Expanded(
                      child: PrismEntityIntelPanel(
                        selection: current,
                        bodyBuilders: registry(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      expect(find.byKey(agentBodyKey), findsOneWidget);

      await tester.tap(find.text('select-region'));
      await tester.pump();

      expect(find.byKey(agentBodyKey), findsNothing);
      expect(find.byKey(regionBodyKey), findsOneWidget);
    });

    testWidgets('null selection shows empty state', (tester) async {
      await tester.pumpWidget(harness(selection: null));

      expect(find.byKey(PrismEntityIntelPanel.emptyStateKey), findsOneWidget);
      expect(find.byKey(PrismEntityIntelPanel.bodyKey), findsNothing);
      expect(find.byKey(agentBodyKey), findsNothing);
      expect(find.text('No selection'), findsOneWidget);
    });

    testWidgets('unknown type shows unknown fallback', (tester) async {
      const unknown = PrismEntitySelection(
        id: 'x-1',
        type: 'satellite',
        title: 'SAT-9',
        subtitle: 'Unregistered type fixture',
      );

      await tester.pumpWidget(harness(selection: unknown));

      expect(find.byKey(PrismEntityIntelPanel.unknownStateKey), findsOneWidget);
      expect(find.byKey(PrismEntityIntelPanel.bodyKey), findsNothing);
      expect(find.text('Unknown type'), findsOneWidget);
      expect(find.textContaining('satellite'), findsWidgets);
      expect(find.text('SAT-9'), findsOneWidget);
    });

    testWidgets('rich dossiers override bodyBuilders on key clash', (
      tester,
    ) async {
      final dossiers = [
        PrismEntityIntelDossier(
          type: 'agent',
          label: 'Agent',
          builder: (context, selection) =>
              const Text('Rich agent dossier body'),
        ),
      ];

      await tester.pumpWidget(
        harness(
          selection: PrismEntityIntelFixtures.agent,
          bodyBuilders: registry(),
          dossiers: dossiers,
        ),
      );

      expect(find.text('Rich agent dossier body'), findsOneWidget);
      expect(find.byKey(agentBodyKey), findsNothing);
    });

    testWidgets('close and pin expose a11y labels', (tester) async {
      var closed = false;
      var pinned = false;

      await tester.pumpWidget(
        harness(
          selection: PrismEntityIntelFixtures.agent,
          onClose: () => closed = true,
          onPinChanged: (v) => pinned = v,
          pinned: false,
        ),
      );

      final closeHandle = tester.getSemantics(
        find.byKey(PrismEntityIntelPanel.closeButtonKey),
      );
      expect(closeHandle.label, PrismEntityIntelPanel.closeSemanticLabel);

      final pinHandle = tester.getSemantics(
        find.byKey(PrismEntityIntelPanel.pinButtonKey),
      );
      expect(pinHandle.label, PrismEntityIntelPanel.pinSemanticLabel);

      await tester.tap(find.byKey(PrismEntityIntelPanel.closeButtonKey));
      await tester.pump();
      expect(closed, isTrue);

      await tester.tap(find.byKey(PrismEntityIntelPanel.pinButtonKey));
      await tester.pump();
      expect(pinned, isTrue);
    });

    testWidgets('panel semantic label is present', (tester) async {
      await tester.pumpWidget(
        harness(selection: PrismEntityIntelFixtures.agent),
      );

      final panel = tester.getSemantics(
        find.byKey(PrismEntityIntelPanel.panelKey),
      );
      expect(panel.label, contains(PrismEntityIntelPanel.panelSemanticLabel));
    });

    testWidgets('composeDetailInspector hosts body in PrismDetailInspector', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          selection: PrismEntityIntelFixtures.agent,
          composeDetailInspector: true,
          wrapInGlass: false,
        ),
      );

      expect(find.byType(PrismDetailInspector), findsOneWidget);
      expect(find.byKey(agentBodyKey), findsOneWidget);
      expect(find.text('Dossier'), findsOneWidget);
    });

    testWidgets('fixture sample builders render property rows', (tester) async {
      await tester.pumpWidget(
        harness(
          selection: PrismEntityIntelFixtures.agent,
          bodyBuilders: PrismEntityIntelFixtures.sampleBodyBuilders(),
        ),
      );

      expect(find.text('recon-agent'), findsOneWidget);
      expect(find.text('agent-recon-01'), findsOneWidget);
      expect(find.text('recon'), findsOneWidget);
    });

    testWidgets('public Prism* surface is non-null', (tester) async {
      expect(PrismEntityIntelPanel, isNotNull);
      expect(PrismEntitySelection, isNotNull);
      expect(PrismEntityIntelDossier, isNotNull);
      expect(PrismEntityIntelFixtures, isNotNull);
      expect(PrismEntityIntelPanel.panelKey, isNotNull);
      expect(PrismEntityIntelPanel.closeSemanticLabel, isNotEmpty);
    });

    testWidgets('close and pin buttons meet 48dp minimum touch target', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          selection: PrismEntityIntelFixtures.agent,
          onClose: () {},
          onPinChanged: (_) {},
          showPin: true,
        ),
      );

      final closeSize = tester.getSize(
        find.byKey(PrismEntityIntelPanel.closeButtonKey),
      );
      expect(closeSize.height, greaterThanOrEqualTo(kMinInteractiveDimension));
      expect(closeSize.width, greaterThanOrEqualTo(kMinInteractiveDimension));

      final pinSize = tester.getSize(
        find.byKey(PrismEntityIntelPanel.pinButtonKey),
      );
      expect(pinSize.height, greaterThanOrEqualTo(kMinInteractiveDimension));
      expect(pinSize.width, greaterThanOrEqualTo(kMinInteractiveDimension));
    });
  });
}
