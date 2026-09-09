use std::collections::HashMap;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::{Arc, Mutex};

/// Execution status of an asynchronous command.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CommandStatus {
    Idle,
    Running,
    Succeeded,
    Failed,
    Cancelled,
}

/// A request to execute an asynchronous command.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CommandRequest {
    pub id: String,
    pub command_type: String,
    pub payload: String,
    pub timeout_ms: Option<u64>,
}

impl CommandRequest {
    pub fn new(id: impl Into<String>, command_type: impl Into<String>, payload: impl Into<String>) -> Self {
        Self {
            id: id.into(),
            command_type: command_type.into(),
            payload: payload.into(),
            timeout_ms: None,
        }
    }

    pub fn with_timeout(mut self, timeout_ms: u64) -> Self {
        self.timeout_ms = Some(timeout_ms);
        self
    }
}

/// Typed error representation for command execution failures.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum CommandError {
    Execution {
        message: String,
        error_code: Option<String>,
    },
    Validation {
        message: String,
        field: String,
    },
    Timeout {
        message: String,
        timeout_ms: u64,
    },
    Transport {
        message: String,
    },
    Generic {
        message: String,
    },
}

impl CommandError {
    pub fn execution(message: impl Into<String>, error_code: Option<String>) -> Self {
        Self::Execution {
            message: message.into(),
            error_code,
        }
    }

    pub fn validation(message: impl Into<String>, field: impl Into<String>) -> Self {
        Self::Validation {
            message: message.into(),
            field: field.into(),
        }
    }

    pub fn timeout(message: impl Into<String>, timeout_ms: u64) -> Self {
        Self::Timeout {
            message: message.into(),
            timeout_ms,
        }
    }

    pub fn transport(message: impl Into<String>) -> Self {
        Self::Transport {
            message: message.into(),
        }
    }

    pub fn generic(message: impl Into<String>) -> Self {
        Self::Generic {
            message: message.into(),
        }
    }
}

/// The result of executing an asynchronous command.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CommandResult {
    pub duration_ms: u64,
    pub timestamp_millis: i64,
    pub value: Option<String>,
    pub error: Option<CommandError>,
    pub is_cancelled: bool,
}

impl CommandResult {
    pub fn success(value: impl Into<String>, duration_ms: u64, timestamp_millis: i64) -> Self {
        Self {
            duration_ms,
            timestamp_millis,
            value: Some(value.into()),
            error: None,
            is_cancelled: false,
        }
    }

    pub fn failure(error: CommandError, duration_ms: u64, timestamp_millis: i64) -> Self {
        Self {
            duration_ms,
            timestamp_millis,
            value: None,
            error: Some(error),
            is_cancelled: false,
        }
    }

    pub fn cancelled(duration_ms: u64, timestamp_millis: i64) -> Self {
        Self {
            duration_ms,
            timestamp_millis,
            value: None,
            error: None,
            is_cancelled: true,
        }
    }

    pub fn is_success(&self) -> bool {
        self.error.is_none() && !self.is_cancelled
    }
}

/// Cooperative cancellation token for asynchronous commands.
#[derive(Debug, Clone, Default)]
pub struct CancellationToken {
    cancelled: Arc<AtomicBool>,
}

impl CancellationToken {
    pub fn new() -> Self {
        Self {
            cancelled: Arc::new(AtomicBool::new(false)),
        }
    }

    pub fn cancel(&self) {
        self.cancelled.store(true, Ordering::SeqCst);
    }

    pub fn is_cancelled(&self) -> bool {
        self.cancelled.load(Ordering::SeqCst)
    }
}

/// Registry for managing active command cancellation tokens.
#[derive(Debug, Default, Clone)]
pub struct CommandRegistry {
    tokens: Arc<Mutex<HashMap<String, CancellationToken>>>,
}

impl CommandRegistry {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn register(&self, command_id: &str) -> CancellationToken {
        let token = CancellationToken::new();
        let mut map = self.tokens.lock().unwrap();
        map.insert(command_id.to_string(), token.clone());
        token
    }

    pub fn cancel(&self, command_id: &str) -> bool {
        let map = self.tokens.lock().unwrap();
        if let Some(token) = map.get(command_id) {
            token.cancel();
            true
        } else {
            false
        }
    }

