import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  Directory resolvePackageRoot() {
    var dir = Directory.current.absolute;
    if (File('${dir.path}/lib/warp_prism_ui.dart').existsSync()) {
      return dir;
    }
    final child = Directory('${dir.path}/packages/warp_prism_ui');
    if (File('${child.path}/lib/warp_prism_ui.dart').existsSync()) {
      return child;
    }
    throw StateError('Cannot locate warp_prism_ui package root');
  }

  group('Public Barrel Boundary - No DS Export Regression Gate', () {
    test('warp_prism_ui.dart exports zero DS* names', () {
      final pkgRoot = resolvePackageRoot();
      final barrelFile = File('${pkgRoot.path}/lib/warp_prism_ui.dart');
      expect(
        barrelFile.existsSync(),
        isTrue,
        reason: 'warp_prism_ui.dart must exist',
      );

      final barrelContent = barrelFile.readAsStringSync();
      final exportMatches = RegExp(
        r'''export\s+['"]([^'"]+)['"]([^;]*);''',
        multiLine: true,
      ).allMatches(barrelContent);

      for (final match in exportMatches) {
        final target = match.group(1)!;
        final suffix = match.group(2) ?? '';

        // Must not export DS implementation files directly
        expect(
          RegExp(r'(^|/)ds_[^/]+\.dart$').hasMatch(target),
          isFalse,
          reason:
              'Public barrel must not export DS implementation file: $target',
        );

        // Any shown/exported symbol must not start with DS
        final showMatch = RegExp(r'\bshow\s+([^;]+)').firstMatch(suffix);
        if (showMatch != null) {
          final shown = showMatch.group(1)!;
          final shownDsMatches = RegExp(r'\b(DS[A-Z]\w+)\b').allMatches(shown);
          expect(
            shownDsMatches.isEmpty,
            isTrue,
            reason:
                'Public barrel show clause exports DS symbols: ${shownDsMatches.map((m) => m.group(1))}',
          );
        }
      }
    });

    test(
      'prism_aliases.dart contains zero export statements re-exporting DS* symbols',
      () {
        final pkgRoot = resolvePackageRoot();
        final aliasesFile = File('${pkgRoot.path}/lib/src/prism_aliases.dart');
        expect(
          aliasesFile.existsSync(),
          isTrue,
          reason: 'prism_aliases.dart must exist',
        );

        final aliasesContent = aliasesFile.readAsStringSync();
        final exportMatches = RegExp(
          r'''export\s+['"]([^'"]+)['"]([^;]*);''',
          multiLine: true,
        ).allMatches(aliasesContent);

        for (final match in exportMatches) {
          final target = match.group(1)!;
          final suffix = match.group(2) ?? '';

          if (RegExp(r'(^|/)ds_[^/]+\.dart$').hasMatch(target)) {
            final showMatch = RegExp(r'\bshow\s+([^;]+)').firstMatch(suffix);
            final hideMatch = RegExp(r'\bhide\s+([^;]+)').firstMatch(suffix);

            if (showMatch != null) {
              final shown = showMatch.group(1)!;
              final shownDsMatches = RegExp(
                r'\b(DS[A-Z]\w+)\b',
              ).allMatches(shown);
              expect(
                shownDsMatches.isEmpty,
                isTrue,
                reason:
                    'prism_aliases.dart show clause re-exports DS symbols: ${shownDsMatches.map((m) => m.group(1))}',
              );
            } else if (hideMatch == null) {
              fail(
                'prism_aliases.dart re-exports DS implementation file $target without show/hide clauses',
              );
            }
          }
        }
      },
    );

    test(
      'PrismOperationalState and PrismOperationalStateUI getters are fully functional via public barrel',
      () {
        const state = PrismOperationalState.running;

        expect(state.color, isNotNull);
        expect(state.icon, isNotNull);
        expect(state.label, equals('Running'));
        expect(state.semanticLabel, equals('Running: in progress'));
        expect(state.allowsActions, isTrue);
        expect(state.isTerminal, isFalse);
        expect(state.showsWarning, isFalse);
        expect(state.severity, equals(PrismOperationalSeverity.info));
        expect(state.category, equals(PrismOperationalCategory.lifecycle));
      },
    );
  });
}
