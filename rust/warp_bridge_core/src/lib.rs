pub mod command;
pub mod events;
pub mod graph;
pub mod health;

/// Wall-clock milliseconds since the Unix epoch.
///
/// Production call sites MUST use this instead of a hardcoded literal:
/// a frozen timestamp silently corrupts every downstream freshness check,
/// event ordering comparison, and duration measurement that reads it.
///
/// Deterministic timestamps are only acceptable inside `#[cfg(test)]`
/// fixtures that assert on an exact value.
#[must_use]
pub fn now_millis() -> i64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map_or(0, |d| i64::try_from(d.as_millis()).unwrap_or(i64::MAX))
}

pub use command::{
    execute_command_pure, CancellationToken, CommandError, CommandRegistry, CommandRequest,
    CommandResult, CommandStatus,
};
pub use events::{Event, EventBuffer, EventSeverity};
pub use graph::{GraphEdge, GraphNode, GraphSnapshot, GraphState, GraphUpdate};
pub use health::{derive_aggregate_state, HealthCell, HealthSnapshot, HealthState};
