import 'package:flutter/material.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

import 'connected/connected_bridge_lab_page.dart';

export 'connected/connected_bridge_lab_page.dart';

void main() {
  runApp(const WarpPrismCatalogApp());
}

/// Catalog theme accent variants for live preview.
enum CatalogThemeVariant {
  khalaiBlue('Khalai Blue (#2F81FF)'),
  taldarimRed('Taldarim Red (#E51A4C)'),
  talonPurple('Talon Purple (#9911E5)'),
  cybercoreTeal('CyberCore Teal (#00FFCC)');

  final String label;
  const CatalogThemeVariant(this.label);
}

final ValueNotifier<CatalogThemeVariant> catalogThemeVariant =
    ValueNotifier<CatalogThemeVariant>(CatalogThemeVariant.khalaiBlue);

/// Catalog section descriptors distinguishing STATIC/INTERACTIVE from CONNECTED modes.
enum CatalogSection {
  gallery(
    id: 'gallery',
    title: 'ADS Gallery',
    modeLabel: 'STATIC / INTERACTIVE',
    icon: Icons.palette_outlined,
  ),
  connectedLab(
    id: 'connected-lab',
    title: 'Connected Bridge Lab',
    modeLabel: 'CONNECTED',
    icon: Icons.hub_outlined,
  );

  final String id;
  final String title;
  final String modeLabel;
  final IconData icon;

  const CatalogSection({
    required this.id,
    required this.title,
    required this.modeLabel,
    required this.icon,
  });
}

class WarpPrismCatalogApp extends StatefulWidget {
  final int initialSectionIndex;
  final GraphSource<String, String>? connectedSource;
  final bool enablePhysics;

  const WarpPrismCatalogApp({
    super.key,
    this.initialSectionIndex = 0,
    this.connectedSource,
    this.enablePhysics = true,
  });

  @override
  State<WarpPrismCatalogApp> createState() => _WarpPrismCatalogAppState();
}

class _WarpPrismCatalogAppState extends State<WarpPrismCatalogApp> {
  late int _selectedSectionIndex;

  @override
  void initState() {
    super.initState();
    _selectedSectionIndex = widget.initialSectionIndex;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PrismTokenRegistry.instance,
      builder: (context, _) {
        return ValueListenableBuilder<CatalogThemeVariant>(
          valueListenable: catalogThemeVariant,
          builder: (context, variant, _) {
            ThemeData theme;
            switch (variant) {
              case CatalogThemeVariant.taldarimRed:
                theme = PrismTheme.taldarimRed();
              case CatalogThemeVariant.talonPurple:
                theme = PrismTheme.talonPurple();
              case CatalogThemeVariant.cybercoreTeal:
                theme = const PrismCyberCoreTealSkin.omniRoute().applyToTheme(
                  PrismTheme.dark(),
                );
              case CatalogThemeVariant.khalaiBlue:
                theme = PrismTheme.dark();
            }
            return MaterialApp(
              title: 'Warp Prism — ADS Catalog',
              theme: theme,
              home: Scaffold(
                backgroundColor: PrismColors.obsidianDeep,
                body: Column(
                  children: [
                    _buildCatalogHeader(context, variant),
                    Expanded(
                      child: _selectedSectionIndex == 1
                          ? ConnectedBridgeLabPage(
                              source: widget.connectedSource,
                              enablePhysics: widget.enablePhysics,
                            )
                          : const DesignSystemGalleryPage(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCatalogHeader(
    BuildContext context,
    CatalogThemeVariant activeVariant,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PrismSpacing.md,
        vertical: PrismSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: PrismColors.obsidianBase,
        border: const Border(
          bottom: BorderSide(color: PrismColors.borderSubtle),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(
              Icons.view_in_ar,
              size: 20,
              color: PrismColors.accentCyan,
            ),
            const SizedBox(width: PrismSpacing.xs),
            const PrismText.labelLarge('ADS Catalog'),
            const SizedBox(width: PrismSpacing.lg),
            for (final (i, sec) in CatalogSection.values.indexed) ...[
              InkWell(
                key: Key('catalog-nav-${sec.id}'),
                onTap: () => setState(() => _selectedSectionIndex = i),
                borderRadius: BorderRadius.circular(PrismRadii.sm),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PrismSpacing.sm,
                    vertical: PrismSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedSectionIndex == i
                        ? PrismColors.obsidianActive
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(PrismRadii.sm),
                    border: Border.all(
                      color: _selectedSectionIndex == i
                          ? PrismColors.accentBlue.withValues(alpha: 0.6)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        sec.icon,
                        size: 16,
                        color: _selectedSectionIndex == i
                            ? PrismColors.accentBlue
                            : PrismColors.textSecondary,
                      ),
                      const SizedBox(width: PrismSpacing.xs),
                      PrismText.labelMedium(
                        sec.title,
                        color: _selectedSectionIndex == i
                            ? PrismColors.textPrimary
                            : PrismColors.textSecondary,
                      ),
                      const SizedBox(width: PrismSpacing.xs),
                      PrismBadge(
                        label: sec.modeLabel,
                        color: sec == CatalogSection.connectedLab
                            ? PrismColors.statusSuccess
                            : PrismColors.accentCyan,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: PrismSpacing.xs),
            ],
            const SizedBox(width: PrismSpacing.md),
            _buildThemeDropdown(activeVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeDropdown(CatalogThemeVariant activeVariant) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<CatalogThemeVariant>(
        value: activeVariant,
        dropdownColor: PrismColors.obsidianBase,
        icon: const Icon(
          Icons.palette,
          size: 16,
          color: PrismColors.accentCyan,
        ),
        items: CatalogThemeVariant.values.map((v) {
          return DropdownMenuItem<CatalogThemeVariant>(
            value: v,
            child: PrismText.labelSmall(v.label),
          );
        }).toList(),
        onChanged: (newVariant) {
          if (newVariant != null) {
            catalogThemeVariant.value = newVariant;
            switch (newVariant) {
              case CatalogThemeVariant.taldarimRed:
                PrismTokenRegistry.instance.applySkin(
                  const PrismTaldarimRedSkin.taldarimRed(),
                );
              case CatalogThemeVariant.talonPurple:
                PrismTokenRegistry.instance.applySkin(
                  const PrismTalonPurpleSkin.talonPurple(),
                );
              case CatalogThemeVariant.cybercoreTeal:
                PrismTokenRegistry.instance.applySkin(
                  const PrismCyberCoreTealSkin.omniRoute(),
                );
              case CatalogThemeVariant.khalaiBlue:
                PrismTokenRegistry.instance.reset();
            }
          }
        },
      ),
    );
  }
}

