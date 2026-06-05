/// Graph canvas organism for the Map workspace
/// Displays nodes and edges in an interactive force-directed graph
library;

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// Represents a node in the graph
class GraphNode {
  final String id;
  final String label;
  final String type; // agent, skill, workflow, task, doc
  final String? status;
  final Map<String, dynamic> metadata;
  Offset position;
  Offset velocity;
  bool isDragging;
  bool isHovered;
  bool isSelected;

  GraphNode({
    required this.id,
    required this.label,
    required this.type,
    this.status,
    this.metadata = const {},
    Offset? position,
  })  : position = position ?? Offset.zero,
        velocity = Offset.zero,
        isDragging = false,
        isHovered = false,
        isSelected = false;

  GraphNode copyWith({
    String? id,
    String? label,
    String? type,
    String? status,
    Map<String, dynamic>? metadata,
    Offset? position,
    Offset? velocity,
    bool? isDragging,
    bool? isHovered,
    bool? isSelected,
  }) {
    return GraphNode(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      position: position ?? this.position,
    )
      ..velocity = velocity ?? this.velocity
      ..isDragging = isDragging ?? this.isDragging
      ..isHovered = isHovered ?? this.isHovered
      ..isSelected = isSelected ?? this.isSelected;
  }
}

/// Represents an edge connecting two nodes
class GraphEdge {
  final String sourceId;
  final String targetId;
  final String? label;
  final String edgeType; // uses, triggers, references

  const GraphEdge({
    required this.sourceId,
    required this.targetId,
    this.label,
    this.edgeType = 'references',
  });
}

/// Interactive graph canvas with force-directed layout
class DsGraphCanvas extends StatefulWidget {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final void Function(GraphNode)? onNodeTap;
  final void Function(GraphNode)? onNodeDoubleTap;
  final void Function(GraphNode, Offset)? onNodeDragEnd;
  final bool enablePhysics;
  final double nodeSpacing;

  const DsGraphCanvas({
    super.key,
    required this.nodes,
    required this.edges,
    this.onNodeTap,
    this.onNodeDoubleTap,
    this.onNodeDragEnd,
    this.enablePhysics = true,
    this.nodeSpacing = 150.0,
  });

  @override
  State<DsGraphCanvas> createState() => _DsGraphCanvasState();
}

