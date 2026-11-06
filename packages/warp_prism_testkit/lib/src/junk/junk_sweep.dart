// Junk + adversarial sweep conventions (Task 1867, part c).
//
// Every IDS/runtime suite gets a mechanism-mirrored `*_junk_test.dart` that
// feeds the shared [kJunkCorpus] and [kAdversarialInputs] through the
// mechanism and asserts fail-closed behavior: no crash, no silent corruption,
// documented rejection (StateError / no-op / sanitized round-trip).
//
// Stable test-id convention: every junk test name starts with
// `[<mechanism>_junk_<case>]` built by [stableTestId], so sweep reports stay
// greppable across suites. This file is pure Dart (testkit law).

/// Builds the stable test id for a junk-sweep case.
///
/// Format: `[<mechanism>_junk_<case>]`, e.g. `[selection_junk_empty_select]`.
String stableTestId(String mechanism, String caseLabel) =>
    '[${mechanism}_junk_$caseLabel]';

/// Junk corpus: hostile-but-typable inputs every mechanism must survive.
///
/// Empty, blank, control characters, over-long, unicode/emoji/RTL, format and
/// template syntax, path traversal, and markup — none may crash a mechanism.
const List<String> kJunkCorpus = <String>[
  '',
  ' ',
  '   ',
  '\t',
  '\n',
  '\r\n',
  '\u0000',
  'null',
  'undefined',
  'None',
  '%s %d %i %@',
  '{{template}}',
  '{{{{}}}}',
  '\${injected}',
  '#{interpolated}',
  '<script>alert(1)</script>',
  '<b>bold</b>',
  '&amp;',
  '../../etc/passwd',
  '..\\..\\windows',
  'C:\\Windows\\System32',
  '/tmp/evil.sh; rm -rf /',
  'a very long input a very long input a very long input a very long input '
      'a very long input a very long input a very long input end',
  '🔥🚀💥',
  '日本語テスト',
  'مرحبا بالعالم',
  'τεστ δοκιμή',
  'zero\u200bwidth\u200binvisible',
  'combining á é í',
  'line one\nline two\nline three',
  'tab\tseparated\tvalues',
  'quote "double" and \'single\'',
  'backslash \\ path',
  'SELECT * FROM users; --',
  '"; DROP TABLE tests; --',
  '() { :; }; echo vulnerable',
];

/// Adversarial inputs: structured attacks beyond stray strings.
///
/// Each entry pairs a case id with a hostile payload: extreme repetition,
/// mixed-script spoofing, newline injection, and truncation probes.
const List<Map<String, String>> kAdversarialInputs = <Map<String, String>>[
  {'case': 'extreme_repetition', 'payload': 'aaaaaaaaaa'},
  {'case': 'newline_injection', 'payload': 'first\ninjected: second'},
  {'case': 'mixed_script_spoof', 'payload': 'раypal'},
  {'case': 'truncation_probe', 'payload': 'prefix…'},
  {'case': 'control_wrapped', 'payload': '\u0001wrapped\u0002'},
];

/// Sweep helper: stable ids for every corpus case of [mechanism].
Iterable<String> junkCaseIds(String mechanism) sync* {
  for (var i = 0; i < kJunkCorpus.length; i++) {
    yield stableTestId(mechanism, 'corpus_$i');
  }
  for (final adversarial in kAdversarialInputs) {
    yield stableTestId(mechanism, adversarial['case']!);
  }
}

/// Sweep helper: asserts the corpus is non-trivially hostile.
///
/// Guards against a future edit hollowing the corpus out to `['']`.
void assertCorpusHostile() {
  assert(kJunkCorpus.length >= 20, 'junk corpus must stay hostile');
  assert(
    kJunkCorpus.any((input) => input.length > 100),
    'junk corpus needs an over-long input',
  );
  assert(
    kJunkCorpus.any((input) => input.contains('\n')),
    'junk corpus needs a newline input',
  );
}

/// Facade over one mechanism's sweep: stable ids plus the shared corpora.
///
/// Suites iterate [caseIds] to build one test per junk input with the stable
/// `[<mechanism>_junk_<case>]` id, so sweep reports stay greppable.
class JunkSweep {
  const JunkSweep(this.mechanism);

  /// Mechanism under sweep (mirrors the mechanism source filename).
  final String mechanism;

  /// Stable test ids for every corpus + adversarial case.
  Iterable<String> get caseIds => junkCaseIds(mechanism);

  /// The shared hostile corpus.
  List<String> get corpus => kJunkCorpus;

  /// The shared structured adversarial inputs.
  List<Map<String, String>> get adversarial => kAdversarialInputs;
}
