import 'dart:io';
import 'package:test/test.dart';

Directory _resolveLibDir() {
  var dir = Directory('lib');
  if (dir.existsSync()) return dir;

  dir = Directory('packages/warp_prism_runtime/lib');
  if (dir.existsSync()) return dir;

  try {
    final scriptFile = File(Platform.script.toFilePath());
    final packageRoot = scriptFile.parent.parent;
    final candidate = Directory('${packageRoot.path}/lib');
    if (candidate.existsSync()) return candidate;
  } catch (_) {}

  return Directory('lib');
}

/// Strips comments so a token scan judges code, not prose.
///
/// Mirrors the precedent in
/// `packages/warp_prism_bindings/test/boundary_isolation_test.dart`
/// (`_stripComments`): block comments are removed wholesale, then every line
/// whose trimmed content starts with `//` — `///` doc-comments included — is
/// dropped.
///
/// Trailing comments are deliberately left in place. That is the conservative
/// direction for a ban: it can only produce a loud false positive on a later
/// scan, never a silent miss, and it avoids mangling string literals that
/// legitimately contain `//` (URLs, path separators).
String _stripComments(String source) {
  final withoutMultiLine = source.replaceAll(
    RegExp(r'/\*.*?\*/', dotAll: true),
    '',
  );
  return withoutMultiLine
      .split('\n')
      .where((line) => !line.trim().startsWith('//'))
      .join('\n');
}

void main() {
  group('Purity Verification', () {
    test(
      'warp_prism_runtime lib/ contains zero package:flutter or dart:ui imports',
      () {
        final libDir = _resolveLibDir();
        expect(
          libDir.existsSync(),
          isTrue,
          reason: 'lib directory must exist in packages/warp_prism_runtime',
        );

        final dartFiles = libDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .toList();

        expect(
          dartFiles,
          isNotEmpty,
          reason: 'There should be Dart files in lib/',
        );

        final violations = <String>[];

        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          if (content.contains('package:flutter') ||
              content.contains("import 'package:flutter") ||
              content.contains('import "package:flutter') ||
              content.contains('dart:ui')) {
            violations.add(file.path);
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'warp_prism_runtime core must remain pure Dart without Flutter dependencies. Violations: $violations',
        );
      },
    );

    test(
      'warp_prism_runtime lib/ contains zero presentation or polling policies',
      () {
        final libDir = _resolveLibDir();
        final dartFiles = libDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .toList();

        final forbiddenPatterns = [
          RegExp(
            r'auto-scroll|autoScroll|followTail|follow-tail',
            caseSensitive: false,
          ),
          RegExp(r'Timer\.periodic'),
        ];

        final violations = <String>[];

        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          for (final pattern in forbiddenPatterns) {
            if (pattern.hasMatch(content)) {
              violations.add('${file.path} matched $pattern');
            }
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'warp_prism_runtime must honor presentation-purge law. Violations: $violations',
        );
      },
    );

    test(
      'warp_prism_runtime lib/ contains zero bare presentation tokens',
      () {
        final libDir = _resolveLibDir();
        final dartFiles = libDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .toList();

        // MUST-NOT 3: a runtime contract must not contain a Flutter
        // layout/presentation concept. An import scan cannot catch a concept
        // spelled without its import, so the concept tokens themselves are
        // scanned — on comment-stripped source, so documented examples such as
        // "`position: Offset`" in a doc-comment do not trip the scan.
        final forbiddenPatterns = [
          RegExp(r'\b(Offset|Widget|BuildContext|Color)\b'),
        ];

        final violations = <String>[];

        for (final file in dartFiles) {
          final content = _stripComments(file.readAsStringSync());
          for (final pattern in forbiddenPatterns) {
            final match = pattern.firstMatch(content);
            if (match != null) {
              violations.add(
                '${file.path} matched $pattern near "${match.input.substring(
                  match.start,
                  match.end,
                )}"',
              );
            }
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'warp_prism_runtime must not contain bare Flutter presentation '
              'concepts (Offset/Widget/BuildContext/Color) outside imports. '
              'Violations: $violations',
        );
      },
    );
  });
}
