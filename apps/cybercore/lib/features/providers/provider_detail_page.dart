import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../../data/fixtures/fixtures.dart';

/// Pilot A nested — `/providers/:id` read-only detail.
class ProviderDetailPage extends StatefulWidget {
  final String providerId;

  const ProviderDetailPage({super.key, required this.providerId});

  @override
  State<ProviderDetailPage> createState() => _ProviderDetailPageState();
}

class _ProviderDetailPageState extends State<ProviderDetailPage> {
  ProviderConnection? _provider;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final provider = await FixtureLoader.loadProviderById(widget.providerId);
      if (mounted) {
        setState(() {
          _provider = provider;
          _loading = false;
          if (provider == null) {
            _error = 'Provider ${widget.providerId} not found in fixtures';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const PrismStateSurface.loading(
        title: 'Loading provider...',
        subtitle: 'Resolving connection fixture',
      );
    }

    if (_error != null || _provider == null) {
      return PrismStateSurface.error(
        title: 'Provider not found',
        subtitle: _error ?? 'Missing fixture',
        actionLabel: 'Back to providers',
        onAction: () => context.go('/providers'),
      );
    }

    final p = _provider!;
    return PrismErrorBoundary(
      child: ListView(
        padding: const EdgeInsets.all(PrismSpacing.lg),
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.go('/providers'),
                icon: const Icon(Icons.arrow_back),
                color: PrismColors.textSecondary,
                tooltip: 'Back to providers',
              ),
              const SizedBox(width: PrismSpacing.sm),
              Expanded(
                child: PrismText.headingMedium(
                  p.name,
                  color: PrismColors.textPrimary,
                ),
              ),
              PrismBadge(
                label: p.operationalLabel,
                color: _statusColor(p.operationalLabel),
              ),
            ],
          ),
          const SizedBox(height: PrismSpacing.lg),
          _DetailRow(label: 'ID', value: p.id),
          _DetailRow(label: 'Provider', value: p.provider),
          _DetailRow(label: 'Auth type', value: p.authType),
          _DetailRow(label: 'Default model', value: p.defaultModel ?? '—'),
          _DetailRow(label: 'Priority', value: '${p.priority}'),
          _DetailRow(
            label: 'Global priority',
            value: p.globalPriority?.toString() ?? '—',
          ),
          _DetailRow(label: 'Active', value: p.isActive ? 'yes' : 'no'),
          _DetailRow(label: 'Test status', value: p.testStatus ?? 'unknown'),
          _DetailRow(label: 'Last tested', value: p.lastTested ?? '—'),
          _DetailRow(label: 'Last error', value: p.lastError ?? '—'),
          _DetailRow(label: 'Error code', value: p.errorCode ?? '—'),
          _DetailRow(label: 'Created', value: p.createdAt ?? '—'),
          _DetailRow(label: 'Updated', value: p.updatedAt ?? '—'),
          const SizedBox(height: PrismSpacing.lg),
          const PrismText.labelSmall(
            'Read-only fixture detail — no mutation actions call a backend.',
            color: PrismColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Color _statusColor(String label) {
    switch (label) {
      case 'active':
        return PrismColors.statusSuccess;
      case 'error':
        return PrismColors.statusError;
      case 'inactive':
        return PrismColors.textTertiary;
      default:
        return PrismColors.statusWarning;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PrismSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: PrismText.labelMedium(
              label,
              color: PrismColors.textTertiary,
            ),
          ),
          Expanded(
            child: PrismText.bodyMedium(value, color: PrismColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
