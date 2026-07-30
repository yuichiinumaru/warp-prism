import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1503: PrismLayerControlPanel widget tests
///
/// Covers: group render, per-layer toggle, master toggle, empty groups,
/// disabled layer, consent gate, freshness/counts, a11y labels.
void main() {
  List<PrismLayerGroup> fixtureGroups({
    bool withConsent = true,
    bool withDisabled = true,
  }) {
    return [
      const PrismLayerGroup(
        id: 'base',
        label: 'Base map',
        layers: [
          PrismLayerItem(
            id: 'basemap',
            label: 'Basemap',
            enabled: true,
            count: 1,
            freshness: PrismLayerFreshness.live,
            freshnessLabel: 'live',
          ),
          PrismLayerItem(
            id: 'labels',
            label: 'Labels',
            enabled: false,
            count: 12,
            freshness: PrismLayerFreshness.recent,
            freshnessLabel: '2m ago',
          ),
        ],
      ),
      PrismLayerGroup(
        id: 'feeds',
        label: 'Feeds',
        layers: [
          const PrismLayerItem(
            id: 'agents',
            label: 'Agents',
            enabled: true,
            count: 24,
            freshness: PrismLayerFreshness.aging,
            freshnessLabel: '18m ago',
          ),
          if (withConsent)
            const PrismLayerItem(
              id: 'pii',
              label: 'PII overlay',
              enabled: false,
              requiresConsent: true,
              count: 3,
            ),
          if (withDisabled)
            const PrismLayerItem(
              id: 'archived',
              label: 'Archived',
              enabled: false,
              disabled: true,
              count: 0,
            ),
        ],
      ),
      const PrismLayerGroup(id: 'empty', label: 'Empty group', layers: []),
    ];
  }

  Widget harness({
    List<PrismLayerGroup>? groups,
    Set<String>? enabledLayerIds,
    void Function(String layerId, bool enabled)? onLayerChanged,
    ValueChanged<bool>? onMasterToggle,
    ValueChanged<String>? onConsentRequired,
    ValueChanged<Set<String>>? onEnabledLayersChanged,
    bool showMasterToggle = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 360,
          height: 640,
          child: PrismLayerControlPanel(
            groups: groups ?? fixtureGroups(),
            enabledLayerIds: enabledLayerIds,
            onLayerChanged: onLayerChanged,
            onMasterToggle: onMasterToggle,
            onConsentRequired: onConsentRequired,
            onEnabledLayersChanged: onEnabledLayersChanged,
            showMasterToggle: showMasterToggle,
          ),
        ),
      ),
    );
  }

  group('PrismLayerControlPanel', () {
    testWidgets('renders groups and layer rows with counts/freshness', (
      tester,
    ) async {
      await tester.pumpWidget(harness());

      expect(find.byType(PrismLayerControlPanel), findsOneWidget);
      expect(find.byKey(PrismLayerControlPanel.panelRegionKey), findsOneWidget);
      expect(find.text('Layers'), findsOneWidget);
      expect(find.text('Base map'), findsOneWidget);
      expect(find.text('Feeds'), findsOneWidget);
      expect(find.text('Basemap'), findsOneWidget);
      expect(find.text('Labels'), findsOneWidget);
      expect(find.text('Agents'), findsOneWidget);
      expect(find.text('live'), findsOneWidget);
      expect(find.text('2m ago'), findsOneWidget);
      // Count badges render numeric labels.
      expect(find.text('24'), findsWidgets);
      expect(
        find.byKey(PrismLayerControlPanel.layerRowKey('basemap')),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismLayerControlPanel.layerToggleKey('labels')),
        findsOneWidget,
      );
    });

    testWidgets('toggles a layer on and reports callbacks', (tester) async {
      final changes = <(String, bool)>[];
      Set<String>? lastSet;

      await tester.pumpWidget(
        harness(
          onLayerChanged: (id, enabled) => changes.add((id, enabled)),
          onEnabledLayersChanged: (ids) => lastSet = ids,
        ),
      );

      // Labels starts off.
      await tester.tap(
        find.byKey(PrismLayerControlPanel.layerToggleKey('labels')),
      );
      // Avoid pumpAndSettle: live freshness dots use repeating animation.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(changes, equals([('labels', true)]));
      expect(lastSet, containsAll(['basemap', 'agents', 'labels']));
    });

    testWidgets('master toggle all-off then all-on', (tester) async {
      final masterEvents = <bool>[];
      final layerEvents = <(String, bool)>[];

      await tester.pumpWidget(
        harness(
          groups: fixtureGroups(withConsent: false, withDisabled: false),
          onMasterToggle: masterEvents.add,
          onLayerChanged: (id, enabled) => layerEvents.add((id, enabled)),
        ),
      );

      // Default: basemap + agents on → not all on → master value false-ish
      // (allEnabled is false because labels is off). Tap master → all-on.
      await tester.tap(find.byKey(PrismLayerControlPanel.masterToggleKey));
      // Avoid pumpAndSettle: live freshness dots use repeating animation.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(masterEvents, equals([true]));
      expect(layerEvents, contains(('labels', true)));

      // All on now — master toggle → all off.
      await tester.tap(find.byKey(PrismLayerControlPanel.masterToggleKey));
      // Avoid pumpAndSettle: live freshness dots use repeating animation.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(masterEvents, equals([true, false]));
      expect(layerEvents.where((e) => e.$2 == false).length, greaterThan(0));
    });

    testWidgets('empty groups list shows placeholder', (tester) async {
      await tester.pumpWidget(harness(groups: const []));

      expect(
        find.byKey(PrismLayerControlPanel.emptyPlaceholderKey),
        findsOneWidget,
      );
      expect(find.text('No layers'), findsOneWidget);
      expect(find.byKey(PrismLayerControlPanel.masterToggleKey), findsNothing);
    });

    testWidgets('empty group section shows empty-group hint when expanded', (
      tester,
    ) async {
      await tester.pumpWidget(harness());

      expect(find.text('Empty group'), findsOneWidget);
      // initiallyExpanded defaults true → empty hint visible.
      expect(find.text('No layers in group'), findsOneWidget);
    });

    testWidgets('disabled layer does not toggle', (tester) async {
      final changes = <(String, bool)>[];
      await tester.pumpWidget(
        harness(onLayerChanged: (id, enabled) => changes.add((id, enabled))),
      );

      await tester.tap(
        find.byKey(PrismLayerControlPanel.layerToggleKey('archived')),
      );
      // Avoid pumpAndSettle: live freshness dots use repeating animation.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(changes, isEmpty);
    });

    testWidgets('consent-gated layer fires onConsentRequired, stays off', (
      tester,
    ) async {
      final consent = <String>[];
      final changes = <(String, bool)>[];

      await tester.pumpWidget(
        harness(
          onConsentRequired: consent.add,
          onLayerChanged: (id, enabled) => changes.add((id, enabled)),
        ),
      );

      await tester.tap(
        find.byKey(PrismLayerControlPanel.layerToggleKey('pii')),
      );
      // Avoid pumpAndSettle: live freshness dots use repeating animation.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(consent, equals(['pii']));
      expect(changes, isEmpty);

      // Consent chip visible.
      expect(find.text('Consent'), findsOneWidget);
    });

    testWidgets('turning off consent layer does not re-request consent', (
      tester,
    ) async {
      final consent = <String>[];
      final changes = <(String, bool)>[];

      // Controlled: start with pii enabled.
      await tester.pumpWidget(
        harness(
          enabledLayerIds: {'basemap', 'agents', 'pii'},
          onConsentRequired: consent.add,
          onLayerChanged: (id, enabled) => changes.add((id, enabled)),
        ),
      );

      await tester.tap(
        find.byKey(PrismLayerControlPanel.layerToggleKey('pii')),
      );
      // Avoid pumpAndSettle: live freshness dots use repeating animation.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(consent, isEmpty);
      expect(changes, equals([('pii', false)]));
    });

    testWidgets('master all-on requests consent for gated off layers', (
      tester,
    ) async {
      final consent = <String>[];
      final master = <bool>[];

      await tester.pumpWidget(
        harness(
          groups: [
            const PrismLayerGroup(
              id: 'g',
              label: 'G',
              layers: [
                PrismLayerItem(id: 'a', label: 'A', enabled: false),
                PrismLayerItem(
                  id: 'c',
                  label: 'Consent layer',
                  enabled: false,
                  requiresConsent: true,
                ),
              ],
            ),
          ],
          onConsentRequired: consent.add,
          onMasterToggle: master.add,
        ),
      );

      await tester.tap(find.byKey(PrismLayerControlPanel.masterToggleKey));
      // Avoid pumpAndSettle: live freshness dots use repeating animation.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(master, equals([true]));
      expect(consent, equals(['c']));
    });

    testWidgets('collapsing a group hides its layer rows', (tester) async {
      await tester.pumpWidget(harness());

      expect(find.text('Basemap'), findsOneWidget);

      await tester.tap(
        find.byKey(PrismLayerControlPanel.groupHeaderKey('base')),
      );
      // Avoid pumpAndSettle: live freshness dots use repeating animation.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Basemap'), findsNothing);
      expect(find.text('Labels'), findsNothing);
    });

    testWidgets('layer toggles expose Semantics labels', (tester) async {
      await tester.pumpWidget(harness());

      final labelsHandle = tester.getSemantics(
        find.byKey(PrismLayerControlPanel.layerToggleKey('labels')),
      );
      expect(
        labelsHandle.label,
        PrismLayerControlPanel.layerToggleSemanticLabel(
          'Labels',
          enabled: false,
          disabled: false,
          requiresConsent: false,
        ),
      );
      expect(labelsHandle.flagsCollection.isButton, isTrue);

      final piiHandle = tester.getSemantics(
        find.byKey(PrismLayerControlPanel.layerToggleKey('pii')),
      );
      expect(
        piiHandle.label,
        PrismLayerControlPanel.layerToggleSemanticLabel(
          'PII overlay',
          enabled: false,
          disabled: false,
          requiresConsent: true,
        ),
      );

      final masterHandle = tester.getSemantics(
        find.byKey(PrismLayerControlPanel.masterToggleKey),
      );
      expect(
        masterHandle.label,
        PrismLayerControlPanel.masterSemanticLabel(allEnabled: false),
      );

      expect(
        tester.getSemantics(find.byType(PrismLayerControlPanel)).label,
        contains('Layer control panel'),
      );
    });

    testWidgets('public Prism aliases construct and mount', (tester) async {
      await tester.pumpWidget(harness());
      expect(find.byType(PrismLayerControlPanel), findsOneWidget);

      // typedef identity — Prism* names resolve to implementation types.
      const item = PrismLayerItem(id: 'x', label: 'X');
      const group = PrismLayerGroup(id: 'g', label: 'G', layers: [item]);
      expect(item, isA<PrismLayerItem>());
      expect(group, isA<PrismLayerGroup>());
      expect(PrismLayerFreshness.live, isNotNull);
    });
  });
}
