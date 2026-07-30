import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'apps/observatory/lib/data/providers/workspace_providers.dart';
import 'apps/observatory/lib/features/map/map_workspace.dart';
import 'apps/observatory/lib/data/repositories/workspace_load_state.dart';

class MapPageShell extends ConsumerWidget {
  const MapPageShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadState = ref.watch(workspaceSnapshotAsyncProvider);
    
    // ... how to build MapWorkspaceState?
  }
}
