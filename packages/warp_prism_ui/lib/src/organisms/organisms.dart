/// Organisms barrel file - exports all organism components
library;

export 'ds_shell.dart';
export 'ds_sidebar.dart';
export 'ds_topbar.dart';
export 'ds_lane_board.dart';
export 'ds_timeline.dart';
export 'ds_detail_inspector.dart';
export 'ds_story_panel.dart';
export 'ds_graph_canvas.dart';
export 'code_block/ds_code_block.dart';
export 'markdown_renderer/ds_markdown_renderer.dart';
export 'ds_fallback_view.dart';
export 'ds_error_boundary.dart';
export 'ds_status_grid.dart';

/// Graph composable layers — model, layout engine, painter, orchestrator.
///
/// The model types (GraphNode, GraphEdge) are exported with typed aliases
/// to avoid collision with the legacy string-ID versions from ds_graph_canvas.dart.
/// Import the graph sub-package directly for the typed model:
///   import 'package:warp_prism_ui/src/organisms/graph/graph.dart' as graph;
export 'graph/graph.dart' hide GraphNode, GraphEdge;
export 'log_viewer/log_viewer.dart';
export 'command_palette/command_palette.dart';
export 'tab_bar/tab_bar.dart';
export 'split_pane/split_pane.dart';
export 'data_table/ds_data_table.dart';
export 'virtual_scroll/virtual_scroll.dart';
