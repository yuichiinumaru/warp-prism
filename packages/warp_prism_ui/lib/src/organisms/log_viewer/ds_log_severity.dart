import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';
import '../../atoms/atoms.dart';

/// Log severity levels for [DSLogViewer].
///
/// Each level carries a canonical color (aligned with the operational state
/// vocabulary), a Material icon, and a short uppercase label.
///
/// Ordering is intentional — [debug] is lowest severity, [critical] is highest.
enum DSLogSeverity {
  /// Diagnostic detail, suppressed by default.
  debug,

  /// Routine operational information.
  info,

  /// Degraded state — attention needed but not blocking.
  warning,

  /// Failure — requires intervention.
  error,

  /// Catastrophic failure — system-wide impact.
  critical,
}

/// UI extensions for [DSLogSeverity]: color, icon, label.
extension DSLogSeverityUI on DSLogSeverity {
  /// Canonical color per severity level.
  ///
  /// Follows operational-state-vocabulary.md color reuse:
  /// - debug   → textTertiary (muted, low emphasis)
  /// - info    → statusInfo
  /// - warning → statusWarning
  /// - error   → statusError
  /// - critical → statusError with glow emphasis
  Color get color {
    switch (this) {
      case DSLogSeverity.debug:
        return DSColors.textTertiary;
      case DSLogSeverity.info:
        return DSColors.statusInfo;
      case DSLogSeverity.warning:
        return DSColors.statusWarning;
      case DSLogSeverity.error:
        return DSColors.statusError;
      case DSLogSeverity.critical:
        return DSColors.statusError;
    }
  }

  /// Icon per severity level.
  ///
  /// Reuses existing [DSIcons] constants where possible.
  IconData get icon {
    switch (this) {
      case DSLogSeverity.debug:
        return Icons.bug_report_outlined;
      case DSLogSeverity.info:
        return DSIcons.info;
      case DSLogSeverity.warning:
        return DSIcons.warning;
      case DSLogSeverity.error:
        return DSIcons.error;
      case DSLogSeverity.critical:
        return Icons.gpp_bad_outlined;
    }
  }

  /// Uppercase label for chip display.
  String get label {
    switch (this) {
      case DSLogSeverity.debug:
        return 'DEBUG';
      case DSLogSeverity.info:
        return 'INFO';
      case DSLogSeverity.warning:
        return 'WARN';
      case DSLogSeverity.error:
        return 'ERROR';
      case DSLogSeverity.critical:
        return 'FATAL';
    }
  }
}
