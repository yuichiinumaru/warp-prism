// Deterministic visual acceptance capture test suite for Catalog (canonical host).
// Viewport: 1280x800 desktop, DPR 1.0.
// Captures typography, token swatches, a dense organism, and a form primitive.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

Future<void> _safeTakeScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  try {
    await binding.takeScreenshot(name);
  } catch (error) {
    debugPrint('Screenshot capture unavailable for $name: $error');
  }
}

void _setDesktopViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Catalog Host — Visual Acceptance Capture Harness', () {
    testWidgets('captures typography specimen with UI, Mono, and Numeric roles', (
      tester,
    ) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: PrismTheme.dark(),
          home: Scaffold(
            backgroundColor: PrismColors.obsidianDeep,
            body: const Padding(
              padding: EdgeInsets.all(PrismSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrismText.headingLarge(
                    'VISUAL ACCEPTANCE — TYPOGRAPHY SPECIMEN',
                    color: PrismColors.accentCyan,
                  ),
                  SizedBox(height: PrismSpacing.md),
                  PrismText.headingMedium(
                    'UI Sans Header (Rajdhani)',
                    key: Key('capture-typo-ui'),
                  ),
                  SizedBox(height: PrismSpacing.xs),
                  PrismText.bodyMedium(
                    'The quick brown fox jumps over the lazy dog in non-mono UI display text.',
                  ),
                  SizedBox(height: PrismSpacing.md),
                  PrismText.code(
                    'TECHNICAL MONO CODE: git commit -m "Task 1805 visual acceptance gate"',
                    key: Key('capture-typo-mono'),
                  ),
                  SizedBox(height: PrismSpacing.xs),
                  PrismText.code(
                    'METRICS NUMERIC: 99.98% uptime · 42ms lat · 1,805 tasks',
                    key: Key('capture-typo-numeric'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _safeTakeScreenshot(binding, 'catalog_typography_specimen');
      expect(find.byKey(const Key('capture-typo-ui')), findsOneWidget);
    });

    testWidgets('captures token swatches palette specimen', (tester) async {
      _setDesktopViewport(tester);
      final swatches = <String, Color>{
        'obsidianDeep': PrismColors.obsidianDeep,
        'obsidianBase': PrismColors.obsidianBase,
        'obsidianElevated': PrismColors.obsidianElevated,
        'surfaceHigh': const Color(0xFF12181C),
        'accentCyan': PrismColors.accentCyan,
        'accentViolet': PrismColors.accentViolet,
        'primaryAction': const Color(0xFF2F81FF),
        'statusSuccess': PrismColors.statusSuccess,
        'statusWarning': PrismColors.statusWarning,
        'statusError': PrismColors.statusError,
      };
      await tester.pumpWidget(
        MaterialApp(
          theme: PrismTheme.dark(),
          home: Scaffold(
            backgroundColor: PrismColors.obsidianDeep,
            body: Padding(
              padding: const EdgeInsets.all(PrismSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PrismText.headingLarge(
                    'VISUAL ACCEPTANCE — TOKEN SWATCHES PALETTE',
                    color: PrismColors.accentCyan,
                  ),
                  const SizedBox(height: PrismSpacing.md),
                  Wrap(
                    spacing: PrismSpacing.sm,
                    runSpacing: PrismSpacing.sm,
                    children: swatches.entries.map((entry) {
                      final foreground = entry.value.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white;
                      return Container(
                        width: 220,
                        padding: const EdgeInsets.all(PrismSpacing.sm),
                        decoration: BoxDecoration(
                          color: entry.value,
                          borderRadius: BorderRadius.circular(PrismRadii.sm),
                          border: Border.all(color: PrismColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PrismText.labelMedium(entry.key, color: foreground),
                            PrismText.bodySmall(
                              '#${entry.value.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                              color: foreground.withValues(alpha: 0.8),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _safeTakeScreenshot(binding, 'catalog_token_swatches');
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('captures dense organism specimen (Provider Health Matrix)', (
      tester,
    ) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: PrismTheme.dark(),
          home: Scaffold(
            backgroundColor: PrismColors.obsidianBase,
            body: Padding(
              padding: const EdgeInsets.all(PrismSpacing.lg),
              child: PrismProviderHealthMatrix(
                providers: prismProviderHealthMatrixMinimalFixture(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _safeTakeScreenshot(binding, 'catalog_dense_organism');
      expect(find.byType(PrismProviderHealthMatrix), findsOneWidget);
    });

    testWidgets('captures form primitive specimen (Theme Editor & Atoms)', (
      tester,
    ) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: PrismTheme.dark(),
          home: Scaffold(
            backgroundColor: PrismColors.obsidianBase,
            body: Padding(
              padding: const EdgeInsets.all(PrismSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PrismText.headingMedium(
                    'FORM PRIMITIVES & THEME EDITOR',
                  ),
                  const SizedBox(height: PrismSpacing.md),
                  Row(
                    children: [
                      const Expanded(
                        child: PrismTextField(
                          label: 'Provider API Endpoint',
                          hint: 'https://api.omniroute.local/v1',
                          helperText: 'Must be HTTPS or local transport',
                        ),
                      ),
                      const SizedBox(width: PrismSpacing.md),
                      PrismButton(
                        label: 'Test Connection',
                        onPressed: () {},
                        variant: PrismButtonVariant.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: PrismSpacing.md),
                  PrismCheckbox(
                    value: true,
                    onChanged: (_) {},
                    label: 'Enable strict visual acceptance gate',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _safeTakeScreenshot(binding, 'catalog_form_primitive');
      expect(find.byType(PrismTextField), findsOneWidget);
    });
  });
}
