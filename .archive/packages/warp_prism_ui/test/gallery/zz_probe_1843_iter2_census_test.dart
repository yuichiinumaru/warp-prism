// TEMPORARY Task 1843 iteration-2 census probe — archived after the run.
//
// Measures whether the two residual benign-hint classes in the gallery oracle
// occur AT ALL in the current tree (Task 1840 fixed the Material ancestry at the
// demo host). Includes POSITIVE and NEGATIVE controls so a zero count cannot be
// a broken probe.
//
// Prints machine-greppable census lines of the form:
//   ===CENSUS=== phase=<phase> vp=<viewport> class=<class> count=<n>

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// The REAL Flutter 3.44.1 framework message
/// (packages/flutter/lib/src/material/list_tile.dart:1154). One combined
/// `ErrorSummary`, reported via `FlutterError.reportError` from an assert in
/// `ListTile._debugCheckBackgroundIsHidden`, which only runs when
/// `onTap != null || onLongPress != null || hasOpaqueBackground`
/// (list_tile.dart:832).
const String classListTileCombined =
    'ListTile background color or ink splashes may be invisible.';

/// The two strings the oracle allow-list is written against. Neither exists in
/// Flutter 3.44.1 (verified by grep over packages/flutter/lib/src).
const String classSyntheticOpaque =
    'ListTile background color set to an opaque color.';
const String classSyntheticInk = 'The ink splashes may be invisible.';

const List<(Size, String)> _viewports = <(Size, String)>[
  (Size(1280, 800), '1280x800'),
  (Size(1400, 2400), '1400x2400'),
];

String _site = 'none';
final List<String> _recordSites = <String>[];
final List<String> _recordMessages = <String>[];

/// Records every FlutterError message WITHOUT losing it.
///
/// Iteration 1's probe overrode `FlutterError.onError` and returned without
/// forwarding, which bypasses the binding's pending-exception bookkeeping:
/// `takeException()` went null and teardown asserted. Forwarding to the
/// handler that was active at install time keeps the bookkeeping intact, so the
/// census is both complete AND teardown-clean.
void _installCensusRecorder() {
  final FlutterExceptionHandler? previous = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    _recordSites.add(_site);
    _recordMessages.add(details.exceptionAsString());
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);
}

String _classify(String msg) {
  if (msg.contains(classListTileCombined)) {
    return 'REAL_SDK_LISTTILE';
  }
  if (msg.contains(classSyntheticOpaque)) {
    return 'SYNTH_OPAQUE';
  }
  if (msg.contains(classSyntheticInk)) {
    return 'SYNTH_INK';
  }
  if (msg.contains('RenderFlex') ||
      msg.contains('overflowed') ||
      msg.contains('overflow')) {
    return 'LAYOUT_OVERFLOW';
  }
  return 'OTHER';
}

void _drainPending(WidgetTester tester) {
  while (tester.takeException() != null) {
    // ignore: avoid_print
    print('===CENSUS-DRAIN=== site=$_site');
  }
}

int _countOf(String cls) {
  int n = 0;
  for (final String msg in _recordMessages) {
    if (_classify(msg) == cls) n++;
  }
  return n;
}

void _report(String phase, String vp) {
  for (final cls in <String>[
    'REAL_SDK_LISTTILE',
    'SYNTH_OPAQUE',
    'SYNTH_INK',
    'LAYOUT_OVERFLOW',
    'OTHER',
  ]) {
    // ignore: avoid_print
    print('===CENSUS=== phase=$phase vp=$vp class=$cls count=${_countOf(cls)}');
  }
  // Full attribution for every recorded message, with its site.
  for (int i = 0; i < _recordMessages.length; i++) {
    final String msg = _recordMessages[i];
    // ignore: avoid_print
    print(
      '===CENSUS-FULL=== phase=$phase vp=$vp site=${_recordSites[i]} '
      'class=${_classify(msg)}\n$msg',
    );
  }
  _recordMessages.clear();
  _recordSites.clear();
}

Future<void> _censusSections(WidgetTester tester, String vp) async {
  for (final section in dsGallerySections) {
    _site = 'section:${section.id}';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: section.builder())),
      ),
    );
    await tester.pump();
    _drainPending(tester);
  }
  _report('section-builders', vp);
}

Future<void> _censusPage(WidgetTester tester, String vp) async {
  // Real host composition: lazy ListView, so every section is only built once
  // scrolled into view. Mirrors the gallery suite's own scroll helper.
  _site = 'page';
  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
  );
  await tester.pump();
  _drainPending(tester);

  final Finder listView = find.byType(ListView).first;
  for (var i = 0; i < 60; i++) {
    _site = 'page-scroll-$i';
    await tester.fling(listView, const Offset(0, -500), 10000);
    await tester.pump();
    _drainPending(tester);
  }
  _report('page-scroll-through', vp);
}

void main() {
  testWidgets('POSITIVE CONTROL — census detects the real SDK hint', (
    tester,
  ) async {
    _installCensusRecorder();
    _site = 'positive-control';

    // Deliberate violation of the ListTile debug contract — the exact shape
    // Task 1840 removed from the layer registry: nearest Material is ABOVE a
    // ColoredBox that carries a color. `onTap` is required, otherwise the
    // guard at list_tile.dart:832 short-circuits and the assert never runs.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Material(
            child: ColoredBox(
              color: const Color(0xFF102030),
              child: ListView(
                children: <Widget>[
                  ListTile(
                    onTap: () {},
                    title: const Text('deliberate control tile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    _drainPending(tester);

    expect(
      _countOf('REAL_SDK_LISTTILE'),
      greaterThanOrEqualTo(1),
      reason:
          'Census non-vacuity: the recorder must catch the real SDK hint when '
          'the contract is deliberately violated.',
    );
    _report('positive-control', 'n/a');
  });

  testWidgets('NEGATIVE CONTROL — the Task 1840 fix shape is silent', (
    tester,
  ) async {
    _installCensusRecorder();
    _site = 'negative-control';

    // Same tree as the positive control, but with its own Material between the
    // ListTile and the ColoredBox — precisely the Task 1840 remedy. The
    // census must stay silent here. If this fired, every zero measured below
    // would be meaningless in the other direction.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Material(
            child: ColoredBox(
              color: const Color(0xFF102030),
              child: Material(
                type: MaterialType.transparency,
                child: ListView(
                  children: <Widget>[
                    ListTile(
                      onTap: () {},
                      title: const Text('control tile under own Material'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    _drainPending(tester);

    expect(
      _countOf('REAL_SDK_LISTTILE'),
      0,
      reason:
          'Wrapping the ListTile in its own Material must silence the hint; '
          'that is the remedy Task 1840 applied to the layer registry.',
    );
    _report('negative-control', 'n/a');
  });

  for (final (Size size, String label) in _viewports) {
    testWidgets('census — isolated section builders @ $label', (tester) async {
      _installCensusRecorder();
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _censusSections(tester, label);
    });

    testWidgets('census — full page scroll-through @ $label', (tester) async {
      _installCensusRecorder();
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _censusPage(tester, label);
    });
  }
}
