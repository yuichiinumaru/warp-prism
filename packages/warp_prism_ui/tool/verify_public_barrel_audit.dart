// ignore_for_file: avoid_print
/// Pure-Dart lock: public barrel audit ↔ live prism_aliases set equality.
///
/// Task 1302 regression guard — fails when inventory freezes drift from
/// `src/prism_aliases.dart` (the failure class that scored drain 58/100).
///
/// Usage (from monorepo root):
///   dart run packages/warp_prism_ui/tool/verify_public_barrel_audit.dart
///   dart run packages/warp_prism_ui/tool/verify_public_barrel_audit.dart --repo-root .
library;

import 'dart:io';

void main(List<String> args) {
  final repoRoot = _resolveRepoRoot(args);
  final aliasesFile = File(
    '${repoRoot.path}/packages/warp_prism_ui/lib/src/prism_aliases.dart',
  );
  final auditFile = File('${repoRoot.path}/docs/design/public-barrel-audit.md');
  final barrelFile = File(
    '${repoRoot.path}/packages/warp_prism_ui/lib/warp_prism_ui.dart',
  );

  for (final f in [aliasesFile, auditFile, barrelFile]) {
    if (!f.existsSync()) {
      stderr.writeln('MISSING: ${f.path}');
      exit(2);
    }
  }

  final aliases = aliasesFile.readAsStringSync();
  final audit = auditFile.readAsStringSync();
  final barrel = barrelFile.readAsStringSync();

  final srcTypedef = RegExp(
    r'^typedef\s+(Prism\w+)\b',
    multiLine: true,
  ).allMatches(aliases).map((m) => m.group(1)!).toSet();
  final srcExtension = RegExp(
    r'^extension\s+(Prism\w+)\b',
    multiLine: true,
  ).allMatches(aliases).map((m) => m.group(1)!).toSet();
  final src = {...srcTypedef, ...srcExtension};

  final auditPrism = RegExp(
    r'\|\s+`(Prism\w+)`\s+\|',
  ).allMatches(audit).map((m) => m.group(1)!).toSet();

  const expectedNonPrism = {
    'DesignSystemGalleryPage',
    'dsGallerySections',
    'dsGallerySectionIds',
    'dsGallerySectionTitles',
  };
  final auditNonPrism = RegExp(
    r'\|\s+`(DesignSystemGalleryPage|dsGallerySections|dsGallerySectionIds|dsGallerySectionTitles)`\s+\|',
  ).allMatches(audit).map((m) => m.group(1)!).toSet();

  final missing = src.difference(auditPrism).toList()..sort();
  final extra = auditPrism.difference(src).toList()..sort();
  final missingNonPrism = expectedNonPrism.difference(auditNonPrism).toList()
    ..sort();

  final hideGallerySpec = barrel.contains('hide DSGallerySectionSpec');
  final hideGallerySections = barrel.contains('hide DSGallerySections');
  final exportCount = RegExp(
    r"^export\s+'",
    multiLine: true,
  ).allMatches(barrel).length;

  var failed = false;
  void fail(String msg) {
    failed = true;
    stderr.writeln('FAIL: $msg');
  }

  print('Public barrel audit lock');
  print(
    '  src Prism: ${src.length} '
    '(${srcTypedef.length} typedef + ${srcExtension.length} extension)',
  );
  print('  audit Prism rows: ${auditPrism.length}');
  print('  audit non-Prism gallery: ${auditNonPrism.length}');
  print('  barrel exports: $exportCount');

  if (missing.isNotEmpty) {
    fail(
      'audit missing ${missing.length} live Prism symbols '
      '(sample: ${missing.take(8).join(', ')})',
    );
  }
  if (extra.isNotEmpty) {
    fail(
      'audit has ${extra.length} extra Prism symbols not in source '
      '(sample: ${extra.take(8).join(', ')})',
    );
  }
  if (missingNonPrism.isNotEmpty) {
    fail('audit missing non-Prism gallery: $missingNonPrism');
  }
  if (exportCount != 4) {
    fail('public barrel must export exactly 4 libraries (got $exportCount)');
  }
  if (!hideGallerySpec || !hideGallerySections) {
    fail('public barrel must hide DSGallerySectionSpec and DSGallerySections');
  }
  if (src.length != auditPrism.length) {
    fail('count mismatch src=${src.length} audit=${auditPrism.length}');
  }

  final totalPublic = auditPrism.length + auditNonPrism.length;
  print('  total public top-level (Prism + non-Prism gallery): $totalPublic');

  if (failed) {
    stderr.writeln('Public barrel audit lock: FAIL');
    exit(1);
  }
  print(
    'Public barrel audit lock: PASS '
    '(set equality empty; 4-export barrel; gallery hides OK)',
  );
  exit(0);
}

Directory _resolveRepoRoot(List<String> args) {
  String? explicit;
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--repo-root' && i + 1 < args.length) {
      explicit = args[++i];
    } else if (arg.startsWith('--repo-root=')) {
      explicit = arg.substring('--repo-root='.length);
    }
  }
  if (explicit != null) {
    return Directory(explicit).absolute;
  }
  var dir = Directory.current.absolute;
  while (true) {
    final pubspec = File('${dir.path}/pubspec.yaml');
    if (pubspec.existsSync()) {
      final text = pubspec.readAsStringSync();
      if (text.contains('name: warp_prism') &&
          !text.contains('name: warp_prism_ui')) {
        return dir;
      }
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  // Fallback: package cwd → monorepo root
  final fromPackage = Directory.current.parent.parent;
  if (File('${fromPackage.path}/pubspec.yaml').existsSync()) {
    return fromPackage.absolute;
  }
  throw StateError('Could not resolve monorepo root; pass --repo-root');
}
