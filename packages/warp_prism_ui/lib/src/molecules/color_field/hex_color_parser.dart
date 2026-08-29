import 'package:flutter/material.dart';

/// Pure function hex color utilities for [DSColorField].
abstract class HexColorParser {
  /// Parses hex color strings in `#RGB`, `#RRGGBB`, or `#AARRGGBB` format.
  ///
  /// Returns `null` if [input] is `null`, empty, or an invalid hex representation.
  /// Leading `#` is optional. Whitespace is trimmed.
  static Color? tryParseHexColor(String? input) {
    if (input == null) return null;
    var raw = input.trim();
    if (raw.startsWith('#')) {
      raw = raw.substring(1);
    }
    if (raw.isEmpty) return null;

    final hexRegExp = RegExp(r'^[0-9a-fA-F]+$');
    if (!hexRegExp.hasMatch(raw)) return null;

    if (raw.length == 3) {
      final r = int.parse(raw[0] + raw[0], radix: 16);
      final g = int.parse(raw[1] + raw[1], radix: 16);
      final b = int.parse(raw[2] + raw[2], radix: 16);
      return Color.fromARGB(255, r, g, b);
    } else if (raw.length == 6) {
      final val = int.parse(raw, radix: 16);
      return Color(0xFF000000 | val);
    } else if (raw.length == 8) {
      final val = int.parse(raw, radix: 16);
      return Color(val);
    }

    return null;
  }

  /// Formats a [Color] to a hex string.
  ///
  /// If [includeAlpha] is true, returns `#AARRGGBB`.
  /// If [includeAlpha] is false (default), returns `#RRGGBB`.
  /// If [leadingHash] is true (default), prefixes `#`.
  static String formatHexColor(
    Color color, {
    bool includeAlpha = false,
    bool leadingHash = true,
  }) {
    final prefix = leadingHash ? '#' : '';
    final a = (color.a * 255)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();
    final r = (color.r * 255)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();
    final g = (color.g * 255)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();
    final b = (color.b * 255)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();

    if (includeAlpha) {
      return '$prefix$a$r$g$b';
    }
    return '$prefix$r$g$b';
  }
}
