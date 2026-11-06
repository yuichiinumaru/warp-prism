// Graph-source junk/adversarial sweep (Task 1867, part c).
//
// Mechanism mirror of `src/graph_source/`. Stable test ids follow the
// canonical convention (`stableTestId` in the testkit):
// `[graph_source_junk_<case>]`. Node/edge ids, kinds, and labels are open
// caller vocabularies — junk must round-trip and stay equal for identical
// junk.

import 'package:test/test.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

List<String> _junkTexts() => <String>[
  '',
  'null',
  'node:🔥:日本語',
  '<label/>',
  '{{kind}}',
  'service.daemon',
  'a' * 500,
];

String _id(String c) => '[graph_source_junk_$c]';

void main() {
  group('graph source junk sweep', () {
    test('${_id('node_roundtrip')} junk nodes round-trip', () {
      for (final junk in _junkTexts()) {
        final node = GraphNode<String>(
          id: junk,
          kind: junk,
          label: junk,
          payload: junk,
        );
        expect(node.id, equals(junk));
        expect(node.kind, equals(junk));
        expect(node.label, equals(junk));
        expect(
          node,
          equals(
            GraphNode<String>(id: junk, kind: junk, label: junk, payload: junk),
          ),
        );
      }
    });

    test('${_id('edge_roundtrip')} junk edges keep endpoints', () {
      const from = '🔥-from';
      const to = '日本語-to';
      const edge = GraphEdge<String>(
        id: '<edge/>',
        kind: '{{flow}}',
        fromNodeId: from,
        toNodeId: to,
        payload: 'p',
      );
      expect(edge.fromNodeId, equals(from));
      expect(edge.toNodeId, equals(to));
      final moved = edge.copyWith(toNodeId: to);
      expect(moved.fromNodeId, equals(from));
      expect(moved.toNodeId, equals(to));
    });

    test('${_id('node_copy')} copyWith preserves junk unless overridden', () {
      const node = GraphNode<String>(
        id: 'n',
        kind: 'k',
        label: '🔥',
        payload: 'p',
      );
      final copied = node.copyWith(label: '日本語');
      expect(copied.id, equals('n'));
      expect(copied.label, equals('日本語'));
    });
  });
}
