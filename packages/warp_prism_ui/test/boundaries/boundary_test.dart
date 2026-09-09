import 'dart:io';

void main([List<String> args = const []]) {
  final repoRoot = _resolveRepoRoot(args);
  final harness = BoundaryHarness(repoRoot: repoRoot);
  final result = harness.run();

  _printResults(result);
  exitCode = result.hasFailures ? 1 : 0;
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
Usage: dart packages/warp_prism_ui/test/boundaries/boundary_test.dart [--repo-root <path>]

Pure Dart boundary harness for Warp Prism package namespace rules.
''';

class BoundaryHarness {
  BoundaryHarness({required this.repoRoot});

  final Directory repoRoot;

  List<BoundaryCheck> get checks => [
    BoundaryCheck(
      name: 'CyberCore contains zero DS* references',
      run: _checkCyberCoreDsReferences,
    ),
    BoundaryCheck(
      name: 'Consumer apps do not import warp_prism_ui src/ paths',
      run: _checkConsumerSrcImports,
    ),
    BoundaryCheck(
      name: 'warp_prism_ui does not import Riverpod or GoRouter',
      run: _checkUiFrameworkImports,
    ),
    BoundaryCheck(
      name: 'warp_prism_ui does not import app-specific packages',
      run: _checkUiAppImports,
    ),
    BoundaryCheck(
      name:
          'warp_prism_ui does not import forbidden persistence or IO packages',
      run: _checkUiForbiddenPackages,
    ),
    BoundaryCheck(
      name: 'All public DS declarations have Prism aliases',
      run: _checkPrismAliasCompleteness,
    ),
    BoundaryCheck(
      name: 'Public barrel hides DS* names from consumers',
      run: _checkPublicBarrelHidesDsNames,
    ),
    BoundaryCheck(
      name:
          'PrismTokenRegistry mutators called only by theme_editor organism and authorized tooling',
      run: _checkRegistryMutatorScope,
    ),
    BoundaryCheck(
      name:
          'Repository root contains no fix_/tmp_/patch_/append_/snippet_/test_ scratch files',
      run: _checkRepoRootScratchFiles,
    ),
    BoundaryCheck(
      name: 'warp_prism_runtime contains no Flutter imports',
      run: _checkRuntimeNoFlutterImports,
    ),
    BoundaryCheck(
      name: 'warp_prism_interaction is pure Dart',
      run: _checkInteractionPureDart,
    ),
    BoundaryCheck(
      name: 'warp_prism_ui does not import warp_prism_bindings',
      run: _checkUiNoBindingsImports,
    ),
    BoundaryCheck(
      name: 'warp_prism_adapter_frb is not imported by ui/interaction/runtime',
      run: _checkNoAdapterFrbImports,
    ),
    BoundaryCheck(
      name: 'Core packages contain no domain types',
      run: _checkNoDomainTypesInCorePackages,
    ),
    BoundaryCheck(
      name: 'FRB generated files are not imported directly by widgets',
      run: _checkNoDirectFrbGeneratedImports,
    ),
  ];

  BoundaryRunResult run() {
    final results = checks
        .map((check) {
          try {
            return BoundaryCheckResult(
              name: check.name,
              violations: check.run(),
            );
          } catch (error, stackTrace) {
            return BoundaryCheckResult(
              name: check.name,
              error: '$error\n$stackTrace',
            );
          }
        })
        .toList(growable: false);

    return BoundaryRunResult(results);
  }

  List<String> _checkCyberCoreDsReferences() {
    final dir = _childDir('apps/cybercore/lib');
    final missing = _missingDirectory(dir, 'apps/cybercore/lib');
    if (missing != null) return missing;

    return _scanDartFiles(dir, RegExp(r'DS[A-Z]'));
  }

  List<String> _checkConsumerSrcImports() {
    final appsDir = _childDir('apps');
    final missing = _missingDirectory(appsDir, 'apps');
    if (missing != null) return missing;

    final violations = <String>[];
    final appDirs =
        appsDir.listSync(followLinks: false).whereType<Directory>().toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    for (final appDir in appDirs) {
      final libDir = Directory('${appDir.path}/lib');
      if (!libDir.existsSync()) continue;

      violations.addAll(
        _scanDartFiles(
          libDir,
          RegExp(r'''^\s*import\s+['"]package:warp_prism_ui/src/'''),
        ),
      );
    }

    return violations;
  }

  List<String> _checkUiFrameworkImports() {
    final uiLib = _childDir('packages/warp_prism_ui/lib');
    final missing = _missingDirectory(uiLib, 'packages/warp_prism_ui/lib');
    if (missing != null) return missing;

    return _scanDartFiles(
      uiLib,
      RegExp(
        r'''^\s*import\s+['"]package:(flutter_riverpod|riverpod|go_router)(?=/)''',
      ),
    );
  }

  List<String> _checkUiAppImports() {
    final uiLib = _childDir('packages/warp_prism_ui/lib');
    final missing = _missingDirectory(uiLib, 'packages/warp_prism_ui/lib');
    if (missing != null) return missing;

    return _scanDartFiles(
      uiLib,
      RegExp(
        r'''^\s*import\s+['"]package:warp_prism_(observatory|cybercore|catalog)(?=/)''',
      ),
    );
  }

  List<String> _checkUiForbiddenPackages() {
    final uiLib = _childDir('packages/warp_prism_ui/lib');
    final missing = _missingDirectory(uiLib, 'packages/warp_prism_ui/lib');
    if (missing != null) return missing;

    return _scanDartFiles(
      uiLib,
      RegExp(
        r'''^\s*import\s+['"](dart:io|package:(shared_preferences|hive|isar|sqflite)(?=/))''',
      ),
    );
  }

  /// Ensures every public `DS*` type declaration under the design-system
  /// source layers has a matching `typedef Prism* = DS*` in prism_aliases.
  ///
  /// "Public" means: declared in a file reachable from a layer barrel export
  /// (`tokens.dart`, `atoms.dart`, `molecules.dart`, `organisms.dart`,
  /// `templates.dart`) or from the gallery surface files. Internal helpers
  /// that are never barrel-exported (e.g. unexported molecules) are ignored.
  List<String> _checkPrismAliasCompleteness() {
    final aliasesFile = File(
      '${repoRoot.path}/packages/warp_prism_ui/lib/src/prism_aliases.dart',
    );
    if (!aliasesFile.existsSync()) {
      return [
        'Missing required file: packages/warp_prism_ui/lib/src/prism_aliases.dart',
      ];
    }

    final aliasText = aliasesFile.readAsStringSync();
    final aliasedDsNames = <String>{};
    final typedefPattern = RegExp(
      r'typedef\s+Prism\w+(?:<[^>]*>)?\s*=\s*(DS[A-Z]\w+)(?:<[^>]*>)?\s*;',
    );
    for (final match in typedefPattern.allMatches(aliasText)) {
      aliasedDsNames.add(match.group(1)!);
    }

    final srcRoot = Directory(
      '${repoRoot.path}/packages/warp_prism_ui/lib/src',
    );
    final publicFiles = <File>{};

    final layerBarrels = [
      'tokens/tokens.dart',
      'atoms/atoms.dart',
      'molecules/molecules.dart',
      'organisms/organisms.dart',
      'templates/templates.dart',
    ];
    for (final barrel in layerBarrels) {
      publicFiles.addAll(
        _collectExportedDartFiles(File('${srcRoot.path}/$barrel'), srcRoot),
      );
    }

    // Gallery is part of the intentional public documentation surface.
    for (final galleryFile in [
      'gallery/design_system_gallery_registry.dart',
      'gallery/design_system_gallery_sections.dart',
      'gallery/design_system_gallery_page.dart',
    ]) {
      final file = File('${srcRoot.path}/$galleryFile');
      if (file.existsSync()) publicFiles.add(file.absolute);
    }

    final declarationPattern = RegExp(
      r'^(?:abstract\s+)?(?:class|enum|mixin|extension\s+type)\s+(DS[A-Z]\w+)\b',
      multiLine: true,
    );

    final violations = <String>[];
    final sortedFiles = publicFiles.toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    for (final file in sortedFiles) {
      final content = file.readAsStringSync();
      for (final match in declarationPattern.allMatches(content)) {
        final dsName = match.group(1)!;
        if (aliasedDsNames.contains(dsName)) continue;
        violations.add(
          '${_relativePath(file)}: missing Prism* alias for $dsName',
        );
      }
    }

    return violations;
  }

  /// Recursively collects Dart files reachable from [barrel] via `export`
  /// statements under [srcRoot].
  Set<File> _collectExportedDartFiles(File barrel, Directory srcRoot) {
    final collected = <File>{};
    final queue = <File>[];
    if (barrel.existsSync()) queue.add(barrel.absolute);

    final exportPattern = RegExp(r'''export\s+['"]([^'"]+)['"]''');

    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      if (!collected.add(current)) continue;
      if (!current.existsSync()) continue;

      final text = current.readAsStringSync();
      for (final match in exportPattern.allMatches(text)) {
        final relative = match.group(1)!;
        if (relative.startsWith('package:')) continue;

        final resolved = File('${current.parent.path}/$relative').absolute;
        if (resolved.existsSync() && resolved.path.endsWith('.dart')) {
          queue.add(resolved);
        }
      }
    }

    // Layer barrel files themselves are not type declaration homes; keep
    // only concrete implementation files plus any non-barrel re-exports.
    return collected;
  }

  /// Ensures the top-level public barrel does not re-export raw `DS*` names.
  ///
  /// Rules:
  /// - No direct export of layer sub-barrels (tokens/atoms/molecules/...).
  /// - No direct export of `ds_*.dart` implementation files.
  /// - Every non-alias export that declares public `DS*` types must `hide`
  ///   those type names on the export statement.
  List<String> _checkPublicBarrelHidesDsNames() {
    final barrelFile = File(
      '${repoRoot.path}/packages/warp_prism_ui/lib/warp_prism_ui.dart',
    );
    if (!barrelFile.existsSync()) {
      return [
        'Missing required file: packages/warp_prism_ui/lib/warp_prism_ui.dart',
      ];
    }

    final barrelText = barrelFile.readAsStringSync();
    final violations = <String>[];

    final bannedSubBarrels = [
      'src/tokens/tokens.dart',
      'src/atoms/atoms.dart',
      'src/molecules/molecules.dart',
      'src/organisms/organisms.dart',
      'src/templates/templates.dart',
    ];
    for (final banned in bannedSubBarrels) {
      if (RegExp("export\\s+['\"]$banned['\"]").hasMatch(barrelText)) {
        violations.add(
          'packages/warp_prism_ui/lib/warp_prism_ui.dart: '
          'must not export layer sub-barrel $banned',
        );
      }
    }

    final exportPattern = RegExp(
      r'''export\s+['"]([^'"]+)['"]([^;]*);''',
      multiLine: true,
    );

    for (final match in exportPattern.allMatches(barrelText)) {
      final exportPath = match.group(1)!;
      final exportSuffix = match.group(2) ?? '';

      if (exportPath.endsWith('prism_aliases.dart')) {
        final aliasesResolved = File(
          '${repoRoot.path}/packages/warp_prism_ui/lib/$exportPath',
        );
        if (aliasesResolved.existsSync()) {
          final aliasesContent = aliasesResolved.readAsStringSync();
          final exportedDsMatches = RegExp(
            r'''export\s+['"]([^'"]+)['"]([^;]*);''',
            multiLine: true,
          ).allMatches(aliasesContent);
          for (final aliasExport in exportedDsMatches) {
            final target = aliasExport.group(1)!;
            final suffix = aliasExport.group(2) ?? '';
            final showMatch = RegExp(r'\bshow\s+([^;]+)').firstMatch(suffix);
            if (showMatch != null) {
              final shown = showMatch.group(1)!;
              final shownDsMatches = RegExp(
                r'\b(DS[A-Z]\w+)\b',
              ).allMatches(shown);
              for (final m in shownDsMatches) {
                violations.add(
                  'packages/warp_prism_ui/lib/src/prism_aliases.dart: '
                  'must not export DS implementation symbol ${m.group(1)}',
                );
              }
            }
            if (RegExp(r'(^|/)ds_[^/]+\.dart$').hasMatch(target)) {
              final hideMatch = RegExp(r'\bhide\s+([^;]+)').firstMatch(suffix);
              if (showMatch == null && hideMatch == null) {
                violations.add(
                  'packages/warp_prism_ui/lib/src/prism_aliases.dart: '
                  'must not re-export DS implementation file $target without hiding DS* names',
                );
              }
            }
          }
        }
        continue;
      }

      if (RegExp(r'(^|/)ds_[^/]+\.dart$').hasMatch(exportPath)) {
        violations.add(
          'packages/warp_prism_ui/lib/warp_prism_ui.dart: '
          'must not export DS implementation file $exportPath',
        );
        continue;
      }

      final resolved = File(
        '${repoRoot.path}/packages/warp_prism_ui/lib/$exportPath',
      );
      if (!resolved.existsSync()) {
        violations.add(
          'packages/warp_prism_ui/lib/warp_prism_ui.dart: '
          'export target missing: $exportPath',
        );
        continue;
      }

      final content = resolved.readAsStringSync();
      final declarationPattern = RegExp(
        r'^(?:abstract\s+)?(?:class|enum|mixin|extension\s+type)\s+(DS[A-Z]\w+)\b',
        multiLine: true,
      );
      final dsNames = declarationPattern
          .allMatches(content)
          .map((m) => m.group(1)!)
          .toSet();

      if (dsNames.isEmpty) continue;

      final hideMatch = RegExp(r'\bhide\s+([^;]+)').firstMatch(exportSuffix);
      final hidden = <String>{};
      if (hideMatch != null) {
        hidden.addAll(
          hideMatch
              .group(1)!
              .split(',')
              .map((part) => part.trim())
              .where((part) => part.isNotEmpty),
        );
      }

      for (final dsName in dsNames.toList()..sort()) {
        if (!hidden.contains(dsName)) {
          violations.add(
            'packages/warp_prism_ui/lib/warp_prism_ui.dart: '
            'export of $exportPath leaks $dsName '
            '(add `hide $dsName` or Prism-wrap and hide)',
          );
        }
      }
    }

    return violations;
  }

  List<String> _checkRegistryMutatorScope() {
    final violations = <String>[];

    final scanDirs = [
      'packages/warp_prism_ui/lib',
      'apps/cybercore/lib',
      'apps/observatory/lib',
      'apps/catalog/lib',
    ];

    final appMutatorPattern = RegExp(
      r'\b(applySkin|setAccentRecipe|setColor|resetRole|reset)\b',
    );
    final uiMutatorPattern = RegExp(
      r'\b(applySkin|setAccentRecipe|setColor|resetRole)\b|(?:\b_?registry\b|PrismTokenRegistry(?:\.instance)?)\.reset\b',
    );

    for (final dirPath in scanDirs) {
      final dir = _childDir(dirPath);
      if (!dir.existsSync()) continue;

      final files =
          dir
              .listSync(recursive: true, followLinks: false)
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart'))
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path));

      for (final file in files) {
        final rel = _relativePath(file);

        // Tooling / registry internal allowlist
        if (rel ==
                'packages/warp_prism_ui/lib/src/tokens/prism_token_registry.dart' ||
            rel.startsWith(
              'packages/warp_prism_ui/lib/src/organisms/theme_editor/',
            ) ||
            rel == 'apps/catalog/lib/main.dart') {
          continue;
        }

        final isUi = rel.startsWith('packages/warp_prism_ui/lib/');
        final pattern = isUi ? uiMutatorPattern : appMutatorPattern;

        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (pattern.hasMatch(lines[i])) {
            violations.add('$rel:${i + 1}:${lines[i].trim()}');
          }
        }
      }
    }

    return violations;
  }

  List<String> _checkRepoRootScratchFiles() {
    final violations = <String>[];
    final rootEntries =
        repoRoot.listSync(followLinks: false).whereType<File>().toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    final scratchPrefixPattern = RegExp(
      r'^(fix_|tmp_|patch_|append_|snippet_|test_|replace_ds\.|start-tmux\.)',
    );
    final scratchExtensionPattern = RegExp(r'\.(py|sh|dart)$');

    for (final file in rootEntries) {
      final fileName =
          file.uri.pathSegments.isNotEmpty &&
              file.uri.pathSegments.last.isNotEmpty
          ? file.uri.pathSegments.last
          : file.path.split(Platform.pathSeparator).last;

      if (scratchPrefixPattern.hasMatch(fileName) ||
          scratchExtensionPattern.hasMatch(fileName)) {
        violations.add(
          '${_relativePath(file)}: root scratch file must be moved to tool/, scripts/, or docs/archive/',
        );
      }
    }

    return violations;
  }

  List<String> _checkRuntimeNoFlutterImports() {
    final runtimeLib = _childDir('packages/warp_prism_runtime/lib');
    final missing = _missingDirectory(
      runtimeLib,
      'packages/warp_prism_runtime/lib',
    );
    if (missing != null) return missing;

    return _scanDartFiles(
      runtimeLib,
      RegExp(r'''^\s*import\s+['"](dart:ui|package:flutter(?=/))'''),
    );
  }

  List<String> _checkInteractionPureDart() {
    final interactionLib = _childDir('packages/warp_prism_interaction/lib');
    final missing = _missingDirectory(
      interactionLib,
      'packages/warp_prism_interaction/lib',
    );
    if (missing != null) return missing;

    return _scanDartFiles(
      interactionLib,
      RegExp(r'''^\s*import\s+['"](dart:ui|package:flutter(?=/))'''),
    );
  }

  List<String> _checkUiNoBindingsImports() {
    final uiLib = _childDir('packages/warp_prism_ui/lib');
    final missing = _missingDirectory(uiLib, 'packages/warp_prism_ui/lib');
    if (missing != null) return missing;

    return _scanDartFiles(
      uiLib,
      RegExp(r'''^\s*import\s+['"]package:warp_prism_bindings(?=/|['"])'''),
    );
  }

  List<String> _checkNoAdapterFrbImports() {
    final violations = <String>[];
    for (final pkg in [
      'packages/warp_prism_ui/lib',
      'packages/warp_prism_interaction/lib',
      'packages/warp_prism_runtime/lib',
    ]) {
      final dir = _childDir(pkg);
      final missing = _missingDirectory(dir, pkg);
      if (missing != null) {
        violations.addAll(missing);
        continue;
      }
      violations.addAll(
        _scanDartFiles(
          dir,
          RegExp(
            r'''^\s*import\s+['"]package:(warp_prism_adapter_frb|flutter_rust_bridge)(?=/|['"])''',
          ),
        ),
      );
    }
    return violations;
  }

  List<String> _checkNoDomainTypesInCorePackages() {
    final violations = <String>[];
    for (final pkg in [
      'packages/warp_prism_interaction/lib',
      'packages/warp_prism_runtime/lib',
      'packages/warp_prism_bindings/lib',
      'packages/warp_prism_testkit/lib',
      'packages/warp_prism_adapter_frb/lib',
    ]) {
      final dir = _childDir(pkg);
      final missing = _missingDirectory(dir, pkg);
      if (missing != null) {
        violations.addAll(missing);
        continue;
      }
      violations.addAll(
        _scanDartFiles(
          dir,
          RegExp(r'\b(Ganthritor|Cersei|OmniRoute|CyberCore)\b'),
        ),
      );
    }
    return violations;
  }

  List<String> _checkNoDirectFrbGeneratedImports() {
    final violations = <String>[];
    final candidateDirs = <Directory>[];

    final appsDir = _childDir('apps');
    if (appsDir.existsSync()) {
      final appDirs =
          appsDir.listSync(followLinks: false).whereType<Directory>().toList()
            ..sort((a, b) => a.path.compareTo(b.path));
      for (final appDir in appDirs) {
        final libDir = Directory('${appDir.path}/lib');
        if (libDir.existsSync()) {
          candidateDirs.add(libDir);
        }
      }
    }

    final packagesDir = _childDir('packages');
    if (packagesDir.existsSync()) {
      final pkgDirs =
          packagesDir
              .listSync(followLinks: false)
              .whereType<Directory>()
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path));
      for (final pkgDir in pkgDirs) {
        final dirName =
            pkgDir.uri.pathSegments.isNotEmpty &&
                pkgDir.uri.pathSegments.last.isNotEmpty
            ? pkgDir.uri.pathSegments.last
            : pkgDir.path.split(Platform.pathSeparator).last;
        if (dirName == 'warp_prism_adapter_frb') continue;
        final libDir = Directory('${pkgDir.path}/lib');
        if (libDir.existsSync()) {
          candidateDirs.add(libDir);
        }
      }
    }

    for (final dir in candidateDirs) {
      violations.addAll(
        _scanDartFiles(
          dir,
          RegExp(r'''^\s*import\s+['"].*(?:src/rust/|frb_generated)'''),
        ),
      );
    }

    return violations;
  }

  Directory _childDir(String relativePath) =>
      Directory('${repoRoot.path}/$relativePath');

  List<String>? _missingDirectory(Directory dir, String label) {
    if (dir.existsSync()) return null;
    return ['Missing required directory: $label (${dir.path})'];
  }

  List<String> _scanDartFiles(Directory dir, RegExp pattern) {
    final results = <String>[];
    final files =
        dir
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (pattern.hasMatch(lines[i])) {
          results.add('${_relativePath(file)}:${i + 1}:${lines[i].trim()}');
        }
      }
    }

    return results;
  }

  String _relativePath(File file) {
    final rootPath = repoRoot.path;
    final path = file.path;
    if (path == rootPath) return '.';

    final prefix = rootPath.endsWith('/') ? rootPath : '$rootPath/';
    if (path.startsWith(prefix)) {
      return path.substring(prefix.length);
    }

    return path;
  }
}

