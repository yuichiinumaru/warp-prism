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
  });
}
