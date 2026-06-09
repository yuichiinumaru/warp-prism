import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter/services.dart';
import '../../tokens/tokens.dart';

// ============================================================================
// VIRTUAL SCROLL CONFIGURATION
// ============================================================================

/// Configuration for virtual scroll behavior.
///
/// Provides a single control surface for tuning [DSVirtualList] and
/// [DSVirtualGrid] rendering performance.
///
/// When [itemExtent] is provided the underlying [ListView] uses O(1) scroll
/// offset computation (fixed-height items). When null, the list falls back to
/// standard variable-height layout.
class DSVirtualScrollConfig {
  /// Fixed item extent (height for lists, width for grids).
  ///
  /// When non-null, enables O(1) scroll offset computation.
  /// When null, uses standard variable-extent layout.
  final double? itemExtent;

  /// Number of logical pixels of content to cache beyond the viewport.
  ///
  /// Higher values reduce pop-in during fast scrolling at the cost of memory.
  /// Default: 250.
  final double cacheExtent;

  /// Whether to add automatic keep-alives for off-screen children.
  final bool addAutomaticKeepAlives;

  /// Whether to add repaint boundaries around each child.
  final bool addRepaintBoundaries;

  /// Whether to add semantic indexes to children.
  final bool addSemanticIndexes;

  const DSVirtualScrollConfig({
    this.itemExtent,
    this.cacheExtent = 250.0,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  });

  /// Default configuration for fixed-height items (48px extent, 250px cache).
  static const fixed = DSVirtualScrollConfig(itemExtent: 48.0);

  /// Default configuration for variable-height items.
  static const variable = DSVirtualScrollConfig();

  /// High-cache configuration for fast-scrolling scenarios (10K+ items).
  static const highCache = DSVirtualScrollConfig(
    itemExtent: 48.0,
    cacheExtent: 500.0,
  );

  /// Copy with overrides.
  DSVirtualScrollConfig copyWith({
    double? itemExtent,
    double? cacheExtent,
    bool? addAutomaticKeepAlives,
    bool? addRepaintBoundaries,
    bool? addSemanticIndexes,
  }) {
    return DSVirtualScrollConfig(
      itemExtent: itemExtent ?? this.itemExtent,
      cacheExtent: cacheExtent ?? this.cacheExtent,
      addAutomaticKeepAlives:
          addAutomaticKeepAlives ?? this.addAutomaticKeepAlives,
      addRepaintBoundaries:
          addRepaintBoundaries ?? this.addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes ?? this.addSemanticIndexes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSVirtualScrollConfig &&
        other.itemExtent == itemExtent &&
        other.cacheExtent == cacheExtent &&
        other.addAutomaticKeepAlives == addAutomaticKeepAlives &&
        other.addRepaintBoundaries == addRepaintBoundaries &&
        other.addSemanticIndexes == addSemanticIndexes;
  }

  @override
  int get hashCode => Object.hash(
        itemExtent,
        cacheExtent,
        addAutomaticKeepAlives,
        addRepaintBoundaries,
        addSemanticIndexes,
      );
}

// ============================================================================
// VIRTUAL LIST
// ============================================================================

/// A high-performance virtualized list optimized for 10K+ items.
///
/// Wraps Flutter's [ListView.builder] with explicit configuration for:
/// - [DSVirtualScrollConfig.itemExtent] → O(1) scroll offset when fixed-height
/// - [DSVirtualScrollConfig.cacheExtent] → off-screen cache tuning
/// - Keyboard navigation (Page Up/Down, Home/End)
/// - Scroll-to-index support via [scrollController]
///
/// ## Usage
///
/// ```dart
/// DSVirtualList(
///   itemCount: 10000,
///   itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
///   config: DSVirtualScrollConfig.fixed,
/// )
/// ```
///
/// ## Performance
///
/// When [DSVirtualScrollConfig.itemExtent] is provided, the underlying
/// [ListView] uses SliverFixedExtentList which computes scroll offsets in O(1).
/// This is critical for 10K+ item lists where variable-height layout would
/// cause frame drops during fast scrollbar drags.
class DSVirtualList extends StatefulWidget {
  /// Total number of items.
  final int itemCount;

  /// Builder for each item at the given index.
  final IndexedWidgetBuilder itemBuilder;

  /// Virtual scroll configuration. Defaults to [DSVirtualScrollConfig.variable].
  final DSVirtualScrollConfig config;

  /// Optional external scroll controller for programmatic scroll control.
  final ScrollController? scrollController;

  /// Whether to enable keyboard navigation (Page Up/Down, Home/End).
  /// Default: true.
  final bool enableKeyboardNavigation;

