import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// ASW Observatory Molecule - Shimmer
///
/// Animated gradient placeholder that sweeps left-to-right, used as the
/// base building block for all skeleton loading variants.
///
/// Contract:
/// - Loops continuously until removed from the widget tree.
/// - Default colors derived from [DSColors] — no hardcoded values.
/// - Default border radius uses [DSRadii.sm].
/// - Duration defaults to 1500ms.
/// - Decorative: wrapped in [ExcludeSemantics] (hidden from a11y tree).
/// - Honors [MediaQuery.disableAnimationsOf] (reduced motion → solid base).
///
/// Usage:
/// ```dart
/// DSShimmer(
///   width: 200,
///   height: 16,
/// )
/// DSShimmer(
///   width: 48,
///   height: 48,
///   borderRadius: DSRadii.full,
/// )
/// ```
class DSShimmer extends StatefulWidget {
  /// Width of the shimmer rectangle. If null, expands to fill available width.
  final double? width;

  /// Height of the shimmer rectangle.
  final double height;

  /// Base fill color. Defaults to [DSColors.obsidianHover].
  final Color? baseColor;

  /// Highlight sweep color. Defaults to [DSColors.glassOverlay].
  final Color? highlightColor;

  /// Border radius of the shimmer rectangle. Defaults to [DSRadii.sm].
  final double borderRadius;

  /// Duration of one full shimmer sweep. Defaults to 1500ms.
  final Duration duration;

  const DSShimmer({
    super.key,
    this.width,
    required this.height,
    this.baseColor,
    this.highlightColor,
    this.borderRadius = DSRadii.sm,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<DSShimmer> createState() => _DSShimmerState();
}

class _DSShimmerState extends State<DSShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimationToMotionPreference();
  }

  @override
  void didUpdateWidget(DSShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    _syncAnimationToMotionPreference();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Start/stop the sweep based on [MediaQuery.disableAnimationsOf].
  void _syncAnimationToMotionPreference() {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBase = widget.baseColor ?? DSColors.obsidianHover;
    final effectiveHighlight = widget.highlightColor ?? DSColors.glassOverlay;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    // Decorative loading affordance — exclude from the a11y tree.
    return ExcludeSemantics(
      child: reduceMotion
          ? Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: effectiveBase,
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            )
          : AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final stops = [
                  (_controller.value - 0.4).clamp(0.0, 1.0),
                  _controller.value,
                  (_controller.value + 0.4).clamp(0.0, 1.0),
                ];

                return Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    gradient: LinearGradient(
                      begin: const Alignment(-1.0, 0.0),
                      end: const Alignment(1.0, 0.0),
                      colors: [
                        effectiveBase,
                        effectiveHighlight.withValues(alpha: 0.6),
                        effectiveBase,
                      ],
                      stops: stops,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
