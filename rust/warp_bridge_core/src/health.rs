/// Operational health state enum.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum HealthState {
    Healthy,
    Degraded,
    Unreachable,
    Unknown,
}

/// A discrete health evaluation cell representing a single dimension of a provider.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct HealthCell {
    pub id: String,
    pub provider_id: String,
    pub provider_label: String,
    pub dimension_id: String,
    pub dimension_label: String,
    pub state: HealthState,
    pub latency_ms: Option<u64>,
}

impl HealthCell {
    pub fn new(
        id: impl Into<String>,
        provider_id: impl Into<String>,
        provider_label: impl Into<String>,
        dimension_id: impl Into<String>,
        dimension_label: impl Into<String>,
        state: HealthState,
    ) -> Self {
        Self {
            id: id.into(),
            provider_id: provider_id.into(),
            provider_label: provider_label.into(),
            dimension_id: dimension_id.into(),
            dimension_label: dimension_label.into(),
            state,
            latency_ms: None,
        }
    }

    pub fn with_latency(mut self, latency_ms: u64) -> Self {
        self.latency_ms = Some(latency_ms);
        self
    }
}

/// Point-in-time snapshot of system or provider health cells.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct HealthSnapshot {
    pub timestamp_millis: i64,
    pub cells: Vec<HealthCell>,
    pub aggregate_state: HealthState,
    pub freshness_ttl_ms: Option<u64>,
}

impl HealthSnapshot {
    pub fn new(timestamp_millis: i64, cells: Vec<HealthCell>) -> Self {
        let aggregate_state = derive_aggregate_state(&cells);
        Self {
            timestamp_millis,
            cells,
            aggregate_state,
            freshness_ttl_ms: None,
        }
    }

    pub fn with_freshness_ttl(mut self, ttl_ms: u64) -> Self {
        self.freshness_ttl_ms = Some(ttl_ms);
        self
    }

    pub fn is_fresh(&self, now_millis: i64) -> bool {
        match self.freshness_ttl_ms {
            Some(ttl) => (now_millis - self.timestamp_millis) <= ttl as i64,
            None => true,
        }
    }

    pub fn get_cell(&self, cell_id: &str) -> Option<&HealthCell> {
        self.cells.iter().find(|c| c.id == cell_id)
    }

    pub fn cells_for_provider(&self, provider_id: &str) -> Vec<&HealthCell> {
        self.cells.iter().filter(|c| c.provider_id == provider_id).collect()
    }
}

/// Derives aggregate health state using worst-state fold:
/// Unreachable > Degraded > Unknown > Healthy.
pub fn derive_aggregate_state(cells: &[HealthCell]) -> HealthState {
    if cells.is_empty() {
        return HealthState::Unknown;
    }

    let mut has_degraded = false;
    let mut has_unknown = false;

    for cell in cells {
        match cell.state {
            HealthState::Unreachable => return HealthState::Unreachable,
            HealthState::Degraded => has_degraded = true,
            HealthState::Unknown => has_unknown = true,
            HealthState::Healthy => {}
        }
    }

    if has_degraded {
        HealthState::Degraded
    } else if has_unknown {
        HealthState::Unknown
    } else {
        HealthState::Healthy
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_health_cell_creation() {
        let cell = HealthCell {
            id: "cell-1".to_string(),
            provider_id: "prov-a".to_string(),
            provider_label: "Provider A".to_string(),
            dimension_id: "latency".to_string(),
            dimension_label: "Latency".to_string(),
            state: HealthState::Healthy,
            latency_ms: Some(42),
        };
        assert_eq!(cell.id, "cell-1");
        assert_eq!(cell.state, HealthState::Healthy);
        assert_eq!(cell.latency_ms, Some(42));
    }

    #[test]
    fn test_derive_aggregate_state_order() {
        assert_eq!(derive_aggregate_state(&[]), HealthState::Unknown);

        let healthy = HealthCell {
            id: "1".into(),
            provider_id: "p".into(),
            provider_label: "P".into(),
            dimension_id: "d1".into(),
            dimension_label: "D1".into(),
            state: HealthState::Healthy,
            latency_ms: None,
        };
        assert_eq!(derive_aggregate_state(&[healthy.clone()]), HealthState::Healthy);

        let degraded = HealthCell {
            id: "2".into(),
            provider_id: "p".into(),
            provider_label: "P".into(),
            dimension_id: "d2".into(),
            dimension_label: "D2".into(),
            state: HealthState::Degraded,
            latency_ms: None,
        };
        assert_eq!(
            derive_aggregate_state(&[healthy.clone(), degraded.clone()]),
            HealthState::Degraded
        );

        let unreachable = HealthCell {
            id: "3".into(),
            provider_id: "p".into(),
            provider_label: "P".into(),
            dimension_id: "d3".into(),
            dimension_label: "D3".into(),
            state: HealthState::Unreachable,
            latency_ms: None,
        };
        assert_eq!(
            derive_aggregate_state(&[healthy, degraded, unreachable]),
            HealthState::Unreachable
        );
    }

    #[test]
    fn test_health_snapshot_freshness() {
        let cells = vec![HealthCell {
            id: "1".into(),
            provider_id: "p1".into(),
            provider_label: "P1".into(),
            dimension_id: "auth".into(),
            dimension_label: "Auth".into(),
            state: HealthState::Healthy,
            latency_ms: None,
        }];
        let snapshot = HealthSnapshot::new(1000, cells).with_freshness_ttl(500);

        assert!(snapshot.is_fresh(1200));
        assert!(snapshot.is_fresh(1500));
        assert!(!snapshot.is_fresh(1600));
        assert!(snapshot.get_cell("1").is_some());
        assert_eq!(snapshot.cells_for_provider("p1").len(), 1);
    }
}
