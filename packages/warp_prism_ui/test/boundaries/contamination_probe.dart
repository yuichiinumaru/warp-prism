import 'dart:io';

/// Contamination Probe — enforces cache convention at runtime.
///
/// Fails if generated dependency caches (pub-cache, tmp with pubspec.yaml)
/// are discovered under workspace member globs (apps/**, packages/**).
///
/// Run with: dart packages/warp_prism_ui/test/boundaries/contamination_probe.dart --repo-root <path>
/// Or add as a Melos script for CI gate.

void main([List<String> args = const []]) {
  final repoRoot = _resolveRepoRoot(args);
  final violations = <String>[];

  // Check apps/** for nested pubspec.yaml in tmp/ or pub-cache/
  violations.addAll(
    _probeDirectory(Directory('${repoRoot.path}/apps'), 'apps', [
      'tmp',
      'pub-cache',
    ]),
  );

  // Check packages/** for nested pubspec.yaml in tmp/ or pub-cache/
  violations.addAll(
    _probeDirectory(Directory('${repoRoot.path}/packages'), 'packages', [
      'tmp',
      'pub-cache',
    ]),
  );

  if (violations.isNotEmpty) {
    stderr.writeln(
      'CONTAMINATION PROBE FAILED: ${violations.length} violation(s) found',
    );
    for (final v in violations) {
      stderr.writeln('  - $v');
    }
    stderr.writeln('');
    stderr.writeln(
      'Fix: Remove the offending directories. Use root-level tmp/ instead.',
    );
    exitCode = 1;
  } else {
    stdout.writeln(
      'Contamination probe: PASS (no nested workspace pubspecs in cache dirs)',
    );
    exitCode = 0;
  }
}

List<String> _probeDirectory(
  Directory root,
  String label,
  List<String> forbiddenDirs,
) {
  final violations = <String>[];

  if (!root.existsSync()) return violations;

  for (final entry in root.listSync(recursive: true, followLinks: false)) {
    if (entry is Directory) {
      final basename = entry.path.split(Platform.pathSeparator).last;
      if (forbiddenDirs.contains(basename)) {
        // Check if this forbidden directory contains a pubspec.yaml
        final pubspec = File('${entry.path}/pubspec.yaml');
        if (pubspec.existsSync()) {
          final relative = _relativePath(root, entry);
          violations.add(
            '$label/$relative contains pubspec.yaml — will be discovered by Melos workspace glob',
          );
        }
      }
    }
  }

  return violations;
}

Directory _resolveRepoRoot(List<String> args) {
  String? explicitRoot;

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--repo-root') {
      if (i + 1 >= args.length) {
        stderr.writeln('Missing value for --repo-root.');
        exit(2);
      }
      explicitRoot = args[++i];
    } else if (arg.startsWith('--repo-root=')) {
      explicitRoot = arg.substring('--repo-root='.length);
    } else if (arg == '--help' || arg == '-h') {
      stdout.writeln(_usage);
      exit(0);
    } else {
      stderr.writeln('Unknown argument: $arg');
      stderr.writeln(_usage);
      exit(2);
    }
  }

  if (explicitRoot != null) {
    final dir = Directory(explicitRoot);
    if (!dir.existsSync()) {
      throw StateError('Repository root does not exist: ${dir.path}');
    }
    return dir.absolute;
  }

  var candidates = <Directory>[Directory.current, Directory.current.parent];

  try {
    candidates = [
      ...candidates,
      File(Platform.script.toFilePath()).parent,
      File(Platform.script.toFilePath()).parent.parent,
    ];
  } on UnsupportedError {
    // Platform.script may be a data URI under some test runners.
  }

  for (final candidate in candidates) {
    var dir = candidate.absolute;
    while (true) {
      final pubspec = File('${dir.path}/pubspec.yaml');
      if (pubspec.existsSync()) {
        final text = pubspec.readAsStringSync();
        // Prefer the monorepo root (name: warp_prism) over package pubspec
        if (text.contains('name: warp_prism') &&
            !text.contains('name: warp_prism_ui') &&
            !text.contains('name: warp_prism_observatory') &&
            !text.contains('name: warp_prism_catalog') &&
            !text.contains('name: warp_prism_cybercore')) {
          return dir.absolute;
        }
      }

      final parent = dir.parent;
      if (parent.path == dir.path) {
        break;
      }
      dir = parent;
    }
  }

  throw StateError(
    'Could not locate Warp Prism repository root. Pass --repo-root explicitly.',
  );
}

const _usage = '''
Usage: dart packages/warp_prism_ui/test/boundaries/contamination_probe.dart [--repo-root <path>]

Enforces cache convention: no generated pubspec.yaml under apps/**/tmp, apps/**/pub-cache, packages/**/tmp, packages/**/pub-cache.
''';

String _relativePath(Directory root, Directory target) {
  final rootPath = root.path;
  final path = target.path;
  if (path == rootPath) return '.';

  final prefix = rootPath.endsWith('/') ? rootPath : '$rootPath/';
  if (path.startsWith(prefix)) {
    return path.substring(prefix.length);
  }

  return path;
}
