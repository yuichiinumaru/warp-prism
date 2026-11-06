/// Unit tests for graph painter.
///
/// Task 1117: Tests that GraphPainter draws edges via PictureRecorder,
/// handles highlighting, and produces a picture without errors.
library;

import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/organisms/graph/graph_model.dart';
import 'package:warp_prism_ui/src/organisms/graph/graph_painter.dart';

void main() {
  group('GraphPainter', () {
    late GraphModel model;
    late Map<GraphNodeId, Offset> positions;

    setUp(() {
      model = GraphModel(
        nodes: [
          const GraphNode(id: GraphNodeId('a'), label: 'Alpha', type: 'agent'),
          const GraphNode(id: GraphNodeId('b'), label: 'Beta', type: 'skill'),
          const GraphNode(
            id: GraphNodeId('c'),
            label: 'Gamma',
            type: 'workflow',
          ),
        ],
        edges: [
          GraphEdge.create(sourceId: 'a', targetId: 'b'),
          GraphEdge.create(sourceId: 'b', targetId: 'c', edgeType: 'triggers'),
        ],
      );

      positions = {
        const GraphNodeId('a'): const Offset(-100, 0),
        const GraphNodeId('b'): const Offset(0, 0),
        const GraphNodeId('c'): const Offset(100, 0),
      };
    });

    test('paints without throwing', () {
      final painter = GraphPainter(model: model, positions: positions);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(800, 600);

      // Should not throw
      expect(() => painter.paint(canvas, size), returnsNormally);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('paints with pan and scale transforms', () {
      final painter = GraphPainter(
        model: model,
        positions: positions,
        panOffset: const Offset(50, 50),
        scale: 1.5,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      expect(
        () => painter.paint(canvas, const Size(800, 600)),
        returnsNormally,
      );
    });

    test('paints with highlighted edges (hovered node)', () {
      final painter = GraphPainter(
        model: model,
        positions: positions,
        hoveredNodeId: const GraphNodeId('a'),
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      expect(
        () => painter.paint(canvas, const Size(800, 600)),
        returnsNormally,
      );
    });

    test('paints with highlighted edges (selected node)', () {
      final painter = GraphPainter(
        model: model,
        positions: positions,
        selectedNodeId: const GraphNodeId('b'),
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      expect(
        () => painter.paint(canvas, const Size(800, 600)),
        returnsNormally,
      );
    });

    test('handles empty model gracefully', () {
      const emptyModel = GraphModel(nodes: [], edges: []);
      final painter = GraphPainter(model: emptyModel, positions: {});

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      expect(
        () => painter.paint(canvas, const Size(800, 600)),
        returnsNormally,
      );
    });

    test('handles missing positions gracefully', () {
      // Only provide positions for some nodes
      final partialPositions = {
        const GraphNodeId('a'): const Offset(-100, 0),
        // b and c missing
      };

      final painter = GraphPainter(model: model, positions: partialPositions);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Should not throw even with missing positions
      expect(
        () => painter.paint(canvas, const Size(800, 600)),
        returnsNormally,
      );
    });

    test('shouldRepaint returns true when model changes', () {
      final painter1 = GraphPainter(model: model, positions: positions);

      const differentModel = GraphModel(
        nodes: [
          GraphNode(id: GraphNodeId('x'), label: 'Different', type: 'task'),
        ],
        edges: [],
      );
      final painter2 = GraphPainter(
        model: differentModel,
        positions: {const GraphNodeId('x'): Offset.zero},
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns true when positions change', () {
      final painter1 = GraphPainter(model: model, positions: positions);

      final movedPositions = {
        const GraphNodeId('a'): const Offset(-200, 0),
        const GraphNodeId('b'): const Offset(0, 0),
        const GraphNodeId('c'): const Offset(200, 0),
      };
      final painter2 = GraphPainter(model: model, positions: movedPositions);

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns true when hover state changes', () {
      final painter1 = GraphPainter(model: model, positions: positions);
      final painter2 = GraphPainter(
        model: model,
        positions: positions,
        hoveredNodeId: const GraphNodeId('a'),
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns false when nothing changes', () {
      final painter1 = GraphPainter(model: model, positions: positions);
      final painter2 = GraphPainter(model: model, positions: positions);

      expect(painter1.shouldRepaint(painter2), isFalse);
    });

    test('accepts custom painter config', () {
      const customConfig = GraphPainterConfig(
        edgeStrokeWidth: 2.0,
        arrowSize: 12.0,
        curveOffset: 30.0,
      );

      final painter = GraphPainter(
        model: model,
        positions: positions,
        config: customConfig,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      expect(
        () => painter.paint(canvas, const Size(800, 600)),
        returnsNormally,
      );
    });
  });

  group('GraphPainterConfig', () {
    test('has sensible defaults', () {
      const config = GraphPainterConfig();

      expect(config.edgeStrokeWidth, 1.0);
      expect(config.edgeHighlightStrokeWidth, 2.0);
      expect(config.arrowSize, 8.0);
      expect(config.curveOffset, 20.0);
    });
  });
}
