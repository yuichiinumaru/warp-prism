import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';
import '../../atoms/atoms.dart';
import '../code_block/ds_code_block.dart';

/// ASW Observatory Organism — Markdown Renderer
///
/// Renders a subset of Markdown as Flutter widgets.  Display-only — no
/// editing capability.
///
/// Supported block types:
/// - Headings (h1–h4)
/// - Fenced code blocks (delegated to [DSCodeBlock])
/// - Bullet lists (unordered)
/// - Ordered lists
/// - Blockquotes
///
/// Supported inline types:
/// - **bold**
/// - *italic*
/// - `inline code`
/// - [link text](url)
///
/// Falls back to plain [Text] for unrecognized content.
class DSMarkdownRenderer extends StatelessWidget {
  final String data;

  const DSMarkdownRenderer({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const DSText.bodySmall('No content', color: DSColors.textTertiary);
    }

    final blocks = _MarkdownParser.parse(data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: blocks.map((block) => _buildBlock(block)).toList(),
    );
  }

  Widget _buildBlock(_MarkdownBlock block) {
    return switch (block) {
      _HeadingBlock(:final level, :final text) => _buildHeading(level, text),
      _ParagraphBlock(:final text) => _buildParagraph(text),
      _CodeBlock(:final source, :final language) => Padding(
        padding: const EdgeInsets.only(bottom: DSSpacing.md),
        child: DSCodeBlock(source: source, language: language),
      ),
      _BulletListBlock(:final items) => _buildBulletList(items),
      _OrderedListBlock(:final items) => _buildOrderedList(items),
      _BlockquoteBlock(:final text) => _buildBlockquote(text),
    };
  }

