import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// ASW Observatory Atom - Glow Border
/// 
/// Luminous border effect for emphasis
class DSGlowBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double width;
  final double radius;
  final double glowSpread;
  final double glowBlur;
  final bool animated;

  const DSGlowBorder({
    super.key,
    required this.child,
    this.color = DSColors.accentCyan,
    this.width = 1,
    this.radius = DSRadii.card,
    this.glowSpread = 0,
    this.glowBlur = 8,
    this.animated = false,
  });

  // === NAMED CONSTRUCTORS ===
  const DSGlowBorder.cyan({super.key, required this.child, this.width = 1, this.radius = DSRadii.card, this.animated = false})
      : color = DSColors.accentCyan, glowSpread = 0, glowBlur = 8;
  
  const DSGlowBorder.violet({super.key, required this.child, this.width = 1, this.radius = DSRadii.card, this.animated = false})
      : color = DSColors.accentViolet, glowSpread = 0, glowBlur = 8;
  
  const DSGlowBorder.gold({super.key, required this.child, this.width = 1, this.radius = DSRadii.card, this.animated = false})
      : color = DSColors.accentGold, glowSpread = 0, glowBlur = 8;
  
  const DSGlowBorder.success({super.key, required this.child, this.width = 1, this.radius = DSRadii.card, this.animated = false})
      : color = DSColors.statusSuccess, glowSpread = 0, glowBlur = 8;
  
  const DSGlowBorder.error({super.key, required this.child, this.width = 1, this.radius = DSRadii.card, this.animated = false})
      : color = DSColors.statusError, glowSpread = 0, glowBlur = 8;

  @override
  Widget build(BuildContext context) {
    if (animated) {
      return _AnimatedGlowBorder(
        color: color,
        width: width,
        radius: radius,
        glowSpread: glowSpread,
        glowBlur: glowBlur,
        child: child,
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: color, width: width),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: glowBlur,
            spreadRadius: glowSpread,
          ),
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: glowBlur * 2,
            spreadRadius: glowSpread,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - width),
        child: child,
      ),
    );
  }
}

class _AnimatedGlowBorder extends StatefulWidget {
  final Widget child;
  final Color color;
  final double width;
  final double radius;
  final double glowSpread;
  final double glowBlur;

  const _AnimatedGlowBorder({
    required this.child,
    required this.color,
    required this.width,
    required this.radius,
    required this.glowSpread,
    required this.glowBlur,
  });

  @override
  State<_AnimatedGlowBorder> createState() => _AnimatedGlowBorderState();
}

class _AnimatedGlowBorderState extends State<_AnimatedGlowBorder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(color: widget.color, width: widget.width),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3 * _animation.value),
                blurRadius: widget.glowBlur * _animation.value,
                spreadRadius: widget.glowSpread,
              ),
              BoxShadow(
                color: widget.color.withOpacity(0.1 * _animation.value),
                blurRadius: widget.glowBlur * 2 * _animation.value,
                spreadRadius: widget.glowSpread,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius - widget.width),
            child: widget.child,
          ),
        );
      },
    );
  }
}
