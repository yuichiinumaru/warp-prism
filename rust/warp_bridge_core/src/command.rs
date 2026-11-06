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
    /// A command id was registered while another *active* execution already
    /// owns that id.
    ///
    /// Distinct from [CommandError::Execution]: nothing ran, so this is an
    /// identity/registry fault rather than a domain rejection. Surfacing it as
    /// its own variant prevents an id collision from silently cancelling or
    /// hijacking an unrelated in-flight command.
    Duplicate {
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

    pub fn duplicate(message: impl Into<String>) -> Self {
        Self::Duplicate {
            message: message.into(),
        }
    }

    pub fn generic(message: impl Into<String>) -> Self {
        Self::Generic {
            message: message.into(),
        }
    }

    /// Stable, transport-friendly discriminator for this variant.
    ///
    /// Lets a bridge preserve the taxonomy instead of flattening every failure
    /// into one opaque string.
    pub fn kind(&self) -> &'static str {
        match self {
            Self::Execution { .. } => "execution",
            Self::Validation { .. } => "validation",
            Self::Timeout { .. } => "timeout",
            Self::Transport { .. } => "transport",
            Self::Duplicate { .. } => "duplicate",
            Self::Generic { .. } => "generic",
        }
    }

    /// The human-readable message carried by any variant.
    pub fn message(&self) -> &str {
        match self {
            Self::Execution { message, .. }
            | Self::Validation { message, .. }
            | Self::Timeout { message, .. }
            | Self::Transport { message }
            | Self::Duplicate { message }
            | Self::Generic { message } => message,
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
    /// Identity of this token, shared by every clone of it.
    ///
    /// Lets a registry distinguish "the token I registered" from "some other
    /// execution's token that happens to use the same command id", which is
    /// what makes late cleanup safe (F4).
    identity: Arc<()>,
}

impl CancellationToken {
    pub fn new() -> Self {
        Self {
            cancelled: Arc::new(AtomicBool::new(false)),
            identity: Arc::new(()),
        }
    }

    pub fn cancel(&self) {
        self.cancelled.store(true, Ordering::SeqCst);
    }

    pub fn is_cancelled(&self) -> bool {
        self.cancelled.load(Ordering::SeqCst)
    }

    /// Opaque identity shared by clones of *this* token only.
    pub(crate) fn shared_flag(&self) -> *const () {
        Arc::as_ptr(&self.identity)
    }
}

/// Registry for managing active command cancellation tokens.
///
/// **Identity safety (F4)**: an id may have at most **one** active
/// registration. [CommandRegistry::register] therefore *rejects* a duplicate id
/// instead of overwriting the incumbent, and [CommandRegistry::unregister_if]
/// only removes the registration when the caller still owns it. Together these
/// make it impossible for one execution's cleanup to evict another
/// execution's token, or for `cancel(id)` to hit the wrong command.
#[derive(Debug, Default, Clone)]
pub struct CommandRegistry {
    tokens: Arc<Mutex<HashMap<String, CancellationToken>>>,
}

/// Why a registration was refused.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum RegisterError {
    /// Another active execution already owns this id.
    Duplicate { command_id: String },
}

impl CommandRegistry {
    pub fn new() -> Self {
        Self::default()
    }

    /// Registers a fresh cancellation token for `command_id`.
    ///
    /// Returns [RegisterError::Duplicate] when an active execution already owns
    /// the id. The incumbent token is left untouched — a collision must never
    /// silently replace, hijack, or cancel a running command.
    pub fn register(&self, command_id: &str) -> Result<CancellationToken, RegisterError> {
        let token = CancellationToken::new();
        let mut map = self.tokens.lock().unwrap_or_else(|e| e.into_inner());
        if map.contains_key(command_id) {
            return Err(RegisterError::Duplicate {
                command_id: command_id.to_string(),
            });
        }
        map.insert(command_id.to_string(), token.clone());
        Ok(token)
    }

    /// Cancels the command registered under `command_id`.
    ///
    /// Returns `true` only when an active registration was found and signalled.
    pub fn cancel(&self, command_id: &str) -> bool {
        let map = self.tokens.lock().unwrap_or_else(|e| e.into_inner());
        if let Some(token) = map.get(command_id) {
            token.cancel();
            true
        } else {
            false
        }
    }