  /// Padding around the list content.
  final EdgeInsetsGeometry? padding;

  /// Whether the list scrolls in reverse (e.g., chat-style bottom-anchored).
  final bool reverse;

  /// Scroll physics. Defaults to [ClampingScrollPhysics] for desktop.
  final ScrollPhysics? physics;

  /// Semantic label for the list.
  final String? semanticLabel;

  /// Called when the scroll position changes.
  final VoidCallback? onScrollChange;

  const DSVirtualList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.config = const DSVirtualScrollConfig(),
    this.scrollController,
    this.enableKeyboardNavigation = true,
    this.padding,
    this.reverse = false,
    this.physics,
    this.semanticLabel,
    this.onScrollChange,
  });

  @override
  State<DSVirtualList> createState() => _DSVirtualListState();
}

class _DSVirtualListState extends State<DSVirtualList> {
  late final ScrollController _defaultController;
  ScrollController get _controller =>
      widget.scrollController ?? _defaultController;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.scrollController == null) {
      _defaultController = ScrollController();
    }
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _focusNode.dispose();
    if (widget.scrollController == null) {
      _defaultController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    widget.onScrollChange?.call();
  }

  /// Scroll to a specific item index with animation.
  ///
  /// When [DSVirtualScrollConfig.itemExtent] is set, the offset is computed
  /// in O(1). Otherwise it uses [Scrollable.position.ensureVisible] which
  /// requires layout knowledge.
  void scrollToIndex(int index, {bool animated = true}) {
    if (!_controller.hasClients) return;

    final extent = widget.config.itemExtent;
    if (extent != null) {
      // O(1) scroll offset computation for fixed-extent lists.
      final offset = (index * extent).clamp(
        0.0,
        _controller.position.maxScrollExtent,
      );
      if (animated) {
        _controller.animateTo(
          offset,
          duration: DSMotion.normal,
          curve: DSMotion.enter,
        );
      } else {
        _controller.jumpTo(offset);
      }
    } else {
      // For variable-extent lists, jump to the approximate position.
      final estimatedExtent =
          _controller.position.maxScrollExtent / widget.itemCount;
      final offset = (index * estimatedExtent).clamp(
        0.0,
        _controller.position.maxScrollExtent,
      );
      if (animated) {
        _controller.animateTo(
          offset,
          duration: DSMotion.normal,
          curve: DSMotion.enter,
        );
      } else {
        _controller.jumpTo(offset);
      }
    }
  }

  /// Handle keyboard navigation events.
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (!_controller.hasClients) return KeyEventResult.ignored;

    final position = _controller.position;
    final viewportHeight = position.viewportDimension;

    // Page Down
    if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      _controller.animateTo(
        (position.pixels + viewportHeight).clamp(0.0, position.maxScrollExtent),
        duration: DSMotion.fast,
        curve: DSMotion.enter,
      );
      return KeyEventResult.handled;
    }

    // Page Up
    if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      _controller.animateTo(
        (position.pixels - viewportHeight).clamp(0.0, position.maxScrollExtent),
        duration: DSMotion.fast,
        curve: DSMotion.enter,
      );
      return KeyEventResult.handled;
    }

    // Home
    if (event.logicalKey == LogicalKeyboardKey.home) {
      _controller.animateTo(
        0.0,
        duration: DSMotion.normal,
        curve: DSMotion.enter,
      );
      return KeyEventResult.handled;
    }

    // End
    if (event.logicalKey == LogicalKeyboardKey.end) {
      _controller.animateTo(
        position.maxScrollExtent,
        duration: DSMotion.normal,
        curve: DSMotion.enter,
      );
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    Widget listView;

    if (config.itemExtent != null) {
      // Fixed-extent list — O(1) scroll offset computation.
      listView = ListView.builder(
        controller: _controller,
        padding: widget.padding,
        reverse: widget.reverse,
        physics: widget.physics ?? const ClampingScrollPhysics(),
        itemExtent: config.itemExtent,
        scrollCacheExtent: ScrollCacheExtent.pixels(config.cacheExtent),
        addAutomaticKeepAlives: config.addAutomaticKeepAlives,
        addRepaintBoundaries: config.addRepaintBoundaries,
        addSemanticIndexes: config.addSemanticIndexes,
        itemCount: widget.itemCount,
        itemBuilder: widget.itemBuilder,
      );
    } else {
      // Variable-extent list — standard layout.
      listView = ListView.builder(
        controller: _controller,
        padding: widget.padding,
        reverse: widget.reverse,
        physics: widget.physics ?? const ClampingScrollPhysics(),
        scrollCacheExtent: ScrollCacheExtent.pixels(config.cacheExtent),
        addAutomaticKeepAlives: config.addAutomaticKeepAlives,
        addRepaintBoundaries: config.addRepaintBoundaries,
        addSemanticIndexes: config.addSemanticIndexes,
        itemCount: widget.itemCount,
        itemBuilder: widget.itemBuilder,
      );
    }

    if (widget.enableKeyboardNavigation) {
      listView = Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        autofocus: false,
        child: listView,
      );
    }

    if (widget.semanticLabel != null) {
      return Semantics(
        label: widget.semanticLabel,
        explicitChildNodes: true,
        child: listView,
      );
    }

    return listView;
  }
}

