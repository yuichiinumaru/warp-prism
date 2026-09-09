import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// ASW Observatory Molecule - Search Bar
///
/// Searchable input with filter integration
class DSSearchBar extends StatefulWidget {
  final String? placeholder;
  final String? value;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final bool showFilter;
  final int? activeFilterCount;
  final bool autofocus;

  const DSSearchBar({
    super.key,
    this.placeholder = 'Search...',
    this.value,
    this.onChanged,
    this.onClear,
    this.onFilterTap,
    this.showFilter = true,
    this.activeFilterCount,
    this.autofocus = false,
  });

  @override
  State<DSSearchBar> createState() => _DSSearchBarState();
}

class _DSSearchBarState extends State<DSSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!mounted) return;
      setState(() => _isFocused = _focusNode.hasFocus);
    });
    _controller.addListener(() {
      if (!mounted) return;
      // Rebuild to show/hide clear button when text changes.
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(DSSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _isFocused
        ? DSColors.focusRing
        : DSColors.borderSubtle;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          color: DSColors.obsidianElevated,
          borderRadius: BorderRadius.circular(DSRadii.input),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            DSIcon.small(
              DSIcons.search,
              color: _isFocused ? DSColors.accentBlue : DSColors.textTertiary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Semantics(
                textField: true,
                label: widget.placeholder ?? 'Search query',
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  style: DSTypography.bodyMedium.copyWith(
                    color: DSColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: DSTypography.bodyMedium.copyWith(
                      color: DSColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: widget.onChanged,
                ),
              ),
            ),
            if (_controller.text.isNotEmpty) ...[
              _IconButton(
                icon: DSIcons.close,
                semanticLabel: 'Clear search query',
                onTap: () {
                  _controller.clear();
                  widget.onClear?.call();
                  widget.onChanged?.call('');
                },
              ),
            ],
            if (widget.showFilter) ...[
              Container(
                width: 1,
                height: 20,
                color: DSColors.borderSubtle,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              Stack(
                children: [
                  _IconButton(
                    icon: DSIcons.filter,
                    semanticLabel: 'Open search filters',
                    onTap: widget.onFilterTap,
                  ),
                  if (widget.activeFilterCount != null &&
                      widget.activeFilterCount! > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: DSBadge.count(
                        widget.activeFilterCount!,
                        color: DSColors.accentBlue,
                        size: DSBadgeSize.small,
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;

  const _IconButton({
    required this.icon,
    required this.semanticLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticLabel,
      child: SizedBox.square(
        dimension: 48,
        child: Material(
          color: DSColors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(DSRadii.sm),
            child: Center(
              child: DSIcon.small(icon, color: DSColors.textTertiary),
            ),
          ),
        ),
      ),
    );
  }
}
