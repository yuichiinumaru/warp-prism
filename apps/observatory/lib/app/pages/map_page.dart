import 'package:flutter/material.dart';
import '../../features/map/map_workspace.dart';

/// Map workspace — wired to the feature module.
///
/// This page renders the [MapWorkspacePage] with four subviews
/// (Agents, Skills, Workflows, Graph) using the feature-local
/// state contract. The placeholder content in each subview will
/// be replaced by catalog and graph implementations in follow-up tasks.
class MapPageShell extends StatelessWidget {
  const MapPageShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const MapWorkspacePage();
  }
}
