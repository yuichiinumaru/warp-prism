import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  runApp(const WarpPrismCatalogApp());
}

class WarpPrismCatalogApp extends StatelessWidget {
  const WarpPrismCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warp Prism — ADS Catalog',
      theme: ThemeData.dark(),
      home: const DesignSystemGalleryPage(),
    );
  }
}
