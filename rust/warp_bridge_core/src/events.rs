/// Severity levels for runtime events.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum EventSeverity {
    Stdout,
    Stderr,
    Info,
    Warning,
    Error,
    System,
}

/// A discrete runtime event model with provenance metadata.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Event {
    pub id: String,
    pub timestamp_millis: i64,
    pub severity: EventSeverity,
    pub source: Option<String>,
    pub run_group_id: Option<String>,
    pub payload: String,
}

impl Event {
    pub fn new(
        id: impl Into<String>,
        timestamp_millis: i64,
        severity: EventSeverity,
        payload: impl Into<String>,
    ) -> Self {
        Self {
            id: id.into(),
            timestamp_millis,
            severity,
            source: None,
            run_group_id: None,
            payload: payload.into(),
        }
    }

    pub fn with_source(mut self, source: impl Into<String>) -> Self {
        self.source = Some(source.into());
        self
    }

    pub fn with_run_group(mut self, run_group_id: impl Into<String>) -> Self {
        self.run_group_id = Some(run_group_id.into());
        self
    }
}

/// In-memory event buffer with append and snapshot semantics.
#[derive(Debug, Clone, Default)]
pub struct EventBuffer {
    events: Vec<Event>,
}

impl EventBuffer {
    pub fn new() -> Self {
        Self { events: Vec::new() }
    }

    pub fn push(&mut self, event: Event) {
        self.events.push(event);
    }

    pub fn push_batch(&mut self, events: impl IntoIterator<Item = Event>) {
        self.events.extend(events);
    }

    pub fn clear(&mut self) {
        self.events.clear();
    }

    pub fn len(&self) -> usize {
        self.events.len()
    }

    pub fn is_empty(&self) -> bool {
        self.events.is_empty()
    }

    pub fn events(&self) -> &[Event] {
        &self.events
    }

    pub fn to_vec(&self) -> Vec<Event> {
        self.events.clone()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_event_creation() {
        let evt = Event::new("evt-1", 1725148800000, EventSeverity::Info, "startup")
            .with_source("daemon")
            .with_run_group("run-42");

        assert_eq!(evt.id, "evt-1");
        assert_eq!(evt.timestamp_millis, 1725148800000);
        assert_eq!(evt.severity, EventSeverity::Info);
        assert_eq!(evt.source.as_deref(), Some("daemon"));
        assert_eq!(evt.run_group_id.as_deref(), Some("run-42"));
        assert_eq!(evt.payload, "startup");
    }

    #[test]
    fn test_event_buffer_append_and_batch() {
        let mut buffer = EventBuffer::new();
        assert!(buffer.is_empty());

        let e1 = Event::new("e-1", 100, EventSeverity::Info, "one");
        buffer.push(e1.clone());
        assert_eq!(buffer.len(), 1);

        let batch = vec![
            Event::new("e-2", 200, EventSeverity::Warning, "two"),
            Event::new("e-3", 300, EventSeverity::Error, "three"),
        ];
        buffer.push_batch(batch);
        assert_eq!(buffer.len(), 3);
        assert_eq!(buffer.events()[0].id, "e-1");
        assert_eq!(buffer.events()[1].id, "e-2");
        assert_eq!(buffer.events()[2].id, "e-3");

        buffer.clear();
        assert!(buffer.is_empty());
    }
}