class _DsGraphCanvasState extends State<DsGraphCanvas>
    with SingleTickerProviderStateMixin {
  late List<GraphNode> _nodes;
  late AnimationController _physicsController;
  Offset _panOffset = Offset.zero;
  double _scale = 1.0;
  String? _hoveredNodeId;
  String? _selectedNodeId;

  @override
  void initState() {
    super.initState();
    _nodes = List.from(widget.nodes);
    _initializePositions();

    _physicsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_updatePhysics);

    if (widget.enablePhysics) {
      _physicsController.repeat();
    }
  }

  void _initializePositions() {
    final random = math.Random(42);
    for (int i = 0; i < _nodes.length; i++) {
      if (_nodes[i].position == Offset.zero) {
        _nodes[i].position = Offset(
          random.nextDouble() * 600 - 300,
          random.nextDouble() * 400 - 200,
        );
      }
    }
  }

  void _updatePhysics() {
    if (!widget.enablePhysics) return;

    const double repulsion = 5000.0;
    const double attraction = 0.01;
    const double damping = 0.9;
    const double minDistance = 50.0;

    // Calculate forces
    for (int i = 0; i < _nodes.length; i++) {
      if (_nodes[i].isDragging) continue;

      Offset force = Offset.zero;

      // Repulsion from other nodes
      for (int j = 0; j < _nodes.length; j++) {
        if (i == j) continue;
        final delta = _nodes[i].position - _nodes[j].position;
        final distance = math.max(delta.distance, minDistance);
        final direction = delta / distance;
        force += direction * (repulsion / (distance * distance));
      }

      // Attraction along edges
      for (final edge in widget.edges) {
        GraphNode? other;
        if (edge.sourceId == _nodes[i].id) {
          other = _nodes.firstWhere(
            (n) => n.id == edge.targetId,
            orElse: () => _nodes[i],
          );
        } else if (edge.targetId == _nodes[i].id) {
          other = _nodes.firstWhere(
            (n) => n.id == edge.sourceId,
            orElse: () => _nodes[i],
          );
        }
        if (other != null && other.id != _nodes[i].id) {
          final delta = other.position - _nodes[i].position;
          final distance = delta.distance;
          if (distance > widget.nodeSpacing) {
            force += delta * attraction;
          }
        }
      }

      // Center gravity
      force -= _nodes[i].position * 0.001;

      _nodes[i].velocity = (_nodes[i].velocity + force) * damping;
      _nodes[i].position += _nodes[i].velocity;
    }

    setState(() {});
  }

  @override
  void didUpdateWidget(DsGraphCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nodes != oldWidget.nodes) {
      _nodes = List.from(widget.nodes);
      _initializePositions();
    }
  }

  @override
  void dispose() {
    _physicsController.dispose();
    super.dispose();
  }

  Color _getNodeColor(String type) {
    switch (type) {
      case 'agent':
        return DsColors.accentCyan;
      case 'skill':
        return DsColors.accentGreen;
      case 'workflow':
        return DsColors.accentAmber;
      case 'task':
        return DsColors.accentMagenta;
      case 'doc':
        return DsColors.neutral500;
      default:
        return DsColors.neutral600;
    }
  }

  IconData _getNodeIcon(String type) {
    switch (type) {
      case 'agent':
        return Icons.smart_toy_outlined;
      case 'skill':
        return Icons.extension_outlined;
      case 'workflow':
        return Icons.account_tree_outlined;
      case 'task':
        return Icons.task_alt_outlined;
      case 'doc':
        return Icons.description_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        // Store initial state for pan/zoom
      },
      onScaleUpdate: (details) {
        setState(() {
          _panOffset += details.focalPointDelta;
          _scale = (_scale * details.scale).clamp(0.3, 3.0);
        });
      },
      child: Container(
        color: DsColors.background,
        child: CustomPaint(
          painter: _GraphPainter(
            nodes: _nodes,
            edges: widget.edges,
            panOffset: _panOffset,
            scale: _scale,
            getNodeColor: _getNodeColor,
            hoveredNodeId: _hoveredNodeId,
            selectedNodeId: _selectedNodeId,
          ),
          child: Stack(
            children: _nodes.map((node) {
              final screenPos = (node.position * _scale) + _panOffset;
              return Positioned(
                left: screenPos.dx + 
                    (MediaQuery.of(context).size.width / 2) - 30,
                top: screenPos.dy + 
                    (MediaQuery.of(context).size.height / 2) - 30,
                child: _buildNode(node),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNode(GraphNode node) {
    final color = _getNodeColor(node.type);
    final isHovered = _hoveredNodeId == node.id;
    final isSelected = _selectedNodeId == node.id;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredNodeId = node.id),
      onExit: (_) => setState(() => _hoveredNodeId = null),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedNodeId = node.id);
          widget.onNodeTap?.call(node);
        },
        onDoubleTap: () => widget.onNodeDoubleTap?.call(node),
        onPanStart: (_) {
          final index = _nodes.indexWhere((n) => n.id == node.id);
          if (index != -1) {
            _nodes[index].isDragging = true;
          }
        },
        onPanUpdate: (details) {
          final index = _nodes.indexWhere((n) => n.id == node.id);
          if (index != -1) {
            setState(() {
              _nodes[index].position += details.delta / _scale;
            });
          }
        },
        onPanEnd: (_) {
          final index = _nodes.indexWhere((n) => n.id == node.id);
          if (index != -1) {
            _nodes[index].isDragging = false;
            widget.onNodeDragEnd?.call(_nodes[index], _nodes[index].position);
          }
        },
        child: AnimatedContainer(
          duration: DsMotion.fast,
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.3)
                : DsColors.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(DsRadii.lg),
            border: Border.all(
              color: isSelected
                  ? color
                  : isHovered
                      ? color.withValues(alpha: 0.6)
                      : DsColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isHovered || isSelected)
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              DsShadows.md,
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DsIcon(
                icon: _getNodeIcon(node.type),
                color: color,
                size: DsIconSize.md,
              ),
              const SizedBox(height: 2),
              DsText(
                node.label.length > 8
                    ? '${node.label.substring(0, 6)}...'
                    : node.label,
                variant: DsTextVariant.caption,
                color: DsColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for graph edges
class _GraphPainter extends CustomPainter {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final Offset panOffset;
  final double scale;
  final Color Function(String) getNodeColor;
  final String? hoveredNodeId;
  final String? selectedNodeId;

  _GraphPainter({
    required this.nodes,
    required this.edges,
    required this.panOffset,
    required this.scale,
    required this.getNodeColor,
    this.hoveredNodeId,
    this.selectedNodeId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw edges
    for (final edge in edges) {
      final sourceNode = nodes.firstWhere(
        (n) => n.id == edge.sourceId,
        orElse: () => nodes.first,
      );
      final targetNode = nodes.firstWhere(
        (n) => n.id == edge.targetId,
        orElse: () => nodes.first,
      );

      if (sourceNode.id == targetNode.id) continue;

      final sourcePos = (sourceNode.position * scale) + panOffset + center;
      final targetPos = (targetNode.position * scale) + panOffset + center;

      final isHighlighted = hoveredNodeId == edge.sourceId ||
          hoveredNodeId == edge.targetId ||
          selectedNodeId == edge.sourceId ||
          selectedNodeId == edge.targetId;

      final paint = Paint()
        ..color = isHighlighted
            ? DsColors.accentCyan.withValues(alpha: 0.6)
            : DsColors.border.withValues(alpha: 0.3)
        ..strokeWidth = isHighlighted ? 2.0 : 1.0
        ..style = PaintingStyle.stroke;

      // Draw curved edge
      final controlPoint = Offset(
        (sourcePos.dx + targetPos.dx) / 2,
        (sourcePos.dy + targetPos.dy) / 2 - 20,
      );

      final path = Path()
        ..moveTo(sourcePos.dx, sourcePos.dy)
        ..quadraticBezierTo(
          controlPoint.dx,
          controlPoint.dy,
          targetPos.dx,
          targetPos.dy,
        );

      canvas.drawPath(path, paint);

      // Draw arrow
      _drawArrow(canvas, sourcePos, targetPos, paint);
    }
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    final direction = (to - from).direction;
    final arrowSize = 8.0;
    final arrowPoint = to - Offset.fromDirection(direction, 35);

    final path = Path()
      ..moveTo(arrowPoint.dx, arrowPoint.dy)
      ..lineTo(
        arrowPoint.dx - arrowSize * math.cos(direction - math.pi / 6),
        arrowPoint.dy - arrowSize * math.sin(direction - math.pi / 6),
      )
      ..moveTo(arrowPoint.dx, arrowPoint.dy)
      ..lineTo(
        arrowPoint.dx - arrowSize * math.cos(direction + math.pi / 6),
        arrowPoint.dy - arrowSize * math.sin(direction + math.pi / 6),
      );

    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) =>
      nodes != oldDelegate.nodes ||
      edges != oldDelegate.edges ||
      panOffset != oldDelegate.panOffset ||
      scale != oldDelegate.scale ||
      hoveredNodeId != oldDelegate.hoveredNodeId ||
      selectedNodeId != oldDelegate.selectedNodeId;
}