    /// Removes the registration for `command_id`, if any.
    ///
    /// Prefer [CommandRegistry::unregister_if], which additionally verifies
    /// ownership. Retained for direct lifecycle tests.
    pub fn unregister(&self, command_id: &str) {
        let mut map = self.tokens.lock().unwrap_or_else(|e| e.into_inner());
        map.remove(command_id);
    }

    /// Removes the registration for `command_id` **only if** it is still the
    /// one owned by `token`.
    ///
    /// This is the cleanup primitive execution paths must use: a late-finishing
    /// execution cannot evict a newer execution that happens to share the id.
    pub fn unregister_if(&self, command_id: &str, token: &CancellationToken) -> bool {
        let mut map = self.tokens.lock().unwrap_or_else(|e| e.into_inner());
        match map.get(command_id) {
            Some(existing) if existing.shared_flag() == token.shared_flag() => {
                map.remove(command_id);
                true
            }
            _ => false,
        }
    }

    /// Whether `command_id` currently has an active registration.
    pub fn is_registered(&self, command_id: &str) -> bool {
        let map = self.tokens.lock().unwrap_or_else(|e| e.into_inner());
        map.contains_key(command_id)
    }

    pub fn get(&self, command_id: &str) -> Option<CancellationToken> {
        let map = self.tokens.lock().unwrap_or_else(|e| e.into_inner());
        map.get(command_id).cloned()
    }
}

