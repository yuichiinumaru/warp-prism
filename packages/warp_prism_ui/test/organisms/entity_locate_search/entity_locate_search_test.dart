import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1506: PrismEntityLocateSearch widget tests
///
/// Covers: multi-corpus query, select/locate payload, clear, empty, loading,
/// a11y labels, and false-gap vs command palette (locate payload ≠ command id).
void main() {
  List<PrismLocateCorpus> fixtureCorpora() => const [
    PrismLocateCorpus(
      id: 'agents',
      label: 'Agents',
      icon: Icons.smart_toy_outlined,
      color: Color(0xFF00D4FF),
      entries: [
        PrismLocateEntry(
          id: 'agent-recon-01',
          label: 'recon-agent',
          sublabel: 'OSINT · healthy',
          entityType: 'agent',
          latitude: 37.7749,
          longitude: -122.4194,
          zoom: 12,
          searchText: 'recon scout osint',
        ),
        PrismLocateEntry(
          id: 'agent-ops-02',
          label: 'ops-orchestrator',
          sublabel: 'Operate · running',
          entityType: 'agent',
          latitude: 40.7128,
          longitude: -74.0060,
        ),
      ],
    ),
    PrismLocateCorpus(
      id: 'places',
      label: 'Places',
      icon: Icons.place_outlined,
      color: Color(0xFFFFB800),
      entries: [
        PrismLocateEntry(
          id: 'place-sf-hq',
          label: 'San Francisco Hub',
          sublabel: 'West coast node',
          entityType: 'place',
          latitude: 37.7749,
          longitude: -122.4194,
          searchText: 'california bay',
        ),
        PrismLocateEntry(
          id: 'place-lab-remote',
          label: 'Remote Lab',
          sublabel: 'No coords',
          entityType: 'place',
          searchText: 'sandbox',
        ),
      ],
    ),
  ];

  Widget harness({
    List<PrismLocateCorpus>? corpora,
    ValueChanged<PrismLocateResult>? onLocate,
    ValueChanged<String>? onQueryChanged,
    VoidCallback? onClear,
    String? query,
    String initialQuery = '',
    bool isLoading = false,
    Duration searchDelay = Duration.zero,
    Set<String>? activeCorpusIds,
    bool showCorpusChips = true,
    bool wrapInGlass = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 420,
          height: 520,
          child: PrismEntityLocateSearch(
            corpora: corpora ?? fixtureCorpora(),
            onLocate: onLocate,
            onQueryChanged: onQueryChanged,
            onClear: onClear,
            query: query,
            initialQuery: initialQuery,
            isLoading: isLoading,
            searchDelay: searchDelay,
            activeCorpusIds: activeCorpusIds,
            showCorpusChips: showCorpusChips,
            wrapInGlass: wrapInGlass,
          ),
        ),
      ),
    );
  }

  group('PrismEntityLocateSearch', () {
    test('matchResults queries across ≥2 corpora', () {
      final results = PrismEntityLocateSearch.matchResults(
        corpora: fixtureCorpora(),
        query: 'recon',
      );
      expect(results, isNotEmpty);
      expect(results.first.entityId, 'agent-recon-01');
      expect(results.first.corpusId, 'agents');
      expect(results.first.entityType, 'agent');
      expect(results.first.hasCoordinates, isTrue);

      final placeHits = PrismEntityLocateSearch.matchResults(
        corpora: fixtureCorpora(),
        query: 'francisco',
      );
      expect(placeHits, isNotEmpty);
      expect(placeHits.first.corpusId, 'places');
      expect(placeHits.first.entityType, 'place');

      // Shared token across both corpora
      final multi = PrismEntityLocateSearch.matchResults(
        corpora: fixtureCorpora(),
        query: '37', // not in haystack — use broader term
      );
      // latitude not in haystack by design; use search that spans corpora
      final hubAndAgent = PrismEntityLocateSearch.matchResults(
        corpora: fixtureCorpora(),
        query: 'a', // weak token — both labels match
        maxResults: 10,
      );
      final corpusIds = hubAndAgent.map((r) => r.corpusId).toSet();
      expect(corpusIds, containsAll(['agents', 'places']));
      expect(multi, isEmpty); // coords not indexed in match haystack
    });

    testWidgets('renders idle empty state and corpus chips', (tester) async {
      await tester.pumpWidget(harness());

      expect(find.byType(PrismEntityLocateSearch), findsOneWidget);
      expect(find.byKey(PrismEntityLocateSearch.panelKey), findsOneWidget);
      expect(
        find.byKey(PrismEntityLocateSearch.searchFieldKey),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismEntityLocateSearch.corpusChipsKey),
        findsOneWidget,
      );
      expect(find.byKey(PrismEntityLocateSearch.emptyStateKey), findsOneWidget);
      expect(find.text('Type to locate'), findsOneWidget);
      expect(find.text('Agents'), findsOneWidget);
      expect(find.text('Places'), findsOneWidget);
    });

    testWidgets('type query shows matching results from corpora', (
      tester,
    ) async {
      await tester.pumpWidget(harness());

      await tester.enterText(find.byType(TextField), 'recon');
      await tester.pumpAndSettle();

      expect(
        find.byKey(PrismEntityLocateSearch.resultsListKey),
        findsOneWidget,
      );
      expect(
        find.byKey(
          PrismEntityLocateSearch.resultRowKey('agents', 'agent-recon-01'),
        ),
        findsOneWidget,
      );
      expect(find.text('recon-agent'), findsOneWidget);
      expect(find.textContaining('RESULT'), findsOneWidget);
    });

    testWidgets('select result emits locate payload (not command id)', (
      tester,
    ) async {
      PrismLocateResult? located;

      await tester.pumpWidget(harness(onLocate: (r) => located = r));

      await tester.enterText(find.byType(TextField), 'francisco');
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(
          PrismEntityLocateSearch.resultRowKey('places', 'place-sf-hq'),
        ),
      );
      await tester.pumpAndSettle();

      expect(located, isNotNull);
      // Locate payload contract — entity/spatial, not command execution.
      expect(located!.entityId, 'place-sf-hq');
      expect(located!.entityType, 'place');
      expect(located!.corpusId, 'places');
      expect(located!.corpusLabel, 'Places');
      expect(located!.label, 'San Francisco Hub');
      expect(located!.latitude, 37.7749);
      expect(located!.longitude, -122.4194);
      expect(located!.hasCoordinates, isTrue);

      // Explicit false-gap: payload is PrismLocateResult, not PrismCommand.
      expect(located, isA<PrismLocateResult>());
      expect(located, isNot(isA<PrismCommand>()));
    });

    testWidgets('locate action button emits same payload', (tester) async {
      PrismLocateResult? located;

      await tester.pumpWidget(harness(onLocate: (r) => located = r));

      await tester.enterText(find.byType(TextField), 'ops');
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(
          PrismEntityLocateSearch.locateActionKey('agents', 'agent-ops-02'),
        ),
      );
      await tester.pumpAndSettle();

      expect(located, isNotNull);
      expect(located!.entityId, 'agent-ops-02');
      expect(located!.entityType, 'agent');
      expect(located!.corpusId, 'agents');
    });

    testWidgets('clear empties query and returns to idle', (tester) async {
      var clearCount = 0;
      String? lastQuery;

      await tester.pumpWidget(
        harness(
          onClear: () => clearCount++,
          onQueryChanged: (q) => lastQuery = q,
        ),
      );

      await tester.enterText(find.byType(TextField), 'recon');
      await tester.pumpAndSettle();
      expect(find.text('recon-agent'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Clear search query'));
      await tester.pumpAndSettle();

      expect(clearCount, 1);
      expect(lastQuery, '');
      expect(find.byKey(PrismEntityLocateSearch.emptyStateKey), findsOneWidget);
      expect(find.text('Type to locate'), findsOneWidget);
      expect(find.text('recon-agent'), findsNothing);
    });

    testWidgets('empty results for unmatched query', (tester) async {
      await tester.pumpWidget(harness());

      await tester.enterText(find.byType(TextField), 'zzzz-no-match');
      await tester.pumpAndSettle();

      expect(find.byKey(PrismEntityLocateSearch.emptyStateKey), findsOneWidget);
      expect(find.text('No matching entities'), findsOneWidget);
      expect(find.byKey(PrismEntityLocateSearch.resultsListKey), findsNothing);
    });

    testWidgets('loading state surfaces when isLoading', (tester) async {
      await tester.pumpWidget(harness(isLoading: true, initialQuery: 'recon'));

      expect(
        find.byKey(PrismEntityLocateSearch.loadingStateKey),
        findsOneWidget,
      );
      expect(find.text('Searching corpora…'), findsOneWidget);
      expect(find.byKey(PrismEntityLocateSearch.resultsListKey), findsNothing);
    });

    testWidgets('searchDelay shows loading then results', (tester) async {
      await tester.pumpWidget(
        harness(searchDelay: const Duration(milliseconds: 100)),
      );

      await tester.enterText(find.byType(TextField), 'recon');
      await tester.pump(); // start debounce

      expect(
        find.byKey(PrismEntityLocateSearch.loadingStateKey),
        findsOneWidget,
      );

      await tester.pump(const Duration(milliseconds: 120));
      await tester.pumpAndSettle();

      expect(find.text('recon-agent'), findsOneWidget);
      expect(find.byKey(PrismEntityLocateSearch.loadingStateKey), findsNothing);
    });

    testWidgets('active corpus filter limits results', (tester) async {
      await tester.pumpWidget(harness(activeCorpusIds: {'places'}));

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pumpAndSettle();

      // agents should not appear when only places is active
      expect(find.text('recon-agent'), findsNothing);
      expect(find.text('ops-orchestrator'), findsNothing);
      // places still match token "a"
      expect(
        find.byKey(
          PrismEntityLocateSearch.resultRowKey('places', 'place-sf-hq'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a11y labels on panel, search field, and results', (
      tester,
    ) async {
      await tester.pumpWidget(harness(initialQuery: 'recon'));
      // initialQuery applies immediately with zero delay
      await tester.pumpAndSettle();

      final panel = tester.getSemantics(
        find.byKey(PrismEntityLocateSearch.panelKey),
      );
      expect(panel.label, contains(PrismEntityLocateSearch.panelSemanticLabel));

      // DSSearchBar exposes placeholder as text field semantic label
      final field = tester.getSemantics(find.byType(TextField));
      expect(field.label, PrismEntityLocateSearch.searchFieldSemanticLabel);

      final rowFinder = find.byKey(
        PrismEntityLocateSearch.resultRowKey('agents', 'agent-recon-01'),
      );
      final row = tester.getSemantics(rowFinder);
      expect(row.label, contains('recon-agent'));
      expect(row.label, contains('Agents'));
      expect(row.flagsCollection.isButton, isTrue);

      // IconButton owns button semantics via tooltip (no nested ExcludeSemantics).
      final locateKey = PrismEntityLocateSearch.locateActionKey(
        'agents',
        'agent-recon-01',
      );
      expect(find.byKey(locateKey), findsOneWidget);
      expect(find.byTooltip('Locate recon-agent'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(r'Locate recon-agent')),
        findsOneWidget,
      );
    });

    testWidgets('result rows meet 48dp minimum touch target', (tester) async {
      await tester.pumpWidget(harness(initialQuery: 'recon'));
      await tester.pumpAndSettle();

      final rowFinder = find.byKey(
        PrismEntityLocateSearch.resultRowKey('agents', 'agent-recon-01'),
      );
      expect(rowFinder, findsOneWidget);
      final size = tester.getSize(rowFinder);
      expect(size.height, greaterThanOrEqualTo(kMinInteractiveDimension));
    });

    test('Prism* public models carry locate payload fields', () {
      const entry = PrismLocateEntry(
        id: 'e1',
        label: 'Entry',
        entityType: 'agent',
        latitude: 1.0,
        longitude: 2.0,
      );
      const corpus = PrismLocateCorpus(
        id: 'c1',
        label: 'Corpus',
        entries: [entry],
      );
      final result = PrismLocateResult.fromCorpusEntry(
        corpus: corpus,
        entry: entry,
      );
      expect(result.entityId, 'e1');
      expect(result.entityType, 'agent');
      expect(result.corpusId, 'c1');
      expect(result.hasCoordinates, isTrue);
      expect(result, isA<PrismLocateResult>());
      expect(result, isNot(isA<PrismCommand>()));
    });

    testWidgets('locate action IconButton handles keyboard activate intent', (
      tester,
    ) async {
      PrismLocateResult? located;
      await tester.pumpWidget(
        harness(onLocate: (r) => located = r, initialQuery: 'recon'),
      );
      await tester.pumpAndSettle();

      final locateKey = PrismEntityLocateSearch.locateActionKey(
        'agents',
        'agent-recon-01',
      );
      expect(find.byKey(locateKey), findsOneWidget);

      final element = tester.element(find.byKey(locateKey));
      Actions.maybeInvoke(element, const ActivateIntent());
      await tester.pumpAndSettle();

      expect(located, isNotNull);
      expect(located!.entityId, 'agent-recon-01');
    });
  });
}