class BoundaryCheck {
  const BoundaryCheck({required this.name, required this.run});

  final String name;
  final List<String> Function() run;
}

class BoundaryCheckResult {
  const BoundaryCheckResult({
    required this.name,
    this.violations = const [],
    this.error,
  });

  final String name;
  final List<String> violations;
  final String? error;

  bool get passed => error == null && violations.isEmpty;
}

class BoundaryRunResult {
  const BoundaryRunResult(this.checks);

  final List<BoundaryCheckResult> checks;

  bool get hasFailures => checks.any((check) => !check.passed);
  int get passedCount => checks.where((check) => check.passed).length;
  int get failedCount => checks.where((check) => !check.passed).length;
  int get violationCount {
    return checks.fold<int>(
      0,
      (count, check) =>
          count + check.violations.length + (check.error == null ? 0 : 1),
    );
  }
}

void _printResults(BoundaryRunResult result) {
  stdout.writeln('Boundary Test Harness (pure Dart)');
  stdout.writeln('Checks: ${result.passedCount}/${result.checks.length} PASS');

  for (final check in result.checks) {
    stdout.writeln('[${check.passed ? 'PASS' : 'FAIL'}] ${check.name}');

    final error = check.error;
    if (error != null) {
      stderr.writeln('  ERROR: $error');
    }

    for (final violation in check.violations) {
      stdout.writeln('  - $violation');
    }
  }

  stdout.writeln(
    'Boundary harness: '
    '${result.passedCount}/${result.checks.length} PASS, '
    '${result.failedCount} FAIL, '
    '${result.violationCount} violation(s)',
  );
}
