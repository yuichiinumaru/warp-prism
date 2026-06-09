import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';
import 'ds_tab_controller.dart';

/// ASW Observatory Organism — Tab View
///
/// Renders the active tab's content below a [DSTabBar].
///
/// Uses [IndexedStack] to preserve the state of inactive tab content.
/// The content is keyed by the tab's [DSTab.id] to maintain widget
/// identity across reorder operations.
///
/// Listens to [DSTabController] and rebuilds on tab changes.
///
/// Usage:
/// ```dart
/// Column(
///   children: [
///     DSTabBar(controller: controller),
///     Expanded(child: DSTabView(controller: controller)),
///   ],
/// )
/// ```
class DSTabView extends StatefulWidget {
  /// The tab controller managing which tab is active.
  final DSTabController controller;

  /// Background color for the content area.
  /// Defaults to [DSColors.obsidianDeep].
  final Color? backgroundColor;

  const DSTabView({
    super.key,
    required this.controller,
    this.backgroundColor,
  });

  @override
  State<DSTabView> createState() => _DSTabViewState();
}

class _DSTabViewState extends State<DSTabView> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(DSTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tabs = widget.controller.tabs;
    if (tabs.isEmpty) {
      return const SizedBox.expand();
    }

    return Container(
      color: widget.backgroundColor ?? DSColors.obsidianDeep,
      child: IndexedStack(
        index: widget.controller.activeIndex,
        children: [
          for (final tab in tabs)
            KeyedSubtree(
              key: ValueKey(tab.id),
              child: tab.content(context),
            ),
        ],
      ),
    );
  }
}
