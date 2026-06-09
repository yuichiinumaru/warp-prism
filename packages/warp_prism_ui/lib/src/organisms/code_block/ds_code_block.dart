import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/tokens.dart';
import '../../atoms/atoms.dart';

/// ASW Observatory Organism — Code Block
///
/// Displays syntax-highlighted code/config content with a glass-panel
/// aesthetic.  Display-only — no editing capability.
///
/// Contract:
/// - [source] is the raw code/config string to display.
/// - [language] optionally specifies the language; when `null` the widget
///   auto-detects Dart, JSON, YAML, or Markdown.
/// - [showLineNumbers] toggles the gutter (defaults to `true`).
/// - [showCopyButton] toggles the copy-to-clipboard action (defaults to `true`).
class DSCodeBlock extends StatelessWidget {
  final String source;
  final String? language;
  final bool showLineNumbers;
  final bool showCopyButton;
  final double? maxHeight;

  const DSCodeBlock({
    super.key,
    required this.source,
    this.language,
    this.showLineNumbers = true,
    this.showCopyButton = true,
    this.maxHeight,
  });

  /// Returns the effective language — explicit or auto-detected.
  String? get effectiveLanguage =>
      language ?? _LanguageDetector.detect(source);

  @override
  Widget build(BuildContext context) {
    if (source.isEmpty) {
      return _buildEmptyState();
    }

    final lang = effectiveLanguage;
    final lines = source.split('\n');
    final gutterWidth = showLineNumbers ? _gutterWidth(lines.length) : 0.0;

    return DSGlassPanelSimple(
      backgroundColor: DSColors.obsidianDeep.withValues(alpha: 0.9),
      borderColor: DSColors.borderSubtle,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(lang),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxHeight ?? double.infinity,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildCodeContent(lines, gutterWidth, lang),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return DSGlassPanelSimple(
      backgroundColor: DSColors.obsidianDeep.withValues(alpha: 0.9),
      borderColor: DSColors.borderSubtle,
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: const Center(
        child: DSText.bodySmall(
          'No content',
          color: DSColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildHeader(String? lang) {
    final label = _LanguageDetector.labelFor(lang);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: DSColors.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        children: [
          const DSIcon.small(Icons.code, color: DSColors.textTertiary),
          const SizedBox(width: DSSpacing.sm),
          DSText.labelSmall(label, color: DSColors.textTertiary),
          const Spacer(),
          if (showCopyButton) _CopyButton(source: source),
        ],
      ),
    );
  }

  Widget _buildCodeContent(List<String> lines, double gutterWidth, String? lang) {
    final highlighter = _SyntaxHighlighter(source: source, language: lang ?? 'plain');
    final highlightedSpans = highlighter.highlight();

    return Padding(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLineNumbers) ...[
            _buildLineNumbers(lines.length, gutterWidth),
            const SizedBox(width: DSSpacing.md),
          ],
          RichText(
            text: TextSpan(
              style: DSTypography.codeMedium.copyWith(
                color: DSColors.textPrimary,
                height: 1.6,
              ),
              children: highlightedSpans,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineNumbers(int count, double width) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(count, (i) {
          return Text(
            '${i + 1}',
            style: DSTypography.codeSmall.copyWith(
              color: DSColors.textDisabled,
              height: 1.6,
            ),
          );
        }),
      ),
    );
  }

  double _gutterWidth(int lineCount) {
    final digits = '$lineCount'.length;
    return (digits * 8.0) + 4;
  }
}

// =============================================================================
// Copy-to-clipboard button
// =============================================================================

class _CopyButton extends StatefulWidget {
  final String source;
  const _CopyButton({required this.source});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _copied ? 'Copied' : 'Copy to clipboard',
      button: true,
      child: InkWell(
        onTap: _handleCopy,
        borderRadius: BorderRadius.circular(DSRadii.sm),
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DSIcon.small(
                _copied ? Icons.check : Icons.copy,
                color: _copied ? DSColors.statusSuccess : DSColors.textTertiary,
              ),
              if (_copied) ...[
                const SizedBox(width: DSSpacing.xs),
                const DSText.labelSmall('Copied', color: DSColors.statusSuccess),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.source));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }
}

// =============================================================================
// Language detector
// =============================================================================

class _LanguageDetector {
  const _LanguageDetector._();

  static String? detect(String source) {
    if (source.isEmpty) return null;

    final trimmed = source.trimLeft();

    // JSON — starts with { or [
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      return 'json';
    }

    // Markdown — fenced code blocks or headings
    if (RegExp(r'^#{1,6}\s', multiLine: true).hasMatch(source) ||
        RegExp(r'^```', multiLine: true).hasMatch(source)) {
      return 'markdown';
    }

    // Dart — imports, class definitions, main function, annotations
    if (RegExp(r"^import\s+[\x27\x22]", multiLine: true).hasMatch(source) ||
        RegExp(r'\bclass\s+\w+', multiLine: true).hasMatch(source) ||
        RegExp(r'void\s+main\s*\(', multiLine: true).hasMatch(source) ||
        RegExp(r'^@\w+', multiLine: true).hasMatch(source)) {
      return 'dart';
    }

    // YAML — lines matching `key: value` pattern (conservative: at least 2)
    final yamlKeyPattern = RegExp(r'^\s*\w[\w.-]*\s*:', multiLine: true);
    final yamlMatches = yamlKeyPattern.allMatches(source);
    if (yamlMatches.length >= 2) {
      return 'yaml';
    }

    return null;
  }

  static String labelFor(String? language) {
    switch (language) {
      case 'dart':
        return 'Dart';
      case 'json':
        return 'JSON';
      case 'yaml':
      case 'yml':
        return 'YAML';
      case 'markdown':
      case 'md':
        return 'Markdown';
      default:
        return 'Plain Text';
    }
  }
}

// =============================================================================
// Syntax highlighter
// =============================================================================

class _SyntaxHighlighter {
  final String source;
  final String language;

