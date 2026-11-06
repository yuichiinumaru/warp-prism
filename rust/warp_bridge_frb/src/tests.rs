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

/// WP-004: a failing command must not leave a registry entry behind.
///
/// `CommandRegistry` (in `warp_bridge_core`, outside this task's writeset) has
/// no `len()` accessor, so "the registry returns to zero" is asserted through
/// its public per-id presence surface: `get()` and `cancel_command()` both
/// report absence for the command id after the failing execution.
#[test]
fn test_failing_command_does_not_leak_registry_entry() {
    let rt = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .expect("current-thread tokio runtime");

    let req = FrbCommandRequest {
        id: "cmd-wp004-fail".into(),
        command_type: "fail".into(),
        payload: "simulated failure".into(),
        timeout_ms: None,
    };

    // Pre-condition: nothing registered under this id.
    assert!(
        COMMAND_REGISTRY.get(&req.id).is_none(),
        "pre-condition: id must not be registered before execution"
    );
    assert!(!cancel_command(req.id.clone()));

    let result = rt.block_on(execute_command(req.clone()));

    // The command genuinely failed (so this is not a vacuous pass on success).
    assert!(
        result.error_message.is_some(),
        "expected a failing command to surface an error message"
    );
    assert!(!result.is_cancelled);

    // Post-condition: the registration was released despite the failure.
    assert!(
        COMMAND_REGISTRY.get(&req.id).is_none(),
        "registry must not retain an entry after a failing command"
    );
    assert!(
        !cancel_command(req.id.clone()),
        "registry must not report a cancellable entry after a failing command"
    );
}

/// WP-004 companion: cancellation-by-drop must also release the registration.
///
/// This is the leak the pre-fix post-`await` `unregister` could not cover: when
/// the `execute_command` future is dropped before it resumes, no code after the
/// `.await` ever runs. The `CommandRegistrationGuard` Drop impl closes it.
#[test]
fn test_dropped_command_future_does_not_leak_registry_entry() {
    let rt = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .expect("current-thread tokio runtime");

    let req = FrbCommandRequest {
        id: "cmd-wp004-drop".into(),
        command_type: "long_running".into(),
        payload: "will be dropped".into(),
        timeout_ms: None,
    };

    // Scope the future so it is genuinely dropped at the end of the block.
    // `std::pin::pin!` binds a reference to a temporary whose real lifetime is
    // the enclosing block — dropping the pinned reference would NOT drop the
    // future, which is exactly the mistake that made this test fail first.
    {
        // Poll once so the future registers and reaches the `spawn_blocking`
        // await, then leave the block without ever completing it.
        let mut fut = std::pin::pin!(execute_command(req.clone()));
        let completed = poll_once(&mut fut, &rt);
        assert!(
            !completed,
            "long_running command should not complete on the first poll"
        );
        assert!(
            COMMAND_REGISTRY.get(&req.id).is_some(),
            "pre-condition: the id is registered while the command is in flight"
        );
    } // <- the `execute_command` future is dropped here

    assert!(
        COMMAND_REGISTRY.get(&req.id).is_none(),
        "dropping an in-flight command future must release its registry entry"
    );
    assert!(!cancel_command(req.id.clone()));
}

// ===== F4: command identity / registry safety ============================

/// A duplicate id must be REFUSED, not silently allowed to replace the
/// incumbent's active token.
///
/// The collision is constructed DIRECTLY against the registry — no clock, no
/// microsecond racing, no threads — so this is deterministic by construction.
/// The id is then reused through the real `execute_command` entry point.
#[test]
fn test_duplicate_command_id_is_rejected_and_incumbent_survives() {
    let rt = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .expect("current-thread tokio runtime");

    let id = "cmd-f4-duplicate";
    let incumbent = COMMAND_REGISTRY
        .register(id)
        .expect("first registration must win");

    let req = FrbCommandRequest {
        id: id.into(),
        command_type: "echo".into(),
        payload: "collider".into(),
        timeout_ms: None,
    };

    let result = rt.block_on(execute_command(req));

    // The colliding execution must be rejected as a TYPED DUPLICATE fault.
    assert!(
        result.error_message.is_some(),
        "a duplicate id must surface an error message"
    );
    assert_eq!(
        result.error_kind.as_deref(),
        Some("duplicate"),
        "duplicate must be reported as its own taxonomy kind"
    );
    assert!(
        !result.is_cancelled,
        "a duplicate-id rejection is not a cancellation"
    );
    assert!(result.value.is_none());

    // Critically: the incumbent must NOT have been replaced or cancelled.
    assert!(
        !incumbent.is_cancelled(),
        "a refused duplicate must never cancel the running command"
    );
    assert!(
        COMMAND_REGISTRY.get(id).is_some(),
        "the incumbent registration must survive a refused duplicate"
    );
    assert!(
        cancel_command(id.to_string()),
        "cancel(id) must still address the incumbent"
    );

    COMMAND_REGISTRY.unregister_if(id, &incumbent);
}

