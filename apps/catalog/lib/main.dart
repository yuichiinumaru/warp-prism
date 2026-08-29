import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

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

class WarpPrismCatalogApp extends StatelessWidget {
  const WarpPrismCatalogApp({super.key});

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
              home: const DesignSystemGalleryPage(),
            );
          },
        );
      },
    );
  }
}
