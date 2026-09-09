use super::api::*;

#[test]
fn test_smoke_add() {
    assert_eq!(add(19, 23), 42);
}

#[test]
fn test_smoke_echo() {
    assert_eq!(echo("warp-prism".into()), "echo: warp-prism");
}

#[test]
fn test_create_event() {
    let evt = create_event(
        "evt-10".into(),
        1000,
        FrbEventSeverity::Info,
        "test payload".into(),
        Some("src".into()),
        None,
    );
    assert_eq!(evt.id, "evt-10");
    assert_eq!(evt.severity, FrbEventSeverity::Info);
}

#[test]
fn test_health_evaluation() {
    let cells = vec![
        FrbHealthCell {
            id: "cell-lat".into(),
            provider_id: "native-core".into(),
            provider_label: "Native Core Substrate".into(),
            dimension_id: "latency".into(),
            dimension_label: "Latency".into(),
            state: FrbHealthState::Healthy,
            latency_ms: Some(1),
        },
        FrbHealthCell {
            id: "cell-mem".into(),
            provider_id: "native-core".into(),
            provider_label: "Native Core Substrate".into(),
            dimension_id: "memory".into(),
            dimension_label: "Memory".into(),
            state: FrbHealthState::Healthy,
            latency_ms: None,
        },
    ];
    let agg = evaluate_health_cells(cells);
    assert_eq!(agg, FrbHealthState::Healthy);
}

#[test]
fn test_graph_mutation() {
    let initial_snap = get_sample_graph_snapshot();
    assert!(initial_snap.nodes.len() >= 2);

    let new_node = FrbGraphNode {
        id: "node-extra".into(),
        kind: "service.plugin".into(),
        label: "Extra".into(),
        status: None,
        payload: "{}".into(),
    };
    let updated_snap = apply_graph_node_add(new_node);
    assert!(updated_snap.nodes.iter().any(|n| n.id == "node-extra"));

    let updated_node = FrbGraphNode {
        id: "node-extra".into(),
        kind: "service.plugin".into(),
        label: "Extra Updated".into(),
        status: Some("active".into()),
        payload: "{}".into(),
    };
    let snap_after_update = apply_graph_node_update(updated_node);
    assert_eq!(
        snap_after_update.nodes.iter().find(|n| n.id == "node-extra").unwrap().label,
        "Extra Updated"
    );

    let new_edge = FrbGraphEdge {
        id: "edge-extra".into(),
        kind: "connects".into(),
        from_node_id: "node-root".into(),
        to_node_id: "node-extra".into(),
        payload: "{}".into(),
    };
    let snap_after_edge_add = apply_graph_edge_add(new_edge);
    assert!(snap_after_edge_add.edges.iter().any(|e| e.id == "edge-extra"));

    let updated_edge = FrbGraphEdge {
        id: "edge-extra".into(),
        kind: "connects_strong".into(),
        from_node_id: "node-root".into(),
        to_node_id: "node-extra".into(),
        payload: "{}".into(),
    };
    let snap_after_edge_update = apply_graph_edge_update(updated_edge);
    assert_eq!(
        snap_after_edge_update.edges.iter().find(|e| e.id == "edge-extra").unwrap().kind,
        "connects_strong"
    );

    let snap_after_edge_rm = apply_graph_edge_remove("edge-extra".into());
    assert!(!snap_after_edge_rm.edges.iter().any(|e| e.id == "edge-extra"));

    let snap_after_node_rm = apply_graph_node_remove("node-extra".into());
    assert!(!snap_after_node_rm.nodes.iter().any(|n| n.id == "node-extra"));

    let reset_snap = apply_graph_reset(FrbGraphSnapshot {
        timestamp_millis: 1000,
        nodes: vec![FrbGraphNode {
            id: "node-reset-1".into(),
            kind: "k".into(),
            label: "Reset Node".into(),
            status: None,
            payload: "{}".into(),
        }],
        edges: vec![],
    });
    assert_eq!(reset_snap.nodes.len(), 1);
    assert_eq!(reset_snap.nodes[0].id, "node-reset-1");
}

#[test]
fn test_health_mutations() {
    let initial = get_sample_health_snapshot();
    assert_eq!(initial.aggregate_state, FrbHealthState::Healthy);

    let cell_degraded = FrbHealthCell {
        id: "cell-lat".into(),
        provider_id: "native-core".into(),
        provider_label: "Native Core Substrate".into(),
        dimension_id: "latency".into(),
        dimension_label: "Latency".into(),
        state: FrbHealthState::Degraded,
        latency_ms: Some(500),
    };
    let snap_degraded = set_health_cell(cell_degraded);
    assert_eq!(snap_degraded.aggregate_state, FrbHealthState::Degraded);

    let snap_all_cells = set_health_cells(vec![
        FrbHealthCell {
            id: "cell-unreach".into(),
            provider_id: "prov-x".into(),
            provider_label: "Prov X".into(),
            dimension_id: "conn".into(),
            dimension_label: "Connection".into(),
            state: FrbHealthState::Unreachable,
            latency_ms: None,
        }
    ]);
    assert_eq!(snap_all_cells.aggregate_state, FrbHealthState::Unreachable);
}

#[test]
fn test_cancel_command() {
    let req = FrbCommandRequest {
        id: "cmd-test-cancel".into(),
        command_type: "echo".into(),
        payload: "hello".into(),
        timeout_ms: None,
    };
    // Testing synchronous cancellation helper before/after registration
    assert!(!cancel_command(req.id.clone()));
}