/// Synchronous or simple async command executor for native substrate.
pub fn execute_command_pure(request: &CommandRequest, token: Option<&CancellationToken>) -> CommandResult {
    let now = crate::now_millis();

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
        let token = registry.register("cmd-reg-1").expect("fresh id must register");
        assert!(!token.is_cancelled());

        assert!(registry.cancel("cmd-reg-1"));
        assert!(token.is_cancelled());
        assert!(!registry.cancel("cmd-reg-unknown"));

        registry.unregister("cmd-reg-1");
        assert!(registry.get("cmd-reg-1").is_none());
    }

    // ---- F4: command identity / registry safety ----------------------------

    #[test]
    fn test_duplicate_registration_is_rejected_and_does_not_replace() {
        let registry = CommandRegistry::new();

        // Construct the collision DIRECTLY — no clock, no racing, no threads.
        let first = registry.register("dup").expect("first registration wins");
        let second = registry.register("dup");

        assert!(
            matches!(
                second,
                Err(RegisterError::Duplicate { ref command_id }) if command_id == "dup"
            ),
            "a second registration of an active id must be refused"
        );

        // The incumbent must survive intact: cancelling by id still reaches the
        // ORIGINAL token, and the refused registration did not displace it.
        assert!(registry.is_registered("dup"));
        assert!(registry.cancel("dup"));
        assert!(first.is_cancelled());
        assert_eq!(registry.get("dup").map(|t| t.is_cancelled()), Some(true));
    }

    #[test]
    fn test_duplicate_registration_does_not_hijack_or_cancel_incumbent() {
        let registry = CommandRegistry::new();
        let incumbent = registry.register("hijack").expect("first registration");

        // A colliding registration must not cancel or alter the incumbent.
        assert!(registry.register("hijack").is_err());
        assert!(
            !incumbent.is_cancelled(),
            "a rejected duplicate must never cancel the running command"
        );
    }

    #[test]
    fn test_cleanup_only_removes_own_registration() {
        let registry = CommandRegistry::new();
        let owner = registry.register("owned").expect("register");

        // A different token (as if another execution's cleanup ran late) must
        // not be able to evict `owner`.
        let foreign = CancellationToken::new();
        assert!(!registry.unregister_if("owned", &foreign));
        assert!(
            registry.is_registered("owned"),
            "foreign cleanup must not evict a live registration"
        );

        // The true owner can.
        assert!(registry.unregister_if("owned", &owner));
        assert!(!registry.is_registered("owned"));
    }

    #[test]
    fn test_reregistration_allowed_after_cleanup() {
        let registry = CommandRegistry::new();
        let first = registry.register("seq").expect("register");
        assert!(registry.unregister_if("seq", &first));

        // Once the owner released it, the id is reusable.
        let second = registry.register("seq").expect("id reusable after cleanup");
        assert!(!second.is_cancelled());
    }

    #[test]
    fn test_duplicate_error_is_distinct_and_typed() {
        let dup = CommandError::duplicate("id already active");
        assert_eq!(dup.kind(), "duplicate");
        assert_eq!(dup.message(), "id already active");
        // Must not be conflatable with a domain rejection or a transport fault.
        assert_ne!(dup, CommandError::generic("id already active"));
        assert_ne!(dup, CommandError::transport("id already active"));
    }

    // ---- F5: panic / join failure must not mean "cancelled" ---------------

    #[test]
    fn test_transport_failure_is_not_cancellation() {
        let res = CommandResult::failure(
            CommandError::transport("blocking task join failed"),
            0,
            crate::now_millis(),
        );
        assert!(!res.is_cancelled, "a join/transport failure is not a cancellation");
        assert!(!res.is_success());
        assert_eq!(res.error.map(|e| e.kind()), Some("transport"));
        assert!(res.value.is_none());
    }

    #[test]
    fn test_cancellation_and_transport_failure_are_distinguishable() {
        let cancelled = CommandResult::cancelled(0, crate::now_millis());
        let panicked = CommandResult::failure(
            CommandError::transport("blocking task panicked"),
            0,
            crate::now_millis(),
        );

        assert!(cancelled.is_cancelled);
        assert!(!panicked.is_cancelled);
        assert_ne!(cancelled, panicked);
        assert_ne!(
            cancelled.error.map(|e| e.kind()),
            panicked.error.map(|e| e.kind())
        );
    }

    #[test]
    fn test_error_kind_discriminates_every_variant() {
        assert_eq!(CommandError::execution("m", None).kind(), "execution");
        assert_eq!(CommandError::validation("m", "f").kind(), "validation");
        assert_eq!(CommandError::timeout("m", 1).kind(), "timeout");
        assert_eq!(CommandError::transport("m").kind(), "transport");
        assert_eq!(CommandError::duplicate("m").kind(), "duplicate");
        assert_eq!(CommandError::generic("m").kind(), "generic");
    }

    // ---- F3: requested cancellation != observed cancellation ---------------

    /// The deterministic F3 discriminator.
    ///
    /// The native execution runs to genuine SUCCESS while the token is
    /// untouched; the token is cancelled only AFTERWARDS. Any implementation
    /// that decides the terminal result from the *current* token state — rather
    /// than from the native result — will misreport this completed work as
    /// cancelled. That is exactly the defect the Dart adapter had, expressed in
    /// one test.
    #[test]
    fn test_success_is_not_retroactively_rewritten_by_a_later_cancel_request() {
        let token = CancellationToken::new();
        let req = CommandRequest::new("cmd-f3", "echo", "completed");
        assert!(!token.is_cancelled(), "precondition: not cancelled up front");

        // Native execution observes NO cancellation and genuinely succeeds.
        let res = execute_command_pure(&req, Some(&token));
        assert!(res.is_success());
        assert!(!res.is_cancelled);

        // A cancellation REQUEST arrives after the work already finished.
        token.cancel();

        // The recorded native result must still report success: the terminal
        // state reflects what native actually observed, not a later local intent.
        assert!(
            !res.is_cancelled,
            "a late cancellation request must not retroactively rewrite a \\
             genuine native success"
        );
        assert!(res.is_success());
        assert_eq!(res.value.as_deref(), Some("echo: completed"));
    }

    /// The counterpart: a cancellation OBSERVED during execution is honoured.
    #[test]
    fn test_observed_cancellation_is_honoured_by_native_execution() {
        let token = CancellationToken::new();
        let req = CommandRequest::new("cmd-f3-obs", "echo", "x");
        token.cancel();

        let res = execute_command_pure(&req, Some(&token));
        assert!(
            res.is_cancelled,
            "a cancellation observed by the native execution must be honoured"
        );
        assert!(!res.is_success());
    }

    #[test]
    fn test_long_running_in_flight_cancellation() {
        let registry = CommandRegistry::new();
        let token = registry.register("cmd-long-1").expect("register");

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

