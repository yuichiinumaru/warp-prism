/// Graph canvas orchestrator — composes model, layout, painter, and interaction.
///
/// This widget is the new composable replacement for the monolith
/// `DSGraphCanvas`. It delegates to extracted layers:
/// - [GraphModel] for data
/// - [GraphLayoutEngine] for positions
/// - [GraphPainter] for rendering
/// - Internal gesture/mouse handlers for interaction
///
/// The original `DSGraphCanvas` (in `ds_graph_canvas.dart`) is now a thin
/// backward-compatible wrapper around this widget.
library;

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../tokens/tokens.dart';
import '../../atoms/atoms.dart';
import '../../molecules/molecules.dart';
import 'graph_model.dart';
import 'graph_layout_engine.dart';
import 'force_directed_layout.dart';
import 'graph_painter.dart';

/// Node color resolution — maps node type to design system color.
Color defaultNodeColor(String type) {
  switch (type) {
    case 'agent':
      return DSColors.assetAgent;
    case 'skill':
      return DSColors.assetSkill;
    case 'workflow':
      return DSColors.assetWorkflow;
    case 'task':
      return DSColors.assetTask;
    case 'doc':
      return DSColors.assetReference;
    default:
      return DSColors.textSecondary;
  }
}

/// Node icon resolution — maps node type to material icon.
IconData defaultNodeIcon(String type) {
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

/// Composable graph canvas widget.
///
/// Orchestrates [GraphModel] (data), [GraphLayoutEngine] (positions),
/// [GraphPainter] (rendering), and gesture/mouse interaction.
///
/// This is the internal building block. For backward compatibility,
/// use [DSGraphCanvas] which delegates here.
class GraphCanvas extends StatefulWidget {
  /// The graph data model.
  final GraphModel model;

  /// Layout algorithm. Defaults to [ForceDirectedLayout].
  final GraphLayoutEngine? layoutEngine;

  /// Whether to animate physics (continuous force-directed simulation).
  final bool enablePhysics;

  /// Callback when a node is tapped.
  final void Function(GraphNode)? onNodeTap;

  /// Callback when a node is double-tapped.
  final void Function(GraphNode)? onNodeDoubleTap;

  /// Callback when a node drag ends.
  final void Function(GraphNode, Offset)? onNodeDragEnd;

  /// Color resolver for node types. Defaults to design system mapping.
  final Color Function(String type)? nodeColorResolver;

  /// Icon resolver for node types. Defaults to design system mapping.
  final IconData Function(String type)? nodeIconResolver;

  const GraphCanvas({
    super.key,
    required this.model,
    this.layoutEngine,
    this.enablePhysics = true,
    this.onNodeTap,
    this.onNodeDoubleTap,
    this.onNodeDragEnd,
    this.nodeColorResolver,
    this.nodeIconResolver,
  });

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _physicsController;
  late ForceDirectedLayout _forceLayout;

  /// Current node positions (mutable, updated by physics and interaction).
  final Map<GraphNodeId, Offset> _positions = {};

  /// Current node velocities (mutable, updated by physics).
  final Map<GraphNodeId, Offset> _velocities = {};

  /// Set of currently dragging node IDs (exempt from physics forces).
  final Set<GraphNodeId> _draggingNodes = {};

  Offset _panOffset = Offset.zero;
  double _scale = 1.0;
  GraphNodeId? _hoveredNodeId;
  GraphNodeId? _selectedNodeId;

  Color Function(String) get _nodeColor =>
      widget.nodeColorResolver ?? defaultNodeColor;

  IconData Function(String) get _nodeIcon =>
      widget.nodeIconResolver ?? defaultNodeIcon;

  @override
  void initState() {
    super.initState();
    _forceLayout = ForceDirectedLayout();
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
    for (final node in widget.model.nodes) {
      if (node.position != Offset.zero) {
        _positions[node.id] = node.position;
      } else {
        _positions[node.id] = Offset(
          random.nextDouble() * 600 - 300,
          random.nextDouble() * 400 - 200,
        );
      }
      _velocities[node.id] = Offset.zero;
    }
  }

  void _updatePhysics() {
    if (!widget.enablePhysics) return;

    _forceLayout.simulateStep(
      widget.model,
      _positions,
      _velocities,
      _draggingNodes,
    );

    setState(() {});
  }

  @override
  void didUpdateWidget(GraphCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      _positions.clear();
      _velocities.clear();
      _initializePositions();
    }
  }

  @override
  void dispose() {
    _physicsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.model.nodes.isEmpty) {
      return DSStateSurface.empty(
        icon: DSIcons.graph,
        title: 'No assets to display',
        subtitle:
            'The workspace graph will appear here once assets are loaded',
      );
    }

    return GestureDetector(
      onScaleStart: (_) {},
      onScaleUpdate: (details) {
        setState(() {
          _panOffset += details.focalPointDelta;
          _scale = (_scale * details.scale).clamp(0.3, 3.0);
        });
      },
      child: Container(
        color: DSColors.obsidianDeep,
        child: CustomPaint(
          painter: GraphPainter(
            model: widget.model,
            positions: _positions,
            panOffset: _panOffset,
            scale: _scale,
            hoveredNodeId: _hoveredNodeId,
            selectedNodeId: _selectedNodeId,
          ),
          child: Stack(
            children: widget.model.nodes.map((node) {
              final screenPos =
                  ((_positions[node.id] ?? Offset.zero) * _scale) +
                      _panOffset;
              return Positioned(
                left: screenPos.dx +
                    (MediaQuery.of(context).size.width / 2) -
                    30,
                top: screenPos.dy +
                    (MediaQuery.of(context).size.height / 2) -
                    30,
                child: _buildNode(node),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNode(GraphNode node) {
    final color = _nodeColor(node.type);
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
          _draggingNodes.add(node.id);
        },
        onPanUpdate: (details) {
          setState(() {
            final current = _positions[node.id] ?? Offset.zero;
            _positions[node.id] = current + details.delta / _scale;
          });
        },
        onPanEnd: (_) {
          _draggingNodes.remove(node.id);
          final pos = _positions[node.id] ?? Offset.zero;
          widget.onNodeDragEnd?.call(
            node.copyWith(position: pos),
            pos,
          );
        },
        child: AnimatedContainer(
          duration: DSMotion.fast,
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.3)
                : DSColors.obsidianElevated.withOpacity(0.9),
            borderRadius: BorderRadius.circular(DSRadii.lg),
            border: Border.all(
              color: isSelected
                  ? color
                  : isHovered
                      ? color.withOpacity(0.6)
                      : DSColors.borderSubtle,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isHovered || isSelected)
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ...DSShadows.elevation2,
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DSIcon(
                _nodeIcon(node.type),
                color: color,
                iconSize: DSIconSize.medium,
              ),
              const SizedBox(height: 2),
              DSText.labelSmall(
                node.label.length > 8
                    ? '${node.label.substring(0, 6)}...'
                    : node.label,
                color: DSColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
