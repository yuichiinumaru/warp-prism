import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// ASW Observatory Atom - Status Dot
/// 
/// Small colored indicator for status
class DSStatusDot extends StatelessWidget {
  final Color color;
  final double size;
  final bool animated;
  final String? tooltip;

  const DSStatusDot({
    super.key,
    required this.color,
    this.size = 8,
    this.animated = false,
    this.tooltip,
  });

  // === NAMED CONSTRUCTORS ===
  const DSStatusDot.success({super.key, this.size = 8, this.animated = false, this.tooltip})
      : color = DSColors.statusSuccess;
  
  const DSStatusDot.warning({super.key, this.size = 8, this.animated = false, this.tooltip})
      : color = DSColors.statusWarning;
  
  const DSStatusDot.error({super.key, this.size = 8, this.animated = false, this.tooltip})
      : color = DSColors.statusError;
  
  const DSStatusDot.info({super.key, this.size = 8, this.animated = false, this.tooltip})
      : color = DSColors.statusInfo;
  
  const DSStatusDot.neutral({super.key, this.size = 8, this.animated = false, this.tooltip})
      : color = DSColors.textTertiary;

  @override
  Widget build(BuildContext context) {
    Widget dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: animated ? [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ] : null,
      ),
    );

    if (animated) {
      dot = _AnimatedDot(color: color, size: size);
    }

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: dot,
      );
    }

    return dot;
  }
}

class _AnimatedDot extends StatefulWidget {
  final Color color;
  final double size;

  const _AnimatedDot({required this.color, required this.size});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.5 * _animation.value),
                blurRadius: 4 + (4 * _animation.value),
                spreadRadius: 1 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
