use std::sync::{LazyLock, Mutex};
use flutter_rust_bridge::frb;
use tokio::sync::broadcast;
use crate::frb_generated::StreamSink;
use warp_bridge_core::command::{
    execute_command_pure, CommandRegistry, CommandRequest, CommandResult,
};
use warp_bridge_core::events::{Event as CoreEvent, EventSeverity as CoreEventSeverity};
use warp_bridge_core::graph::{
    GraphEdge as CoreGraphEdge, GraphNode as CoreGraphNode, GraphSnapshot as CoreGraphSnapshot,
    GraphState as CoreGraphState, GraphUpdate as CoreGraphUpdate,
};
use warp_bridge_core::health::{
    derive_aggregate_state, HealthCell as CoreHealthCell, HealthSnapshot as CoreHealthSnapshot,
    HealthState as CoreHealthState,
};

// ==========================================
// 1. Smoke API
// ==========================================

#[frb(sync)]
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

pub fn echo(msg: String) -> String {
    format!("echo: {}", msg)
}

pub fn count_stream(sink: StreamSink<i32>, n: i32) {
    std::thread::spawn(move || {
        for i in 1..=n {
            std::thread::sleep(std::time::Duration::from_millis(5));
            if sink.add(i).is_err() {
                break;
            }
        }
    });
}

// ==========================================
// 2. Command API
// ==========================================

