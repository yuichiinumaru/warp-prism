/// Generic YAML frontmatter decoder for markdown documents.
///
/// Splits a document on `---` delimiters, parses the YAML frontmatter
/// section into a `Map<String, dynamic>` via `package:yaml`, and returns
/// both the parsed frontmatter and the remaining markdown body.
///
/// Full YAML decoding is used (maps, lists, quoted scalars with embedded
/// commas, nested structures). Malformed YAML yields a typed error result.
library;

import 'package:flutter/foundation.dart';
import 'package:yaml/yaml.dart';

/// Result of parsing frontmatter from a markdown document.
///
/// Use [FrontmatterResult.success] and [FrontmatterResult.error] factory
/// constructors. Check [isOk] before accessing [frontmatter] and [body].
@immutable
class FrontmatterResult {
  /// Whether parsing succeeded.
  final bool isOk;

  /// Parsed frontmatter fields (empty map on error).
  final Map<String, dynamic> frontmatter;

  /// Markdown body after the frontmatter (empty string on error).
  final String body;

  /// Error message when [isOk] is false; null on success.
  final String? error;

  const FrontmatterResult._({
    required this.isOk,
    required this.frontmatter,
    required this.body,
    this.error,
  });

  /// Successful parse result.
  const FrontmatterResult.success({
    required Map<String, dynamic> frontmatter,
    required String body,
  }) : this._(isOk: true, frontmatter: frontmatter, body: body);

  /// Failed parse result with a descriptive error.
  const FrontmatterResult.error(String message)
    : this._(isOk: false, frontmatter: const {}, body: '', error: message);

  @override
  String toString() => isOk
      ? 'FrontmatterResult.ok(${frontmatter.keys})'
      : 'FrontmatterResult.error($error)';
}

/// Parses YAML frontmatter from a markdown document.
///
/// Expected format:
/// ```
/// ---
/// key: value
/// list:
///   - item1
///   - item2
/// ---
/// # Markdown body
/// ```
class FrontmatterParser {
  const FrontmatterParser();

  /// Parse [raw] markdown content and extract frontmatter + body.
  ///
  /// Returns [FrontmatterResult.error] when:
  /// - The document does not start with `---`
  /// - The closing `---` delimiter is missing
  /// - The frontmatter section is empty
  /// - The YAML section is not a mapping / fails to decode
  FrontmatterResult parse(String raw) {
    if (raw.isEmpty) {
      return const FrontmatterResult.error('Empty document');
    }

    final trimmed = raw.trimLeft();
    if (!trimmed.startsWith('---')) {
      return const FrontmatterResult.error(
        'Document does not start with --- frontmatter delimiter',
      );
    }

    // Find the closing ---
    final afterFirst = trimmed.substring(3);
    final closeIndex = afterFirst.indexOf('\n---');
    if (closeIndex == -1) {
      // Also check for --- at the very end (no body)
      if (afterFirst.trimRight() == '---' || afterFirst.endsWith('\n---')) {
        // No body, just frontmatter
        final yamlSection = afterFirst
            .replaceAll(RegExp(r'^---\s*$', multiLine: true), '')
            .trim();
        if (yamlSection.isEmpty) {
          return const FrontmatterResult.error('Empty frontmatter section');
        }
        return _decodeYaml(yamlSection, body: '');
      }
      return const FrontmatterResult.error(
        'Missing closing --- frontmatter delimiter',
      );
    }

    final yamlSection = afterFirst.substring(0, closeIndex).trim();
    if (yamlSection.isEmpty) {
      return const FrontmatterResult.error('Empty frontmatter section');
    }

    final bodySection = afterFirst.substring(closeIndex + 4).trimLeft();
    return _decodeYaml(yamlSection, body: bodySection);
  }

  /// Decode YAML with `package:yaml` into a plain Dart map.
  FrontmatterResult _decodeYaml(String yamlSection, {required String body}) {
    try {
      final dynamic decoded = loadYaml(yamlSection);
      if (decoded == null) {
        return const FrontmatterResult.error('Empty frontmatter section');
      }
      if (decoded is! YamlMap && decoded is! Map) {
        return const FrontmatterResult.error(
          'Frontmatter YAML must be a mapping',
        );
      }
      final frontmatter = _toPlainMap(decoded);
      return FrontmatterResult.success(frontmatter: frontmatter, body: body);
    } on YamlException catch (e) {
      return FrontmatterResult.error('Invalid YAML frontmatter: ${e.message}');
    } catch (e) {
      return FrontmatterResult.error('Invalid YAML frontmatter: $e');
    }
  }

  /// Convert YamlNode / nested structures into plain Dart values.
  static Map<String, dynamic> _toPlainMap(dynamic value) {
    final plain = _toPlain(value);
    if (plain is Map<String, dynamic>) return plain;
    if (plain is Map) {
      return plain.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }

  static dynamic _toPlain(dynamic value) {
    if (value is YamlMap) {
      return <String, dynamic>{
        for (final e in value.entries) e.key.toString(): _toPlain(e.value),
      };
    }
    if (value is YamlList) {
      return [for (final e in value) _toPlain(e)];
    }
    if (value is Map) {
      return <String, dynamic>{
        for (final e in value.entries) e.key.toString(): _toPlain(e.value),
      };
    }
    if (value is List) {
      return [for (final e in value) _toPlain(e)];
    }
    return value;
  }
}
