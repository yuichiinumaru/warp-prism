import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_ui/src/gallery/design_system_gallery_page.dart';
import 'package:warp_prism_ui/src/gallery/design_system_gallery_sections.dart';

/// Task 0017: Design System Gallery Route Bootstrap
///
/// Widget tests proving that the gallery page renders and demonstrates
/// all atomic design layers.
void main() {
  group('DesignSystemGalleryPage', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DesignSystemGalleryPage()),
        ),
      );

      // Header renders
      expect(find.text('Design System Gallery'), findsOneWidget);
    });

    testWidgets('renders all five atomic layer sections', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DesignSystemGalleryPage()),
        ),
      );

      // All five sections present
      expect(find.text('Tokens'), findsOneWidget);
      expect(find.text('Atoms'), findsOneWidget);
      expect(find.text('Molecules'), findsOneWidget);
      expect(find.text('Organisms'), findsOneWidget);
      expect(find.text('Templates'), findsOneWidget);
    });

    testWidgets('renders token color swatches', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DesignSystemGalleryPage()),
        ),
      );

      // Color swatch labels
      expect(find.text('Color Palette'), findsOneWidget);
      expect(find.text('accentCyan'), findsOneWidget);
      expect(find.text('accentViolet'), findsOneWidget);
    });

    testWidgets('renders atom samples', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DesignSystemGalleryPage()),
        ),
      );

      // Atom section labels
      expect(find.text('Text Variants'), findsOneWidget);
      expect(find.text('Icons'), findsOneWidget);
      expect(find.text('Badges'), findsOneWidget);
      expect(find.text('Chips'), findsOneWidget);
      expect(find.text('Status Dots'), findsOneWidget);
      expect(find.text('Dividers'), findsOneWidget);
      expect(find.text('Glass Panels'), findsOneWidget);
    });

    testWidgets('renders molecule samples', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DesignSystemGalleryPage()),
        ),
      );

      expect(find.text('Search Bar'), findsOneWidget);
      expect(find.text('Filter Chip Group'), findsOneWidget);
      expect(find.text('Metric Tile'), findsOneWidget);
      expect(find.text('Provenance Pill'), findsOneWidget);
      expect(find.text('State Surfaces'), findsOneWidget);
    });

    testWidgets('renders organism previews', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DesignSystemGalleryPage()),
        ),
      );

      // Sidebar items
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Map'), findsWidgets); // appears in sidebar + topbar
      expect(find.text('Operate'), findsOneWidget);

      // Lane board
      expect(find.text('Align organism APIs'), findsOneWidget);
      expect(find.text('Create gallery route'), findsOneWidget);

      // Timeline
      expect(find.text('Project initialized'), findsOneWidget);

      // Story panel
      expect(find.text('Workspace Health'), findsOneWidget);

      // Graph canvas empty state
      expect(find.text('No assets to display'), findsOneWidget);
    });

    testWidgets('renders template descriptions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DesignSystemGalleryPage()),
        ),
      );

      expect(find.text('MasterDetailTemplate'), findsOneWidget);
      expect(find.text('CanvasTemplate'), findsOneWidget);
      expect(find.text('TimelineTemplate'), findsOneWidget);
    });

    testWidgets('renders footer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DesignSystemGalleryPage()),
        ),
      );

      expect(
        find.text('ASW Observatory · Warp Prism · Design System v0.1.0'),
        findsOneWidget,
      );
    });
  });

  group('DSGallerySections', () {
    testWidgets('buildTokensSection renders independently', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [DSGallerySections.buildTokensSection()],
            ),
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
            body: ListView(
              children: [DSGallerySections.buildAtomsSection()],
            ),
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
            body: ListView(
              children: [DSGallerySections.buildOrganismsSection()],
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