/// After the owner releases its registration, the id becomes reusable — the
/// duplicate guard must not permanently poison an id.
#[test]
fn test_command_id_is_reusable_after_cleanup() {
    let rt = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .expect("current-thread tokio runtime");

    let id = "cmd-f4-reusable";
    let first = COMMAND_REGISTRY.register(id).expect("register");
    assert!(COMMAND_REGISTRY.unregister_if(id, &first));

    let req = FrbCommandRequest {
        id: id.into(),
        command_type: "echo".into(),
        payload: "second".into(),
        timeout_ms: None,
    };
    let result = rt.block_on(execute_command(req));

    assert!(result.error_kind.is_none(), "reuse must not report a duplicate");
    assert_eq!(result.value.as_deref(), Some("echo: second"));
    assert!(!result.is_cancelled);
}

// ===== F5: panic / join failure must not mean "cancelled" ===============

/// A normal success carries no error and no taxonomy kind, and is explicitly
/// not cancelled. This is the discrimination baseline the taxonomy exists for:
/// `is_cancelled` alone can no longer be conflated with failure.
#[test]
fn test_successful_command_reports_no_error_kind_and_not_cancelled() {
    let rt = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .expect("current-thread tokio runtime");

    let req = FrbCommandRequest {
        id: "cmd-f5-success".into(),
        command_type: "echo".into(),
        payload: "ok".into(),
        timeout_ms: None,
    };
    let result = rt.block_on(execute_command(req));

    assert!(result.error_message.is_none());
    assert!(result.error_kind.is_none());
    assert!(!result.is_cancelled);
}

/// A native-domain rejection is an EXECUTION failure — distinct from both
/// cancellation and transport. The kind field must preserve that distinction.
#[test]
fn test_domain_rejection_reports_execution_kind_not_cancellation() {
    let rt = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .expect("current-thread tokio runtime");

    let req = FrbCommandRequest {
        id: "cmd-f5-exec".into(),
        command_type: "fail".into(),
        payload: "domain said no".into(),
        timeout_ms: None,
    };
    let result = rt.block_on(execute_command(req));

    assert_eq!(result.error_kind.as_deref(), Some("execution"));
    assert!(!result.is_cancelled);
}

/// Genuine cooperative cancellation remains a cancellation.
///
/// This is the counterpart to the duplicate/transport cases: it proves the
/// narrowing did not break real cancellation.
#[test]
fn test_real_cancellation_is_still_reported_as_cancelled() {
    let rt = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .expect("current-thread tokio runtime");

    let req = FrbCommandRequest {
        id: "cmd-f5-cancel".into(),
        command_type: "long_running".into(),
        payload: "cancel me".into(),
        timeout_ms: None,
    };

    let mut fut = std::pin::pin!(execute_command(req.clone()));
    let completed = poll_once(&mut fut, &rt);
    assert!(!completed, "long_running must still be in flight");

    assert!(cancel_command(req.id.clone()), "pre-condition: must be cancellable");

    let result = rt.block_on(fut);
    assert!(
        result.is_cancelled,
        "an observed cooperative cancellation must still report cancelled"
    );
    assert!(result.error_message.is_none());
    assert!(result.value.is_none());
}

/// Polls `future` exactly once, returning whether it completed.
fn poll_once<F: std::future::Future>(
    future: &mut std::pin::Pin<&mut F>,
    rt: &tokio::runtime::Runtime,
) -> bool {
    rt.block_on(std::future::poll_fn(|cx| match future.as_mut().poll(cx) {
        std::task::Poll::Ready(_) => std::task::Poll::Ready(true),
        std::task::Poll::Pending => std::task::Poll::Ready(false),
    }))
}

