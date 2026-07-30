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
export 'page_shell/page_shell.dart';
export 'map_hud_workspace/map_hud_workspace.dart';
export 'tool_strip_slideout/tool_strip_slideout.dart';
export 'filter_workbench/filter_workbench.dart';
export 'tree/tree.dart';
export 'agent_transcript/agent_transcript.dart';
export 'tool_call_card/tool_call_card.dart';
export 'message_status_history/message_status_history.dart';
export 'layer_control_panel/layer_control_panel.dart';
export 'time_machine_scrubber/time_machine_scrubber.dart';
export 'entity_locate_search/entity_locate_search.dart';
export 'entity_intel_panel/entity_intel_panel.dart';
export 'watchlist_dock/watchlist_dock.dart';
export 'coordinate_status_bar/coordinate_status_bar.dart';
export 'map_legend/map_legend.dart';
export 'artifact_workbench/artifact_workbench.dart';
export 'status_ticker/status_ticker.dart';
export 'provider_health_matrix/provider_health_matrix.dart';
export 'mcp_capability_inspector/mcp_capability_inspector.dart';
export 'timing_waterfall/timing_waterfall.dart';
export 'traffic_inspector/traffic_inspector.dart';
export 'execution_console/execution_console.dart';
export 'osint_workbench/osint_workbench.dart';
export 'ai_analyst_panel/ai_analyst_panel.dart';
export 'floating_analytics_hud/floating_analytics_hud.dart';
export 'map_canvas_stage/map_canvas_stage.dart';
export 'ops_control_cluster/ops_control_cluster.dart';
export 'connector_panel/connector_panel.dart';
export 'workflow_canvas_stage/workflow_canvas_stage.dart';
export 'view_presets/view_presets.dart';
export 'workspace_share_card/workspace_share_card.dart';
export 'terminal_workspace/terminal_workspace.dart';
export 'entity_relation_card/entity_relation_card.dart';
export 'agent_shell_panel/agent_shell_panel.dart';
export 'keyboard_cheatsheet/keyboard_cheatsheet.dart';
export 'media_detail_overlay/media_detail_overlay.dart';
export 'breadcrumbs/breadcrumbs.dart';