  const _SyntaxHighlighter({required this.source, required this.language});

  List<TextSpan> highlight() {
    final patterns = _patternsForLanguage(language);
    if (patterns.isEmpty) {
      return <TextSpan>[_plainSpan(source)];
    }
    return _tokenize(source, patterns);
  }

  // ---------------------------------------------------------------------------
  // Pattern sets per language
  // ---------------------------------------------------------------------------

  static const _commentColor = DSColors.textTertiary;
  static const _keywordColor = DSColors.accentViolet;
  static const _stringColor = DSColors.statusSuccess;
  static const _numberColor = DSColors.accentGold;
  static const _boolColor = DSColors.accentGold;
  static const _typeColor = DSColors.accentCyan;
  static const _punctuationColor = DSColors.textSecondary;
  static const _annotationColor = DSColors.accentCyan;
  static const _keyColor = DSColors.accentCyan;
  static const _headingColor = DSColors.accentCyan;
  static const _emphasisColor = DSColors.accentGold;
  static const _codeColor = DSColors.statusWarning;

  static List<_HighlightPattern> _patternsForLanguage(String language) {
    switch (language) {
      case 'dart':
        return _dartPatterns;
      case 'json':
        return _jsonPatterns;
      case 'yaml':
      case 'yml':
        return _yamlPatterns;
      case 'markdown':
      case 'md':
        return _markdownPatterns;
      default:
        return const [];
    }
  }

  // Dart
  static final _dartPatterns = <_HighlightPattern>[
    _HighlightPattern(RegExp(r"'''[\s\S]*?'''"), _stringColor),
    _HighlightPattern(RegExp(r'"""[\s\S]*?"""'), _stringColor),
    _HighlightPattern(RegExp(r'//.*'), _commentColor),
    _HighlightPattern(RegExp(r'/\*[\s\S]*?\*/'), _commentColor),
    _HighlightPattern(RegExp(r'@\w+'), _annotationColor),
    _HighlightPattern(
      RegExp(
        r'\b(import|export|library|part|class|abstract|extends|implements|'
        r'mixin|enum|typedef|if|else|for|while|do|switch|case|default|'
        r'break|continue|return|throw|try|catch|finally|new|const|final|'
        r'var|late|required|static|void|this|super|is|as|in|async|await|'
        r'yield|sync|get|set|operator|factory|assert|with|rethrow)\b',
      ),
      _keywordColor,
    ),
    _HighlightPattern(
      RegExp(
        r'\b(String|int|double|num|bool|dynamic|Object|List|Map|Set|'
        r'Future|Stream|Iterable|Widget|StatelessWidget|StatefulWidget|'
        r'State|BuildContext|Key|Color|TextStyle|EdgeInsets|IconData|'
        r'FutureOr|Type|Null|Function|Comparable|Pattern|RegExp|DateTime|'
        r'Duration|Uri|StackTrace|Symbol|Never)\b',
      ),
      _typeColor,
    ),
    _HighlightPattern(RegExp(r'\b\d+\.?\d*\b'), _numberColor),
    _HighlightPattern(RegExp(r"'[^'\\]*(?:\\.[^'\\]*)*'"), _stringColor),
    _HighlightPattern(RegExp(r'"[^"\\]*(?:\\.[^"\\]*)*"'), _stringColor),
  ];

