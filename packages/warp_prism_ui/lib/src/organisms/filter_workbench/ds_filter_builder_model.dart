/// EXPERIMENTAL (Task 1860, F-12): filter-builder model, fake, and
/// clock-injectable debounce-commit controller.
///
/// Pure Dart: no Flutter imports. Filter *semantics* stay caller-supplied —
/// this seam owns only the group-tree structure, per-type field descriptors,
/// and deterministic commit scheduling. Nothing here extends the IDS query
/// intent; predicate evaluation lives with the caller.
///
/// Lifecycle: EXPERIMENTAL — no barrel export, no `Prism*` alias.
library;

/// Injectable clock for deterministic debounce scheduling.
///
/// Production passes [dsFilterSystemClock]; tests pass a fake.
typedef DSFilterClock = DateTime Function();

/// Production wall-clock default. The single `DateTime.now` call permitted
/// in the Task 1860 seam (see boundary check `filter_1860_*`).
DateTime dsFilterSystemClock() => DateTime.now();

/// Boolean combination operator for a [DSFilterGroup].
enum DSFilterGroupOperator {
  /// All predicates/subgroups must hold.
  and,

  /// Any predicate/subgroup must hold.
  or,
}

/// Per-type editor selector for a [DSFilterField].
///
/// Caller-supplied: the field catalog decides which editor each field gets.
/// No generic filter semantics are invented here.
enum DSFilterEditorKind {
  /// Free-text field.
  text,

  /// Numeric field (values carried as strings, parsed caller-side).
  number,

  /// Single-select chips.
  enumSingle,

  /// Multi-select chips.
  enumMulti,

  /// On/off toggle.
  boolean,
}

/// Selectable option for enum editors. Pure-Dart twin of the molecule-level
/// chip option so the model stays Flutter-free; mapped at the editor edge.
class DSFilterBuilderOption {
  /// Stable option value.
  final String value;

  /// Human-readable label.
  final String label;

  const DSFilterBuilderOption({required this.value, required this.label});
}

/// Caller-supplied field descriptor: which editor a field gets and, for
/// enum editors, which options exist.
class DSFilterField {
  /// Stable field identity (maps to one criterion/column caller-side).
  final String id;

  /// Human-readable label.
  final String label;

  /// Which per-type editor renders this field.
  final DSFilterEditorKind editorKind;

  /// Options for [DSFilterEditorKind.enumSingle]/[enumMulti].
  final List<DSFilterBuilderOption> options;

  /// Optional helper line under the editor.
  final String? helperText;

  const DSFilterField({
    required this.id,
    required this.label,
    required this.editorKind,
    this.options = const [],
    this.helperText,
  });
}

/// One caller-supplied predicate: a field plus its raw values.
///
/// Values are normalized strings (`boolean` uses `'true'`/`'false'`).
/// Evaluation is caller-side; the model only carries structure.
class DSFilterPredicate {
  /// Stable predicate identity within its group tree.
  final String id;

  /// References [DSFilterField.id] in the caller-supplied catalog.
  final String fieldId;

  /// Raw predicate values (normalized strings).
  final List<String> values;

  const DSFilterPredicate({
    required this.id,
    required this.fieldId,
    this.values = const [],
  });

  /// True when the predicate carries no values.
  bool get isEmpty => values.isEmpty;

  /// True when the predicate carries at least one value.
  bool get isNotEmpty => values.isNotEmpty;

  /// Copy with replaced values.
  DSFilterPredicate copyWith({List<String>? values}) => DSFilterPredicate(
    id: id,
    fieldId: fieldId,
    values: values ?? this.values,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DSFilterPredicate) return false;
    return other.id == id &&
        other.fieldId == fieldId &&
        _listEquals(other.values, values);
  }

  @override
  int get hashCode => Object.hash(id, fieldId, Object.hashAll(values));

  @override
  String toString() =>
      'DSFilterPredicate(id: $id, fieldId: $fieldId, values: $values)';
}

/// Nested AND/OR group of predicates and subgroups.
class DSFilterGroup {
  /// Stable group identity.
  final String id;

  /// How children combine.
  final DSFilterGroupOperator operator;

  /// Leaf predicates in stable insertion order.
  final List<DSFilterPredicate> predicates;

