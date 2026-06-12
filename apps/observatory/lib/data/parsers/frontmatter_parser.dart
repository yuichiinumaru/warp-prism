/// Generic YAML frontmatter decoder for markdown documents.
///
/// Splits a document on `---` delimiters, parses the YAML frontmatter
/// section into a `Map<String, dynamic>`, and returns both the parsed
/// frontmatter and the remaining markdown body.
///
/// This parser handles the subset of YAML used by the Warp-Prism mock
/// corpus: simple key-value pairs, nested lists (YAML block sequences),
/// and scalar values (strings, booleans, numbers). It does NOT handle
/// full YAML (anchors, complex mappings, multi-line strings, etc.).
///
/// For production use, the `yaml` package should be preferred. This
/// self-contained decoder exists so the parser layer can compile and
/// be tested without external dependencies beyond `flutter/foundation`.
library;

import 'package:flutter/foundation.dart';

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
        final frontmatter = _parseYaml(yamlSection);
        return FrontmatterResult.success(frontmatter: frontmatter, body: '');
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

    final frontmatter = _parseYaml(yamlSection);

    return FrontmatterResult.success(
      frontmatter: frontmatter,
      body: bodySection,
    );
  }

  /// Parse a simple YAML string into a Map.
  ///
  /// Handles:
  /// - Simple scalar keys: `key: value`
  /// - Quoted values: `key: "quoted value"`
  /// - Boolean values: `key: true` / `key: false`
  /// - Numeric values: `key: 42` / `key: 3.14`
  /// - Null values: `key: null` / `key: ~` / `key:` (empty)
  /// - Block sequence lists:
  ///   ```yaml
  ///   list:
  ///     - item1
  ///     - item2
  ///   ```
  /// - Inline lists: `list: [item1, item2]`
  Map<String, dynamic> _parseYaml(String yaml) {
    final result = <String, dynamic>{};
    final lines = yaml.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty || line.trim().startsWith('#')) continue;

      // Check for top-level key: value
      final match = RegExp(r'^(\w[\w_-]*):\s*(.*)').firstMatch(line);
      if (match == null) continue;

      final key = match.group(1)!;
      final rawValue = match.group(2)!.trim();

      if (rawValue.isEmpty) {
        // Could be a block list on following lines
        final listItems = _parseBlockList(lines, i + 1);
        if (listItems != null) {
          result[key] = listItems;
        } else {
          result[key] = null;
        }
      } else if (rawValue.startsWith('[') && rawValue.endsWith(']')) {
        // Inline list
        result[key] = _parseInlineList(rawValue);
      } else {
        result[key] = _parseScalar(rawValue);
      }
    }

    return result;
  }

  /// Parse a YAML block sequence (indented `- item` lines) starting at [startIndex].
  List<String>? _parseBlockList(List<String> lines, int startIndex) {
    final items = <String>[];
    for (var i = startIndex; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) continue;
      final listMatch = RegExp(r'^\s+-\s+(.*)').firstMatch(line);
      if (listMatch == null) {
        // Not a list item — if we found items, return them; otherwise not a list
        return items.isEmpty ? null : items;
      }
      items.add(_unquote(listMatch.group(1)!.trim()));
    }
    return items.isEmpty ? null : items;
  }

  /// Parse an inline YAML list `[a, b, c]`.
  List<String> _parseInlineList(String raw) {
    final inner = raw.substring(1, raw.length - 1).trim();
    if (inner.isEmpty) return [];
    return inner.split(',').map((e) => _unquote(e.trim())).toList();
  }

  /// Parse a YAML scalar value.
  dynamic _parseScalar(String raw) {
    final unquoted = _unquote(raw);
    if (unquoted == 'null' || unquoted == '~' || unquoted.isEmpty) return null;
    if (unquoted == 'true') return true;
    if (unquoted == 'false') return false;
    final asInt = int.tryParse(unquoted);
    if (asInt != null) return asInt;
    final asDouble = double.tryParse(unquoted);
    if (asDouble != null) return asDouble;
    return unquoted;
  }

  /// Remove surrounding quotes from a value.
  String _unquote(String raw) {
    if ((raw.startsWith('"') && raw.endsWith('"')) ||
        (raw.startsWith("'") && raw.endsWith("'"))) {
      return raw.substring(1, raw.length - 1);
    }
    return raw;
  }
}
