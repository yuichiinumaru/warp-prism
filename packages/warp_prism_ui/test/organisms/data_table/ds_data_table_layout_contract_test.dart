import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  const sampleColumns = <PrismDataColumn>[
    PrismDataColumn(id: 'name', label: 'Name', sortable: true),
    PrismDataColumn(
      id: 'provider',
      label: 'Provider',
      sortable: true,
      width: 140,
    ),
    PrismDataColumn(id: 'status', label: 'Status', width: 120),
  ];

  final sampleRows = [
    const PrismDataRow(
      id: '1',
      cells: {
        'name': 'OpenAI Production',
        'provider': 'openai',
        'status': 'healthy',
      },
    ),
    const PrismDataRow(
      id: '2',
      cells: {
        'name': 'Anthropic Secondary',
        'provider': 'anthropic',
        'status': 'degraded',
      },
    ),
  ];

  group('DSDataTable Layout Contract & Constraint Regressions', () {
    List<String> setupStrictOverflowFailure(WidgetTester tester) {
      final overflowErrors = <String>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        final message = details.exceptionAsString();
        if (message.contains('overflow') || message.contains('RenderFlex')) {
          overflowErrors.add(message);
        }
        originalOnError?.call(details);
      };
      addTearDown(() {
        FlutterError.onError = originalOnError;
        expect(
          overflowErrors,
          isEmpty,
          reason: 'RenderFlex overflow detected:\n${overflowErrors.join('\n')}',
        );
      });
      return overflowErrors;
    }

    testWidgets(
      'renders without RenderFlex overflow under real CyberCore constraint (w=958, h=50)',
      (tester) async {
        setupStrictOverflowFailure(tester);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 958,
                height: 50,
                child: PrismDataTable(
                  columns: sampleColumns,
                  rows: sampleRows,
                  showPagination: false,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(PrismDataTable), findsOneWidget);
        expect(find.text('Name'), findsOneWidget);
      },
    );

    testWidgets(
      'renders empty state without RenderFlex overflow under h=50 constraint',
      (tester) async {
        setupStrictOverflowFailure(tester);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 958,
                height: 50,
                child: PrismDataTable(
                  columns: sampleColumns,
                  rows: [],
                  showPagination: false,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(PrismDataTable), findsOneWidget);
        expect(find.text('No data'), findsOneWidget);
      },
    );

    testWidgets(
      'renders loading skeleton without RenderFlex overflow under h=50 constraint',
      (tester) async {
        setupStrictOverflowFailure(tester);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 958,
                height: 50,
                child: PrismDataTable(
                  columns: sampleColumns,
                  loading: true,
                  showPagination: false,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(PrismDataTable), findsOneWidget);
      },
    );

    testWidgets(
      'renders error state without RenderFlex overflow under h=50 constraint',
      (tester) async {
        setupStrictOverflowFailure(tester);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 958,
                height: 50,
                child: PrismDataTable(
                  columns: sampleColumns,
                  errorMessage: 'Failed to load connections',
                  showPagination: false,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(PrismDataTable), findsOneWidget);
        expect(find.text('Failed to load data'), findsOneWidget);
      },
    );

    testWidgets('holds under h=50 constraint at 1280x800 capture viewport', (
      tester,
    ) async {
      setupStrictOverflowFailure(tester);
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 958,
              height: 50,
              child: PrismDataTable(
                columns: sampleColumns,
                rows: sampleRows,
                showPagination: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PrismDataTable), findsOneWidget);
    });

    testWidgets(
      'holds under h=50 constraint at 1920x1080 desktop viewport class',
      (tester) async {
        setupStrictOverflowFailure(tester);
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 1400,
                height: 50,
                child: PrismDataTable(
                  columns: sampleColumns,
                  rows: sampleRows,
                  showPagination: false,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(PrismDataTable), findsOneWidget);
      },
    );

    testWidgets(
      'handles extreme constraint h=25 with scrollable fallback without throwing RenderFlex error',
      (tester) async {
        setupStrictOverflowFailure(tester);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 958,
                height: 25,
                child: PrismDataTable(
                  columns: sampleColumns,
                  rows: sampleRows,
                  showPagination: false,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(PrismDataTable), findsOneWidget);
      },
    );
  });
}
