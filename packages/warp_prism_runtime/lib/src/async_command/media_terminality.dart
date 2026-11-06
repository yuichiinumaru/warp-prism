import 'package:meta/meta.dart';

/// Cross-boundary path-refusal contract, preserved verbatim.
///
/// Pinned as a `const` so there is exactly one reader of the cross-boundary
/// contract instead of a pattern copy per presentation site. A backend that
/// refuses a path reports it as `path refused [<detail>]: <message>`; any
/// consumer resolving such a message must check this prefix **before** the
/// variant's own label so a policy refusal is never rendered as a plain
/// "Invalid".
///
/// Source shape: the consumer bridge `media_error_mapper.dart:3-8` (Rust builds
/// via `format!("path refused [{}]: {error}")`). The value below is identical.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
const String pathRefusedPrefix = 'path refused [';

/// Generic media-error kind vocabulary for terminality disclosure.
///
/// Mirrors the consumer `MediaError` shape (`media_error_mapper.dart:31-49`)
/// without importing any consumer domain type: the kinds are generic
/// operational semantics owned by Warp Prism, and consumers project their own
/// domain errors onto them at their edge.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
enum PrismMediaErrorKind {
  /// Session handle is closed or unknown.
  sessionClosed,

  /// Reference to an unknown or released handle.
  unknownHandle,

  /// Filesystem or transport I/O failure.
  ioError,

  /// No video stream present in the probed asset.
  noVideoStream,

  /// Codec not supported by the native substrate.
  unsupportedCodec,

  /// Asset probe failed.
  probeFailed,

  /// Transient decode glitch that may recover or pause.
  decodeFailed,

  /// Bounded seek miss or range clamp.
  seekFailed,

  /// Presentation surface failure.
  surfaceError,

  /// Generic invalid input or state.
  invalid,
}

/// Reports whether [kind] is terminal (never worth re-dispatching as-is).
///
/// Only [PrismMediaErrorKind.decodeFailed] ("transient decode glitch may
/// recover or pause") and [PrismMediaErrorKind.seekFailed] ("bounded seek
/// miss or range clamp") are non-terminal; every other kind is terminal.
///
/// Source shape: the consumer `isTerminalMediaError`
/// (`media_error_mapper.dart:51-65`).
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
bool isTerminalMediaError(PrismMediaErrorKind kind) {
  return kind != PrismMediaErrorKind.decodeFailed &&
      kind != PrismMediaErrorKind.seekFailed;
}

/// Extracts the refusal detail from [message] when it carries the verbatim
/// [pathRefusedPrefix] contract, otherwise returns `null`.
///
/// The detail is the text between `[` and the closing `]` of the prefix
/// segment (e.g. `path refused [sandbox]: denied` yields `sandbox`).
/// Callers must consult this **before** the variant's own label so a policy
/// refusal is never surfaced as a plain "Invalid".
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
String? describePathRefusal(String message) {
  final start = message.indexOf(pathRefusedPrefix);
  if (start < 0) return null;
  final detailStart = start + pathRefusedPrefix.length;
  final end = message.indexOf(']', detailStart);
  if (end < 0) return null;
  return message.substring(detailStart, end);
}

/// Resolves a user-facing label for [kind], with refusal checked first.
///
/// When [message] carries the verbatim [pathRefusedPrefix] contract, the
/// refusal disclosure wins and the variant label is never used — a policy
/// refusal is never rendered as a plain "Invalid".
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
String mediaErrorLabel(PrismMediaErrorKind kind, {String? message}) {
  final refusal = message == null ? null : describePathRefusal(message);
  if (refusal != null) {
    return 'Path refused ($refusal)';
  }
  switch (kind) {
    case PrismMediaErrorKind.sessionClosed:
      return 'Session closed';
    case PrismMediaErrorKind.unknownHandle:
      return 'Unknown handle';
    case PrismMediaErrorKind.ioError:
      return 'I/O error';
    case PrismMediaErrorKind.noVideoStream:
      return 'No video stream';
    case PrismMediaErrorKind.unsupportedCodec:
      return 'Unsupported codec';
    case PrismMediaErrorKind.probeFailed:
      return 'Probe failed';
    case PrismMediaErrorKind.decodeFailed:
      return 'Decode failed (transient)';
    case PrismMediaErrorKind.seekFailed:
      return 'Seek failed (bounded)';
    case PrismMediaErrorKind.surfaceError:
      return 'Surface error';
    case PrismMediaErrorKind.invalid:
      return 'Invalid';
  }
}
