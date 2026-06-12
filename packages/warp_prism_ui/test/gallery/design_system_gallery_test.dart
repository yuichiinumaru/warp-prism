import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_ui/src/gallery/design_system_gallery_page.dart';
import 'package:warp_prism_ui/src/gallery/design_system_gallery_sections.dart';

/// Task 0017 / Task 1304: Design System Gallery
///
/// Widget tests proving that the gallery page renders and demonstrates
/// all atomic design layers.
///
/// The gallery page uses a lazy [ListView].  Tests that need to find
/// off-screen widgets must scroll before asserting.  The
/// [_findByScrolling] helper scrolls downward until the target text
/// is found or the maximum number of scroll attempts is exhausted.
void main() {
  group('DesignSystemGalleryPage', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );

      // Header renders immediately (first visible item)
      expect(find.text('Design System Gallery'), findsOneWidget);
    });

    testWidgets('renders all five atomic layer sections', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );

      // Tokens is near the top — visible without scrolling
      expect(find.text('Tokens'), findsOneWidget);

      // Remaining sections are below the fold — scroll to each
      await _findByScrolling(tester, 'Atoms');
      await _findByScrolling(tester, 'Molecules');
      await _findByScrolling(tester, 'Organisms');
      await _findByScrolling(tester, 'Templates');
    });

    testWidgets('renders token color swatches', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );

      // Color swatch labels — near the top
      expect(find.text('Color Palette'), findsOneWidget);
      expect(find.text('accentCyan'), findsOneWidget);
      expect(find.text('accentViolet'), findsOneWidget);
    });

    testWidgets('renders atom samples', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );

      // Atom section labels — scroll to the Atoms section first
      await _findByScrolling(tester, 'Text Variants');
      expect(find.text('Icons'), findsOneWidget);
      expect(find.text('Badges'), findsOneWidget);
      expect(find.text('Chips'), findsOneWidget);
      expect(find.text('Status Dots'), findsOneWidget);
      expect(find.text('Dividers'), findsOneWidget);
      expect(find.text('Glass Panels'), findsOneWidget);
    });

    testWidgets('renders molecule samples', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );

      await _findByScrolling(tester, 'Search Bar');
      expect(find.text('Filter Chip Group'), findsOneWidget);
      expect(find.text('Metric Tile'), findsOneWidget);
      expect(find.text('Provenance Pill'), findsOneWidget);
      expect(find.text('State Surfaces'), findsOneWidget);
    });

    testWidgets('renders organism previews', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );

      // Sidebar items
      await _findByScrolling(tester, 'Overview');
      expect(find.text('Map'), findsWidgets); // sidebar + topbar
      expect(find.text('Operate'), findsOneWidget);

      // Lane board
      await _findByScrolling(tester, 'Align organism APIs');
      expect(find.text('Create gallery route'), findsOneWidget);

      // Timeline
      await _findByScrolling(tester, 'Project initialized');

      // Story panel
      await _findByScrolling(tester, 'Workspace Health');
    });

    testWidgets('renders template descriptions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );

      await _findByScrolling(tester, 'MasterDetailTemplate');
      expect(find.text('CanvasTemplate'), findsOneWidget);
      expect(find.text('TimelineTemplate'), findsOneWidget);
    });

    testWidgets('renders footer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );

      await _findByScrolling(
        tester,
        'ASW Observatory · Warp Prism · Design System v0.1.0',
      );
    });
  });

  group('DSGallerySections', () {
    testWidgets('buildTokensSection renders independently', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(children: [DSGallerySections.buildTokensSection()]),
          ),
        ),
      );

      expect(find.text('Tokens'), findsOneWidget);
      expect(find.text('Color Palette'), findsOneWidget);
    });

    testWidgets('buildAtomsSection renders independently', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(children: [DSGallerySections.buildAtomsSection()]),
          ),
        ),
      );

      expect(find.text('Atoms'), findsOneWidget);
    });

    testWidgets('buildMoleculesSection renders independently', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [DSGallerySections.buildMoleculesSection()],
            ),
          ),
        ),
      );

      expect(find.text('Molecules'), findsOneWidget);
    });

    testWidgets('buildOrganismsSection renders independently', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DSGallerySections.buildOrganismsSection(),
            ),
          ),
        ),
      );

      expect(find.text('Organisms'), findsOneWidget);
    });

    testWidgets('buildTemplatesSection renders independently', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [DSGallerySections.buildTemplatesSection()],
            ),
          ),
        ),
      );

      expect(find.text('Templates'), findsOneWidget);
    });
  });
}

/// Scrolls the main gallery [ListView] until [text] is visible on screen.
///
/// Uses [pump] instead of [pumpAndSettle] to avoid timing out on
/// infinite animations (e.g. [DSShimmer]).
///
/// Finds the gallery ListView by looking for the outermost [ListView]
/// (the one that is a direct child of the gallery page [Container]).
Future<void> _findByScrolling(
  WidgetTester tester,
  String text, {
  int maxScrolls = 100,
}) async {
  // Use the Scaffold body as the scrollable — the gallery's ListView
  // is nested inside it.
  final listView = find.byType(ListView).first;
  for (var i = 0; i < maxScrolls; i++) {
    if (tester.any(find.text(text))) return;
    await tester.fling(listView, const Offset(0, -500), 10000);
    await tester.pump();
  }
  // Final check — will throw TestFailure if still not found
  expect(find.text(text), findsWidgets);
}
