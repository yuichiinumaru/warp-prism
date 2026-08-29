import 'package:flutter/material.dart';

/// Managed token color roles governed by the Black Obsidian Theme Contract.
///
/// See `docs/design/black-obsidian-visual-contract.md` §2.1.
enum PrismColorRole {
  /// Primary scaffold background, viewport root canvas (#030506 family).
  obsidianDeep(
    'obsidianDeep',
    'Deep Background',
    'Primary scaffold background, viewport root canvas',
    Color(0xFF030506),
  ),

  /// Sidebar, primary panels, shell containers, card backgrounds (#080C0E family).
  obsidianBase(
    'obsidianBase',
    'Base Surface',
    'Sidebar, primary panels, shell containers',
    Color(0xFF080C0E),
  ),

  /// Floating panels, modals, dropdowns, elevated cards (#0C1114 family).
  obsidianElevated(
    'obsidianElevated',
    'Elevated Surface',
    'Floating panels, modals, dropdowns, cards',
    Color(0xFF0C1114),
  ),

  /// Subtle neutral lift for hovered interactive surfaces (#12181C family).
  obsidianHover(
    'obsidianHover',
    'Hover Surface',
    'Subtle neutral lift for hovered surfaces',
    Color(0xFF12181C),
  ),

  /// Low-luminance neutral/blue-gray panel border (#121D22 family).
  borderDefault(
    'borderDefault',
    'Default Border',
    'Low-luminance neutral/blue-gray panel border',
    Color(0xFF121D22),
  ),

  /// Primary action accent — blue energy (#2F81FF family).
  accentBlue(
    'accentBlue',
    'Primary Accent (Blue)',
    'Action buttons, active tab indicators, links',
    Color(0xFF2F81FF),
  ),

  /// Secondary action chrome, muted focus edges (#1D64D8 family).
  accentBlueMuted(
    'accentBlueMuted',
    'Accent Blue Muted',
    'Secondary action chrome, muted focus edges',
    Color(0xFF1D64D8),
  ),

  /// Subtle background tint for selected items (#114299 family).
  accentBlueDim(
    'accentBlueDim',
    'Accent Blue Dim',
    'Subtle background tint for selected items',
    Color(0xFF114299),
  ),

  /// High-contrast focus ring outline (50% opacity blue).
  focusRing(
    'focusRing',
    'Focus Ring',
    'High-contrast keyboard focus indicator (50% opacity)',
    Color(0x802F81FF),
  );

  final String key;
  final String label;
  final String description;
  final Color defaultColor;

  const PrismColorRole(
    this.key,
    this.label,
    this.description,
    this.defaultColor,
  );

  /// Grouping category for UI sectioning.
  String get category {
    switch (this) {
      case PrismColorRole.obsidianDeep:
      case PrismColorRole.obsidianBase:
      case PrismColorRole.obsidianElevated:
      case PrismColorRole.obsidianHover:
        return 'Surfaces';
      case PrismColorRole.borderDefault:
        return 'Borders';
      case PrismColorRole.accentBlue:
      case PrismColorRole.accentBlueMuted:
      case PrismColorRole.accentBlueDim:
      case PrismColorRole.focusRing:
        return 'Accent & Focus';
    }
  }
}

/// Registry and override layer for tooling and Theme Editor live iteration.
///
/// DS token getters delegate to this singleton in the catalog and tooling.
/// Production code paths never mutate token state.
class PrismTokenRegistry extends ChangeNotifier {
  static final PrismTokenRegistry _instance = PrismTokenRegistry._internal();

  /// Singleton instance of the token registry.
  static PrismTokenRegistry get instance => _instance;

  PrismTokenRegistry._internal() {
    reset(silent: true);
  }

  final Map<PrismColorRole, Color> _overrides = {};

  /// Current color for [role] (override or default).
  Color getColor(PrismColorRole role) {
    return _overrides[role] ?? role.defaultColor;
  }

  /// Sets an override color for [role] and notifies listeners.
  void setColor(PrismColorRole role, Color color) {
    if (_overrides[role] == color) return;
    _overrides[role] = color;
    notifyListeners();
  }

  /// Resets a single role back to contract default.
  void resetRole(PrismColorRole role) {
    if (_overrides.containsKey(role)) {
      _overrides.remove(role);
      notifyListeners();
    }
  }

  /// Resets all overrides back to Task 1800 contract default values.
  void reset({bool silent = false}) {
    if (_overrides.isEmpty) return;
    _overrides.clear();
    if (!silent) {
      notifyListeners();
    }
  }

  /// Whether any token role is currently overridden.
  bool get hasOverrides => _overrides.isNotEmpty;

  /// Unmodifiable view of active overrides.
  Map<PrismColorRole, Color> get currentOverrides =>
      Map.unmodifiable(_overrides);

  /// Deep background getter.
  Color get obsidianDeep => getColor(PrismColorRole.obsidianDeep);

  /// Base surface getter.
  Color get obsidianBase => getColor(PrismColorRole.obsidianBase);

  /// Elevated surface getter.
  Color get obsidianElevated => getColor(PrismColorRole.obsidianElevated);

  /// Hover surface getter.
  Color get obsidianHover => getColor(PrismColorRole.obsidianHover);

  /// Default border getter.
  Color get borderDefault => getColor(PrismColorRole.borderDefault);

  /// Primary accent blue getter.
  Color get accentBlue => getColor(PrismColorRole.accentBlue);

  /// Muted accent blue getter.
  Color get accentBlueMuted => getColor(PrismColorRole.accentBlueMuted);

  /// Dim accent blue getter.
  Color get accentBlueDim => getColor(PrismColorRole.accentBlueDim);

  /// Focus ring color getter.
  Color get focusRing => getColor(PrismColorRole.focusRing);

  /// Formats a [Color] into a hex string `#AARRGGBB` or `#RRGGBB`.
  static String colorToHex(Color color, {bool includeAlpha = true}) {
    final argb = color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    if (!includeAlpha || argb.startsWith('FF')) {
      return '#${argb.substring(2)}';
    }
    return '#$argb';
  }

  /// Parses a hex color string into a [Color] or returns null if invalid.
  static Color? parseHex(String input) {
    var clean = input.trim().replaceAll('#', '');
    if (clean.length == 3) {
      // #RGB -> #RRGGBB
      clean = clean.split('').map((c) => '$c$c').join();
    }
    if (clean.length == 6) {
      // #RRGGBB -> #FFRRGGBB
      clean = 'FF$clean';
    }
    if (clean.length == 8) {
      final val = int.tryParse(clean, radix: 16);
      if (val != null) {
        return Color(val);
      }
    }
    return null;
  }

  /// Generates a formatted Dart snippet for baking back overrides into token defaults.
  String generateBakeBackSnippet() {
    final buffer = StringBuffer();
    buffer.writeln(
      '// Converged Theme Token Values — Generated by PrismThemeEditor',
    );
    buffer.writeln(
      '// Copy these values into Task 1800 contract or DSColors defaults:',
    );
    buffer.writeln();
    for (final role in PrismColorRole.values) {
      final color = getColor(role);
      final hex = colorToHex(color);
      final isOverridden = _overrides.containsKey(role);
      final status = isOverridden ? '[OVERRIDDEN]' : '[DEFAULT]';
      final valHex =
          '0x${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
      buffer.writeln('// ${role.label} ($hex) $status');
      buffer.writeln('// static const Color ${role.key} = Color($valHex);');
    }
    return buffer.toString();
  }
}
