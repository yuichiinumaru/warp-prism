use std::collections::HashMap;

/// A discrete semantic graph node model.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct GraphNode {
    pub id: String,
    pub kind: String,
    pub label: String,
    pub status: Option<String>,
    pub payload: String,
}

impl GraphNode {
    pub fn new(
        id: impl Into<String>,
        kind: impl Into<String>,
        label: impl Into<String>,
        payload: impl Into<String>,
    ) -> Self {
        Self {
            id: id.into(),
            kind: kind.into(),
            label: label.into(),
            status: None,
            payload: payload.into(),
        }
    }

    pub fn with_status(mut self, status: impl Into<String>) -> Self {
        self.status = Some(status.into());
        self
    }
}

/// A directed graph edge connecting two nodes.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct GraphEdge {
    pub id: String,
    pub kind: String,
    pub from_node_id: String,
    pub to_node_id: String,
    pub payload: String,
}

impl GraphEdge {
    pub fn new(
        id: impl Into<String>,
        kind: impl Into<String>,
        from_node_id: impl Into<String>,
        to_node_id: impl Into<String>,
        payload: impl Into<String>,
    ) -> Self {
        Self {
            id: id.into(),
            kind: kind.into(),
            from_node_id: from_node_id.into(),
            to_node_id: to_node_id.into(),
            payload: payload.into(),
        }
    }
}

/// Point-in-time snapshot of the semantic graph.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct GraphSnapshot {
    pub timestamp_millis: i64,
    pub nodes: Vec<GraphNode>,
    pub edges: Vec<GraphEdge>,
}

impl GraphSnapshot {
    pub fn empty(timestamp_millis: i64) -> Self {
        Self {
            timestamp_millis,
            nodes: Vec::new(),
            edges: Vec::new(),
        }
    }

    pub fn new(timestamp_millis: i64, nodes: Vec<GraphNode>, edges: Vec<GraphEdge>) -> Self {
        Self {
            timestamp_millis,
            nodes,
            edges,
        }
    }

    pub fn get_node(&self, node_id: &str) -> Option<&GraphNode> {
        self.nodes.iter().find(|n| n.id == node_id)
    }

    pub fn get_edge(&self, edge_id: &str) -> Option<&GraphEdge> {
        self.edges.iter().find(|e| e.id == edge_id)
    }

    pub fn outgoing_edges(&self, node_id: &str) -> Vec<&GraphEdge> {
        self.edges.iter().filter(|e| e.from_node_id == node_id).collect()
    }

    pub fn incoming_edges(&self, node_id: &str) -> Vec<&GraphEdge> {
        self.edges.iter().filter(|e| e.to_node_id == node_id).collect()
    }

    pub fn adjacent_node_ids(&self, node_id: &str) -> Vec<String> {
        self.outgoing_edges(node_id)
            .into_iter()
            .map(|e| e.to_node_id.clone())
            .collect()
    }
}

/// Incremental or whole-graph update event.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum GraphUpdate {
    NodeAdded(GraphNode),
    NodeUpdated {
        node: GraphNode,
        previous_node: Option<GraphNode>,
    },
    NodeRemoved {
        node_id: String,
        removed_node: Option<GraphNode>,
    },
    EdgeAdded(GraphEdge),
    EdgeUpdated {
        edge: GraphEdge,
        previous_edge: Option<GraphEdge>,
    },
    EdgeRemoved {
        edge_id: String,
        removed_edge: Option<GraphEdge>,
    },
    GraphReset(GraphSnapshot),
}

/// In-memory graph state container with mutation helpers.
#[derive(Debug, Clone, Default)]
pub struct GraphState {
    nodes: HashMap<String, GraphNode>,
    edges: HashMap<String, GraphEdge>,
}

impl GraphState {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn apply_update(&mut self, update: GraphUpdate) {
        match update {
            GraphUpdate::NodeAdded(node) => {
                self.nodes.insert(node.id.clone(), node);
            }
            GraphUpdate::NodeUpdated { node, .. } => {
                self.nodes.insert(node.id.clone(), node);
            }
            GraphUpdate::NodeRemoved { node_id, .. } => {
                self.nodes.remove(&node_id);
                // Also clean up connected edges
                self.edges.retain(|_, edge| edge.from_node_id != node_id && edge.to_node_id != node_id);
            }
            GraphUpdate::EdgeAdded(edge) => {
                self.edges.insert(edge.id.clone(), edge);
            }
            GraphUpdate::EdgeUpdated { edge, .. } => {
                self.edges.insert(edge.id.clone(), edge);
            }
            GraphUpdate::EdgeRemoved { edge_id, .. } => {
                self.edges.remove(&edge_id);
            }
            GraphUpdate::GraphReset(snapshot) => {
                self.nodes.clear();
                self.edges.clear();
                for node in snapshot.nodes {
                    self.nodes.insert(node.id.clone(), node);
                }
                for edge in snapshot.edges {
                    self.edges.insert(edge.id.clone(), edge);
                }
            }
        }
    }

    pub fn to_snapshot(&self, timestamp_millis: i64) -> GraphSnapshot {
        let mut nodes: Vec<GraphNode> = self.nodes.values().cloned().collect();
        nodes.sort_by(|a, b| a.id.cmp(&b.id));

        let mut edges: Vec<GraphEdge> = self.edges.values().cloned().collect();
        edges.sort_by(|a, b| a.id.cmp(&b.id));

        GraphSnapshot::new(timestamp_millis, nodes, edges)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_graph_node_and_edge_creation() {
        let n1 = GraphNode::new("n1", "service.daemon", "Observatory", "{}")
            .with_status("running");
        assert_eq!(n1.id, "n1");
        assert_eq!(n1.kind, "service.daemon");
        assert_eq!(n1.status.as_deref(), Some("running"));

        let e1 = GraphEdge::new("e1", "depends_on", "n1", "n2", "{}");
        assert_eq!(e1.id, "e1");
        assert_eq!(e1.from_node_id, "n1");
        assert_eq!(e1.to_node_id, "n2");
    }

    #[test]
    fn test_graph_state_mutations_and_snapshot() {
        let mut state = GraphState::new();

        let n1 = GraphNode::new("n1", "service", "Daemon", "{}");
        let n2 = GraphNode::new("n2", "database", "Surreal", "{}");
        state.apply_update(GraphUpdate::NodeAdded(n1));
        state.apply_update(GraphUpdate::NodeAdded(n2));

        let e1 = GraphEdge::new("e1", "connects", "n1", "n2", "{}");
        state.apply_update(GraphUpdate::EdgeAdded(e1));

        let snap = state.to_snapshot(1000);
        assert_eq!(snap.nodes.len(), 2);
        assert_eq!(snap.edges.len(), 1);
        assert_eq!(snap.adjacent_node_ids("n1"), vec!["n2".to_string()]);
        assert_eq!(snap.outgoing_edges("n1").len(), 1);
        assert_eq!(snap.incoming_edges("n2").len(), 1);

        // Remove node n1 should also remove connected edge e1
        state.apply_update(GraphUpdate::NodeRemoved {
            node_id: "n1".into(),
            removed_node: None,
        });
        let snap2 = state.to_snapshot(2000);
        assert_eq!(snap2.nodes.len(), 1);
        assert_eq!(snap2.edges.len(), 0);
    }
}