  Widget _buildHeading(int level, String text) {
    final (style, padding) = switch (level) {
      1 => (DSTypography.headingLarge, DSSpacing.lg),
      2 => (DSTypography.headingMedium, DSSpacing.md),
      3 => (DSTypography.headingSmall, DSSpacing.sm),
      _ => (
        DSTypography.bodyLarge.copyWith(
          fontWeight: DSTypography.weightSemibold,
        ),
        DSSpacing.sm,
      ),
    };

    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: _RichMarkdownText(
        text: text,
        baseStyle: style.copyWith(color: DSColors.textPrimary),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.md),
      child: _RichMarkdownText(
        text: text,
        baseStyle: DSTypography.bodyMedium.copyWith(
          color: DSColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: SizedBox(
                    width: 6,
                    height: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: DSColors.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: _RichMarkdownText(
                    text: item,
                    baseStyle: DSTypography.bodyMedium.copyWith(
                      color: DSColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderedList(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: DSText.labelMedium(
                    '${entry.key + 1}.',
                    color: DSColors.textTertiary,
                  ),
                ),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: _RichMarkdownText(
                    text: entry.value,
                    baseStyle: DSTypography.bodyMedium.copyWith(
                      color: DSColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBlockquote(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: DSColors.accentCyanDim, width: 3),
          ),
        ),
        child: _RichMarkdownText(
          text: text,
          baseStyle: DSTypography.bodyMedium.copyWith(
            color: DSColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Inline rich text rendering
// =============================================================================

/// Renders a single markdown text string as a [RichText] widget,
/// handling **bold**, *italic*, `code`, and [link](url) inline spans.
class _RichMarkdownText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;

  const _RichMarkdownText({required this.text, required this.baseStyle});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(style: baseStyle, children: _parseInline(text, baseStyle)),
    );
  }

  /// Parses inline markdown spans into [TextSpan] children.
  static List<InlineSpan> _parseInline(String text, TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    // Combined pattern: **bold**, *italic*, `code`, [link](url)
    final pattern = RegExp(
      r'\*\*(.+?)\*\*' // bold
      r'|(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)' // italic
      r'|`([^`]+)`' // inline code
      r'|\[([^\]]+)\]\(([^)]+)\)', // link
    );

    int pos = 0;
    for (final match in pattern.allMatches(text)) {
      // Plain text before match
      if (match.start > pos) {
        spans.add(TextSpan(text: text.substring(pos, match.start)));
      }

      if (match.group(1) != null) {
        // Bold
        spans.add(
          TextSpan(
            text: match.group(1),
            style: baseStyle.copyWith(fontWeight: DSTypography.weightBold),
          ),
        );
      } else if (match.group(2) != null) {
        // Italic
        spans.add(
          TextSpan(
            text: match.group(2),
            style: baseStyle.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      } else if (match.group(3) != null) {
        // Inline code
        spans.add(
          TextSpan(
            text: match.group(3),
            style: DSTypography.codeSmall.copyWith(
              color: DSColors.statusWarning,
              backgroundColor: DSColors.obsidianHover,
            ),
          ),
        );
      } else if (match.group(4) != null && match.group(5) != null) {
        // Link — display-only, no URL launching
        final linkText = match.group(4)!;
        spans.add(
          TextSpan(
            text: linkText,
            style: baseStyle.copyWith(
              color: DSColors.accentCyan,
              decoration: TextDecoration.underline,
              decorationColor: DSColors.accentCyanDim,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // Display-only: URL is surfaced to the caller through semantics.
                // For interactive launching, wrap DSMarkdownRenderer in a
                // GestureDetector or supply a callback in a future extension.
              },
          ),
        );
      }

      pos = match.end;
    }

    // Remaining text
    if (pos < text.length) {
      spans.add(TextSpan(text: text.substring(pos)));
    }

    return spans;
  }
}

// =============================================================================
// Markdown parser — block-level
// =============================================================================

/// Simple line-by-line Markdown parser.
///
/// Produces a flat list of [_MarkdownBlock]s.  Fenced code blocks are
/// detected by tracking ```` ``` ```` open/close state across lines.
class _MarkdownParser {
  const _MarkdownParser._();

  static List<_MarkdownBlock> parse(String data) {
    final blocks = <_MarkdownBlock>[];
    final lines = data.split('\n');

    bool inCodeBlock = false;
    String? codeLanguage;
    final codeBuffer = StringBuffer();
    String? pendingParagraph;
    List<String>? pendingBullets;
    List<String>? pendingOrdered;

    void flushParagraph() {
      if (pendingParagraph != null) {
        blocks.add(_ParagraphBlock(text: pendingParagraph!));
        pendingParagraph = null;
      }
    }

    void flushBullets() {
      if (pendingBullets != null && pendingBullets!.isNotEmpty) {
        blocks.add(_BulletListBlock(items: List.of(pendingBullets!)));
        pendingBullets = null;
      }
    }

    void flushOrdered() {
      if (pendingOrdered != null && pendingOrdered!.isNotEmpty) {
        blocks.add(_OrderedListBlock(items: List.of(pendingOrdered!)));
        pendingOrdered = null;
      }
    }

    void flushAll() {
      flushParagraph();
      flushBullets();
      flushOrdered();
    }

    for (final line in lines) {
      // Fenced code block open/close
      if (RegExp(r'^```').hasMatch(line.trimRight())) {
        if (inCodeBlock) {
          // Close code block
          blocks.add(
            _CodeBlock(
              source: codeBuffer.toString().trimRight(),
              language: codeLanguage,
            ),
          );
          codeBuffer.clear();
          inCodeBlock = false;
          codeLanguage = null;
        } else {
          flushAll();
          // Open code block
          inCodeBlock = true;
          final langMatch = RegExp(r'^```(\w+)').firstMatch(line.trimRight());
          codeLanguage = langMatch?.group(1);
        }
        continue;
      }

      if (inCodeBlock) {
        if (codeBuffer.isNotEmpty) codeBuffer.writeln();
        codeBuffer.write(line);
        continue;
      }

      // Blank line — flush everything
      if (line.trim().isEmpty) {
        flushAll();
        continue;
      }

      // Heading
      final headingMatch = RegExp(r'^(#{1,4})\s+(.+)').firstMatch(line);
      if (headingMatch != null) {
        flushAll();
        blocks.add(
          _HeadingBlock(
            level: headingMatch.group(1)!.length,
            text: headingMatch.group(2)!,
          ),
        );
        continue;
      }

      // Blockquote
      if (line.startsWith('> ')) {
        flushAll();
        blocks.add(_BlockquoteBlock(text: line.substring(2)));
        continue;
      }

      // Unordered list item
      final bulletMatch = RegExp(r'^\s*[-*+]\s+(.+)').firstMatch(line);
      if (bulletMatch != null) {
        flushParagraph();
        flushOrdered();
        pendingBullets ??= [];
        pendingBullets!.add(bulletMatch.group(1)!);
        continue;
      }

      // Ordered list item
      final orderedMatch = RegExp(r'^\s*\d+\.\s+(.+)').firstMatch(line);
      if (orderedMatch != null) {
        flushParagraph();
        flushBullets();
        pendingOrdered ??= [];
        pendingOrdered!.add(orderedMatch.group(1)!);
        continue;
      }

      // Paragraph — accumulate lines
      flushBullets();
      flushOrdered();
      if (pendingParagraph != null) {
        pendingParagraph = '$pendingParagraph $line';
      } else {
        pendingParagraph = line;
      }
    }

    // Flush remaining state
    if (inCodeBlock && codeBuffer.isNotEmpty) {
      blocks.add(
        _CodeBlock(
          source: codeBuffer.toString().trimRight(),
          language: codeLanguage,
        ),
      );
    }
    flushAll();

    return blocks;
  }
}

// =============================================================================
// Block model
// =============================================================================

sealed class _MarkdownBlock {
  const _MarkdownBlock();
}

class _HeadingBlock extends _MarkdownBlock {
  final int level;
  final String text;
  const _HeadingBlock({required this.level, required this.text});
}

class _ParagraphBlock extends _MarkdownBlock {
  final String text;
  const _ParagraphBlock({required this.text});
}

class _CodeBlock extends _MarkdownBlock {
  final String source;
  final String? language;
  const _CodeBlock({required this.source, this.language});
}

class _BulletListBlock extends _MarkdownBlock {
  final List<String> items;
  const _BulletListBlock({required this.items});
}

class _OrderedListBlock extends _MarkdownBlock {
  final List<String> items;
  const _OrderedListBlock({required this.items});
}

class _BlockquoteBlock extends _MarkdownBlock {
  final String text;
  const _BlockquoteBlock({required this.text});
}