// ============================================================================
// VIRTUAL GRID
// ============================================================================

/// A high-performance virtualized grid for dashboard-style layouts.
///
/// Wraps Flutter's [GridView.builder] with explicit configuration for
/// [crossAxisCount], [childAspectRatio], and [cacheExtent].
///
/// ## Usage
///
/// ```dart
/// DSVirtualGrid(
///   itemCount: 1000,
///   itemBuilder: (context, index) => Card(child: Text('Item $index')),
///   crossAxisCount: 4,
/// )
/// ```
///
/// ## Responsive Column Count
///
/// Use [DSVirtualGrid.responsive] to automatically compute [crossAxisCount]
/// from available width and a minimum [minCrossAxisExtent].
class DSVirtualGrid extends StatelessWidget {
  /// Total number of items.
  final int itemCount;

  /// Builder for each item at the given index.
  final IndexedWidgetBuilder itemBuilder;

  /// Number of columns in the grid (used in fixed mode).
  final int crossAxisCount;

  /// Aspect ratio of each grid child (width / height). Default: 1.0.
  final double childAspectRatio;

  /// Spacing between columns. Default: 8.
  final double crossAxisSpacing;

  /// Spacing between rows. Default: 8.
  final double mainAxisSpacing;

  /// Number of logical pixels of content to cache beyond the viewport.
  /// Default: 250.
  final double cacheExtent;

  /// Padding around the grid content.
  final EdgeInsetsGeometry? padding;

  /// Whether to add repaint boundaries around each child.
  final bool addRepaintBoundaries;

  /// Semantic label for the grid.
  final String? semanticLabel;

  /// Optional scroll physics.
  final ScrollPhysics? physics;

  /// Whether the grid should shrink-wrap its content.
  final bool shrinkWrap;

  /// Whether to add automatic keep-alives for off-screen children.
  final bool addAutomaticKeepAlives;

  /// Whether to add semantic indexes to children.
  final bool addSemanticIndexes;

  /// Whether to use a responsive [SliverGridDelegateWithMaxCrossAxisExtent]
  /// instead of a fixed [crossAxisCount].
  final bool responsive;

  /// Minimum cross-axis extent per item when [responsive] is true.
  /// Default: 280.
  final double minCrossAxisExtent;

  const DSVirtualGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.cacheExtent = 250.0,
    this.padding,
    this.addRepaintBoundaries = true,
    this.semanticLabel,
    this.physics,
    this.shrinkWrap = false,
    this.addAutomaticKeepAlives = true,
    this.addSemanticIndexes = true,
    this.responsive = false,
    this.minCrossAxisExtent = 280.0,
  });

  /// Creates a responsive grid that computes column count from available
  /// width and [minCrossAxisExtent].
  const DSVirtualGrid.responsive({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.minCrossAxisExtent = 280.0,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.cacheExtent = 250.0,
    this.padding,
    this.addRepaintBoundaries = true,
    this.semanticLabel,
    this.physics,
    this.shrinkWrap = false,
    this.addAutomaticKeepAlives = true,
    this.addSemanticIndexes = true,
  })  : responsive = true,
        crossAxisCount = 1;

  @override
  Widget build(BuildContext context) {
    final SliverGridDelegate delegate;
    if (responsive) {
      delegate = SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: minCrossAxisExtent,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      );
    } else {
      delegate = SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      );
    }

    Widget grid = GridView.builder(
      padding: padding,
      physics: physics ?? const ClampingScrollPhysics(),
      shrinkWrap: shrinkWrap,
      scrollCacheExtent: ScrollCacheExtent.pixels(cacheExtent),
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      gridDelegate: delegate,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );

    if (semanticLabel != null) {
      grid = Semantics(
        label: semanticLabel,
        explicitChildNodes: true,
        child: grid,
      );
    }

    return grid;
  }
}
