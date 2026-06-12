// Copyright (c) 2026 Ganthritor — Warp Prism
// Boundary test harness — architectural enforcement via grep.
//
// These tests enforce package purity and namespace rules across the
// Warp Prism monorepo. They are deterministic, filesystem-based, and
// do not require network access or Flutter widget pumping.
//
// Reference:
//   docs/architecture/warp-prism-melos-monorepo-architecture.md §5.5
//   docs/design/prism-namespace-remediation-report.md (Task 1301)

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Repo root relative to this test file's CWD during `flutter test`.
///
/// `flutter test` runs from the package root (`packages/warp_prism_ui/`),
/// so the repo root is two levels up.
final Directory _repoRoot = Directory.current.parent.parent;

/// Recursively collect all `.dart` files under [dir].
List<File> _dartFiles(Directory dir) {
  if (!dir.existsSync()) return const [];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();
}

/// Scan [files] for lines matching [pattern].
///
/// Returns a list of `relativePath:lineNumber:line` strings for every match.
List<String> _findMatches(List<File> files, RegExp pattern, {Directory? root}) {
  final base = root ?? _repoRoot;
  final results = <String>[];
  for (final file in files) {
    final relativePath = file.path.replaceFirst('${base.path}/', '');
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      if (pattern.hasMatch(lines[i])) {
        results.add('$relativePath:${i + 1}:${lines[i].trim()}');
      }
    }
  }
  return results;
}

/// Scan all `.dart` files under [dir] for lines matching [pattern].
List<String> _scanDir(Directory dir, RegExp pattern) {
  return _findMatches(_dartFiles(dir), pattern, root: dir);
}

void main() {
  group('Boundary Test Harness', () {
    // ── Check 1: No DS* component types in apps/cybercore/lib/ ──────────
    //
    // Task 1301 migrated all DS* references to Prism* in CyberCore.
    // This check enforces zero regression. Observers (apps/observatory/)
    // are NOT checked here — that migration is deferred.
    test(
      'CyberCore contains zero DS* references (Prism* migration complete)',
      () {
        final cybercoreLib = Directory('${_repoRoot.path}/apps/cybercore/lib');

        if (!cybercoreLib.existsSync()) {
          // If CyberCore doesn't exist yet, nothing to enforce.
          return;
        }

        final violations = _scanDir(cybercoreLib, RegExp(r'DS[A-Z]'));

        expect(
          violations,
          isEmpty,
          reason:
              'Found ${violations.length} DS* reference(s) in CyberCore. '
              'These should have been migrated to Prism* by Task 1301.\n'
              '${violations.take(10).join('\n')}',
        );
      },
    );

    // ── Check 2: No `src/` imports from consumer apps ───────────────────
    //
    // Consumer apps must import `warp_prism_ui` through its public barrel
    // (`package:warp_prism_ui/warp_prism_ui.dart`). Importing `src/`
    // subpaths couples consumers to internal implementation details.
    test('Consumer apps do not import warp_prism_ui src/ paths', () {
      final appsDir = Directory('${_repoRoot.path}/apps');

      if (!appsDir.existsSync()) return;

      final violations = <String>[];
      for (final appDir in appsDir.listSync().whereType<Directory>()) {
        final libDir = Directory('${appDir.path}/lib');
        if (!libDir.existsSync()) continue;
        violations.addAll(
          _scanDir(
            libDir,
            RegExp(r'''import\s+['"]package:warp_prism_ui/src/'''),
          ),
        );
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Found ${violations.length} src/ import(s) from consumer apps. '
            'Use the barrel export instead.\n'
            '${violations.take(10).join('\n')}',
      );
    });

    // ── Check 3: No Riverpod or GoRouter in warp_prism_ui ───────────────
    //
    // The ADS package must be framework-agnostic. Riverpod and GoRouter
    // are application-level concerns; the ADS must not depend on them.
    test('warp_prism_ui does not import Riverpod or GoRouter', () {
      final uiLib = Directory('${_repoRoot.path}/packages/warp_prism_ui/lib');

      if (!uiLib.existsSync()) return;

      final violations = _scanDir(
        uiLib,
        RegExp(
          r'''import\s+['"]package:(flutter_riverpod|riverpod|go_router)''',
        ),
      );

      expect(
        violations,
        isEmpty,
        reason:
            'Found ${violations.length} Riverpod/GoRouter import(s) in '
            'warp_prism_ui. The ADS must be framework-agnostic.\n'
            '${violations.take(10).join('\n')}',
      );
    });

    // ── Check 4: No app-specific imports in warp_prism_ui ───────────────
    //
    // The ADS package must not depend on any specific consumer app.
    // References to observatory, cybercore, or catalog internals would
    // create a circular dependency.
    test('warp_prism_ui does not import app-specific packages', () {
      final uiLib = Directory('${_repoRoot.path}/packages/warp_prism_ui/lib');

      if (!uiLib.existsSync()) return;

      final violations = _scanDir(
        uiLib,
        RegExp(
          r'''import\s+['"]package:warp_prism_(observatory|cybercore|catalog)''',
        ),
      );

      expect(
        violations,
        isEmpty,
        reason:
            'Found ${violations.length} app-specific import(s) in '
            'warp_prism_ui. The ADS must not depend on consumer apps.\n'
            '${violations.take(10).join('\n')}',
      );
    });
  });
}
