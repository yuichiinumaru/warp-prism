import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  Widget harness({
    required List<PrismViewPreset> presets,
    ValueChanged<PrismViewPreset>? onSelected,
    String? activePresetId,
    String? title = 'View Presets',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PrismViewPresets(
            presets: presets,
            onSelected: onSelected,
            activePresetId: activePresetId,
            title: title,
          ),
        ),
      ),
    );
  }

  group('PrismViewPresets', () {
    final testPresets = [
      const PrismViewPreset(
        id: 'p-1',
        name: 'Preset One',
        description: 'First test preset description',
        payload: {'zoom': 1.0},
      ),
      const PrismViewPreset(
        id: 'p-2',
        name: 'Preset Two',
        description: 'Second test preset description',
        payload: {'zoom': 2.0},
      ),
    ];

    testWidgets('renders grid tiles and title', (tester) async {
      await tester.pumpWidget(harness(presets: testPresets));

      expect(find.byType(PrismViewPresets), findsOneWidget);
      expect(find.text('View Presets'), findsOneWidget);
      expect(find.text('Preset One'), findsOneWidget);
      expect(find.text('Preset Two'), findsOneWidget);
      expect(find.text('First test preset description'), findsOneWidget);
      expect(find.text('Second test preset description'), findsOneWidget);
    });

    testWidgets('triggers callback when preset tile is tapped', (tester) async {
      PrismViewPreset? selected;
      await tester.pumpWidget(
        harness(presets: testPresets, onSelected: (p) => selected = p),
      );

      await tester.tap(find.text('Preset One'));
      await tester.pump();

      expect(selected, isNotNull);
      expect(selected!.id, 'p-1');
      expect(selected!.payload['zoom'], 1.0);
    });

    testWidgets('renders empty state when presets list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(harness(presets: []));

      // Uses DSStateSurface empty view
      expect(find.text('No Presets Available'), findsOneWidget);
      expect(find.text('Preset One'), findsNothing);
    });

    testWidgets('highlights active preset tile', (tester) async {
      await tester.pumpWidget(
        harness(presets: testPresets, activePresetId: 'p-2'),
      );

      final semantics = tester.getSemantics(
        find.bySemanticsLabel(RegExp('Preset: Preset Two.')),
      );
      expect(
        semantics.flagsCollection.isSelected.toString(),
        'Tristate.isTrue',
      );

      final otherSemantics = tester.getSemantics(
        find.bySemanticsLabel(RegExp('Preset: Preset One.')),
      );
      expect(
        otherSemantics.flagsCollection.isSelected.toString(),
        'Tristate.isFalse',
      );
    });

    testWidgets('verifies accessibility labels on preset tiles', (
      tester,
    ) async {
      await tester.pumpWidget(harness(presets: testPresets));

      final firstTile = tester.getSemantics(
        find.bySemanticsLabel(RegExp('Preset: Preset One.')),
      );
      expect(firstTile.flagsCollection.isButton, isTrue);
      expect(firstTile.label, contains('Preset: Preset One.'));
      expect(firstTile.label, contains('First test preset description'));
    });
  });
}
