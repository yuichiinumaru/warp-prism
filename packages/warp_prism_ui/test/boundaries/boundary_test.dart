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
    BoundaryCheck(
      name: 'warp_prism_bindings does not import FRB generated surfaces',
      run: _checkBindingsNoFrbGenerated,
    ),
    BoundaryCheck(
      name:
          'action_gate_1868 capability-gated authority respects layer law (Task 1868)',
      run: _checkActionGate1868Authority,
    ),
    BoundaryCheck(
      name: 'honest_unknown_ds_state_declares_unknown (Task 1869)',
      run: _checkHonestUnknownDsState,
    ),
    BoundaryCheck(
      name: 'honest_unknown_fail_closed_no_success_mapping (Task 1869)',
      run: _checkHonestUnknownFailClosed,
    ),
    BoundaryCheck(
      name: 'honest_unknown_query_declares_abstention_vocabulary (Task 1869)',
      run: _checkHonestUnknownQueryVocabulary,
    ),
    BoundaryCheck(
      name: 'honest_unknown_inspection_declares_unknown (Task 1869)',
      run: _checkHonestUnknownInspectionVocabulary,
    ),
    BoundaryCheck(
      name: 'honest_unknown_goldens_exclude_indeterminate (Task 1869)',
      run: _checkHonestUnknownGoldensExcludeIndeterminate,
    ),
    BoundaryCheck(
      name: 'transport_1875_no_time_ontology_in_prism (Task 1875)',
      run: _checkTransport1875NoTimeOntology,
    ),
    BoundaryCheck(
      name: 'transport_1875_no_wallclock_or_timers (Task 1875)',
      run: _checkTransport1875NoWallclockOrTimers,
    ),
    BoundaryCheck(
      name: 'transport_1875_no_forbidden_imports (Task 1875)',
      run: _checkTransport1875NoForbiddenImports,
    ),
    BoundaryCheck(
      name: 'transport_1875_experimental_no_barrel_export (Task 1875)',
      run: _checkTransport1875NoBarrelExport,
    ),
    BoundaryCheck(
      name: 'registry_1870_command_module_pure_dart (Task 1870)',
      run: _checkRegistry1870CommandModulePure,
    ),
    BoundaryCheck(
      name: 'registry_1870_interaction_barrel_hides_command (Task 1870)',
      run: _checkRegistry1870InteractionBarrelHidesCommand,
    ),
    BoundaryCheck(
      name: 'registry_1870_runtime_describe_pure (Task 1870)',
      run: _checkRegistry1870RuntimeDescribePure,
    ),
    BoundaryCheck(
      name: 'registry_1870_palette_stays_presentation (Task 1870)',
      run: _checkRegistry1870PaletteStaysPresentation,
    ),
    BoundaryCheck(
      name: 'registry_1870_router_molecule_scoped (Task 1870)',
      run: _checkRegistry1870RouterMoleculeScoped,
    ),
    BoundaryCheck(
      name: 'registry_1870_toolstrip_reason (Task 1870)',
      run: _checkRegistry1870ToolstripReason,
    ),
    BoundaryCheck(
      name: 'registry_1870_no_new_prism_aliases (Task 1870)',
      run: _checkRegistry1870NoNewPrismAliases,
    ),
    BoundaryCheck(
      name: 'shell_1873_slot_machine_pure (Task 1873)',
      run: _checkShell1873SlotMachinePure,
    ),
    BoundaryCheck(
      name: 'shell_1873_router_scoped (Task 1873)',
      run: _checkShell1873RouterScoped,
    ),
    BoundaryCheck(
      name: 'shell_1873_sidebar_sections_scoped (Task 1873)',
      run: _checkShell1873SidebarSectionsScoped,
    ),
    BoundaryCheck(
      name: 'shell_1873_experimental_no_barrel_export (Task 1873)',
      run: _checkShell1873NoBarrelExport,
    ),
    BoundaryCheck(
      name: 'lineage_1872_no_hash_verification_logic_in_prism (Task 1872)',
      run: _checkLineage1872NoHashVerificationLogic,
    ),
    BoundaryCheck(
      name: 'lineage_1872_experimental_no_barrel_export (Task 1872)',
      run: _checkLineage1872NoBarrelExport,
    ),
    BoundaryCheck(
      name: 'lineage_1872_unknown_consumes_1869_vocabulary (Task 1872)',
      run: _checkLineage1872UnknownConsumes1869,
    ),
    BoundaryCheck(
      name: 'timeline_1874_interaction_module_pure (Task 1874)',
      run: _checkTimeline1874InteractionModulePure,
    ),
    BoundaryCheck(
      name: 'timeline_1874_no_time_ontology_in_prism (Task 1874)',
      run: _checkTimeline1874NoTimeOntology,
    ),
    BoundaryCheck(
      name: 'timeline_1874_no_wallclock_or_timers (Task 1874)',
      run: _checkTimeline1874NoWallclockOrTimers,
    ),
    BoundaryCheck(
      name: 'timeline_1874_experimental_no_barrel_export (Task 1874)',
      run: _checkTimeline1874NoBarrelExport,
    ),
    BoundaryCheck(
      name: 'review_1871_experimental_no_barrel_export (Task 1871)',
      run: _checkReview1871NoBarrelExport,
    ),
    BoundaryCheck(
      name: 'review_1871_no_forbidden_imports (Task 1871)',
      run: _checkReview1871NoForbiddenImports,
    ),
    BoundaryCheck(
      name:
          'review_1871_unknown_consumes_1869_and_gate_consumes_1868 (Task 1871)',
      run: _checkReview1871UnknownConsumes1869AndGateConsumes1868,
    ),
    BoundaryCheck(
      name: 'startup_1876_experimental_no_barrel_export (Task 1876)',
      run: _checkStartup1876NoBarrelExport,
    ),
    BoundaryCheck(
      name: 'startup_1876_no_leak_rendering (Task 1876)',
      run: _checkStartup1876NoLeakRendering,
    ),
    BoundaryCheck(
      name: 'startup_1876_unknown_consumes_1869_vocabulary (Task 1876)',
      run: _checkStartup1876UnknownConsumes1869,
    ),
    BoundaryCheck(
      name: 'startup_1876_deterministic_no_animation (Task 1876)',
      run: _checkStartup1876DeterministicNoAnimation,
    ),
    BoundaryCheck(
      name: 'startup_1876_goldens_exclude_startup (Task 1876)',
      run: _checkStartup1876GoldensExcludeStartup,
    ),
    BoundaryCheck(
      name: 'executor_1859_runtime_executor_purity (Task 1859)',
      run: _checkExecutor1859RuntimeExecutorPurity,
    ),
    BoundaryCheck(
      name: 'banner_1858_job_banner_no_barrel_export (Task 1858)',
      run: _checkBanner1858NoBarrelExport,
    ),
    BoundaryCheck(
      name: 'banner_1858_job_banner_no_forbidden_imports (Task 1858)',
      run: _checkBanner1858NoForbiddenImports,
    ),
    BoundaryCheck(
      name: 'banner_1858_job_banner_unknown_fail_closed (Task 1858)',
      run: _checkBanner1858UnknownFailClosed,
    ),
    BoundaryCheck(
      name: 'banner_1858_job_banner_goldens_exclude_indeterminate (Task 1858)',
      run: _checkBanner1858GoldensExcludeIndeterminate,
    ),
    BoundaryCheck(
      name: 'meter_1861_no_audio_domain_types_in_meter_seam (Task 1861)',
      run: _checkMeter1861NoAudioDomainTypes,
    ),
    BoundaryCheck(
      name: 'meter_1861_no_forbidden_imports_or_clocks (Task 1861)',
      run: _checkMeter1861NoForbiddenImports,
    ),
    BoundaryCheck(
      name: 'meter_1861_experimental_no_barrel_export (Task 1861)',
      run: _checkMeter1861NoBarrelExport,
    ),
    BoundaryCheck(
      name: 'filter_1860_builder_seam_purity (Task 1860)',
      run: _checkFilter1860BuilderSeamPurity,
    ),
    BoundaryCheck(
      name: 'filter_1860_experimental_no_barrel_export (Task 1860)',
      run: _checkFilter1860NoBarrelExport,
    ),
    BoundaryCheck(
      name: 'filter_1860_debounce_deterministic_clock (Task 1860)',
      run: _checkFilter1860DebounceDeterministic,
    ),
    BoundaryCheck(
      name: 'composer_1866_no_domain_types_in_composer_seam (Task 1866)',
      run: _checkComposer1866NoDomainTypes,
    ),
    BoundaryCheck(
      name: 'composer_1866_no_forbidden_imports_or_clocks (Task 1866)',
      run: _checkComposer1866NoForbiddenImports,
    ),
    BoundaryCheck(
      name: 'composer_1866_experimental_no_barrel_export (Task 1866)',
      run: _checkComposer1866NoBarrelExport,
    ),
    BoundaryCheck(
      name: 'token_1882_no_forked_tempest_tokens_in_prism (Task 1882)',
      run: _checkToken1882NoForkedTempestTokens,
    ),
    BoundaryCheck(
      name: 'token_1882_stem_colors_stay_injected (Task 1882)',
      run: _checkToken1882StemColorsStayInjected,
    ),
    BoundaryCheck(
      name: 'token_1882_registry_roles_stable (Task 1882)',
      run: _checkToken1882RegistryRolesStable,
    ),
    BoundaryCheck(
      name: 'numeric_1881_experimental_no_barrel_export (Task 1881)',
      run: _checkNumeric1881NoBarrelExport,
    ),
    BoundaryCheck(
      name: 'numeric_1881_no_domain_math_in_numeric_seam (Task 1881)',
      run: _checkNumeric1881NoDomainMath,
    ),
    BoundaryCheck(
      name: 'numeric_1881_no_forbidden_imports (Task 1881)',
      run: _checkNumeric1881NoForbiddenImports,
    ),
    BoundaryCheck(
      name: 'numeric_1881_deterministic_no_wallclock (Task 1881)',
      run: _checkNumeric1881DeterministicNoWallclock,
    ),
    BoundaryCheck(
      name: 'session_1883_no_new_primitive (Task 1883)',
      run: _checkSession1883NoNewPrimitive,
    ),
    BoundaryCheck(
      name: 'session_1883_experimental_no_barrel_export (Task 1883)',
      run: _checkSession1883NoBarrelExport,
    ),
    BoundaryCheck(
      name: 'session_1883_deterministic_no_wallclock (Task 1883)',
      run: _checkSession1883Deterministic,
    ),
    BoundaryCheck(
      name: 'layer_table_1867_upward_rule (Task 1867)',
      run: _checkLayerTableUpwardRule,
    ),
    BoundaryCheck(
      name: 'layer_table_1867_single_source (Task 1867)',
      run: _checkLayerTableSingleSource,
    ),
    BoundaryCheck(
      name: 'toast_1867_policy_symbols (Task 1867)',
      run: _checkToast1867PolicySymbols,
    ),
    BoundaryCheck(
      name: 'capture_1867_tiers_present (Task 1867)',
      run: _checkCapture1867TiersPresent,
    ),
    BoundaryCheck(
      name: 'junk_1867_conventions_present (Task 1867)',
      run: _checkJunk1867ConventionsPresent,
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
    // Task 1867 (a): compacted onto the layer table — see kLayerForbiddenRules.
    return _runLayerForbiddenRule(
      kLayerForbiddenRules.firstWhere(
        (rule) =>
            rule.legacyCheck ==
            'warp_prism_runtime contains no Flutter imports',
      ),
    );
  }

  List<String> _checkInteractionPureDart() {
    // Task 1867 (a): compacted onto the layer table — see kLayerForbiddenRules.
    return _runLayerForbiddenRule(
      kLayerForbiddenRules.firstWhere(
        (rule) => rule.legacyCheck == 'warp_prism_interaction is pure Dart',
      ),
    );
  }

  List<String> _checkUiNoBindingsImports() {
    // Task 1867 (a): compacted onto the layer table — see kLayerForbiddenRules.
    return _runLayerForbiddenRule(
      kLayerForbiddenRules.firstWhere(
        (rule) =>
            rule.legacyCheck ==
            'warp_prism_ui does not import warp_prism_bindings',
      ),
    );
  }

  List<String> _checkNoAdapterFrbImports() {
    // Task 1867 (a): compacted onto the layer table — see kLayerForbiddenRules.
    return _runLayerForbiddenRule(
      kLayerForbiddenRules.firstWhere(
        (rule) =>
            rule.legacyCheck ==
            'warp_prism_adapter_frb is not imported by ui/interaction/runtime',
      ),
    );
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
          RegExp(
            r'\b(Ganthritor|Cersei|OmniRoute|CyberCore|Warpblade|Tempest)\b',
          ),
        ),
      );
    }
    return violations;
  }

  List<String> _checkNoDirectFrbGeneratedImports() {
    // Task 1867 (a): compacted onto the layer table — see kLayerForbiddenRules.
    return _runLayerForbiddenRule(
      kLayerForbiddenRules.firstWhere(
        (rule) =>
            rule.legacyCheck ==
            'FRB generated files are not imported directly by widgets',
      ),
    );
  }

  List<String> _checkBindingsNoFrbGenerated() {
    // Task 1867 (a): compacted onto the layer table — see kLayerForbiddenRules.
    return _runLayerForbiddenRule(
      kLayerForbiddenRules.firstWhere(
        (rule) =>
            rule.legacyCheck ==
            'warp_prism_bindings does not import FRB generated surfaces',
      ),
    );
  }

  /// Task 1868 (F-01) contract check: capability-gated action authority.
  ///
  /// EXPERIMENTAL scope: IDS `ActionAvailability`/`CapabilityState` stay pure
  /// Dart with deterministic fail-closed resolution; the ADS `DSActionGate`
  /// molecule stays dependency-light (no bindings/FRB/generated imports),
  /// always renders (never hidden) with a Semantics announcement and a
  /// refusal path; the generic allow/constrain/deny vocabulary lives only in
  /// tokens; no `PrismActionGate` public alias exists yet (promotion defers
  /// to the STABLE task, which must update this check).
  List<String> _checkActionGate1868Authority() {
    final violations = <String>[];

    final idsFile = File(
      '${repoRoot.path}/packages/warp_prism_interaction/lib/src/input/action_availability.dart',
    );
    if (!idsFile.existsSync()) {
      violations.add(
        'Missing required file: packages/warp_prism_interaction/lib/src/input/action_availability.dart',
      );
    } else {
      final text = idsFile.readAsStringSync();
      final lines = text.split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (RegExp(
          r'''^\s*import\s+['"](dart:ui|package:flutter(?=/))''',
        ).hasMatch(line)) {
          violations.add(
            'packages/warp_prism_interaction/lib/src/input/action_availability.dart:${i + 1}: must stay pure Dart: ${line.trim()}',
          );
        }
        if (line.contains('DateTime.now') || line.contains('Random(')) {
          violations.add(
            'packages/warp_prism_interaction/lib/src/input/action_availability.dart:${i + 1}: outcome resolution must be deterministic (no time/random): ${line.trim()}',
          );
        }
      }
      for (final symbol in [
        'ActionAvailability',
        'CapabilityState',
        'availabilityFor',
        'ReferenceAvailabilityPolicy',
      ]) {
        if (!text.contains(symbol)) {
          violations.add(
            'packages/warp_prism_interaction/lib/src/input/action_availability.dart: missing required symbol $symbol',
          );
        }
      }
    }

    final gateFile = File(
      '${repoRoot.path}/packages/warp_prism_ui/lib/src/molecules/ds_action_gate.dart',
    );
    if (!gateFile.existsSync()) {
      violations.add(
        'Missing required file: packages/warp_prism_ui/lib/src/molecules/ds_action_gate.dart',
      );
    } else {
      final text = gateFile.readAsStringSync();
      final lines = text.split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (RegExp(
          r'''^\s*import\s+['"]package:(warp_prism_bindings|warp_prism_adapter_frb|flutter_rust_bridge)(?=/|['"])''',
        ).hasMatch(line)) {
          violations.add(
            'packages/warp_prism_ui/lib/src/molecules/ds_action_gate.dart:${i + 1}: forbidden dependency: ${line.trim()}',
          );
        }
        if (RegExp(
          r'''^\s*import\s+['"].*(?:src/rust/|frb_generated)''',
        ).hasMatch(line)) {
          violations.add(
            'packages/warp_prism_ui/lib/src/molecules/ds_action_gate.dart:${i + 1}: forbidden generated import: ${line.trim()}',
          );
        }
        if (line.contains('Offstage(') || line.contains('Visibility(')) {
          violations.add(
            'packages/warp_prism_ui/lib/src/molecules/ds_action_gate.dart:${i + 1}: denied actions must never be hidden: ${line.trim()}',
          );
        }
      }
      for (final symbol in [
        'DSActionGate',
        'Semantics',
        'onRefused',
        'announcement',
      ]) {
        if (!text.contains(symbol)) {
          violations.add(
            'packages/warp_prism_ui/lib/src/molecules/ds_action_gate.dart: missing required symbol $symbol',
          );
        }
      }
    }

    final tokensFile = File(
      '${repoRoot.path}/packages/warp_prism_ui/lib/src/tokens/ds_action_authority.dart',
    );
    if (!tokensFile.existsSync()) {
      violations.add(
        'Missing required file: packages/warp_prism_ui/lib/src/tokens/ds_action_authority.dart',
      );
    } else {
      final text = tokensFile.readAsStringSync();
      for (final symbol in ['DSActionAuthority', 'DSActionAuthorityUI']) {
        if (!text.contains(symbol)) {
          violations.add(
            'packages/warp_prism_ui/lib/src/tokens/ds_action_authority.dart: missing required symbol $symbol',
          );
        }
      }
    }

    final aliasesFile = File(
      '${repoRoot.path}/packages/warp_prism_ui/lib/src/prism_aliases.dart',
    );
    if (aliasesFile.existsSync()) {
      final aliasesText = aliasesFile.readAsStringSync();
      if (aliasesText.contains('ActionGate')) {
        violations.add(
          'packages/warp_prism_ui/lib/src/prism_aliases.dart: Task 1868 is EXPERIMENTAL — no PrismActionGate alias until promotion',
        );
      }
    }

    return violations;
  }

  /// Task 1869: `DSStateType` must declare the fail-closed `unknown` value
  /// with neutral token support.
  List<String> _checkHonestUnknownDsState() {
    final violations = <String>[];
    const rel =
        'packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final text = file.readAsStringSync();
    for (final symbol in [
      'unknown,',
      'DSStateSurface.unknown',
      'statusUnknown',
      'isIndeterminate',
      'Unknown: state not yet determined',
    ]) {
      if (!text.contains(symbol)) {
        violations.add('$rel: missing required honest-unknown symbol $symbol');
      }
    }
    return violations;
  }

  /// Task 1869: no `unknown` code path may resolve to a success, action, or
  /// verified token. Scans the state-surface source for fail-open mappings.
  List<String> _checkHonestUnknownFailClosed() {
    final violations = <String>[];
    const rel =
        'packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (!line.contains('unknown')) continue;
      for (final failOpen in [
        'statusSuccess',
        'statusApproved',
        'statusHealthy',
        'accentBlue',
        'CircularProgressIndicator',
      ]) {
        if (line.contains(failOpen)) {
          violations.add(
            '$rel:${i + 1}: unknown must never map to $failOpen: ${line.trim()}',
          );
        }
      }
    }
    return violations;
  }

  /// Task 1869: query IDS must declare unknown / abstained / notAttempted
  /// with transition-table and controller support.
  List<String> _checkHonestUnknownQueryVocabulary() {
    final violations = <String>[];
    const stateRel =
        'packages/warp_prism_interaction/lib/src/query/query_state.dart';
    final stateFile = File('${repoRoot.path}/$stateRel');
    if (!stateFile.existsSync()) {
      return ['Missing required file: $stateRel'];
    }
    final stateText = stateFile.readAsStringSync();
    for (final symbol in [
      'unknown,',
      'abstained,',
      'notAttempted,',
      'markUnknown,',
      'abstain,',
      'isIndeterminate',
      'QueryState.unknown',
      'QueryState.abstained',
      'QueryState.notAttempted',
    ]) {
      if (!stateText.contains(symbol)) {
        violations.add('$stateRel: missing required symbol $symbol');
      }
    }
    const controllerRel =
        'packages/warp_prism_interaction/lib/src/query/query_controller.dart';
    final controllerFile = File('${repoRoot.path}/$controllerRel');
    if (!controllerFile.existsSync()) {
      violations.add('Missing required file: $controllerRel');
    } else {
      final controllerText = controllerFile.readAsStringSync();
      for (final symbol in [
        'markUnknownExecution',
        'abstainExecution',
        'skip(',
      ]) {
        if (!controllerText.contains(symbol)) {
          violations.add('$controllerRel: missing required symbol $symbol');
        }
      }
    }
    return violations;
  }

  /// Task 1869: inspection IDS must declare the unknown lifecycle position.
  List<String> _checkHonestUnknownInspectionVocabulary() {
    final violations = <String>[];
    const rel =
        'packages/warp_prism_interaction/lib/src/inspection/inspection_state.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final text = file.readAsStringSync();
    for (final symbol in ['InspectionLifecycle.unknown', 'isUnknown']) {
      if (!text.contains(symbol)) {
        violations.add('$rel: missing required symbol $symbol');
      }
    }
    return violations;
  }

  /// Task 1869: indeterminate states are excluded from golden capture —
  /// no golden test may reference unknown/abstained/notAttempted.
  List<String> _checkHonestUnknownGoldensExcludeIndeterminate() {
    final violations = <String>[];
    final goldensDir = Directory(
      '${repoRoot.path}/packages/warp_prism_ui/test/goldens',
    );
    if (!goldensDir.existsSync()) {
      return [
        'Missing required directory: packages/warp_prism_ui/test/goldens',
      ];
    }
    final pattern = RegExp(r'\bunknown\b', caseSensitive: false);
    final files =
        goldensDir
            .listSync(recursive: false, followLinks: false)
            .whereType<File>()
            .where((file) => file.path.endsWith('_test.dart'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    for (final file in files) {
      if (pattern.hasMatch(file.readAsStringSync())) {
        violations.add(
          '${_relativePath(file)}: golden test must not capture indeterminate states',
        );
      }
    }
    return violations;
  }

  /// Task 1875: the transport seam carries no time ontology.
  ///
  /// The three EXPERIMENTAL lib files must not name SMPTE/BPM vocabulary,
  /// frame-rate or meter semantics, or date/time types: position, duration,
  /// and intervals are opaque caller numbers rendered through injected
  /// formatters. Scans lib sources only (tests may stage caller fixtures).
  List<String> _checkTransport1875NoTimeOntology() {
    final violations = <String>[];
    for (final rel in [
      'packages/warp_prism_ui/lib/src/organisms/transport_bar/ds_transport_bar.dart',
      'packages/warp_prism_ui/lib/src/atoms/ds_timecode_badge.dart',
      'packages/warp_prism_ui/lib/src/atoms/ds_timebase_badge.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final forbidden in [
          'SMPTE',
          'BPM',
          'Bpm',
          'bpm',
          'DateTime',
          'TimeSignature',
          'framesPerSecond',
          'frameRate',
        ]) {
          if (line.contains(forbidden)) {
            violations.add(
              '$rel:${i + 1}: time ontology must stay caller-side, found `$forbidden`: ${line.trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1875: rendering is deterministic — no wall-clock, timers, or
  /// randomness in the transport seam. Time arrives injected; the widgets
  /// never advance it.
  List<String> _checkTransport1875NoWallclockOrTimers() {
    final violations = <String>[];
    for (final rel in [
      'packages/warp_prism_ui/lib/src/organisms/transport_bar/ds_transport_bar.dart',
      'packages/warp_prism_ui/lib/src/atoms/ds_timecode_badge.dart',
      'packages/warp_prism_ui/lib/src/atoms/ds_timebase_badge.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final forbidden in ['DateTime.now', 'Timer(', 'Random(']) {
          if (line.contains(forbidden)) {
            violations.add(
              '$rel:${i + 1}: deterministic rendering only, found `$forbidden`: ${line.trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1875: the transport seam stays dependency-light per layer law —
  /// no bindings/FRB/generated imports, no state-routing frameworks, no IO.
  List<String> _checkTransport1875NoForbiddenImports() {
    final violations = <String>[];
    final importPattern = RegExp(
      r'''^\s*import\s+['"]package:(warp_prism_bindings|warp_prism_adapter_frb|flutter_rust_bridge|flutter_riverpod|riverpod|go_router)(?=/|['"])|['"](dart:io)['"]''',
    );
    final generatedPattern = RegExp(
      r'''^\s*import\s+['"].*(?:src/rust/|frb_generated)''',
    );
    for (final rel in [
      'packages/warp_prism_ui/lib/src/organisms/transport_bar/ds_transport_bar.dart',
      'packages/warp_prism_ui/lib/src/atoms/ds_timecode_badge.dart',
      'packages/warp_prism_ui/lib/src/atoms/ds_timebase_badge.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (importPattern.hasMatch(line) || generatedPattern.hasMatch(line)) {
          violations.add('$rel:${i + 1}: forbidden dependency: ${line.trim()}');
        }
      }
    }
    return violations;
  }

  /// Task 1875: EXPERIMENTAL means no barrel export and no Prism alias.
  ///
  /// The layer contracts (§9) grant barrel export only at STABLE. Until the
  /// promotion task, none of the layer barrels, the public barrel, or the
  /// alias file may name the transport seam.
  List<String> _checkTransport1875NoBarrelExport() {
    final violations = <String>[];
    const markers = [
      'transport_bar',
      'timecode_badge',
      'timebase_badge',
      'TransportBar',
      'TransportRange',
      'TransportFormat',
      'TimecodeBadge',
      'TimebaseBadge',
    ];
    for (final rel in [
      'packages/warp_prism_ui/lib/src/organisms/organisms.dart',
      'packages/warp_prism_ui/lib/src/atoms/atoms.dart',
      'packages/warp_prism_ui/lib/src/molecules/molecules.dart',
      'packages/warp_prism_ui/lib/warp_prism_ui.dart',
      'packages/warp_prism_ui/lib/src/prism_aliases.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final marker in markers) {
          if (lines[i].contains(marker)) {
            violations.add(
              '$rel:${i + 1}: EXPERIMENTAL seam must stay out of barrels: ${lines[i].trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1870 (F-03) contract check: IDS command module stays pure Dart.
  ///
  /// EXPERIMENTAL scope: `src/command/` owns identity/label/chord/
  /// applicability/enabled-reason/enumeration with collision/precedence
  /// rules. It must import no Flutter, consume the frozen 1868
  /// `ActionAvailability` outcome (never re-invent availability), and prove
  /// determinism (no wall-clock, no randomness).
  List<String> _checkRegistry1870CommandModulePure() {
    final violations = <String>[];
    const moduleFiles = [
      'packages/warp_prism_interaction/lib/src/command/command_chord.dart',
      'packages/warp_prism_interaction/lib/src/command/command_context.dart',
      'packages/warp_prism_interaction/lib/src/command/command_intent.dart',
      'packages/warp_prism_interaction/lib/src/command/command_registry.dart',
      'packages/warp_prism_interaction/lib/src/command/command_router.dart',
      'packages/warp_prism_interaction/lib/src/command/command.dart',
    ];
    for (final rel in moduleFiles) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (RegExp(
          r'''^\s*import\s+['"](dart:ui|package:flutter(?=/))''',
        ).hasMatch(line)) {
          violations.add('$rel:${i + 1}: must stay pure Dart: ${line.trim()}');
        }
        if (line.contains('DateTime.now') || line.contains('Random(')) {
          violations.add(
            '$rel:${i + 1}: registry resolution must be deterministic: ${line.trim()}',
          );
        }
      }
    }
    final registryFile = File(
      '${repoRoot.path}/packages/warp_prism_interaction/lib/src/command/command_registry.dart',
    );
    if (registryFile.existsSync()) {
      final text = registryFile.readAsStringSync();
      for (final symbol in [
        'CommandIntent',
        'CommandRegistry',
        'CommandCollision',
        'ChordResolution',
        'ReferenceCommandCatalog',
        'ActionAvailability',
      ]) {
        if (!text.contains(symbol)) {
          violations.add(
            'packages/warp_prism_interaction/lib/src/command/command_registry.dart: missing required symbol $symbol',
          );
        }
      }
    }
    final routerFile = File(
      '${repoRoot.path}/packages/warp_prism_interaction/lib/src/command/command_router.dart',
    );
    if (routerFile.existsSync()) {
      final text = routerFile.readAsStringSync();
      for (final symbol in [
        'CommandRouter',
        'CommandRoute',
        'CommandDispatch',
        'CommandRefusal',
        'CommandRefusalKind',
        'editingHasFocus',
      ]) {
        if (!text.contains(symbol)) {
          violations.add(
            'packages/warp_prism_interaction/lib/src/command/command_router.dart: missing required symbol $symbol',
          );
        }
      }
    }
    return violations;
  }

  /// Task 1870: EXPERIMENTAL means no export from the interaction barrel.
  List<String> _checkRegistry1870InteractionBarrelHidesCommand() {
    final violations = <String>[];
    const rel =
        'packages/warp_prism_interaction/lib/warp_prism_interaction.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].contains('command')) {
        violations.add(
          '$rel:${i + 1}: EXPERIMENTAL command module must stay out of the barrel: ${lines[i].trim()}',
        );
      }
    }
    return violations;
  }

  /// Task 1870: runtime describe() seam stays pure and presentation-free.
  List<String> _checkRegistry1870RuntimeDescribePure() {
    final violations = <String>[];
    const rel =
        'packages/warp_prism_runtime/lib/src/describe/runtime_describe.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final text = file.readAsStringSync();
    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (RegExp(
        r'''^\s*import\s+['"](dart:ui|package:flutter(?=/))''',
      ).hasMatch(line)) {
        violations.add('$rel:${i + 1}: must stay pure Dart: ${line.trim()}');
      }
      if (line.contains('package:warp_prism_interaction')) {
        violations.add(
          '$rel:${i + 1}: runtime must not import interaction (leaf law): ${line.trim()}',
        );
      }
      if (line.contains('Offset') ||
          line.contains('Widget') ||
          line.contains('BuildContext') ||
          line.contains('Color')) {
        violations.add(
          '$rel:${i + 1}: no presentation concepts in runtime: ${line.trim()}',
        );
      }
    }
    for (final symbol in [
      'RuntimeDescribable',
      'CommandDispatchRecord',
      'describe()',
      'CommandDispatchOutcome',
    ]) {
      if (!text.contains(symbol)) {
        violations.add('$rel: missing required symbol $symbol');
      }
    }
    const barrelRel = 'packages/warp_prism_runtime/lib/warp_prism_runtime.dart';
    final barrelFile = File('${repoRoot.path}/$barrelRel');
    if (barrelFile.existsSync()) {
      final barrelLines = barrelFile.readAsLinesSync();
      for (var i = 0; i < barrelLines.length; i++) {
        if (barrelLines[i].contains('describe')) {
          violations.add(
            '$barrelRel:${i + 1}: EXPERIMENTAL describe seam must stay out of the barrel: ${barrelLines[i].trim()}',
          );
        }
      }
    }
    return violations;
  }

  /// Task 1870: palette stays presentation — no runtime/eligibility imports,
  /// disabled reason propagated as data, never hidden.
  List<String> _checkRegistry1870PaletteStaysPresentation() {
    final violations = <String>[];
    const rel =
        'packages/warp_prism_ui/lib/src/organisms/command_palette/ds_command_palette.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final text = file.readAsStringSync();
    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (RegExp(
        r'''^\s*import\s+['"]package:(warp_prism_interaction|warp_prism_runtime|warp_prism_bindings|warp_prism_adapter_frb|flutter_rust_bridge)(?=/|['"])''',
      ).hasMatch(line)) {
        violations.add(
          '$rel:${i + 1}: palette must stay presentation (no eligibility/runtime imports): ${line.trim()}',
        );
      }
      if (line.contains('Offstage(') || line.contains('Visibility(')) {
        violations.add(
          '$rel:${i + 1}: denied commands must never be hidden: ${line.trim()}',
        );
      }
    }
    for (final symbol in [
      'disabledReason',
      'onDisabledCommand',
      'isEnabled',
      'Disabled: ',
    ]) {
      if (!text.contains(symbol)) {
        violations.add('$rel: missing required symbol $symbol');
      }
    }
    return violations;
  }

  /// Task 1870: router molecule stays scoped — no barrel export, no Prism
  /// alias, no hidden surfaces, edit-focus guard present.
  List<String> _checkRegistry1870RouterMoleculeScoped() {
    final violations = <String>[];
    const rel =
        'packages/warp_prism_ui/lib/src/molecules/ds_command_router.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      violations.add('Missing required file: $rel');
    } else {
      final text = file.readAsStringSync();
      final lines = text.split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (RegExp(
          r'''^\s*import\s+['"]package:(warp_prism_interaction|warp_prism_runtime|warp_prism_bindings|warp_prism_adapter_frb|flutter_rust_bridge)(?=/|['"])''',
        ).hasMatch(line)) {
          violations.add(
            '$rel:${i + 1}: router must stay presentation-only: ${line.trim()}',
          );
        }
        if (line.contains('Offstage(') || line.contains('Visibility(')) {
          violations.add(
            '$rel:${i + 1}: routed commands must never be hidden: ${line.trim()}',
          );
        }
      }
      for (final symbol in [
        'DSCommandRouter',
        'editingHasFocus',
        'onDispatch',
        'onRefused',
        'normalizeChordDisplay',
      ]) {
        if (!text.contains(symbol)) {
          violations.add('$rel: missing required symbol $symbol');
        }
      }
    }
    for (final barrelRel in [
      'packages/warp_prism_ui/lib/src/molecules/molecules.dart',
      'packages/warp_prism_ui/lib/warp_prism_ui.dart',
      'packages/warp_prism_ui/lib/src/prism_aliases.dart',
    ]) {
      final barrelFile = File('${repoRoot.path}/$barrelRel');
      if (!barrelFile.existsSync()) continue;
      final barrelLines = barrelFile.readAsLinesSync();
      for (var i = 0; i < barrelLines.length; i++) {
        if (barrelLines[i].contains('ds_command_router') ||
            barrelLines[i].contains('CommandRouter')) {
          violations.add(
            '$barrelRel:${i + 1}: EXPERIMENTAL router must stay out of barrels/aliases: ${barrelLines[i].trim()}',
          );
        }
      }
    }
    return violations;
  }

  /// Task 1870: tool-strip item carries the disabled reason, never hidden.
  List<String> _checkRegistry1870ToolstripReason() {
    final violations = <String>[];
    const rel =
        'packages/warp_prism_ui/lib/src/organisms/tool_strip_slideout/ds_tool_strip_slideout.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final text = file.readAsStringSync();
    for (final symbol in ['disabledReason', 'isEnabled', 'Disabled: ']) {
      if (!text.contains(symbol)) {
        violations.add('$rel: missing required symbol $symbol');
      }
    }
    return violations;
  }

  /// Task 1870: EXPERIMENTAL means no new Prism aliases for the seam.
  List<String> _checkRegistry1870NoNewPrismAliases() {
    final violations = <String>[];
    const rel = 'packages/warp_prism_ui/lib/src/prism_aliases.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      for (final marker in [
        'CommandRegistry',
        'CommandRouter',
        'CommandIntent',
        'CommandChord',
        'CommandDispatchRecord',
        'RuntimeDescribable',
      ]) {
        if (lines[i].contains(marker)) {
          violations.add(
            '$rel:${i + 1}: EXPERIMENTAL seam must not gain a Prism alias until promotion: ${lines[i].trim()}',
          );
        }
      }
    }
    return violations;
  }

  /// Task 1873 (F-06) contract check: IDS slot machine stays pure Dart.
  ///
  /// EXPERIMENTAL scope: `src/state_machine/shell_slot_machine.dart` owns
  /// slot/active-pane/focus-token semantics with deterministic refocus +
  /// scroll_to edges. It may consume the frozen 1868 `action_availability`
  /// shape but must import no Flutter, and prove determinism (no
  /// wall-clock, no randomness).
  List<String> _checkShell1873SlotMachinePure() {
    final violations = <String>[];
    const rel =
        'packages/warp_prism_interaction/lib/src/state_machine/shell_slot_machine.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (RegExp(
        r'''^\s*import\s+['"](dart:ui|package:flutter(?=/))''',
      ).hasMatch(line)) {
        violations.add('$rel:${i + 1}: must stay pure Dart: ${line.trim()}');
      }
      if (line.contains('DateTime.now') || line.contains('Random(')) {
        violations.add(
          '$rel:${i + 1}: token resolution must be deterministic: ${line.trim()}',
        );
      }
    }
    final text = file.readAsStringSync();
    for (final symbol in [
      'ShellSlotMachine',
      'FocusReturnToken',
      'ShellLayout',
      'ShellRegion',
      'refocus',
      'scrollTo',
      'availabilityFor',
    ]) {
      if (!text.contains(symbol)) {
        violations.add('$rel: missing required symbol $symbol');
      }
    }
    return violations;
  }

  /// Task 1873: router organism stays presentation-only and scoped.
  List<String> _checkShell1873RouterScoped() {
    final violations = <String>[];
    const rel =
        'packages/warp_prism_ui/lib/src/organisms/shell_router/ds_shell_router.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final text = file.readAsStringSync();
    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (RegExp(
        r'''^\s*import\s+['"]package:(warp_prism_interaction|warp_prism_runtime|warp_prism_bindings|warp_prism_adapter_frb|flutter_rust_bridge)(?=/|['"])|['"](dart:io)['"]''',
      ).hasMatch(line)) {
        violations.add(
          '$rel:${i + 1}: router must stay presentation-only: ${line.trim()}',
        );
      }
      if (line.contains('Offstage(') || line.contains('Visibility(')) {
        violations.add(
          '$rel:${i + 1}: routed panes must never be hidden: ${line.trim()}',
        );
      }
    }
    for (final symbol in [
      'DSShellRouter',
      'DSFocusReturnToken',
      'DSShell',
      'DSSplitPane',
      'Semantics',
      'onFocusRestored',
    ]) {
      if (!text.contains(symbol)) {
        violations.add('$rel: missing required symbol $symbol');
      }
    }
    return violations;
  }

  /// Task 1873: sidebar section model stays presentation-only.
  List<String> _checkShell1873SidebarSectionsScoped() {
    final violations = <String>[];
    const rel =
        'packages/warp_prism_ui/lib/src/organisms/ds_sidebar_sections.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final text = file.readAsStringSync();
    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (RegExp(
        r'''^\s*import\s+['"]package:(warp_prism_interaction|warp_prism_runtime|warp_prism_bindings|warp_prism_adapter_frb|flutter_rust_bridge)(?=/|['"])''',
      ).hasMatch(line)) {
        violations.add(
          '$rel:${i + 1}: sections must stay presentation-only: ${line.trim()}',
        );
      }
    }
    for (final symbol in [
      'DSSidebarSection',
      'DSSidebarRowGateData',
      'DSSidebarRowFlags',
      'DSSidebarSections',
      'keptRowIds',
      'insertionIndex',
      'starred',
      'unreadCount',
    ]) {
      if (!text.contains(symbol)) {
        violations.add('$rel: missing required symbol $symbol');
      }
    }
    return violations;
  }

  /// Task 1873: EXPERIMENTAL means no barrel export and no Prism alias.
  List<String> _checkShell1873NoBarrelExport() {
    final violations = <String>[];
    const markers = [
      'shell_slot_machine',
      'shell_router',
      'sidebar_sections',
      'ShellSlotMachine',
      'FocusReturnToken',
      'ShellLayout',
      'ShellRegion',
      'ShellSlot',
      'SidebarSection',
      'SidebarRowGate',
      'ShellRouter',
    ];
    for (final rel in [
      'packages/warp_prism_ui/lib/src/organisms/organisms.dart',
      'packages/warp_prism_ui/lib/src/atoms/atoms.dart',
      'packages/warp_prism_ui/lib/src/molecules/molecules.dart',
      'packages/warp_prism_ui/lib/warp_prism_ui.dart',
      'packages/warp_prism_ui/lib/src/prism_aliases.dart',
      'packages/warp_prism_interaction/lib/warp_prism_interaction.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final marker in markers) {
          if (lines[i].contains(marker)) {
            violations.add(
              '$rel:${i + 1}: EXPERIMENTAL seam must stay out of barrels: ${lines[i].trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1872 (F-05): the opaque-hash rule is mechanically guarded.
  ///
  /// EXPERIMENTAL scope: the provenance/witness/lineage seam must never
  /// gain hashing, fingerprinting, verification, or signing logic — hashes
  /// arrive opaque from the consumer and are display-truncated only.
  List<String> _checkLineage1872NoHashVerificationLogic() {
    final violations = <String>[];
    const rels = [
      'packages/warp_prism_ui/lib/src/atoms/ds_provenance_badge.dart',
      'packages/warp_prism_ui/lib/src/atoms/ds_witness_badge.dart',
      'packages/warp_prism_ui/lib/src/molecules/ds_lineage_strip.dart',
    ];
    for (final rel in rels) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final forbidden in [
          'package:crypto',
          'sha256',
          'SHA-256',
          'Sha256',
          'Digest(',
          'MessageDigest',
          'md5',
          'MD5',
          'sha1',
          'SHA-1',
          'Hmac',
          'hmac',
          'Blake',
          'blake',
          'computeHash',
          'verifyHash',
          'signReceipt',
          'encrypt',
          'decrypt',
          'hashCode',
        ]) {
          if (line.contains(forbidden)) {
            violations.add(
              '$rel:${i + 1}: opaque-hash rule — Prism must never compute or verify hashes, found `$forbidden`: ${line.trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1872: EXPERIMENTAL means no barrel export and no Prism alias.
  List<String> _checkLineage1872NoBarrelExport() {
    final violations = <String>[];
    const markers = [
      'provenance_badge',
      'witness_badge',
      'lineage_strip',
      'ProvenanceBadge',
      'WitnessBadge',
      'LineageStrip',
    ];
    for (final rel in [
      'packages/warp_prism_ui/lib/src/atoms/atoms.dart',
      'packages/warp_prism_ui/lib/src/molecules/molecules.dart',
      'packages/warp_prism_ui/lib/warp_prism_ui.dart',
      'packages/warp_prism_ui/lib/src/prism_aliases.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final marker in markers) {
          if (lines[i].contains(marker)) {
            violations.add(
              '$rel:${i + 1}: EXPERIMENTAL seam must stay out of barrels: ${lines[i].trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1872: the `unknown` witness state consumes Task 1869's frozen
  /// vocabulary — neutral token, non-animated, fail-closed rendering.
  List<String> _checkLineage1872UnknownConsumes1869() {
    final violations = <String>[];
    const rel = 'packages/warp_prism_ui/lib/src/atoms/ds_witness_badge.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final text = file.readAsStringSync();
    for (final symbol in [
      'DSWitnessState.unknown',
      'statusUnknown',
      'isIndeterminate',
      'help_outline',
    ]) {
      if (!text.contains(symbol)) {
        violations.add('$rel: missing required 1869-vocabulary symbol $symbol');
      }
    }
    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].contains('CircularProgressIndicator')) {
        violations.add(
          '$rel:${i + 1}: unknown is indeterminate, never in-flight: ${lines[i].trim()}',
        );
      }
    }
    return violations;
  }

  /// Task 1874 (F-07) contract check: IDS timeline module stays pure Dart.
  ///
  /// EXPERIMENTAL scope: `src/timeline/` owns verb/edit typing, 1868-gated
  /// resolution, the scrub-session commit edge, the injected-model interface
  /// plus reference fake, and proportional pixel mapping. It must import no
  /// Flutter, consume the frozen 1868 `ActionAvailability` outcome (never
  /// re-invent gating), and prove determinism (no wall-clock, no randomness).
  List<String> _checkTimeline1874InteractionModulePure() {
    final violations = <String>[];
    const moduleFiles = [
      'packages/warp_prism_interaction/lib/src/timeline/timeline_intent.dart',
      'packages/warp_prism_interaction/lib/src/timeline/timeline_model.dart',
    ];
    for (final rel in moduleFiles) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (RegExp(
          r'''^\s*import\s+['"](dart:ui|package:flutter(?=/))''',
        ).hasMatch(line)) {
          violations.add('$rel:${i + 1}: must stay pure Dart: ${line.trim()}');
        }
        if (line.contains('DateTime.now') || line.contains('Random(')) {
          violations.add(
            '$rel:${i + 1}: verb resolution must be deterministic: ${line.trim()}',
          );
        }
      }
    }
    final intentFile = File(
      '${repoRoot.path}/packages/warp_prism_interaction/lib/src/timeline/timeline_intent.dart',
    );
    if (intentFile.existsSync()) {
      final text = intentFile.readAsStringSync();
      for (final symbol in [
        'TimelineIntent',
        'TimelineSeek',
        'TimelineScrubStart',
        'TimelineScrubUpdate',
        'TimelineScrubEnd',
        'TimelineStep',
        'TimelineEdit',
        'TimelineSet',
        'TimelineScrub',
        'TimelineResolution',
        'TimelineDispatch',
        'TimelineRefusal',
        'TimelineScrubSession',
        'resolveTimelineVerb',
        'ActionAvailability',
        'timeForPixel',
        'pixelForTime',
      ]) {
        if (!text.contains(symbol)) {
          violations.add(
            'packages/warp_prism_interaction/lib/src/timeline/timeline_intent.dart: missing required symbol $symbol',
          );
        }
      }
    }
    final modelFile = File(
      '${repoRoot.path}/packages/warp_prism_interaction/lib/src/timeline/timeline_model.dart',
    );
    if (modelFile.existsSync()) {
      final text = modelFile.readAsStringSync();
      for (final symbol in [
        'TimelineModel',
        'ReferenceTimelineModel',
        'historySteps',
        'applyGesture',
      ]) {
        if (!text.contains(symbol)) {
          violations.add(
            'packages/warp_prism_interaction/lib/src/timeline/timeline_model.dart: missing required symbol $symbol',
          );
        }
      }
    }
    return violations;
  }

  /// Task 1874: the timeline seam carries no time ontology.
  ///
  /// Prism chrome renders caller-computed ticks and caller-formatted strings;
  /// tempo/meter/frame/clock vocabulary must stay product-local. Scans lib
  /// sources only (tests may stage caller fixtures).
  List<String> _checkTimeline1874NoTimeOntology() {
    final violations = <String>[];
    for (final rel in [
      'packages/warp_prism_interaction/lib/src/timeline/timeline_intent.dart',
      'packages/warp_prism_interaction/lib/src/timeline/timeline_model.dart',
      'packages/warp_prism_ui/lib/src/organisms/timeline/ds_time_ruler.dart',
      'packages/warp_prism_ui/lib/src/organisms/timeline/ds_track_lane.dart',
      'packages/warp_prism_ui/lib/src/organisms/timeline/ds_multitrack_timeline.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final forbidden in [
          'SMPTE',
          'BPM',
          'Bpm',
          'bpm',
          'DateTime',
          'TimeSignature',
          'framesPerSecond',
          'frameRate',
        ]) {
          if (line.contains(forbidden)) {
            violations.add(
              '$rel:${i + 1}: time ontology must stay caller-side, found `$forbidden`: ${line.trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1874: rendering is deterministic — no wall-clock, timers, or
  /// randomness in the timeline seam. Positions arrive injected; widgets
  /// never advance them.
  List<String> _checkTimeline1874NoWallclockOrTimers() {
    final violations = <String>[];
    for (final rel in [
      'packages/warp_prism_ui/lib/src/organisms/timeline/ds_time_ruler.dart',
      'packages/warp_prism_ui/lib/src/organisms/timeline/ds_track_lane.dart',
      'packages/warp_prism_ui/lib/src/organisms/timeline/ds_multitrack_timeline.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final forbidden in ['DateTime.now', 'Timer(', 'Random(']) {
          if (line.contains(forbidden)) {
            violations.add(
              '$rel:${i + 1}: deterministic rendering only, found `$forbidden`: ${line.trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1874: EXPERIMENTAL means no barrel export and no Prism alias.
  ///
  /// The layer contracts (§9) grant barrel export only at STABLE. Until the
  /// promotion task, none of the layer barrels, the public barrel, the alias
  /// file, or the interaction barrel may name the timeline seam.
  List<String> _checkTimeline1874NoBarrelExport() {
    final violations = <String>[];
    const markers = [
      'organisms/timeline/',
      'MultitrackTimeline',
      'TimeRuler',
      'TrackLane',
      'TimelineIntent',
      'TimelineEdit',
      'TimelineSet',
      'TimelineScrub',
      'TimelineModel',
      'ReferenceTimelineModel',
    ];
    for (final rel in [
      'packages/warp_prism_ui/lib/src/organisms/organisms.dart',
      'packages/warp_prism_ui/lib/warp_prism_ui.dart',
      'packages/warp_prism_ui/lib/src/prism_aliases.dart',
      'packages/warp_prism_interaction/lib/warp_prism_interaction.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final marker in markers) {
          if (lines[i].contains(marker)) {
            violations.add(
              '$rel:${i + 1}: EXPERIMENTAL seam must stay out of barrels: ${lines[i].trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1871 (F-04) contract check: EXPERIMENTAL review seam stays out of
  /// barrels and gains no Prism alias until the promotion task.
  List<String> _checkReview1871NoBarrelExport() {
    final violations = <String>[];
    const markers = [
      'ds_review_verdict',
      'ds_decision_review_surface',
      'ds_bounded_repair',
      'DecisionReviewSurface',
      'ReviewVerdict',
      'ReferenceReviewPolicy',
      'BoundedRepair',
      'RepairApprovalMode',
      'RepairReply',
      'VerdictGate',
      'DSReviewAction',
      'DSReviewEvidence',
    ];
    for (final rel in [
      'packages/warp_prism_ui/lib/src/organisms/organisms.dart',
      'packages/warp_prism_ui/lib/src/molecules/molecules.dart',
      'packages/warp_prism_ui/lib/src/atoms/atoms.dart',
      'packages/warp_prism_ui/lib/warp_prism_ui.dart',
      'packages/warp_prism_ui/lib/src/prism_aliases.dart',
      'packages/warp_prism_interaction/lib/warp_prism_interaction.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final marker in markers) {
          if (lines[i].contains(marker)) {
            violations.add(
              '$rel:${i + 1}: EXPERIMENTAL seam must stay out of barrels: ${lines[i].trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1871: the review seam stays dependency-light per layer law — no
  /// interaction/runtime/bindings/FRB/generated imports, no state-routing
  /// frameworks, no IO, no wall-clock, no randomness. Time and capability
  /// evaluation arrive as caller data; the seam never advances them.
  List<String> _checkReview1871NoForbiddenImports() {
    final violations = <String>[];
    final importPattern = RegExp(
      r'''^\s*import\s+['"]package:(warp_prism_interaction|warp_prism_runtime|warp_prism_bindings|warp_prism_adapter_frb|flutter_rust_bridge|flutter_riverpod|riverpod|go_router)(?=/|['"])|['"](dart:io)['"]''',
    );
    final generatedPattern = RegExp(
      r'''^\s*import\s+['"].*(?:src/rust/|frb_generated)''',
    );
    for (final rel in [
      'packages/warp_prism_ui/lib/src/organisms/ds_review_verdict.dart',
      'packages/warp_prism_ui/lib/src/organisms/ds_decision_review_surface.dart',
      'packages/warp_prism_ui/lib/src/molecules/ds_bounded_repair.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (importPattern.hasMatch(line) || generatedPattern.hasMatch(line)) {
          violations.add('$rel:${i + 1}: forbidden dependency: ${line.trim()}');
        }
        if (line.contains('DateTime.now') || line.contains('Random(')) {
          violations.add(
            '$rel:${i + 1}: deterministic rendering only, found `${line.trim()}`',
          );
        }
      }
    }
    return violations;
  }

  /// Task 1871: the review seam consumes the frozen 1868/1869 contracts
  /// instead of re-inventing them — indeterminacy through 1869's vocabulary
  /// and gating through 1868's outcome type with a tooltip reason per verdict.
  List<String> _checkReview1871UnknownConsumes1869AndGateConsumes1868() {
    final violations = <String>[];
    const requiredByFile = {
      'packages/warp_prism_ui/lib/src/organisms/ds_review_verdict.dart': [
        'DSReviewVerdict.unknown',
        'isIndeterminate',
        'DSActionAuthority',
        'ReferenceReviewPolicy',
      ],
      'packages/warp_prism_ui/lib/src/organisms/ds_decision_review_surface.dart':
          [
            'resolveReviewVerdict',
            'DSStateSurface.unknown',
            'DSActionGate',
            'onRefused',
            'Tooltip',
          ],
      'packages/warp_prism_ui/lib/src/molecules/ds_bounded_repair.dart': [
        'DSActionGate',
        'onRefused',
        'DSRepairApprovalMode',
        'undoPerReply',
        'Tooltip',
        'DSDialog',
      ],
    };
    requiredByFile.forEach((rel, symbols) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        return;
      }
      final text = file.readAsStringSync();
      for (final symbol in symbols) {
        if (!text.contains(symbol)) {
          violations.add(
            '$rel: missing required 1868/1869-contract symbol $symbol',
          );
        }
      }
    });
    return violations;
  }

  /// Task 1876 (F-09) contract check: EXPERIMENTAL startup seam stays out of
  /// barrels and gains no Prism alias until the promotion task.
  List<String> _checkStartup1876NoBarrelExport() {
    final violations = <String>[];
    const markers = ['startup_failure_view', 'StartupFailureView'];
    for (final rel in [
      'packages/warp_prism_ui/lib/src/organisms/organisms.dart',
      'packages/warp_prism_ui/lib/src/molecules/molecules.dart',
      'packages/warp_prism_ui/lib/src/atoms/atoms.dart',
      'packages/warp_prism_ui/lib/warp_prism_ui.dart',
      'packages/warp_prism_ui/lib/src/prism_aliases.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final marker in markers) {
          if (lines[i].contains(marker)) {
            violations.add(
              '$rel:${i + 1}: EXPERIMENTAL seam must stay out of barrels: ${lines[i].trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1876: the startup view must never render internals — no trace
  /// type, no debug-mode branch, no stringification of the caught failure.
  List<String> _checkStartup1876NoLeakRendering() {
    final violations = <String>[];
    const rel =
        'packages/warp_prism_ui/lib/src/molecules/ds_startup_failure_view.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      for (final forbidden in [
        'StackTrace',
        'stackTrace',
        'kDebugMode',
        '.toString()',
        'SocketException',
      ]) {
        if (line.contains(forbidden)) {
          violations.add(
            '$rel:${i + 1}: leak-negative — startup view must never render internals, found `$forbidden`: ${line.trim()}',
          );
        }
      }
    }
    final text = file.readAsStringSync();
    for (final symbol in [
      'DSStartupFailureView',
      'DSStartupFailureView.indeterminate',
      'static DSErrorBoundary guard',
      'DSErrorBoundary',
      'DSStateSurface.error',
      'defaultGuidance',
      'liveRegion',
      'cause',
    ]) {
      if (!text.contains(symbol)) {
        violations.add('$rel: missing required symbol $symbol');
      }
    }
    return violations;
  }

  /// Task 1876: the indeterminate startup case consumes Task 1869's frozen
  /// vocabulary — unknown surface, neutral token, fail-closed rendering.
  List<String> _checkStartup1876UnknownConsumes1869() {
    final violations = <String>[];
    const rel =
        'packages/warp_prism_ui/lib/src/molecules/ds_startup_failure_view.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final text = file.readAsStringSync();
    // Neutral-token rendering is inherited from the shared unknown surface
    // (DSColors.statusUnknown); the seam itself declares no colors.
    for (final symbol in [
      'DSStateSurface.unknown',
      'DSStateType.unknown',
      'isIndeterminate',
    ]) {
      if (!text.contains(symbol)) {
        violations.add('$rel: missing required 1869-vocabulary symbol $symbol');
      }
    }
    const surfaceRel =
        'packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart';
    final surfaceFile = File('${repoRoot.path}/$surfaceRel');
    if (!surfaceFile.existsSync()) {
      return ['Missing required file: $surfaceRel'];
    }
    final surfaceText = surfaceFile.readAsStringSync();
    for (final symbol in [
      'DSStateSurface.loadingPane',
      'DSStateSurface.loadingRow',
      'DSStateSurface.inlineError',
      'DSStateSurface.startupFailure',
      'DSStateSurface.bootstrapLoading',
    ]) {
      if (!surfaceText.contains(symbol)) {
        violations.add(
          '$surfaceRel: missing required convergence symbol $symbol',
        );
      }
    }
    return violations;
  }

  /// Task 1876: deterministic rendering — no animation, timers, wall-clock,
  /// or randomness in the startup seam. Loading arrives as static chrome;
  /// the failure view never animates (GOLD non-animated rationale).
  List<String> _checkStartup1876DeterministicNoAnimation() {
    final violations = <String>[];
    const rel =
        'packages/warp_prism_ui/lib/src/molecules/ds_startup_failure_view.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      for (final forbidden in [
        'CircularProgressIndicator',
        'Timer(',
        'DateTime.now',
        'Random(',
        'Animation',
        'Ticker',
        'Shimmer',
      ]) {
        if (line.contains(forbidden)) {
          violations.add(
            '$rel:${i + 1}: deterministic rendering only, found `$forbidden`: ${line.trim()}',
          );
        }
      }
    }
    return violations;
  }

  /// Task 1876: startup/loading states are excluded from golden capture —
  /// no golden test may reference the startup seam or converged loading
  /// constructors.
  List<String> _checkStartup1876GoldensExcludeStartup() {
    final violations = <String>[];
    final goldensDir = Directory(
      '${repoRoot.path}/packages/warp_prism_ui/test/goldens',
    );
    if (!goldensDir.existsSync()) {
      return [
        'Missing required directory: packages/warp_prism_ui/test/goldens',
      ];
    }
    final pattern = RegExp(
      r'StartupFailure|startupFailure|bootstrapLoading|loadingPane|loadingRow|inlineError',
    );
    final files =
        goldensDir
            .listSync(recursive: false, followLinks: false)
            .whereType<File>()
            .where((file) => file.path.endsWith('_test.dart'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    for (final file in files) {
      if (pattern.hasMatch(file.readAsStringSync())) {
        violations.add(
          '${_relativePath(file)}: golden test must not capture startup/loading states',
        );
      }
    }
    return violations;
  }

  /// Task 1859 (F-11) contract check: the executor seam stays pure Dart.
  ///
  /// EXPERIMENTAL scope: `async_job_executor.dart` (per-execution identity
  /// over existing contracts) and `media_terminality.dart` (verbatim refusal
  /// contract + terminality shape) must import no Flutter/FRB/adapter
  /// surfaces, carry no presentation policy, and never weaken the frozen
  /// single-flight `AsyncCommand` contract it builds upon.
  List<String> _checkExecutor1859RuntimeExecutorPurity() {
    final violations = <String>[];

    const executorRel =
        'packages/warp_prism_runtime/lib/src/async_command/async_job_executor.dart';
    const terminalityRel =
        'packages/warp_prism_runtime/lib/src/async_command/media_terminality.dart';
    const contractRel =
        'packages/warp_prism_runtime/lib/src/async_command/async_command_contract.dart';

    for (final rel in [executorRel, terminalityRel, contractRel]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
      }
    }

    final importPattern = RegExp(
      r'''^\s*import\s+['"](dart:ui|package:flutter(?=/))''',
    );
    final adapterPattern = RegExp(
      r'''^\s*import\s+['"]package:(warp_prism_bindings|warp_prism_adapter_frb|flutter_rust_bridge|warp_prism_ui)(?=/|['"])''',
    );
    final generatedPattern = RegExp(
      r'''^\s*import\s+['"].*(?:src/rust/|frb_generated)''',
    );
    for (final rel in [executorRel, terminalityRel]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (importPattern.hasMatch(line) ||
            adapterPattern.hasMatch(line) ||
            generatedPattern.hasMatch(line)) {
          violations.add(
            '$rel:${i + 1}: executor seam must stay pure Dart: ${line.trim()}',
          );
        }
        for (final forbidden in [
          'autoScroll',
          'auto-scroll',
          'followTail',
          'follow-tail',
          'Timer.periodic',
        ]) {
          if (line.contains(forbidden)) {
            violations.add(
              '$rel:${i + 1}: executor seam carries no presentation policy, found `$forbidden`: ${line.trim()}',
            );
          }
        }
      }
    }

    final contractFile = File('${repoRoot.path}/$contractRel');
    if (contractFile.existsSync()) {
      final text = contractFile.readAsStringSync();
      for (final marker in [
        'SINGLE-FLIGHT, CANCEL-AND-REPLACE',
        'cancel-and-replace',
      ]) {
        if (!text.contains(marker)) {
          violations.add(
            '$contractRel: missing frozen single-flight marker `$marker` — the AsyncCommand contract must stay byte-identical',
          );
        }
      }
    }

    return violations;
  }

  /// Task 1858 (F-10) contract check: EXPERIMENTAL job banner stays pure.
  ///
  /// EXPERIMENTAL scope: `ds_job_banner.dart` (staged progress + cancel +
  /// deterministic terminal receipt slot) must import no bindings/FRB/
  /// generated surfaces, no state-routing frameworks, no IO, no wall-clock,
  /// no timers, no randomness, and no animation drivers (determinate static
  /// chrome only). A toast is not a job: no toast imports either.
  List<String> _checkBanner1858NoForbiddenImports() {
    final violations = <String>[];
    const rel = 'packages/warp_prism_ui/lib/src/molecules/ds_job_banner.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final importPattern = RegExp(
      r'''^\s*import\s+['"]package:(warp_prism_bindings|warp_prism_adapter_frb|flutter_rust_bridge|flutter_riverpod|riverpod|go_router)(?=/|['"])|['"](dart:io)['"]''',
    );
    final generatedPattern = RegExp(
      r'''^\s*import\s+['"].*(?:src/rust/|frb_generated)''',
    );
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (importPattern.hasMatch(line) || generatedPattern.hasMatch(line)) {
        violations.add('$rel:${i + 1}: forbidden dependency: ${line.trim()}');
      }
      for (final forbidden in [
        'DateTime.now',
        'Timer(',
        'Random(',
        'AnimationController',
        'AnimatedBuilder',
        'AnimatedContainer',
        'Tween',
        'Ticker',
        'vsync',
        'CircularProgressIndicator',
        'DSToast',
        'ds_toast',
      ]) {
        if (line.contains(forbidden)) {
          violations.add(
            '$rel:${i + 1}: job banner must stay deterministic and toast-free, found `$forbidden`: ${line.trim()}',
          );
        }
      }
    }
    final text = file.readAsStringSync();
    for (final symbol in [
      'DSJobBanner',
      'DSJobBannerPhase',
      'DSJobStage',
      'LinearProgressIndicator',
      'onCancel',
      'cancelReason',
      'receipt',
    ]) {
      if (!text.contains(symbol)) {
        violations.add('$rel: missing required symbol $symbol');
      }
    }
    return violations;
  }

  /// Task 1858: EXPERIMENTAL means no barrel export and no Prism alias.
  ///
  /// The layer contracts (§9) grant barrel export only at STABLE. Until the
  /// promotion task, none of the layer barrels, the public barrel, or the
  /// alias file may name the job-banner seam.
  List<String> _checkBanner1858NoBarrelExport() {
    final violations = <String>[];
    const markers = ['job_banner', 'JobBanner'];
    for (final rel in [
      'packages/warp_prism_ui/lib/src/organisms/organisms.dart',
      'packages/warp_prism_ui/lib/src/molecules/molecules.dart',
      'packages/warp_prism_ui/lib/src/atoms/atoms.dart',
      'packages/warp_prism_ui/lib/warp_prism_ui.dart',
      'packages/warp_prism_ui/lib/src/prism_aliases.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final marker in markers) {
          if (lines[i].contains(marker)) {
            violations.add(
              '$rel:${i + 1}: EXPERIMENTAL seam must stay out of barrels: ${lines[i].trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1858: the withheld banner case consumes Task 1869's frozen
  /// vocabulary — neutral token, help icon, indeterminate flag — and no
  /// withheld line may resolve to a success, enabled, or disabled mapping.
  List<String> _checkBanner1858UnknownFailClosed() {
    final violations = <String>[];
    const rel = 'packages/warp_prism_ui/lib/src/molecules/ds_job_banner.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final text = file.readAsStringSync();
    for (final symbol in [
      'DSStateType.unknown',
      'statusUnknown',
      'isIndeterminate',
      'help_outline',
    ]) {
      if (!text.contains(symbol)) {
        violations.add('$rel: missing required 1869-vocabulary symbol $symbol');
      }
    }
    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      if (!lines[i].toLowerCase().contains('unknown')) continue;
      for (final failOpen in [
        'statusSuccess',
        'statusApproved',
        'statusHealthy',
        'textDisabled',
        'statusDisabled',
        'CircularProgressIndicator',
      ]) {
        if (lines[i].contains(failOpen)) {
          violations.add(
            '$rel:${i + 1}: withheld determination must never map to $failOpen: ${lines[i].trim()}',
          );
        }
      }
    }
    return violations;
  }

  /// Task 1858: withheld banner phases are excluded from golden capture —
  /// no golden test may reference the banner alongside indeterminate
  /// vocabulary.
  List<String> _checkBanner1858GoldensExcludeIndeterminate() {
    final violations = <String>[];
    final goldensDir = Directory(
      '${repoRoot.path}/packages/warp_prism_ui/test/goldens',
    );
    if (!goldensDir.existsSync()) {
      return [
        'Missing required directory: packages/warp_prism_ui/test/goldens',
      ];
    }
    final bannerPattern = RegExp(r'JobBanner');
    final indeterminatePattern = RegExp(
      r'\bunknown\b|\bindeterminate\b|notAttempted|abstained',
      caseSensitive: false,
    );
    final files =
        goldensDir
            .listSync(recursive: false, followLinks: false)
            .whereType<File>()
            .where((file) => file.path.endsWith('_test.dart'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    for (final file in files) {
      final text = file.readAsStringSync();
      if (bannerPattern.hasMatch(text) && indeterminatePattern.hasMatch(text)) {
        violations.add(
          '${_relativePath(file)}: golden test must not capture withheld banner phases',
        );
      }
    }
    return violations;
  }

  /// Task 1861 (F-13) contract check: the meter/fader/canvas-host seam
  /// carries no audio, DSP, or consumer domain vocabulary.
  ///
  /// EXPERIMENTAL scope: geometry is generic, calibration is injected.
  /// Enforces the task's own grep contract
  /// (`dBFS|LUFS|FFTGoniometer|SpectralPainter|Tempest[A-Z]`, extended to
  /// sibling qualified domain types and spectral/goniometer vocabulary):
  /// full-scale floors, loudness targets, spectral painters, and
  /// consumer-qualified types stay caller-side and must never appear in the
  /// three seam files. Plain prose donor citations (e.g. `docs/bridge/`
  /// paths) are not qualified type references and are out of scope.
  List<String> _checkMeter1861NoAudioDomainTypes() {
    final violations = <String>[];
    const rels = [
      'packages/warp_prism_ui/lib/src/atoms/ds_meter.dart',
      'packages/warp_prism_ui/lib/src/atoms/ds_canvas_host.dart',
      'packages/warp_prism_ui/lib/src/molecules/ds_fader_strip.dart',
    ];
    const forbiddenLiterals = [
      'dBFS',
      'LUFS',
      'FFTGoniometer',
      'SpectralPainter',
      'Goniometer',
      'Spectrogram',
    ];
    final qualifiedDomainType = RegExp(
      r'(Tempest|Warpblade|CyberCore|Ganthritor|Cersei|OmniRoute)[A-Z]',
    );
    for (final rel in rels) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final forbidden in forbiddenLiterals) {
          if (line.contains(forbidden)) {
            violations.add(
              '$rel:${i + 1}: audio/domain vocabulary must stay caller-side, found `$forbidden`: ${line.trim()}',
            );
          }
        }
        if (qualifiedDomainType.hasMatch(line)) {
          violations.add(
            '$rel:${i + 1}: qualified consumer domain type must stay caller-side: ${line.trim()}',
          );
        }
      }
    }
    return violations;
  }

  /// Task 1861: the meter seam stays dependency-light and deterministic —
  /// no bindings/FRB/generated imports, no state-routing frameworks, no IO,
  /// no wall-clock, no timers, no randomness, no animation drivers.
  List<String> _checkMeter1861NoForbiddenImports() {
    final violations = <String>[];
    const rels = [
      'packages/warp_prism_ui/lib/src/atoms/ds_meter.dart',
      'packages/warp_prism_ui/lib/src/atoms/ds_canvas_host.dart',
      'packages/warp_prism_ui/lib/src/molecules/ds_fader_strip.dart',
    ];
    final importPattern = RegExp(
      r'''^\s*import\s+['"]package:(warp_prism_bindings|warp_prism_adapter_frb|flutter_rust_bridge|flutter_riverpod|riverpod|go_router)(?=/|['"])|['"](dart:io)['"]''',
    );
    final generatedPattern = RegExp(
      r'''^\s*import\s+['"].*(?:src/rust/|frb_generated)''',
    );
    for (final rel in rels) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (importPattern.hasMatch(line) || generatedPattern.hasMatch(line)) {
          violations.add('$rel:${i + 1}: forbidden dependency: ${line.trim()}');
        }
        for (final forbidden in [
          'DateTime.now',
          'Timer(',
          'Random(',
          'AnimationController',
          'AnimatedBuilder',
          'AnimatedContainer',
          'Tween',
          'Ticker',
          'vsync',
        ]) {
          if (line.contains(forbidden)) {
            violations.add(
              '$rel:${i + 1}: meter seam must stay deterministic and animation-free, found `$forbidden`: ${line.trim()}',
            );
          }
        }
      }
    }
    const symbolsByFile = {
      'packages/warp_prism_ui/lib/src/atoms/ds_meter.dart': [
        'DSMeterScale',
        'DSMeterZone',
        'DSMeter',
        'dsMeterReferenceScale',
        'fractionFor',
        'zoneFor',
        'peakValue',
        'announcement',
      ],
      'packages/warp_prism_ui/lib/src/atoms/ds_canvas_host.dart': [
        'DSCanvasHostSpec',
        'DSCanvasHost',
        'viewportSize',
        'maxDataPoints',
        'clampData',
        'placeholder',
        'semanticValue',
      ],
      'packages/warp_prism_ui/lib/src/molecules/ds_fader_strip.dart': [
        'DSFaderStrip',
        'onFaderChanged',
        'dbReadout',
        'formatFader',
        'announcement',
      ],
    };
    symbolsByFile.forEach((rel, symbols) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) return;
      final text = file.readAsStringSync();
      for (final symbol in symbols) {
        if (!text.contains(symbol)) {
          violations.add('$rel: missing required symbol $symbol');
        }
      }
    });
    return violations;
  }

  /// Task 1861: EXPERIMENTAL means no barrel export and no Prism alias.
  ///
  /// The layer contracts (§9) grant barrel export only at STABLE. Until the
  /// promotion task, none of the layer barrels, the public barrel, or the
  /// alias file may name the meter/fader/canvas-host seam.
  List<String> _checkMeter1861NoBarrelExport() {
    final violations = <String>[];
    const markers = [
      'ds_meter',
      'ds_canvas_host',
      'ds_fader_strip',
      'DSMeter',
      'DSFaderStrip',
      'DSCanvasHost',
      'MeterScale',
      'MeterZone',
      'FaderStrip',
      'CanvasHost',
    ];
    for (final rel in [
      'packages/warp_prism_ui/lib/src/organisms/organisms.dart',
      'packages/warp_prism_ui/lib/src/molecules/molecules.dart',
      'packages/warp_prism_ui/lib/src/atoms/atoms.dart',
      'packages/warp_prism_ui/lib/warp_prism_ui.dart',
      'packages/warp_prism_ui/lib/src/prism_aliases.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final marker in markers) {
          if (lines[i].contains(marker)) {
            violations.add(
              '$rel:${i + 1}: EXPERIMENTAL seam must stay out of barrels: ${lines[i].trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1860 (F-12) contract check: filter-builder seam stays lean.
  ///
  /// EXPERIMENTAL scope: model + editors + builder + toolbar files import no
  /// bindings/adapter/FRB/generated/consumer/runtime/interaction surfaces; no
  /// randomness and no unbounded waits anywhere in the seam; only
  /// `ds_filter_builder.dart` may arm the bounded single-shot commit timer;
  /// required model/framework symbols are present.
  List<String> _checkFilter1860BuilderSeamPurity() {
    final violations = <String>[];
    const rels = [
      'packages/warp_prism_ui/lib/src/organisms/filter_workbench/ds_filter_builder_model.dart',
      'packages/warp_prism_ui/lib/src/organisms/filter_workbench/ds_filter_builder_editors.dart',
      'packages/warp_prism_ui/lib/src/organisms/filter_workbench/ds_filter_builder.dart',
      'packages/warp_prism_ui/lib/src/organisms/filter_workbench/ds_toolbar_panel.dart',
    ];
    for (final rel in rels) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (RegExp(
          r'''^\s*import\s+['"]package:(warp_prism_bindings|warp_prism_adapter_frb|flutter_rust_bridge|flutter_riverpod|riverpod|go_router|warp_prism_runtime|warp_prism_interaction)(?=/|['"])|['"](dart:io)['"]''',
        ).hasMatch(line)) {
          violations.add(
            '$rel:${i + 1}: seam must stay dependency-light: ${line.trim()}',
          );
        }
        if (RegExp(
          r'''^\s*import\s+['"].*(?:src/rust/|frb_generated)''',
        ).hasMatch(line)) {
          violations.add(
            '$rel:${i + 1}: forbidden generated import: ${line.trim()}',
          );
        }
        if (line.contains('Random(')) {
          violations.add(
            '$rel:${i + 1}: seam must be deterministic, found `Random(`: ${line.trim()}',
          );
        }
        if (line.contains('Timer.periodic') ||
            line.contains('Future.delayed')) {
          violations.add('$rel:${i + 1}: no unbounded waits: ${line.trim()}');
        }
      }
    }
    // Only the builder widget may arm the bounded single-shot commit timer.
    for (final rel in [rels[0], rels[1], rels[3]]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('Timer(')) {
          violations.add(
            '$rel:${i + 1}: only ds_filter_builder.dart may arm the bounded commit timer: ${lines[i].trim()}',
          );
        }
      }
    }
    final modelFile = File('${repoRoot.path}/${rels[0]}');
    if (modelFile.existsSync()) {
      final text = modelFile.readAsStringSync();
      for (final symbol in [
        'DSFilterGroupOperator',
        'DSFilterPredicate',
        'DSFilterGroup',
        'DSFilterBuilderSnapshot',
        'DSFilterDebounceController',
        'DSFilterClock',
        'DSFilterBuilderFake',
        'flush',
      ]) {
        if (!text.contains(symbol)) {
          violations.add('${rels[0]}: missing required symbol $symbol');
        }
      }
    }
    final builderFile = File('${repoRoot.path}/${rels[2]}');
    if (builderFile.existsSync()) {
      final text = builderFile.readAsStringSync();
      for (final symbol in [
        'DSFilterBuilder',
        'DSFilterBuilderController',
        'fieldsFromSections',
        'flushCommit',
      ]) {
        if (!text.contains(symbol)) {
          violations.add('${rels[2]}: missing required symbol $symbol');
        }
      }
    }
    final toolbarFile = File('${repoRoot.path}/${rels[3]}');
    if (toolbarFile.existsSync()) {
      final text = toolbarFile.readAsStringSync();
      for (final symbol in [
        'DSToolbarPanel',
        'DSToolbarPanelPhase',
        'onReanchored',
      ]) {
        if (!text.contains(symbol)) {
          violations.add('${rels[3]}: missing required symbol $symbol');
        }
      }
    }
    return violations;
  }

  /// Task 1860: EXPERIMENTAL means no barrel export and no Prism alias.
  List<String> _checkFilter1860NoBarrelExport() {
    final violations = <String>[];
    const markers = [
      'filter_builder',
      'toolbar_panel',
      'FilterBuilder',
      'ToolbarPanel',
      'FilterDebounce',
      'FilterPredicate',
      'FilterField',
      'FilterGroup',
    ];
    for (final rel in [
      'packages/warp_prism_ui/lib/src/organisms/organisms.dart',
      'packages/warp_prism_ui/lib/src/molecules/molecules.dart',
      'packages/warp_prism_ui/lib/src/atoms/atoms.dart',
      'packages/warp_prism_ui/lib/warp_prism_ui.dart',
      'packages/warp_prism_ui/lib/src/prism_aliases.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final marker in markers) {
          if (lines[i].contains(marker)) {
            violations.add(
              '$rel:${i + 1}: EXPERIMENTAL seam must stay out of barrels: ${lines[i].trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1860: debounce-commit is clock-injectable with an explicit flush.
  ///
  /// Only the model file may name the wall clock (as the production default
  /// closure); editors/builder/toolbar schedule nothing from `DateTime.now`.
  /// The controller exposes an injectable clock plus `flush`/`commitIfDue`.
  List<String> _checkFilter1860DebounceDeterministic() {
    final violations = <String>[];
    const modelRel =
        'packages/warp_prism_ui/lib/src/organisms/filter_workbench/ds_filter_builder_model.dart';
    const clockFree = [
      'packages/warp_prism_ui/lib/src/organisms/filter_workbench/ds_filter_builder_editors.dart',
      'packages/warp_prism_ui/lib/src/organisms/filter_workbench/ds_filter_builder.dart',
      'packages/warp_prism_ui/lib/src/organisms/filter_workbench/ds_toolbar_panel.dart',
    ];
    for (final rel in clockFree) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('DateTime.now')) {
          violations.add(
            '$rel:${i + 1}: debounce must be clock-injectable, found wall-clock read: ${lines[i].trim()}',
          );
        }
      }
    }
    final modelFile = File('${repoRoot.path}/$modelRel');
    if (!modelFile.existsSync()) {
      violations.add('Missing required file: $modelRel');
    } else {
      final text = modelFile.readAsStringSync();
      for (final symbol in [
        'DSFilterClock',
        'markEditedNow',
        'commitIfDue',
        'flush()',
        'dueIn',
      ]) {
        if (!text.contains(symbol)) {
          violations.add('$modelRel: missing required symbol $symbol');
        }
      }
    }
    return violations;
  }

  /// Task 1866 (F-18) contract check: the composer seam carries no
  /// consumer domain vocabulary.
  ///
  /// EXPERIMENTAL scope: comments, annotations, and operator notes stay
  /// product-local models; Prism takes injected descriptors only
  /// (`DSComposerMention` id + display label). Enforces the layer
  /// domain-leakage rule plus composer-specific model leakage
  /// (`CommentModel`, `AnnotationModel`, `NoteModel` qualified types).
  List<String> _checkComposer1866NoDomainTypes() {
    final violations = <String>[];
    const rels = [
      'packages/warp_prism_ui/lib/src/organisms/composer/ds_composer_model.dart',
      'packages/warp_prism_ui/lib/src/organisms/composer/ds_composer.dart',
    ];
    final qualifiedDomainType = RegExp(
      r'(Warpblade|Tempest|CyberCore|Ganthritor|Cersei|OmniRoute)[A-Z]',
    );
    final qualifiedComposerModel = RegExp(
      r'(Comment|Annotation|Note)(Model|Thread|Entry)[A-Z]?',
    );
    for (final rel in rels) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (qualifiedDomainType.hasMatch(line)) {
          violations.add(
            '$rel:${i + 1}: qualified consumer domain type must stay caller-side: ${line.trim()}',
          );
        }
        if (qualifiedComposerModel.hasMatch(line)) {
          violations.add(
            '$rel:${i + 1}: consumer note models must stay caller-side, found descriptor leak: ${line.trim()}',
          );
        }
      }
    }
    const symbolsByFile = {
      'packages/warp_prism_ui/lib/src/organisms/composer/ds_composer_model.dart':
          [
            'DSComposerAttachmentState',
            'DSComposerAttachment',
            'DSComposerMention',
            'DSComposerFormat',
            'DSComposerDraft',
            'DSComposerDraftStore',
            'DSComposerSendPayload',
            'DSComposerFake',
            'extractMentionQuery',
            'filterComposerMentions',
            'applyComposerFormat',
            'insertComposerEmoji',
            'announcement',
          ],
      'packages/warp_prism_ui/lib/src/organisms/composer/ds_composer.dart': [
        'DSComposerController',
        'DSComposer',
        'canSend',
        'buildPayload',
        'park',
        'restore',
        'onSend',
        'liveRegion',
        'FocusNode',
      ],
    };
    symbolsByFile.forEach((rel, symbols) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) return;
      final text = file.readAsStringSync();
      for (final symbol in symbols) {
        if (!text.contains(symbol)) {
          violations.add('$rel: missing required symbol $symbol');
        }
      }
    });
    return violations;
  }

  /// Task 1866: the composer seam stays dependency-light and deterministic —
  /// no bindings/FRB/generated imports, no state-routing frameworks, no IO,
  /// no wall-clock, no timers, no randomness, no animation drivers.
  List<String> _checkComposer1866NoForbiddenImports() {
    final violations = <String>[];
    const rels = [
      'packages/warp_prism_ui/lib/src/organisms/composer/ds_composer_model.dart',
      'packages/warp_prism_ui/lib/src/organisms/composer/ds_composer.dart',
    ];
    final importPattern = RegExp(
      r'''^\s*import\s+['"]package:(warp_prism_bindings|warp_prism_adapter_frb|flutter_rust_bridge|flutter_riverpod|riverpod|go_router)(?=/|['"])|['"](dart:io)['"]''',
    );
    final generatedPattern = RegExp(
      r'''^\s*import\s+['"].*(?:src/rust/|frb_generated)''',
    );
    for (final rel in rels) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (importPattern.hasMatch(line) || generatedPattern.hasMatch(line)) {
          violations.add('$rel:${i + 1}: forbidden dependency: ${line.trim()}');
        }
        for (final forbidden in [
          'DateTime.now',
          'Timer(',
          'Future.delayed',
          'Random(',
          'AnimationController',
          'AnimatedBuilder',
          'AnimatedContainer',
          'Tween',
          'Ticker',
          'vsync',
          'CircularProgressIndicator',
          'Offstage(',
          'Visibility(',
        ]) {
          if (line.contains(forbidden)) {
            violations.add(
              '$rel:${i + 1}: composer seam must stay deterministic and animation-free, found `$forbidden`: ${line.trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1866: EXPERIMENTAL means no barrel export and no Prism alias.
  ///
  /// The layer contracts (§9) grant barrel export only at STABLE. Until the
  /// promotion task, none of the layer barrels, the public barrel, or the
  /// alias file may name the composer seam.
  List<String> _checkComposer1866NoBarrelExport() {
    final violations = <String>[];
    const markers = [
      'organisms/composer/',
      'ds_composer',
      'DSComposer',
      'ComposerDraft',
      'ComposerAttachment',
      'ComposerMention',
      'ComposerFormat',
      'ComposerSend',
    ];
    for (final rel in [
      'packages/warp_prism_ui/lib/src/organisms/organisms.dart',
      'packages/warp_prism_ui/lib/src/molecules/molecules.dart',
      'packages/warp_prism_ui/lib/src/atoms/atoms.dart',
      'packages/warp_prism_ui/lib/warp_prism_ui.dart',
      'packages/warp_prism_ui/lib/src/prism_aliases.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final marker in markers) {
          if (lines[i].contains(marker)) {
            violations.add(
              '$rel:${i + 1}: EXPERIMENTAL seam must stay out of barrels: ${lines[i].trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1882 (F-15): no forked Tempest tokens in Prism.
  ///
  /// Tempest hex literals may appear only in the owned disposition ledger
  /// (`tokens/ds_tempest_token_map.dart`, string table). Every other file
  /// under `tokens/` must stay free of them — convergence maps onto Prism
  /// tokens, it never copies Tempest values into them.
  List<String> _checkToken1882NoForkedTempestTokens() {
    final violations = <String>[];
    const ledgerRel =
        'packages/warp_prism_ui/lib/src/tokens/ds_tempest_token_map.dart';
    // NOTE: `#6B7280` (Tempest darkTextTertiary) is deliberately absent:
    // it coincides with the pre-existing Prism grays `governanceArchive` /
    // `assetReference` (ds_colors.dart), which predate this convergence and
    // are not a fork. The ledger maps darkTextTertiary structurally onto
    // `textTertiary` (#8888A0), never by hex parity.
    const tempestHexes = [
      '7c4dff',
      'b47cff',
      '3f1dcb',
      '00e5ff',
      '6effff',
      '00b2cc',
      'ffb300',
      'ff3366',
      '00e676',
      'ff9100',
      'b388ff',
      'ff5252',
      'ffd700',
      '40c4ff',
      '0e0f14',
      '161820',
      '1e212d',
      '282c3c',
      '2c3042',
      'f1f3f9',
      'a0a6b8',
      'f3f5fa',
      'e8ecf4',
      'dce2ee',
      'd0d7e5',
      '141722',
      '555e75',
      '8b94a7',
      '004d5a',
      'e8ddff',
      '0097a7',
      'b2ebf2',
      'e65100',
    ];
    final pattern = RegExp(tempestHexes.join('|'), caseSensitive: false);
    final dir = _childDir('packages/warp_prism_ui/lib/src/tokens');
    final missing = _missingDirectory(
      dir,
      'packages/warp_prism_ui/lib/src/tokens',
    );
    if (missing != null) return missing;

    final files =
        dir
            .listSync(recursive: false, followLinks: false)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    for (final file in files) {
      final rel = _relativePath(file);
      if (rel == ledgerRel) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (pattern.hasMatch(lines[i])) {
          violations.add(
            '$rel:${i + 1}: forked Tempest token literal outside the owned ledger: ${lines[i].trim()}',
          );
        }
      }
    }
    return violations;
  }

  /// Task 1882 (F-15): stem colours stay injected, never owned.
  ///
  /// No file under `tokens/` may declare an owned stem token
  /// (`static const Color stem*` / `Color get stem*`). Stems travel as
  /// caller-supplied parameters (see `DSTempestTokenMap.resolveDark`).
  List<String> _checkToken1882StemColorsStayInjected() {
    final dir = _childDir('packages/warp_prism_ui/lib/src/tokens');
    final missing = _missingDirectory(
      dir,
      'packages/warp_prism_ui/lib/src/tokens',
    );
    if (missing != null) return missing;

    return _scanDartFiles(
      dir,
      RegExp(r'static\s+(const\s+)?Color\w*\s+stem|Color\s+get\s+stem'),
    );
  }

  /// Task 1882 (F-15): no new token primitive smuggled into the registry.
  ///
  /// `PrismColorRole` keeps exactly its 9 Black Obsidian roles; convergence
  /// wiring adds mappings, never roles.
  List<String> _checkToken1882RegistryRolesStable() {
    final violations = <String>[];
    const rel =
        'packages/warp_prism_ui/lib/src/tokens/prism_token_registry.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    const expected = {
      'obsidianDeep',
      'obsidianBase',
      'obsidianElevated',
      'obsidianHover',
      'borderDefault',
      'accentBlue',
      'accentBlueMuted',
      'accentBlueDim',
      'focusRing',
    };
    final entryPattern = RegExp(r'^\s{2}([A-Za-z][A-Za-z0-9]*)\($');
    final found = <String>{};
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final match = entryPattern.firstMatch(lines[i]);
      if (match != null) {
        final name = match.group(1)!;
        // Enum entries carry constructor args; the constructor itself and
        // method calls at other depths do not match `^  name($`.
        found.add(name);
        if (!expected.contains(name)) {
          violations.add(
            '$rel:${i + 1}: unexpected PrismColorRole entry $name (no new token primitive)',
          );
        }
      }
    }
    for (final name in expected) {
      if (!found.contains(name)) {
        violations.add('$rel: missing expected PrismColorRole entry $name');
      }
    }
    return violations;
  }

  /// Task 1881: EXPERIMENTAL means no barrel export and no Prism alias.
  ///
  /// The layer contracts (§9) grant barrel export only at STABLE. Until the
  /// promotion task, none of the layer barrels, the public barrel, or the
  /// alias file may name the numeric seam.
  List<String> _checkNumeric1881NoBarrelExport() {
    final violations = <String>[];
    const markers = [
      'numeric_field/',
      'ds_numeric_field',
      'DSNumericField',
      'DSNumericLead',
      'NumericCommit',
      'NumericSet',
      'NumericScrub',
      'NumericTypedEdit',
      'NumericValue',
      'dsNumericReference',
    ];
    for (final rel in [
      'packages/warp_prism_ui/lib/src/organisms/organisms.dart',
      'packages/warp_prism_ui/lib/src/molecules/molecules.dart',
      'packages/warp_prism_ui/lib/src/atoms/atoms.dart',
      'packages/warp_prism_ui/lib/warp_prism_ui.dart',
      'packages/warp_prism_ui/lib/src/prism_aliases.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final marker in markers) {
          if (lines[i].contains(marker)) {
            violations.add(
              '$rel:${i + 1}: EXPERIMENTAL seam must stay out of barrels: ${lines[i].trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1881: no domain math in the numeric seam.
  ///
  /// BigInt/GCD rational arithmetic, timebase quantisation, and product
  /// domain types stay product-local; the atom takes injected
  /// parse/format/quantum and computes caller-unit doubles only.
  List<String> _checkNumeric1881NoDomainMath() {
    final violations = <String>[];
    const rels = [
      'packages/warp_prism_ui/lib/src/atoms/numeric_field/ds_numeric_field.dart',
    ];
    for (final rel in rels) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final forbidden in [
          'BigInt',
          'GCD',
          'gcd',
          'rational',
          'Rational',
          'Warpblade',
          'Tempest',
          'Ganthritor',
          'Cersei',
          'OmniRoute',
          'CyberCore',
        ]) {
          if (line.contains(forbidden)) {
            violations.add(
              '$rel:${i + 1}: domain math must stay product-local, found `$forbidden`: ${line.trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1881: the numeric seam stays dependency-light per layer law —
  /// no bindings/FRB/generated imports, no state-routing frameworks, no IO,
  /// and no interaction imports (mechanics stay in presentation).
  List<String> _checkNumeric1881NoForbiddenImports() {
    final violations = <String>[];
    const rels = [
      'packages/warp_prism_ui/lib/src/atoms/numeric_field/ds_numeric_field.dart',
    ];
    final importPattern = RegExp(
      r'''^\s*import\s+['"]package:(warp_prism_bindings|warp_prism_adapter_frb|warp_prism_interaction|flutter_rust_bridge|flutter_riverpod|riverpod|go_router)(?=/|['"])|['"](dart:io)['"]''',
    );
    final generatedPattern = RegExp(
      r'''^\s*import\s+['"].*(?:src/rust/|frb_generated)''',
    );
    for (final rel in rels) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (importPattern.hasMatch(line) || generatedPattern.hasMatch(line)) {
          violations.add('$rel:${i + 1}: forbidden dependency: ${line.trim()}');
        }
      }
    }
    return violations;
  }

  /// Task 1881: rendering is deterministic — no wall-clock, timers, or
  /// randomness in the numeric seam. Modifiers arrive synchronously from
  /// framework keyboard state; the widget never advances time.
  List<String> _checkNumeric1881DeterministicNoWallclock() {
    final violations = <String>[];
    const rels = [
      'packages/warp_prism_ui/lib/src/atoms/numeric_field/ds_numeric_field.dart',
    ];
    for (final rel in rels) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final forbidden in ['DateTime.now', 'Timer(', 'Random(']) {
          if (line.contains(forbidden)) {
            violations.add(
              '$rel:${i + 1}: deterministic rendering only, found `$forbidden`: ${line.trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  Directory _childDir(String relativePath) =>
      Directory('${repoRoot.path}/$relativePath');

  // ==========================================================================
  // Task 1867 (a): generated layer table — single source for import-direction
  // law. The six legacy import-direction checks below delegate to rows of
  // this table; [_checkLayerTableUpwardRule] proves the table is complete by
  // failing any `package:warp_prism_*` edge the table does not grant.
  // ==========================================================================

  /// Allowed `package:warp_prism_*` dependencies per library scope.
  ///
  /// Mirrors §1 matrix rows 1/4/6 + Global MUST-NOTs 1/4. `warp_prism_ui` may
  /// reference `warp_prism_interaction` as a dev-only MAY; every other scope
  /// grants exactly what its row needs and nothing more.
  static const Map<String, Set<String>> kLayerAllowedDeps = {
    'packages/warp_prism_ui/lib': {'warp_prism_interaction'},
    'packages/warp_prism_interaction/lib': {},
    'packages/warp_prism_runtime/lib': {},
    'packages/warp_prism_bindings/lib': {
      'warp_prism_ui',
      'warp_prism_interaction',
      'warp_prism_runtime',
    },
    'packages/warp_prism_testkit/lib': {'warp_prism_runtime'},
    'packages/warp_prism_adapter_frb/lib': {'warp_prism_runtime'},
  };

  /// Forbidden-pattern rows of the layer table (non-`warp_prism_*` bans and
  /// generated-surface bans). Each entry names the legacy check it compacts.
  static final List<LayerForbiddenRule> kLayerForbiddenRules = [
    LayerForbiddenRule(
      legacyCheck: 'warp_prism_runtime contains no Flutter imports',
      scopes: ['packages/warp_prism_runtime/lib'],
      pattern: r'''^\s*import\s+['"](dart:ui|package:flutter(?=/))''',
      reason: 'runtime stays pure Dart',
    ),
    LayerForbiddenRule(
      legacyCheck: 'warp_prism_interaction is pure Dart',
      scopes: ['packages/warp_prism_interaction/lib'],
      pattern: r'''^\s*import\s+['"](dart:ui|package:flutter(?=/))''',
      reason: 'interaction stays pure Dart',
    ),
    LayerForbiddenRule(
      legacyCheck: 'warp_prism_ui does not import warp_prism_bindings',
      scopes: ['packages/warp_prism_ui/lib'],
      pattern: r'''^\s*import\s+['"]package:warp_prism_bindings(?=/|['"])''',
      reason: 'ui never imports bindings (§1 row 1)',
    ),
    LayerForbiddenRule(
      legacyCheck:
          'warp_prism_adapter_frb is not imported by ui/interaction/runtime',
      scopes: [
        'packages/warp_prism_ui/lib',
        'packages/warp_prism_interaction/lib',
        'packages/warp_prism_runtime/lib',
      ],
      pattern:
          r'''^\s*import\s+['"]package:(warp_prism_adapter_frb|flutter_rust_bridge)(?=/|['"])''',
      reason: 'adapter/FRB stays below the projection seam',
    ),
    LayerForbiddenRule(
      legacyCheck: 'FRB generated files are not imported directly by widgets',
      scopes: ['apps', 'packages'],
      pattern: r'''^\s*import\s+['"].*(?:src/rust/|frb_generated)''',
      reason: 'generated surfaces stay inside the adapter',
      excludeDirName: 'warp_prism_adapter_frb',
    ),
    LayerForbiddenRule(
      legacyCheck: 'warp_prism_bindings does not import FRB generated surfaces',
      scopes: ['packages/warp_prism_bindings/lib'],
      pattern: r'''^\s*import\s+['"].*(?:src/rust/|frb_generated)''',
      reason: 'bindings stay transport-free',
    ),
  ];

  /// Runs one forbidden-pattern table row over its scopes.
  List<String> _runLayerForbiddenRule(LayerForbiddenRule rule) {
    final violations = <String>[];
    final pattern = RegExp(rule.pattern);
    for (final scope in rule.scopes) {
      final dir = _childDir(scope);
      if (!dir.existsSync()) {
        violations.add('Missing required directory: $scope');
        continue;
      }
      if (scope == 'apps' || scope == 'packages') {
        final subDirs =
            dir.listSync(followLinks: false).whereType<Directory>().toList()
              ..sort((a, b) => a.path.compareTo(b.path));
        for (final sub in subDirs) {
          final dirName =
              sub.uri.pathSegments.isNotEmpty &&
                  sub.uri.pathSegments.last.isNotEmpty
              ? sub.uri.pathSegments.last
              : sub.path.split(Platform.pathSeparator).last;
          if (dirName == rule.excludeDirName) continue;
          final libDir = Directory('${sub.path}/lib');
          if (libDir.existsSync()) {
            violations.addAll(_scanDartFiles(libDir, pattern));
          }
        }
        continue;
      }
      violations.addAll(_scanDartFiles(dir, pattern));
    }
    return violations;
  }

  /// Task 1867 (a): the generic upward rule. Every `package:warp_prism_*`
  /// import in the six layer scopes must be granted by [kLayerAllowedDeps];
  /// any edge outside the table fails. This is what makes the table — not
  /// the prose — the single source of import-direction law.
  List<String> _checkLayerTableUpwardRule() {
    final violations = <String>[];
    final importPattern = RegExp(
      r'''^\s*import\s+['"]package:(warp_prism_[a-z_]+)(?=/|['"])''',
    );
    final scopePackage = RegExp(r'packages/(warp_prism_[a-z_]+)/lib');
    kLayerAllowedDeps.forEach((scope, allowed) {
      final dir = _childDir(scope);
      if (!dir.existsSync()) {
        violations.add('Missing required directory: $scope');
        return;
      }
      final ownMatch = scopePackage.firstMatch(scope);
      final ownPackage = ownMatch?.group(1);
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
          final match = importPattern.firstMatch(lines[i]);
          if (match == null) continue;
          final dep = match.group(1)!;
          if (dep == ownPackage) continue;
          if (!allowed.contains(dep)) {
            violations.add(
              '${_relativePath(file)}:${i + 1}: upward edge outside the layer table: $ownPackage -> $dep (add a §1 row + table grant first): ${lines[i].trim()}',
            );
          }
        }
      }
    });
    return violations;
  }

  /// Task 1867 (a): table-integrity proof. The harness file itself must
  /// declare the table, the generic upward rule, and keep every compacted
  /// legacy check name registered (report continuity).
  List<String> _checkLayerTableSingleSource() {
    final violations = <String>[];
    const rel = 'packages/warp_prism_ui/test/boundaries/boundary_test.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final text = file.readAsStringSync();
    for (final symbol in [
      'kLayerAllowedDeps',
      'kLayerForbiddenRules',
      '_checkLayerTableUpwardRule',
      '_runLayerForbiddenRule',
    ]) {
      if (!text.contains(symbol)) {
        violations.add(
          '$rel: layer table single-source symbol missing: $symbol',
        );
      }
    }
    for (final rule in kLayerForbiddenRules) {
      if (!text.contains(rule.legacyCheck)) {
        violations.add(
          '$rel: compacted legacy check not registered: ${rule.legacyCheck}',
        );
      }
    }
    return violations;
  }

  /// Task 1867 (d): toast policy seam stays dependency-light and declares
  /// the 1867 policy vocabulary (cap/hand-back/onDismiss-only-on-close).
  List<String> _checkToast1867PolicySymbols() {
    final violations = <String>[];
    const rel =
        'packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final lines = file.readAsLinesSync();
    final importPattern = RegExp(
      r'''^\s*import\s+['"]package:(warp_prism_bindings|warp_prism_adapter_frb|flutter_rust_bridge|flutter_riverpod|riverpod|go_router)(?=/|['"])|['"](dart:io)['"]''',
    );
    final generatedPattern = RegExp(
      r'''^\s*import\s+['"].*(?:src/rust/|frb_generated)''',
    );
    for (var i = 0; i < lines.length; i++) {
      if (importPattern.hasMatch(lines[i]) ||
          generatedPattern.hasMatch(lines[i])) {
        violations.add(
          '$rel:${i + 1}: forbidden dependency: ${lines[i].trim()}',
        );
      }
    }
    final text = file.readAsStringSync();
    for (final symbol in [
      'PrismToastRemovalReason',
      'PrismToastHandBack',
      'onHandBack',
      'onCloseDismissed',
      'sticky',
      'maxVisible',
    ]) {
      if (!text.contains(symbol)) {
        violations.add('$rel: missing required toast-policy symbol $symbol');
      }
    }
    return violations;
  }

  /// Task 1867 (b): two-tier capture reference is present and exported.
  List<String> _checkCapture1867TiersPresent() {
    final violations = <String>[];
    const rel =
        'packages/warp_prism_host_exercise/lib/src/capture/capture_tiers.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final text = file.readAsStringSync();
    for (final symbol in [
      'CaptureTier',
      'WindowedCaptureInspect',
      'FrameBoundaryDrain',
      'CooperativeCancelScope',
      'pumpBounded',
    ]) {
      if (!text.contains(symbol)) {
        violations.add('$rel: missing required capture-tier symbol $symbol');
      }
    }
    const barrelRel =
        'packages/warp_prism_host_exercise/lib/warp_prism_host_exercise.dart';
    final barrelFile = File('${repoRoot.path}/$barrelRel');
    if (barrelFile.existsSync()) {
      if (!barrelFile.readAsStringSync().contains('capture/capture_tiers')) {
        violations.add('$barrelRel: must export capture/capture_tiers.dart');
      }
    } else {
      violations.add('Missing required file: $barrelRel');
    }
    return violations;
  }

  /// Task 1867 (c): junk-sweep conventions live in the testkit and are
  /// exported for suite reuse.
  List<String> _checkJunk1867ConventionsPresent() {
    final violations = <String>[];
    const rel = 'packages/warp_prism_testkit/lib/src/junk/junk_sweep.dart';
    final file = File('${repoRoot.path}/$rel');
    if (!file.existsSync()) {
      return ['Missing required file: $rel'];
    }
    final text = file.readAsStringSync();
    for (final symbol in [
      'stableTestId',
      'kJunkCorpus',
      'kAdversarialInputs',
      'JunkSweep',
    ]) {
      if (!text.contains(symbol)) {
        violations.add('$rel: missing required junk-sweep symbol $symbol');
      }
    }
    if (text.contains('package:flutter')) {
      violations.add('$rel: junk conventions must stay pure Dart');
    }
    return violations;
  }

  /// Task 1883 (F-16) contract check: convergence is composition-only.
  ///
  /// EXPERIMENTAL scope: the session-panel seam must declare no new
  /// table/list/grid/board/tree/canvas primitive, must carry no consumer
  /// domain types or credentials, and the single authorized extension
  /// ([DSDropZoneCard] + [DSDropZoneMetadata]) must be present in
  /// `ds_drop_zone_card.dart` (relocated out of barrel-exported
  /// `ds_drop_target.dart` so the generic alias-completeness gate stays
  /// coherent — Task 1868 `DSActionGate` precedent).
  List<String> _checkSession1883NoNewPrimitive() {
    final violations = <String>[];
    const rels = [
      'packages/warp_prism_ui/lib/src/organisms/session_panel/ds_session_panel_compositions.dart',
      'packages/warp_prism_ui/lib/src/molecules/ds_drop_zone_card.dart',
    ];
    final declarationPattern = RegExp(
      r'^(?:abstract\s+)?(?:class|enum|mixin)\s+(DS[A-Z]\w*(?:Table|List|Grid|Board|Tree|Canvas))\b',
    );
    // Negative lookbehind for the DS prefix: mandated `DSTempest*`
    // composition names pass, while raw Tempest/Warpblade/CyberCore/
    // Ganthritor/Cersei/OmniRoute qualified types still fail.
    final qualifiedDomainType = RegExp(
      r'(?<!DS)(Tempest|Warpblade|CyberCore|Ganthritor|Cersei|OmniRoute)[A-Z]',
    );
    for (final rel in rels) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (declarationPattern.hasMatch(line)) {
          violations.add(
            '$rel:${i + 1}: convergence must not declare a new primitive: ${line.trim()}',
          );
        }
        if (qualifiedDomainType.hasMatch(line)) {
          violations.add(
            '$rel:${i + 1}: consumer domain type must stay product-local: ${line.trim()}',
          );
        }
        for (final forbidden in ['password', 'apiKey', 'ApiKey', 'secret:']) {
          if (line.contains(forbidden)) {
            violations.add(
              '$rel:${i + 1}: credentials must never cross the seam, found `$forbidden`: ${line.trim()}',
            );
          }
        }
      }
    }
    const dropTargetRel =
        'packages/warp_prism_ui/lib/src/molecules/ds_drop_zone_card.dart';
    final dropTargetFile = File('${repoRoot.path}/$dropTargetRel');
    if (dropTargetFile.existsSync()) {
      final text = dropTargetFile.readAsStringSync();
      for (final symbol in ['DSDropZoneCard', 'DSDropZoneMetadata']) {
        if (!text.contains(symbol)) {
          violations.add(
            '$dropTargetRel: missing required sole-extension symbol $symbol',
          );
        }
      }
    }
    return violations;
  }

  /// Task 1883: EXPERIMENTAL means no barrel export and no Prism alias.
  ///
  /// The layer contracts (§9) grant barrel export only at STABLE. Until the
  /// promotion task, none of the layer barrels, the public barrel, or the
  /// alias file may name the session-1883 seam.
  List<String> _checkSession1883NoBarrelExport() {
    final violations = <String>[];
    const markers = [
      'session_panel/',
      'drop_zone_card',
      'DSSessionListView',
      'DSSessionDetailView',
      'DSSessionRecord',
      'DSEventStreamView',
      'DSProjectPanelView',
      'DSMediaPanelView',
      'DSTempestLibraryView',
      'DSTempestLibraryItem',
      'DSTempestModelsView',
      'DSTempestProvidersView',
      'DSTempestSettingsView',
      'DSTempestSeparateView',
      'DSTempestCreateView',
      'DSTempestModelMetric',
      'DSVerificationBadge',
      'DSSessionEventSplitHost',
      'DSDropZoneCard',
      'DSDropZoneMetadata',
      'session_1883_',
      'session-1883-',
    ];
    for (final rel in [
      'packages/warp_prism_ui/lib/src/organisms/organisms.dart',
      'packages/warp_prism_ui/lib/src/molecules/molecules.dart',
      'packages/warp_prism_ui/lib/src/atoms/atoms.dart',
      'packages/warp_prism_ui/lib/warp_prism_ui.dart',
      'packages/warp_prism_ui/lib/src/prism_aliases.dart',
    ]) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final marker in markers) {
          if (lines[i].contains(marker)) {
            violations.add(
              '$rel:${i + 1}: EXPERIMENTAL seam must stay out of barrels: ${lines[i].trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

  /// Task 1883: rendering is deterministic — no wall-clock, timers, or
  /// randomness in the session-panel seam. Time and stream positions arrive
  /// injected and pre-formatted; the widgets never advance them.
  List<String> _checkSession1883Deterministic() {
    final violations = <String>[];
    const rels = [
      'packages/warp_prism_ui/lib/src/organisms/session_panel/ds_session_panel_compositions.dart',
      'packages/warp_prism_ui/lib/src/molecules/ds_drop_zone_card.dart',
    ];
    for (final rel in rels) {
      final file = File('${repoRoot.path}/$rel');
      if (!file.existsSync()) {
        violations.add('Missing required file: $rel');
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final forbidden in [
          'DateTime.now',
          'Timer(',
          'Random(',
          'AnimationController',
        ]) {
          if (line.contains(forbidden)) {
            violations.add(
              '$rel:${i + 1}: deterministic rendering only, found `$forbidden`: ${line.trim()}',
            );
          }
        }
      }
    }
    return violations;
  }

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

class LayerForbiddenRule {
  const LayerForbiddenRule({
    required this.legacyCheck,
    required this.scopes,
    required this.pattern,
    required this.reason,
    this.excludeDirName,
  });

  /// Display name of the compacted legacy check (report continuity).
  final String legacyCheck;

  /// Repository-relative directories to scan (`apps`/`packages` expand to
  /// per-package `lib/` subdirectories).
  final List<String> scopes;

  /// Forbidden import pattern for this row.
  final String pattern;

  /// §1 reason recorded for audit readability.
  final String reason;

  /// Package directory name skipped during `apps`/`packages` expansion.
  final String? excludeDirName;
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
