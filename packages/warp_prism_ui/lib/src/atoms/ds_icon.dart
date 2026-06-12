import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// ASW Observatory Atom - Icon
///
/// Consistent icon styling with semantic colors
class DSIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final DSIconSize iconSize;
  final String? semanticLabel;

  const DSIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.iconSize = DSIconSize.medium,
    this.semanticLabel,
  });

  // === NAMED CONSTRUCTORS ===
  const DSIcon.small(this.icon, {super.key, this.color, this.semanticLabel})
    : size = null,
      iconSize = DSIconSize.small;

  const DSIcon.medium(this.icon, {super.key, this.color, this.semanticLabel})
    : size = null,
      iconSize = DSIconSize.medium;

  const DSIcon.large(this.icon, {super.key, this.color, this.semanticLabel})
    : size = null,
      iconSize = DSIconSize.large;

  double get _effectiveSize {
    if (size != null) return size!;
    switch (iconSize) {
      case DSIconSize.tiny:
        return 12;
      case DSIconSize.small:
        return 16;
      case DSIconSize.medium:
        return 20;
      case DSIconSize.large:
        return 24;
      case DSIconSize.xlarge:
        return 32;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: _effectiveSize,
      color: color ?? DSColors.textSecondary,
      semanticLabel: semanticLabel,
    );
  }
}

enum DSIconSize { tiny, small, medium, large, xlarge }

/// Common icons used throughout the app
abstract class DSIcons {
  // Navigation
  static const IconData map = Icons.map_outlined;
  static const IconData operate = Icons.play_circle_outline;
  static const IconData history = Icons.history;
  static const IconData governance = Icons.shield_outlined;
  static const IconData settings = Icons.settings_outlined;
  static const IconData search = Icons.search;
  static const IconData filter = Icons.filter_list;
  static const IconData menu = Icons.menu;
  static const IconData close = Icons.close;
  static const IconData back = Icons.arrow_back;
  static const IconData forward = Icons.arrow_forward;
  static const IconData expand = Icons.expand_more;
  static const IconData collapse = Icons.expand_less;

  // Asset kinds
  static const IconData agent = Icons.smart_toy_outlined;
  static const IconData skill = Icons.psychology_outlined;
  static const IconData subskill = Icons.extension_outlined;
  static const IconData workflow = Icons.account_tree_outlined;
  static const IconData task = Icons.task_outlined;
  static const IconData changelog = Icons.article_outlined;
  static const IconData script = Icons.code;
  static const IconData reference = Icons.link;
  static const IconData rule = Icons.rule_outlined;

  // Status
  static const IconData success = Icons.check_circle_outline;
  static const IconData warning = Icons.warning_amber_outlined;
  static const IconData error = Icons.error_outline;
  static const IconData info = Icons.info_outline;
  static const IconData pending = Icons.schedule;
  static const IconData blocked = Icons.block;

  // Actions
  static const IconData refresh = Icons.refresh;
  static const IconData edit = Icons.edit_outlined;
  static const IconData delete = Icons.delete_outline;
  static const IconData copy = Icons.copy_outlined;
  static const IconData link = Icons.link;
  static const IconData unlink = Icons.link_off;
  static const IconData graph = Icons.hub_outlined;
  static const IconData list = Icons.list;
  static const IconData grid = Icons.grid_view;

  // Governance
  static const IconData canonical = Icons.verified_outlined;
  static const IconData local = Icons.home_outlined;
  static const IconData generated = Icons.auto_awesome_outlined;
  static const IconData appendOnly = Icons.lock_clock_outlined;
  static const IconData archive = Icons.inventory_2_outlined;
  static const IconData mock = Icons.science_outlined;

  // Lanes
  static const IconData planning = Icons.lightbulb_outline;
  static const IconData open = Icons.inbox_outlined;
  static const IconData doing = Icons.trending_up;
  static const IconData review = Icons.rate_review_outlined;
  static const IconData completed = Icons.done_all;

  /// Get icon for asset kind
  static IconData forAssetKind(String kind) {
    switch (kind.toLowerCase()) {
      case 'agent':
        return agent;
      case 'skill':
        return skill;
      case 'subskill':
        return subskill;
      case 'workflow':
        return workflow;
      case 'task':
        return task;
      case 'changelog':
        return changelog;
      case 'script':
        return script;
      case 'reference':
        return reference;
      case 'rule':
        return rule;
      default:
        return info;
    }
  }

  /// Get icon for lane
  static IconData forLane(String lane) {
    switch (lane.toLowerCase()) {
      case '00-planning':
        return planning;
      case '01-open':
        return open;
      case '02-doing':
        return doing;
      case '03-review':
        return review;
      case '04-completed':
        return completed;
      default:
        return info;
    }
  }

  /// Get icon for governance status
  static IconData forCanonicity(String canonicity) {
    switch (canonicity.toLowerCase()) {
      case 'parentcanonical':
        return canonical;
      case 'childlocal':
        return local;
      case 'generated':
        return generated;
      case 'appendonly':
        return appendOnly;
      case 'archive':
        return archive;
      case 'mock':
        return mock;
      default:
        return info;
    }
  }
}