  /// Nested subgroups in stable insertion order.
  final List<DSFilterGroup> subgroups;

  const DSFilterGroup({
    required this.id,
    this.operator = DSFilterGroupOperator.and,
    this.predicates = const [],
    this.subgroups = const [],
  });

  /// Predicate ids in stable enumeration order (depth-first, insertion).
  List<String> get predicateIds {
    final out = <String>[];
    for (final p in predicates) {
      out.add(p.id);
    }
    for (final g in subgroups) {
      out.addAll(g.predicateIds);
    }
    return out;
  }

  /// Total predicate count across this group and all subgroups.
  int get predicateCount {
    var count = predicates.length;
    for (final g in subgroups) {
      count += g.predicateCount;
    }
    return count;
  }

  /// Copy with replaced children/operator.
  DSFilterGroup copyWith({
    DSFilterGroupOperator? operator,
    List<DSFilterGroup>? subgroups,
    List<DSFilterPredicate>? predicates,
  }) => DSFilterGroup(
    id: id,
    operator: operator ?? this.operator,
    predicates: predicates ?? this.predicates,
    subgroups: subgroups ?? this.subgroups,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DSFilterGroup) return false;
    return other.id == id &&
        other.operator == operator &&
        _listEquals(other.predicates, predicates) &&
        _listEquals(other.subgroups, subgroups);
  }

  @override
  int get hashCode => Object.hash(
    id,
    operator,
    Object.hashAll(predicates),
    Object.hashAll(subgroups),
  );

  @override
  String toString() =>
      'DSFilterGroup(id: $id, operator: $operator, '
      'predicates: $predicates, subgroups: $subgroups)';
}

/// Immutable committed builder state handed to `onCommit`.
class DSFilterBuilderSnapshot {
  /// Committed group tree (root).
  final DSFilterGroup root;

  /// Monotonic commit revision from the debounce controller.
  final int revision;

  const DSFilterBuilderSnapshot({required this.root, required this.revision});

  /// Predicate ids in stable enumeration order.
  List<String> get predicateIds => root.predicateIds;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DSFilterBuilderSnapshot) return false;
    return other.root == root && other.revision == revision;
  }

  @override
  int get hashCode => Object.hash(root, revision);

  @override
  String toString() =>
      'DSFilterBuilderSnapshot(revision: $revision, root: $root)';
}

/// Deterministic debounce-commit scheduler with an injectable clock.
///
/// No timers, no wall-clock reads, no unbounded waits: the caller supplies
/// `now` on every edge ([markEdited], [isDue], [commitIfDue]) and [flush]
/// commits immediately. A hosting widget may arm a bounded single-shot timer
/// from [dueIn], but this controller never waits on its own.
class DSFilterDebounceController {
  /// Delay after the last edit before a commit is due.
  final Duration commitDelay;

  /// Clock used only via caller-supplied `now` values; retained for
  /// hosts that prefer `markEditedNow()` / `commitIfDueNow()`.
  final DSFilterClock clock;

  DateTime? _pendingSince;
  int _revision = 0;
  bool _disposed = false;

  DSFilterDebounceController({required this.commitDelay, DSFilterClock? clock})
    : clock = clock ?? dsFilterSystemClock {
    if (commitDelay.isNegative) {
      throw ArgumentError.value(
        commitDelay,
        'commitDelay',
        'must not be negative',
      );
    }
  }

  /// True while an edit awaits commit.
  bool get hasPending => _pendingSince != null;

  /// When the pending edit occurred, if any.
  DateTime? get pendingSince => _pendingSince;

  /// Monotonic commit revision; increments on every commit.
  int get revision => _revision;

  /// Remaining delay before the pending edit is due at `now`, or null when
  /// nothing is pending. Never negative: overdue returns [Duration.zero].
  Duration? dueIn(DateTime now) {
    final pending = _pendingSince;
    if (pending == null) return null;
    final dueAt = pending.add(commitDelay);
    if (!now.isBefore(dueAt)) return Duration.zero;
    return dueAt.difference(now);
  }

  /// True when a pending edit is due at `now`.
  bool isDue(DateTime now) {
    final pending = _pendingSince;
    if (pending == null) return false;
    return !now.isBefore(pending.add(commitDelay));
  }

