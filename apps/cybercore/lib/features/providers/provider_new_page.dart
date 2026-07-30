import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Pilot A nested — `/providers/new` read-only form shell.
///
/// Displays fixture form fields only. Save is disabled (no backend).
class ProviderNewPage extends StatelessWidget {
  const ProviderNewPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              const Expanded(
                child: PrismText.headingMedium(
                  'New Provider Connection',
                  color: PrismColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: PrismSpacing.md),
          const PrismStateSurface.empty(
            icon: Icons.lock_outline,
            title: 'Read-only form fixture',
            subtitle:
                'Pilot shell shows the create surface without mutation. '
                'No credentials are submitted to a backend.',
            compact: true,
          ),
          const SizedBox(height: PrismSpacing.lg),
          const _ReadonlyField(label: 'Name', hint: 'e.g. OpenAI Production'),
          const _ReadonlyField(
            label: 'Provider',
            hint: 'openai | anthropic | azure',
          ),
          const _ReadonlyField(
            label: 'Auth type',
            hint: 'apikey | oauth | cookie',
          ),
          const _ReadonlyField(
            label: 'Default model',
            hint: 'optional model id',
          ),
          const _ReadonlyField(label: 'API key', hint: '***REDACTED***'),
          const SizedBox(height: PrismSpacing.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save (disabled — read-only pilot)'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  final String label;
  final String hint;

  const _ReadonlyField({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PrismSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrismText.labelMedium(label, color: PrismColors.textSecondary),
          const SizedBox(height: PrismSpacing.xs),
          TextField(
            enabled: false,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: PrismColors.obsidianBase,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(PrismRadii.sm),
                borderSide: const BorderSide(color: PrismColors.borderSubtle),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(PrismRadii.sm),
                borderSide: const BorderSide(color: PrismColors.borderSubtle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