  // JSON
  static final _jsonPatterns = <_HighlightPattern>[
    _HighlightPattern(RegExp(r'"[^"\\]*(?:\\.[^"\\]*)*"\s*(?=:)'), _keyColor),
    _HighlightPattern(RegExp(r'"[^"\\]*(?:\\.[^"\\]*)*"'), _stringColor),
    _HighlightPattern(RegExp(r'-?\b\d+\.?\d*(?:[eE][+-]?\d+)?\b'), _numberColor),
    _HighlightPattern(RegExp(r'\b(true|false|null)\b'), _boolColor),
    _HighlightPattern(RegExp(r'[{}\[\]]'), _punctuationColor),
  ];

  // YAML
  static final _yamlPatterns = <_HighlightPattern>[
    _HighlightPattern(RegExp(r'#.*'), _commentColor),
    _HighlightPattern(RegExp(r'^\s*\w[\w.-]*\s*(?=:)', multiLine: true), _keyColor),
    _HighlightPattern(RegExp(r'[&*]\w+'), _annotationColor),
    _HighlightPattern(RegExp(r"'[^']*'"), _stringColor),
    _HighlightPattern(RegExp(r'"[^"]*"'), _stringColor),
    _HighlightPattern(RegExp(r'\b(true|false|null|yes|no|on|off)\b'), _boolColor),
    _HighlightPattern(RegExp(r'\b\d+\.?\d*\b'), _numberColor),
  ];

  // Markdown
  static final _markdownPatterns = <_HighlightPattern>[
    _HighlightPattern(RegExp(r'^#{1,6}\s+.*', multiLine: true), _headingColor),
    _HighlightPattern(RegExp(r'\*\*[^*]+\*\*'), _emphasisColor),
    _HighlightPattern(RegExp(r'(?<!\*)\*(?!\*)[^*]+\*(?!\*)'), _emphasisColor),
    _HighlightPattern(RegExp(r'`[^`]+`'), _codeColor),
    _HighlightPattern(RegExp(r'\[[^\]]+\]\([^)]+\)'), _typeColor),
    _HighlightPattern(RegExp(r'^>\s*.*', multiLine: true), _commentColor),
    _HighlightPattern(RegExp(r'^\s*[-*+]\s', multiLine: true), _punctuationColor),
    _HighlightPattern(RegExp(r'^\s*\d+\.\s', multiLine: true), _punctuationColor),
  ];

  // ---------------------------------------------------------------------------
  // Tokenization engine
  // ---------------------------------------------------------------------------

  List<TextSpan> _tokenize(String text, List<_HighlightPattern> patterns) {
    final spans = <TextSpan>[];
    int pos = 0;

    while (pos < text.length) {
      _HighlightMatch? bestMatch;
      int bestStart = text.length;

      // Try to match at current position first (priority to earlier pattern)
      for (final pattern in patterns) {
        final match = pattern.regex.matchAsPrefix(text, pos);
        if (match != null) {
          bestStart = match.start;
          bestMatch = _HighlightMatch(match, pattern.color);
          break;
        }
      }

      // If no match at current pos, find the next occurrence of any pattern
      if (bestMatch == null) {
        for (final pattern in patterns) {
          final matches = pattern.regex.allMatches(text, pos);
          for (final match in matches) {
            if (match.start < bestStart) {
              bestStart = match.start;
              bestMatch = _HighlightMatch(match, pattern.color);
              break;
            }
          }
          if (bestStart == pos) break;
        }
      }

      if (bestMatch != null) {
        // Add plain text before match
        if (bestStart > pos) {
          spans.add(_plainSpan(text.substring(pos, bestStart)));
        }
        // Add highlighted match
        spans.add(TextSpan(
          text: bestMatch.match.group(0),
          style: TextStyle(color: bestMatch.color),
        ));
        pos = bestMatch.match.end;
      } else {
        // No more matches — remaining text is plain
        spans.add(_plainSpan(text.substring(pos)));
        break;
      }
    }

    return spans;
  }

  static TextSpan _plainSpan(String text) {
    return TextSpan(
      text: text,
      style: const TextStyle(color: DSColors.textPrimary),
    );
  }
}

class _HighlightPattern {
  final RegExp regex;
  final Color color;

  const _HighlightPattern(this.regex, this.color);
}

class _HighlightMatch {
  final Match match;
  final Color color;

  const _HighlightMatch(this.match, this.color);
}