  /// Records an edit at `now`, restarting the debounce window.
  void markEdited(DateTime now) {
    _throwIfDisposed();
    _pendingSince = now;
  }

  /// Records an edit at the injected clock's current time.
  void markEditedNow() => markEdited(clock());

  /// Commits if due at `now`. Returns true when a commit happened.
  bool commitIfDue(DateTime now) {
    _throwIfDisposed();
    if (!isDue(now)) return false;
    _pendingSince = null;
    _revision++;
    return true;
  }

  /// Commits if due at the injected clock's current time.
  bool commitIfDueNow() => commitIfDue(clock());

  /// Commits any pending edit immediately. Returns true when a commit
  /// happened; false when nothing was pending. Never waits.
  bool flush() {
    _throwIfDisposed();
    if (_pendingSince == null) return false;
    _pendingSince = null;
    _revision++;
    return true;
  }

  /// Drops a pending edit without committing.
  void cancel() {
    _throwIfDisposed();
    _pendingSince = null;
  }

  /// Releases the controller; further edges throw.
  void dispose() {
    _disposed = true;
    _pendingSince = null;
  }

  void _throwIfDisposed() {
    if (_disposed) throw StateError('DSFilterDebounceController disposed');
  }
}

/// Reference fake model + fixture catalog for the filter-builder seam
/// (Task 1860, F-12).
///
/// Fixture flavor mirrors real anchors (logs / timelines / status grids) so
/// host composition can project the same fixture rows it already renders.
class DSFilterBuilderFake {
  DSFilterBuilderFake._();

  /// Deterministic caller-supplied field catalog for fixtures.
  static List<DSFilterField> fixtureFields() => const [
    DSFilterField(
      id: 'severity',
      label: 'Severity',
      editorKind: DSFilterEditorKind.enumMulti,
      options: [
        DSFilterBuilderOption(value: 'error', label: 'Error'),
        DSFilterBuilderOption(value: 'warning', label: 'Warning'),
        DSFilterBuilderOption(value: 'info', label: 'Info'),
      ],
    ),
    DSFilterField(
      id: 'service',
      label: 'Service contains',
      editorKind: DSFilterEditorKind.text,
      helperText: 'Substring match, case-insensitive',
    ),
    DSFilterField(
      id: 'latency_ms',
      label: 'Latency (ms)',
      editorKind: DSFilterEditorKind.number,
      helperText: 'Upper bound in milliseconds',
    ),
    DSFilterField(
      id: 'environment',
      label: 'Environment',
      editorKind: DSFilterEditorKind.enumSingle,
      options: [
        DSFilterBuilderOption(value: 'prod', label: 'Prod'),
        DSFilterBuilderOption(value: 'staging', label: 'Staging'),
      ],
    ),
    DSFilterField(
      id: 'pinned',
      label: 'Pinned only',
      editorKind: DSFilterEditorKind.boolean,
    ),
  ];

  /// Deterministic fixture tree: root AND with two predicates plus one
  /// nested OR subgroup.
  static DSFilterGroup fixtureTree() => const DSFilterGroup(
    id: 'root',
    operator: DSFilterGroupOperator.and,
    predicates: [
      DSFilterPredicate(
        id: 'p-severity',
        fieldId: 'severity',
        values: ['error', 'warning'],
      ),
      DSFilterPredicate(id: 'p-service', fieldId: 'service', values: ['obs']),
    ],
    subgroups: [
      DSFilterGroup(
        id: 'g-env',
        operator: DSFilterGroupOperator.or,
        predicates: [
          DSFilterPredicate(
            id: 'p-env',
            fieldId: 'environment',
            values: ['prod'],
          ),
          DSFilterPredicate(
            id: 'p-pinned',
            fieldId: 'pinned',
            values: ['true'],
          ),
        ],
      ),
    ],
  );

  /// Deterministic committed snapshot for conformance tests.
  static DSFilterBuilderSnapshot fixtureSnapshot() =>
      DSFilterBuilderSnapshot(root: fixtureTree(), revision: 1);

  /// Empty root group for builder seed tests.
  static DSFilterGroup emptyTree() => const DSFilterGroup(id: 'root');
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
