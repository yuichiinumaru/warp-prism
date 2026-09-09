import 'package:test/test.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';

void main() {
  group('SelectionState', () {
    test('empty constructor defaults', () {
      const state = SelectionState<String>.empty();
      expect(state.isEmpty, isTrue);
      expect(state.isNotEmpty, isFalse);
      expect(state.count, equals(0));
      expect(state.primarySelection, isNull);
      expect(state.hasPrimary, isFalse);
      expect(state.anchor, isNull);
      expect(state.hasAnchor, isFalse);
      expect(state.contains('item-1'), isFalse);
    });

    test('single selection creation and inspection', () {
      final state = SelectionState<String>.single('node-1', anchor: 'anchor-0');
      expect(state.isEmpty, isFalse);
      expect(state.count, equals(1));
      expect(state.primarySelection, equals('node-1'));
      expect(state.hasPrimary, isTrue);
      expect(state.anchor, equals('anchor-0'));
      expect(state.contains('node-1'), isTrue);
      expect(state.contains('node-2'), isFalse);
    });

    test('multi selection creation and inspection', () {
      final state = SelectionState<String>.multi(
        {'a', 'b', 'c'},
        primarySelection: 'b',
        anchor: 'a',
      );
      expect(state.count, equals(3));
      expect(state.primarySelection, equals('b'));
      expect(state.anchor, equals('a'));
      expect(state.contains('a'), isTrue);
      expect(state.contains('b'), isTrue);
      expect(state.contains('c'), isTrue);
      expect(state.contains('d'), isFalse);
    });

    test('select in single mode replaces selection', () {
      const initial = SelectionState<String>.empty();
      final s1 = initial.select('first', mode: SelectionMode.single);
      expect(s1.selectedItems, equals({'first'}));
      expect(s1.primarySelection, equals('first'));
      expect(s1.anchor, equals('first'));

      final s2 = s1.select('second', mode: SelectionMode.single);
      expect(s2.selectedItems, equals({'second'}));
      expect(s2.primarySelection, equals('second'));
      expect(s2.anchor, equals('first')); // anchor preserved
    });

    test('select in multiple mode accumulates items', () {
      const initial = SelectionState<String>.empty();
      final s1 = initial.select('a', mode: SelectionMode.multiple);
      final s2 = s1.select('b', mode: SelectionMode.multiple);
      final s3 = s2.select('c', mode: SelectionMode.multiple);

      expect(s3.count, equals(3));
      expect(s3.selectedItems, equals({'a', 'b', 'c'}));
      expect(s3.primarySelection, equals('c'));
      expect(s3.anchor, equals('a'));
    });

    test('select in none mode is no-op', () {
      const initial = SelectionState<String>.empty();
      final s1 = initial.select('a', mode: SelectionMode.none);
      expect(s1.isEmpty, isTrue);
    });

    test('deselect removes item and updates primary if needed', () {
      final state = SelectionState<String>.multi(
        {'a', 'b', 'c'},
        primarySelection: 'c',
        anchor: 'a',
      );
      final s1 = state.deselect('c');
      expect(s1.selectedItems, equals({'a', 'b'}));
      expect(s1.primarySelection, isNotNull);
      expect(s1.primarySelection != 'c', isTrue);

      final s2 = s1.deselect('non-existent');
      expect(identical(s2, s1), isTrue);

      final s3 = s1.deselect('a').deselect('b');
      expect(s3.isEmpty, isTrue);
      expect(s3.primarySelection, isNull);
    });

    test('toggle adds unselected and removes selected', () {
      const initial = SelectionState<String>.empty();
      final s1 = initial.toggle('a', mode: SelectionMode.multiple);
      expect(s1.contains('a'), isTrue);

      final s2 = s1.toggle('b', mode: SelectionMode.multiple);
      expect(s2.contains('a'), isTrue);
      expect(s2.contains('b'), isTrue);

      final s3 = s2.toggle('a', mode: SelectionMode.multiple);
      expect(s3.contains('a'), isFalse);
      expect(s3.contains('b'), isTrue);
    });

    test('selectAll and clear', () {
      const initial = SelectionState<String>.empty();
      final s1 = initial.selectAll(['x', 'y', 'z']);
      expect(s1.count, equals(3));

      final s2 = s1.clear(preserveAnchor: true);
      expect(s2.isEmpty, isTrue);
      expect(s2.anchor, isNull); // anchor wasn't set on initial

      final s3 = s1.withAnchor('anchor-item');
      final s4 = s3.clear(preserveAnchor: true);
      expect(s4.isEmpty, isTrue);
      expect(s4.anchor, equals('anchor-item'));
    });

    test('value equality and hashCode', () {
      final a = SelectionState<String>.multi({'1', '2'}, primarySelection: '2');
      final b = SelectionState<String>.multi({'2', '1'}, primarySelection: '2');
      final c = SelectionState<String>.multi({'1', '2'}, primarySelection: '1');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('SelectionChangeEvent', () {
    test('computes added and removed sets accurately', () {
      final prev = SelectionState<String>.single('a');
      final curr = SelectionState<String>.multi({'a', 'b', 'c'});

      final event = SelectionChangeEvent<String>(
        previous: prev,
        current: curr,
        source: SelectionSource.user,
      );

      expect(event.added, equals({'b', 'c'}));
      expect(event.removed, isEmpty);
      expect(event.hasStructuralChanges, isTrue);
      expect(event.hasChanges, isTrue);
      expect(event.source, equals(SelectionSource.user));
    });
  });

  group('SelectionNotifier', () {
    test('single mode enforcement and listener dispatch', () {
      final notifier = SelectionNotifier<String>(mode: SelectionMode.single);
      final events = <SelectionChangeEvent<String>>[];

      notifier.addListener(events.add);

      notifier.select('item-1', source: SelectionSource.user);
      expect(notifier.value.selectedItems, equals({'item-1'}));
      expect(events.length, equals(1));
      expect(events.first.source, equals(SelectionSource.user));
      expect(events.first.added, equals({'item-1'}));

      notifier.select('item-2', source: SelectionSource.keyboard);
      expect(notifier.value.selectedItems, equals({'item-2'}));
      expect(events.length, equals(2));
      expect(events.last.source, equals(SelectionSource.keyboard));
      expect(events.last.added, equals({'item-2'}));
      expect(events.last.removed, equals({'item-1'}));

      notifier.clear(source: SelectionSource.programmatic);
      expect(notifier.value.isEmpty, isTrue);
      expect(events.length, equals(3));
      expect(events.last.source, equals(SelectionSource.programmatic));

      notifier.dispose();
      expect(notifier.isDisposed, isTrue);
      expect(() => notifier.select('item-3'), throwsStateError);
    });

    test('multiple mode accumulation and listener unsubscribe', () {
      final notifier = SelectionNotifier<String>(mode: SelectionMode.multiple);
      final events = <SelectionChangeEvent<String>>[];

      void listener(SelectionChangeEvent<String> e) => events.add(e);
      notifier.addListener(listener);

      notifier.selectAll(['1', '2', '3']);
      expect(notifier.value.count, equals(3));
      expect(events.length, equals(1));

      notifier.toggle('2');
      expect(notifier.value.count, equals(2));
      expect(events.length, equals(2));

      notifier.removeListener(listener);
      notifier.deselect('1');
      expect(notifier.value.count, equals(1));
      expect(events.length, equals(2)); // No new event captured
    });
  });
}
