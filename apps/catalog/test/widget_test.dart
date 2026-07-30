/// Catalog contract tests — ADS proof surface.
///
/// Verifies that the Design System Gallery renders all registered sections,
/// has no duplicate section IDs (component/case ID uniqueness is delegated to
/// individual boundary tests), covers state matrices per atomic design layer,
/// and adapts to responsive breakpoints.
///
/// Task 1305: Catalog Contract Expansion
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_catalog/main.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Scroll the gallery [ListView] until [finder] is visible.
Future<void> _scrollUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxFlings = 50,
}) async {
  for (var i = 0; i < maxFlings; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.fling(
      find.byType(ListView).first,
      const Offset(0, -500),
      1000,
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Build the gallery inside a [MaterialApp].
Widget _buildGalleryInMaterial({TextScaler? textScaler}) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        final data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(textScaler: textScaler ?? data.textScaler),
          child: const Scaffold(body: DesignSystemGalleryPage()),
        );
      },
    ),
  );
}

void main() {
  group('Catalog app', () {
    testWidgets('renders gallery page without crashing', (tester) async {
      await tester.pumpWidget(const WarpPrismCatalogApp());
      expect(find.byType(WarpPrismCatalogApp), findsOneWidget);
    });
  });

  group('Gallery Registry proofs', () {
    testWidgets('all dsGallerySections render', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Render-without-crash proof: ignore layout overflow while scrolling
      // heavy gallery demos (high-scale test asserts overflowCount == 0).
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        final msg = details.exceptionAsString();
        if (msg.contains('overflow') ||
            msg.contains('RenderFlex') ||
            msg.contains('layout')) {
          return;
        }
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      await tester.pumpWidget(_buildGalleryInMaterial());
      await tester.pump();

      for (final title in dsGallerySectionTitles) {
        await _scrollUntilFound(tester, find.text(title));
        expect(
          find.text(title),
          findsWidgets,
          reason: 'Section $title should render',
        );
      }
    });

    testWidgets('no duplicate section IDs in registry', (tester) async {
      final ids = dsGallerySectionIds;
      final uniqueIds = ids.toSet();
      expect(
        ids.length,
        uniqueIds.length,
        reason: 'All section IDs must be unique',
      );
    });

    testWidgets(
      'catalog host scrolls to late EPIC-15 ops + terminal sections',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1400, 2400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          final msg = details.exceptionAsString();
          // Match gallery demo noise filter (dense EPIC-15 fixtures).
          if (msg.contains('overflow') ||
              msg.contains('RenderFlex') ||
              msg.contains('layout') ||
              msg.contains('ListTile background color') ||
              msg.contains('ink splashes may be invisible')) {
            return;
          }
          originalOnError?.call(details);
        };
        addTearDown(() => FlutterError.onError = originalOnError);

        await tester.pumpWidget(_buildGalleryInMaterial());
        await tester.pump();

        await _scrollUntilFound(tester, find.text('Ops Pack'));
        expect(find.text('Ops Pack'), findsWidgets);
        await _scrollUntilFound(
          tester,
          find.textContaining('PrismWorkspaceShareCard'),
        );
        expect(find.textContaining('PrismWorkspaceShareCard'), findsWidgets);
        expect(find.textContaining('PrismViewPresets'), findsWidgets);

        await _scrollUntilFound(tester, find.text('Terminal'));
        expect(find.text('Terminal'), findsWidgets);
        await _scrollUntilFound(
          tester,
          find.textContaining('PrismAgentShellPanel'),
        );
        expect(find.textContaining('PrismAgentShellPanel'), findsWidgets);
      },
    );

    testWidgets('high text scale test produces zero overflow exceptions', (
      tester,
    ) async {
      int overflowCount = 0;
      final unexpectedErrors = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        final message = details.exceptionAsString();
        if (message.contains('overflow') ||
            message.contains('RenderFlex') ||
            message.contains('layout')) {
          overflowCount++;
          return;
        }
        unexpectedErrors.add(details);
      };

      try {
        await tester.pumpWidget(
          _buildGalleryInMaterial(textScaler: const TextScaler.linear(2.0)),
        );
        await tester.pump();

        // Scroll through everything
        final listFinder = find.byType(ListView).first;
        for (var i = 0; i < 20; i++) {
          if (listFinder.evaluate().isEmpty) break;
          await tester.fling(listFinder, const Offset(0, -800), 1000);
          await tester.pump(const Duration(milliseconds: 50));
        }
      } finally {
        FlutterError.onError = originalOnError;
      }

      expect(
        unexpectedErrors,
        isEmpty,
        reason: 'High text scale must not hide unexpected Flutter errors',
      );
      expect(
        overflowCount,
        0,
        reason: 'High text scale must not cause layout overflows',
      );
    });
  });

  group('Responsive Layout proofs', () {
    testWidgets('compact geometry vs expanded geometry on PrismShellResponsive', (
      tester,
    ) async {
      // Create a testable responsive shell
      Widget buildShell() => const MaterialApp(
        home: PrismShellResponsive(
          sidebar: SizedBox(
            key: Key('expanded_sidebar'),
            width: PrismSpacing.sidebarExpanded,
          ),
          collapsedSidebar: SizedBox(
            key: Key('collapsed_sidebar'),
            width: PrismSpacing.sidebarCollapsed,
          ),
          content: SizedBox.expand(),
        ),
      );

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Expanded: >= 1200
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(buildShell());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('expanded_sidebar')), findsOneWidget);
      expect(find.byKey(const Key('collapsed_sidebar')), findsNothing);

      final expandedSize = tester.getSize(
        find.byKey(const Key('expanded_sidebar')),
      );

      // Compact: < 800
      tester.view.physicalSize = const Size(400, 900);
      await tester.pumpWidget(buildShell());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('expanded_sidebar')), findsNothing);
      // At < 600, PrismShellResponsive hides ALL sidebars entirely according to the contract,
      // let's use 700 to test the collapsed sidebar behavior (600-799 is narrow).
      tester.view.physicalSize = const Size(700, 900);
      await tester.pumpWidget(buildShell());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('collapsed_sidebar')), findsOneWidget);
      expect(find.byKey(const Key('expanded_sidebar')), findsNothing);

      final compactSize = tester.getSize(
        find.byKey(const Key('collapsed_sidebar')),
      );

      expect(
        expandedSize.width > compactSize.width,
        isTrue,
        reason:
            'Expanded sidebar width must be greater than compact sidebar width',
      );
    });
  });

  group('State Matrices (Task 1106 per layer)', () {
    testWidgets('Atom: PrismBadge covers visible states', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  PrismBadge(label: 'Default'),
                  // Real loading-capable atom/molecule (badge has no loading API).
                  SizedBox(
                    key: Key('atom-loading-skeleton'),
                    width: 120,
                    child: PrismSkeletonTextLine(widthFactor: 1.0),
                  ),
                  PrismBadge(label: 'Empty', variant: PrismBadgeVariant.dot),
                  PrismBadge(label: 'Error', color: PrismColors.statusError),
                  PrismBadge(
                    label: 'Disabled',
                    color: PrismColors.textDisabled,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Default'), findsOneWidget);
      expect(find.byKey(const Key('atom-loading-skeleton')), findsOneWidget);
      expect(find.byType(PrismSkeletonTextLine), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);
      // Empty uses dot variant; badge count is 4 (default/empty/error/disabled).
      expect(find.byType(PrismBadge), findsNWidgets(4));
    });

    testWidgets('Molecule: PrismStateSurface covers visible states', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  PrismStateSurface.empty(title: 'Empty State'),
                  PrismStateSurface.loading(title: 'Loading State'),
                  PrismStateSurface.error(title: 'Error State'),
                  PrismStateSurface.disabled(title: 'Disabled State'),
                  PrismStateSurface.degraded(title: 'Degraded State'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Empty State'), findsOneWidget);
      expect(find.text('Loading State'), findsOneWidget);
      expect(find.text('Error State'), findsOneWidget);
      expect(find.text('Disabled State'), findsOneWidget);
      expect(find.text('Degraded State'), findsOneWidget);
    });

    testWidgets('Organism: PrismDataTable covers visible states', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Loading — positive skeleton UI (not empty/error surfaces)
                  SizedBox(
                    height: 800,
                    child: PrismDataTable(
                      columns: [PrismDataColumn(id: '1', label: 'Loading Col')],
                      loading: true,
                    ),
                  ),
                  // Error / Degraded
                  SizedBox(
                    height: 800,
                    child: PrismDataTable(
                      columns: [PrismDataColumn(id: '1', label: 'Error Col')],
                      errorMessage: 'organism failure',
                    ),
                  ),
                  // Empty
                  SizedBox(
                    height: 800,
                    child: PrismDataTable(
                      columns: [PrismDataColumn(id: '1', label: 'Empty Col')],
                      rows: [],
                    ),
                  ),
                  // Disabled / Degraded behavior (empty columns basically disabled)
                  SizedBox(
                    height: 800,
                    child: PrismDataTable(
                      columns: [],
                      rows: [],
                      errorMessage: 'disabled/degraded condition',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Positive loading UI: internal table skeleton mounts when loading:true.
      expect(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString().contains('TableSkeleton'),
        ),
        findsOneWidget,
        reason: 'loading:true must render table skeleton UI',
      );

      expect(find.text('organism failure'), findsOneWidget);

      // Empty generates a DSStateSurface.empty with "No data" title
      expect(find.text('No records match the current filters'), findsOneWidget);

      // We expect the degraded condition text
      expect(find.text('disabled/degraded condition'), findsOneWidget);
    });

    testWidgets('Template: Mock Layouts cover degraded/empty states', (
      tester,
    ) async {
      // Testing template in empty/degraded condition
      await tester.pumpWidget(
        const MaterialApp(
          home: PrismShellResponsive(
            sidebar: PrismStateSurface.disabled(
              title: 'Template Degraded Sidebar',
            ),
            collapsedSidebar: SizedBox.shrink(),
            topbar: SizedBox.shrink(),
            content: PrismStateSurface.empty(title: 'Template Empty Content'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Template Empty Content'), findsOneWidget);
      expect(find.text('Template Degraded Sidebar'), findsOneWidget);
    });
  });
}