static COMMAND_REGISTRY: LazyLock<CommandRegistry> = LazyLock::new(CommandRegistry::new);

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FrbCommandRequest {
    pub id: String,
    pub command_type: String,
    pub payload: String,
    pub timeout_ms: Option<u64>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FrbCommandResult {
    pub duration_ms: u64,
    pub timestamp_millis: i64,
    pub value: Option<String>,
    pub error_message: Option<String>,
    pub is_cancelled: bool,
}

#[frb(sync)]
pub fn cancel_command(command_id: String) -> bool {
    COMMAND_REGISTRY.cancel(&command_id)
}

pub async fn execute_command(req: FrbCommandRequest) -> FrbCommandResult {
    let token = COMMAND_REGISTRY.register(&req.id);
    let core_req = CommandRequest {
        id: req.id.clone(),
        command_type: req.command_type,
        payload: req.payload,
        timeout_ms: req.timeout_ms,
    };

    let res = tokio::task::spawn_blocking(move || {
        execute_command_pure(&core_req, Some(&token))
    })
    .await
    .unwrap_or_else(|_| CommandResult::cancelled(0, 1_725_148_800_000_i64));

    COMMAND_REGISTRY.unregister(&req.id);

    let error_message = res.error.map(|e| match e {
        warp_bridge_core::command::CommandError::Execution { message, .. } => message,
        warp_bridge_core::command::CommandError::Validation { message, .. } => message,
        warp_bridge_core::command::CommandError::Timeout { message, .. } => message,
        warp_bridge_core::command::CommandError::Transport { message } => message,
        warp_bridge_core::command::CommandError::Generic { message } => message,
    });

    FrbCommandResult {
        duration_ms: res.duration_ms,
        timestamp_millis: res.timestamp_millis,
        value: res.value,
        error_message,
        is_cancelled: res.is_cancelled,
    }
}

// ==========================================
// 3. Events API
// ==========================================

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FrbEventSeverity {
    Stdout,
    Stderr,
    Info,
    Warning,
    Error,
    System,
}

impl From<CoreEventSeverity> for FrbEventSeverity {
    fn from(s: CoreEventSeverity) -> Self {
        match s {
            CoreEventSeverity::Stdout => FrbEventSeverity::Stdout,
            CoreEventSeverity::Stderr => FrbEventSeverity::Stderr,
            CoreEventSeverity::Info => FrbEventSeverity::Info,
            CoreEventSeverity::Warning => FrbEventSeverity::Warning,
            CoreEventSeverity::Error => FrbEventSeverity::Error,
            CoreEventSeverity::System => FrbEventSeverity::System,
        }
    }
}

impl From<FrbEventSeverity> for CoreEventSeverity {
    fn from(s: FrbEventSeverity) -> Self {
        match s {
            FrbEventSeverity::Stdout => CoreEventSeverity::Stdout,
            FrbEventSeverity::Stderr => CoreEventSeverity::Stderr,
            FrbEventSeverity::Info => CoreEventSeverity::Info,
            FrbEventSeverity::Warning => CoreEventSeverity::Warning,
            FrbEventSeverity::Error => CoreEventSeverity::Error,
            FrbEventSeverity::System => CoreEventSeverity::System,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FrbEvent {
    pub id: String,
    pub timestamp_millis: i64,
    pub severity: FrbEventSeverity,
    pub source: Option<String>,
    pub run_group_id: Option<String>,
    pub payload: String,
}

impl From<CoreEvent> for FrbEvent {
    fn from(e: CoreEvent) -> Self {
        Self {
            id: e.id,
            timestamp_millis: e.timestamp_millis,
            severity: e.severity.into(),
            source: e.source,
            run_group_id: e.run_group_id,
            payload: e.payload,
        }
    }
}

pub fn create_event(
    id: String,
    timestamp_millis: i64,
    severity: FrbEventSeverity,
    payload: String,
    source: Option<String>,
    run_group_id: Option<String>,
) -> FrbEvent {
    let mut evt = CoreEvent::new(id, timestamp_millis, severity.into(), payload);
    if let Some(src) = source {
        evt = evt.with_source(src);
    }
    if let Some(rg) = run_group_id {
        evt = evt.with_run_group(rg);
    }
    evt.into()
}

pub fn stream_events(sink: StreamSink<FrbEvent>, count: i32, prefix: String) {
    std::thread::spawn(move || {
        let now = 1_725_148_800_000_i64;
        for i in 1..=count {
            std::thread::sleep(std::time::Duration::from_millis(5));
            let evt = FrbEvent {
                id: format!("evt-{}", i),
                timestamp_millis: now + (i as i64 * 10),
                severity: FrbEventSeverity::Info,
                source: Some("rust-stream".to_string()),
                run_group_id: Some("rg-1".to_string()),
                payload: format!("{}-{}", prefix, i),
            };
            if sink.add(evt).is_err() {
                break;
            }
        }
    });
}

// ==========================================
// 4. Health API
// ==========================================

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FrbHealthState {
    Healthy,
    Degraded,
    Unreachable,
    Unknown,
}

impl From<CoreHealthState> for FrbHealthState {
    fn from(s: CoreHealthState) -> Self {
        match s {
            CoreHealthState::Healthy => FrbHealthState::Healthy,
            CoreHealthState::Degraded => FrbHealthState::Degraded,
            CoreHealthState::Unreachable => FrbHealthState::Unreachable,
            CoreHealthState::Unknown => FrbHealthState::Unknown,
        }
    }
}

impl From<FrbHealthState> for CoreHealthState {
    fn from(s: FrbHealthState) -> Self {
        match s {
            FrbHealthState::Healthy => CoreHealthState::Healthy,
            FrbHealthState::Degraded => CoreHealthState::Degraded,
            FrbHealthState::Unreachable => CoreHealthState::Unreachable,
            FrbHealthState::Unknown => CoreHealthState::Unknown,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FrbHealthCell {
    pub id: String,
    pub provider_id: String,
    pub provider_label: String,
    pub dimension_id: String,
    pub dimension_label: String,
    pub state: FrbHealthState,
    pub latency_ms: Option<u64>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FrbHealthSnapshot {
    pub timestamp_millis: i64,
    pub cells: Vec<FrbHealthCell>,
    pub aggregate_state: FrbHealthState,
    pub freshness_ttl_ms: Option<u64>,
}

struct SharedHealthStore {
    state: Mutex<CoreHealthSnapshot>,
    sender: broadcast::Sender<CoreHealthSnapshot>,
}

impl SharedHealthStore {
    fn new() -> Self {
        let (sender, _) = broadcast::channel(64);
        let cells = vec![
            CoreHealthCell::new(
                "cell-lat",
                "native-core",
                "Native Core Substrate",
                "latency",
                "Latency",
                CoreHealthState::Healthy,
            )
            .with_latency(1),
            CoreHealthCell::new(
                "cell-mem",
                "native-core",
                "Native Core Substrate",
                "memory",
                "Memory",
                CoreHealthState::Healthy,
            ),
        ];
        let snap = CoreHealthSnapshot::new(1_725_148_800_000_i64, cells).with_freshness_ttl(5000);
        Self {
            state: Mutex::new(snap),
            sender,
        }
    }

    fn to_snapshot(&self) -> FrbHealthSnapshot {
        let state = self.state.lock().unwrap();
        FrbHealthSnapshot {
            timestamp_millis: state.timestamp_millis,
            cells: state
                .cells
                .iter()
                .cloned()
                .map(|c| FrbHealthCell {
                    id: c.id,
                    provider_id: c.provider_id,
                    provider_label: c.provider_label,
                    dimension_id: c.dimension_id,
                    dimension_label: c.dimension_label,
                    state: c.state.into(),
                    latency_ms: c.latency_ms,
                })
                .collect(),
            aggregate_state: state.aggregate_state.into(),
            freshness_ttl_ms: state.freshness_ttl_ms,
        }
    }

    fn update_cell(&self, cell: CoreHealthCell) -> FrbHealthSnapshot {
        let snap = {
            let mut state = self.state.lock().unwrap();
            let mut cells = state.cells.clone();
            let mut matched = false;
            for existing in &mut cells {
                if existing.id == cell.id {
                    *existing = cell.clone();
                    matched = true;
                    break;
                }
            }
            if !matched {
                cells.push(cell);
            }
            let mut new_snap = CoreHealthSnapshot::new(state.timestamp_millis, cells);
            if let Some(ttl) = state.freshness_ttl_ms {
                new_snap = new_snap.with_freshness_ttl(ttl);
            }
            *state = new_snap.clone();
            new_snap
        };
        let _ = self.sender.send(snap);
        self.to_snapshot()
    }

    fn set_snapshot(&self, snapshot: CoreHealthSnapshot) -> FrbHealthSnapshot {
        {
            let mut state = self.state.lock().unwrap();
            *state = snapshot.clone();
        }
        let _ = self.sender.send(snapshot);
        self.to_snapshot()
    }

    fn set_cells(&self, cells: Vec<CoreHealthCell>) -> FrbHealthSnapshot {
        let snap = {
            let mut state = self.state.lock().unwrap();
            let mut new_snap = CoreHealthSnapshot::new(state.timestamp_millis, cells);
            if let Some(ttl) = state.freshness_ttl_ms {
                new_snap = new_snap.with_freshness_ttl(ttl);
            }
            *state = new_snap.clone();
            new_snap
        };
        let _ = self.sender.send(snap);
        self.to_snapshot()
    }
}

static SHARED_HEALTH: LazyLock<SharedHealthStore> = LazyLock::new(SharedHealthStore::new);

pub fn evaluate_health_cells(cells: Vec<FrbHealthCell>) -> FrbHealthState {
    let core_cells: Vec<CoreHealthCell> = cells
        .into_iter()
        .map(|c| CoreHealthCell {
            id: c.id,
            provider_id: c.provider_id,
            provider_label: c.provider_label,
            dimension_id: c.dimension_id,
            dimension_label: c.dimension_label,
            state: c.state.into(),
            latency_ms: c.latency_ms,
        })
        .collect();

    derive_aggregate_state(&core_cells).into()
}

pub fn get_sample_health_snapshot() -> FrbHealthSnapshot {
    SHARED_HEALTH.to_snapshot()
}

pub fn set_health_cell(cell: FrbHealthCell) -> FrbHealthSnapshot {
    let core_cell: CoreHealthCell = CoreHealthCell {
        id: cell.id,
        provider_id: cell.provider_id,
        provider_label: cell.provider_label,
        dimension_id: cell.dimension_id,
        dimension_label: cell.dimension_label,
        state: cell.state.into(),
        latency_ms: cell.latency_ms,
    };
    SHARED_HEALTH.update_cell(core_cell)
}

pub fn set_health_cells(cells: Vec<FrbHealthCell>) -> FrbHealthSnapshot {
    let core_cells: Vec<CoreHealthCell> = cells
        .into_iter()
        .map(|c| CoreHealthCell {
            id: c.id,
            provider_id: c.provider_id,
            provider_label: c.provider_label,
            dimension_id: c.dimension_id,
            dimension_label: c.dimension_label,
            state: c.state.into(),
            latency_ms: c.latency_ms,
        })
        .collect();
    SHARED_HEALTH.set_cells(core_cells)
}

pub fn set_health_snapshot(snapshot: FrbHealthSnapshot) -> FrbHealthSnapshot {
    let cells: Vec<CoreHealthCell> = snapshot
        .cells
        .into_iter()
        .map(|c| CoreHealthCell {
            id: c.id,
            provider_id: c.provider_id,
            provider_label: c.provider_label,
            dimension_id: c.dimension_id,
            dimension_label: c.dimension_label,
            state: c.state.into(),
            latency_ms: c.latency_ms,
        })
        .collect();
    let mut snap = CoreHealthSnapshot::new(snapshot.timestamp_millis, cells);
    if let Some(ttl) = snapshot.freshness_ttl_ms {
        snap = snap.with_freshness_ttl(ttl);
    }
    SHARED_HEALTH.set_snapshot(snap)
}

pub async fn watch_health(sink: StreamSink<FrbHealthSnapshot>, sample_count: Option<i32>) {
    let mut rx = SHARED_HEALTH.sender.subscribe();
    let mut count = 0;
    while let Ok(snap) = rx.recv().await {
        let frb_snap = FrbHealthSnapshot {
            timestamp_millis: snap.timestamp_millis,
            cells: snap
                .cells
                .into_iter()
                .map(|c| FrbHealthCell {
                    id: c.id,
                    provider_id: c.provider_id,
                    provider_label: c.provider_label,
                    dimension_id: c.dimension_id,
                    dimension_label: c.dimension_label,
                    state: c.state.into(),
                    latency_ms: c.latency_ms,
                })
                .collect(),
            aggregate_state: snap.aggregate_state.into(),
            freshness_ttl_ms: snap.freshness_ttl_ms,
        };
        if sink.add(frb_snap).is_err() {
            break;
        }
        count += 1;
        if let Some(max) = sample_count {
            if count >= max {
                break;
            }
        }
    }
}

// ==========================================
// 5. Graph API
// ==========================================

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FrbGraphNode {
    pub id: String,
    pub kind: String,
    pub label: String,
    pub status: Option<String>,
    pub payload: String,
}

impl From<CoreGraphNode> for FrbGraphNode {
    fn from(n: CoreGraphNode) -> Self {
        Self {
            id: n.id,
            kind: n.kind,
            label: n.label,
            status: n.status,
            payload: n.payload,
        }
    }
}

impl From<FrbGraphNode> for CoreGraphNode {
    fn from(n: FrbGraphNode) -> Self {
        Self {
            id: n.id,
            kind: n.kind,
            label: n.label,
            status: n.status,
            payload: n.payload,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FrbGraphEdge {
    pub id: String,
    pub kind: String,
    pub from_node_id: String,
    pub to_node_id: String,
    pub payload: String,
}

impl From<CoreGraphEdge> for FrbGraphEdge {
    fn from(e: CoreGraphEdge) -> Self {
        Self {
            id: e.id,
            kind: e.kind,
            from_node_id: e.from_node_id,
            to_node_id: e.to_node_id,
            payload: e.payload,
        }
    }
}

impl From<FrbGraphEdge> for CoreGraphEdge {
    fn from(e: FrbGraphEdge) -> Self {
        Self {
            id: e.id,
            kind: e.kind,
            from_node_id: e.from_node_id,
            to_node_id: e.to_node_id,
            payload: e.payload,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FrbGraphSnapshot {
    pub timestamp_millis: i64,
    pub nodes: Vec<FrbGraphNode>,
    pub edges: Vec<FrbGraphEdge>,
}

impl From<CoreGraphSnapshot> for FrbGraphSnapshot {
    fn from(s: CoreGraphSnapshot) -> Self {
        Self {
            timestamp_millis: s.timestamp_millis,
            nodes: s.nodes.into_iter().map(Into::into).collect(),
            edges: s.edges.into_iter().map(Into::into).collect(),
        }
    }
}

impl From<FrbGraphSnapshot> for CoreGraphSnapshot {
    fn from(s: FrbGraphSnapshot) -> Self {
        Self {
            timestamp_millis: s.timestamp_millis,
            nodes: s.nodes.into_iter().map(Into::into).collect(),
            edges: s.edges.into_iter().map(Into::into).collect(),
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FrbGraphUpdateKind {
    NodeAdded,
    NodeUpdated,
    NodeRemoved,
    EdgeAdded,
    EdgeUpdated,
    EdgeRemoved,
    GraphReset,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FrbGraphUpdate {
    pub kind: FrbGraphUpdateKind,
    pub node: Option<FrbGraphNode>,
    pub previous_node: Option<FrbGraphNode>,
    pub edge: Option<FrbGraphEdge>,
    pub previous_edge: Option<FrbGraphEdge>,
    pub removed_id: Option<String>,
    pub snapshot: Option<FrbGraphSnapshot>,
}

impl From<CoreGraphUpdate> for FrbGraphUpdate {
    fn from(u: CoreGraphUpdate) -> Self {
        match u {
            CoreGraphUpdate::NodeAdded(n) => Self {
                kind: FrbGraphUpdateKind::NodeAdded,
                node: Some(n.into()),
                previous_node: None,
                edge: None,
                previous_edge: None,
                removed_id: None,
                snapshot: None,
            },
            CoreGraphUpdate::NodeUpdated {
                node,
                previous_node,
            } => Self {
                kind: FrbGraphUpdateKind::NodeUpdated,
                node: Some(node.into()),
                previous_node: previous_node.map(Into::into),
                edge: None,
                previous_edge: None,
                removed_id: None,
                snapshot: None,
            },
            CoreGraphUpdate::NodeRemoved {
                node_id,
                removed_node,
            } => Self {
                kind: FrbGraphUpdateKind::NodeRemoved,
                node: None,
                previous_node: removed_node.map(Into::into),
                edge: None,
                previous_edge: None,
                removed_id: Some(node_id),
                snapshot: None,
            },
            CoreGraphUpdate::EdgeAdded(e) => Self {
                kind: FrbGraphUpdateKind::EdgeAdded,
                node: None,
                previous_node: None,
                edge: Some(e.into()),
                previous_edge: None,
                removed_id: None,
                snapshot: None,
            },
            CoreGraphUpdate::EdgeUpdated {
                edge,
                previous_edge,
            } => Self {
                kind: FrbGraphUpdateKind::EdgeUpdated,
                node: None,
                previous_node: None,
                edge: Some(edge.into()),
                previous_edge: previous_edge.map(Into::into),
                removed_id: None,
                snapshot: None,
            },
            CoreGraphUpdate::EdgeRemoved {
                edge_id,
                removed_edge,
            } => Self {
                kind: FrbGraphUpdateKind::EdgeRemoved,
                node: None,
                previous_node: None,
                edge: None,
                previous_edge: removed_edge.map(Into::into),
                removed_id: Some(edge_id),
                snapshot: None,
            },
            CoreGraphUpdate::GraphReset(s) => Self {
                kind: FrbGraphUpdateKind::GraphReset,
                node: None,
                previous_node: None,
                edge: None,
                previous_edge: None,
                removed_id: None,
                snapshot: Some(s.into()),
            },
        }
    }
}

struct SharedGraphStore {
    state: Mutex<CoreGraphState>,
    sender: broadcast::Sender<CoreGraphUpdate>,
}

impl SharedGraphStore {
    fn new() -> Self {
        let (sender, _) = broadcast::channel(64);
        let mut state = CoreGraphState::new();
        state.apply_update(CoreGraphUpdate::NodeAdded(
            CoreGraphNode::new(
                "node-root",
                "system.root",
                "Warp Prism Native Root",
                "{}",
            )
            .with_status("active"),
        ));
        state.apply_update(CoreGraphUpdate::NodeAdded(
            CoreGraphNode::new(
                "node-child",
                "system.worker",
                "Substrate Worker",
                "{}",
            )
            .with_status("ready"),
        ));
        state.apply_update(CoreGraphUpdate::EdgeAdded(CoreGraphEdge::new(
            "edge-1",
            "hierarchy.parent_child",
            "node-root",
            "node-child",
            "{}",
        )));

        Self {
            state: Mutex::new(state),
            sender,
        }
    }

    fn to_snapshot(&self) -> FrbGraphSnapshot {
        let state = self.state.lock().unwrap();
        state.to_snapshot(1_725_148_800_000_i64).into()
    }
}

static SHARED_GRAPH: LazyLock<SharedGraphStore> = LazyLock::new(SharedGraphStore::new);

pub fn get_sample_graph_snapshot() -> FrbGraphSnapshot {
    SHARED_GRAPH.to_snapshot()
}

pub fn apply_graph_node_add(node: FrbGraphNode) -> FrbGraphSnapshot {
    let core_node: CoreGraphNode = node.into();
    {
        let mut state = SHARED_GRAPH.state.lock().unwrap();
        state.apply_update(CoreGraphUpdate::NodeAdded(core_node.clone()));
    }
    let _ = SHARED_GRAPH
        .sender
        .send(CoreGraphUpdate::NodeAdded(core_node));
    SHARED_GRAPH.to_snapshot()
}

pub fn apply_graph_node_update(node: FrbGraphNode) -> FrbGraphSnapshot {
    let core_node: CoreGraphNode = node.into();
    let previous_node = {
        let mut state = SHARED_GRAPH.state.lock().unwrap();
        let prev = state.to_snapshot(0).get_node(&core_node.id).cloned();
        state.apply_update(CoreGraphUpdate::NodeUpdated {
            node: core_node.clone(),
            previous_node: prev.clone(),
        });
        prev
    };
    let _ = SHARED_GRAPH.sender.send(CoreGraphUpdate::NodeUpdated {
        node: core_node,
        previous_node,
    });
    SHARED_GRAPH.to_snapshot()
}

pub fn apply_graph_node_remove(node_id: String) -> FrbGraphSnapshot {
    let removed_node = {
        let mut state = SHARED_GRAPH.state.lock().unwrap();
        let prev = state.to_snapshot(0).get_node(&node_id).cloned();
        state.apply_update(CoreGraphUpdate::NodeRemoved {
            node_id: node_id.clone(),
            removed_node: prev.clone(),
        });
        prev
    };
    let _ = SHARED_GRAPH.sender.send(CoreGraphUpdate::NodeRemoved {
        node_id,
        removed_node,
    });
    SHARED_GRAPH.to_snapshot()
}

pub fn apply_graph_edge_add(edge: FrbGraphEdge) -> FrbGraphSnapshot {
    let core_edge: CoreGraphEdge = edge.into();
    {
        let mut state = SHARED_GRAPH.state.lock().unwrap();
        state.apply_update(CoreGraphUpdate::EdgeAdded(core_edge.clone()));
    }
    let _ = SHARED_GRAPH
        .sender
        .send(CoreGraphUpdate::EdgeAdded(core_edge));
    SHARED_GRAPH.to_snapshot()
}

pub fn apply_graph_edge_update(edge: FrbGraphEdge) -> FrbGraphSnapshot {
    let core_edge: CoreGraphEdge = edge.into();
    let previous_edge = {
        let mut state = SHARED_GRAPH.state.lock().unwrap();
        let prev = state.to_snapshot(0).get_edge(&core_edge.id).cloned();
        state.apply_update(CoreGraphUpdate::EdgeUpdated {
            edge: core_edge.clone(),
            previous_edge: prev.clone(),
        });
        prev
    };
    let _ = SHARED_GRAPH.sender.send(CoreGraphUpdate::EdgeUpdated {
        edge: core_edge,
        previous_edge,
    });
    SHARED_GRAPH.to_snapshot()
}

pub fn apply_graph_edge_remove(edge_id: String) -> FrbGraphSnapshot {
    let removed_edge = {
        let mut state = SHARED_GRAPH.state.lock().unwrap();
        let prev = state.to_snapshot(0).get_edge(&edge_id).cloned();
        state.apply_update(CoreGraphUpdate::EdgeRemoved {
            edge_id: edge_id.clone(),
            removed_edge: prev.clone(),
        });
        prev
    };
    let _ = SHARED_GRAPH.sender.send(CoreGraphUpdate::EdgeRemoved {
        edge_id,
        removed_edge,
    });
    SHARED_GRAPH.to_snapshot()
}

pub fn apply_graph_reset(snapshot: FrbGraphSnapshot) -> FrbGraphSnapshot {
    let core_snapshot: CoreGraphSnapshot = snapshot.into();
    {
        let mut state = SHARED_GRAPH.state.lock().unwrap();
        state.apply_update(CoreGraphUpdate::GraphReset(core_snapshot.clone()));
    }
    let _ = SHARED_GRAPH
        .sender
        .send(CoreGraphUpdate::GraphReset(core_snapshot));
    SHARED_GRAPH.to_snapshot()
}

pub async fn watch_graph_updates(sink: StreamSink<FrbGraphUpdate>, max_events: Option<i32>) {
    let mut rx = SHARED_GRAPH.sender.subscribe();
    let mut count = 0;
    while let Ok(update) = rx.recv().await {
        let frb_update: FrbGraphUpdate = update.into();
        if sink.add(frb_update).is_err() {
            break;
        }
        count += 1;
        if let Some(max) = max_events {
            if count >= max {
                break;
            }
        }
    }
}