    pub fn unregister(&self, command_id: &str) {
        let mut map = self.tokens.lock().unwrap();
        map.remove(command_id);
    }

    pub fn get(&self, command_id: &str) -> Option<CancellationToken> {
        let map = self.tokens.lock().unwrap();
        map.get(command_id).cloned()
    }
}

/// Synchronous or simple async command executor for native substrate.
pub fn execute_command_pure(request: &CommandRequest, token: Option<&CancellationToken>) -> CommandResult {
    let now = 1_725_148_800_000_i64; // deterministic or wallclock timestamp base

    if let Some(tok) = token {
        if tok.is_cancelled() {
            return CommandResult::cancelled(0, now);
        }
    }

    if request.command_type == "echo" {
        CommandResult::success(format!("echo: {}", request.payload), 1, now)
    } else if request.command_type == "fail" {
        CommandResult::failure(
            CommandError::execution(request.payload.clone(), Some("ERR_EXEC".to_string())),
            1,
            now,
        )
    } else if request.command_type == "validate" {
        if request.payload.is_empty() {
            CommandResult::failure(
                CommandError::validation("payload cannot be empty", "payload"),
                1,
                now,
            )
        } else {
            CommandResult::success("valid", 1, now)
        }
    } else if request.command_type == "long_running" {
        let total_steps = 30;
        for _ in 0..total_steps {
            if let Some(tok) = token {
                if tok.is_cancelled() {
                    return CommandResult::cancelled(10, now);
                }
            }
            std::thread::sleep(std::time::Duration::from_millis(10));
        }
        if let Some(tok) = token {
            if tok.is_cancelled() {
                return CommandResult::cancelled(300, now);
            }
        }
        CommandResult::success(format!("completed: {}", request.payload), 300, now)
    } else {
        CommandResult::success(format!("ok: {}", request.payload), 1, now)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_command_request_construction() {
        let req = CommandRequest::new("cmd-1", "echo", "hello").with_timeout(5000);
        assert_eq!(req.id, "cmd-1");
        assert_eq!(req.command_type, "echo");
        assert_eq!(req.payload, "hello");
        assert_eq!(req.timeout_ms, Some(5000));
    }

    #[test]
    fn test_command_execution_success() {
        let req = CommandRequest::new("cmd-1", "echo", "world");
        let result = execute_command_pure(&req, None);
        assert!(result.is_success());
        assert_eq!(result.value.as_deref(), Some("echo: world"));
        assert_eq!(result.error, None);
        assert!(!result.is_cancelled);
    }

    #[test]
    fn test_command_execution_failure() {
        let req = CommandRequest::new("cmd-2", "fail", "simulated failure");
        let result = execute_command_pure(&req, None);
        assert!(!result.is_success());
        assert!(result.value.is_none());
        assert_eq!(
            result.error,
            Some(CommandError::execution("simulated failure", Some("ERR_EXEC".to_string())))
        );
    }

    #[test]
    fn test_command_cancellation() {
        let token = CancellationToken::new();
        token.cancel();
        assert!(token.is_cancelled());

        let req = CommandRequest::new("cmd-3", "echo", "cancelled task");
        let result = execute_command_pure(&req, Some(&token));
        assert!(!result.is_success());
        assert!(result.is_cancelled);
    }

    #[test]
    fn test_command_registry_lifecycle() {
        let registry = CommandRegistry::new();
        let token = registry.register("cmd-reg-1");
        assert!(!token.is_cancelled());

        assert!(registry.cancel("cmd-reg-1"));
        assert!(token.is_cancelled());
        assert!(!registry.cancel("cmd-reg-unknown"));

        registry.unregister("cmd-reg-1");
        assert!(registry.get("cmd-reg-1").is_none());
    }

    #[test]
    fn test_long_running_in_flight_cancellation() {
        let registry = CommandRegistry::new();
        let token = registry.register("cmd-long-1");

        let handle = std::thread::spawn(move || {
            let req = CommandRequest::new("cmd-long-1", "long_running", "payload");
            execute_command_pure(&req, Some(&token))
        });

        std::thread::sleep(std::time::Duration::from_millis(30));
        assert!(registry.cancel("cmd-long-1"));

        let res = handle.join().unwrap();
        assert!(res.is_cancelled);
        assert!(!res.is_success());
    }
}

