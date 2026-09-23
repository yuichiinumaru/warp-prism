#!/bin/bash
#
# cargo-queue.sh — Serialized build queue for multi-agent Rust workspaces
#
# Usage: AGENT_NAME=your-agent TASK_ID=NNNN bash cargo-queue.sh <command> [args...]
#
# Serializes cargo via flock, emits a machine-parseable envelope, and optionally
# skips identical re-runs (agent decides; see SUBSKILL.md).
#
# Environment Variables:
#   AGENT_NAME                    — Agent name (logging)
#   TASK_ID                       — Task id (tracking)
#   CARGO_QUEUE_TIMEOUT           — Lock wait timeout seconds (default: 1800)
#   CARGO_QUEUE_CLEAN_THRESHOLD_GB — Min target/ GiB before clean runs (default: 30)
#   CARGO_QUEUE_DIR               — Override queue state dir (tests; default: $PROJECT_ROOT/.agents/cargo-queue)
#   CARGO_QUEUE_PROJECT_ROOT      — Override project root (tests)
#   CARGO_QUEUE_FORCE=1           — Force enqueue (same as --force)
#   CARGO_QUEUE_DEDUP=0           — Disable dedup short-circuits (still envelope+ledger)
#   CARGO_QUEUE_DEDUP_TTL_SEC     — Dedup TTL seconds (default: 3600)
#   CARGO_QUEUE_FP_INCLUDE_RUSTC=1 — Optional Phase 1.1: include rustc -vV hash in FP
#   CARGO_TARGET_DIR              — FORBIDDEN unless equal to $PROJECT_ROOT/target
#                                   (custom dirs refused; see enforce_cargo_target_policy)
#
# Commands:
#   check|test|clippy|build|clean [args]  — cargo command (serialized)
#   status                                — queue status + thin envelope
#
# Target policy (absolute):
#   - Only $PROJECT_ROOT/target is allowed as the cargo target directory
#   - Refuse non-default CARGO_TARGET_DIR and any --target-dir flag
#   - Refuse to run if orphan target-* / .tmp-target-* dirs exist at project root
#   - After every non-clean cargo run, if target/ > CLEAN threshold, auto cargo clean
#
# Exit Codes:
#   0   — Success (fresh or dedup_hit prior success)
#   1   — Timeout, lock failure, invalid usage, target-policy violation
#   75  — dedup_running (EX_TEMPFAIL — wait/poll/force; not green)
#   N   — Cargo / prior exit code preserved (including dedup_hit failures)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Path / project resolution
# ---------------------------------------------------------------------------

_resolve_project_root() {
    if [[ -n "${CARGO_QUEUE_PROJECT_ROOT:-}" ]]; then
        realpath -m "${CARGO_QUEUE_PROJECT_ROOT}"
        return 0
    fi
    local dir
    dir="$(pwd -P)"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/Cargo.toml" ]]; then
            printf '%s\n' "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    pwd -P
}

PROJECT_ROOT="$(_resolve_project_root)"

if [[ -n "${CARGO_QUEUE_DIR:-}" ]]; then
    QUEUE_DIR="$(realpath -m "$CARGO_QUEUE_DIR")"
else
    QUEUE_DIR="$PROJECT_ROOT/.agents/cargo-queue"
fi

LOCK_FILE="$QUEUE_DIR/queue.lock"
LOGS_DIR="$QUEUE_DIR/logs"
RESULTS_DIR="$QUEUE_DIR/results"
FP_DIR="$QUEUE_DIR/fp"
LEDGER_FILE="$QUEUE_DIR/ledger.jsonl"

mkdir -p "$QUEUE_DIR" "$LOGS_DIR" "$RESULTS_DIR" "$FP_DIR"
touch "$LOCK_FILE"

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

TIMEOUT="${CARGO_QUEUE_TIMEOUT:-1800}"
AGENT_NAME="${AGENT_NAME:-unknown}"
TASK_ID="${TASK_ID:-none}"
CLEAN_THRESHOLD_GB="${CARGO_QUEUE_CLEAN_THRESHOLD_GB:-30}"
DEDUP_TTL_SEC="${CARGO_QUEUE_DEDUP_TTL_SEC:-3600}"
DEDUP_ENABLED="${CARGO_QUEUE_DEDUP:-1}"
FORCE_ENV="${CARGO_QUEUE_FORCE:-0}"
FP_INCLUDE_RUSTC="${CARGO_QUEUE_FP_INCLUDE_RUSTC:-0}"

ISO_TS() { date -Iseconds; }
EPOCH_NOW() { date +%s; }

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
# Make request ids unique under concurrent selftests
REQUEST_ID="${TIMESTAMP}-${AGENT_NAME}-${TASK_ID}-$$"
LOG_FILE="$LOGS_DIR/${REQUEST_ID}.log"
RESULT_FILE="$RESULTS_DIR/${REQUEST_ID}.json"

# Envelope fields (mutable across path)
ENVELOPE_STATUS="error"
ENVELOPE_EXIT=""
ENVELOPE_DEDUP="none"
ENVELOPE_HINT="Inspect prior_log before re-running. Use --force or CARGO_QUEUE_FORCE=1 to enqueue anyway."
PRIOR_REQUEST_ID=""
PRIOR_TIMESTAMP=""
PRIOR_STATUS=""
PRIOR_EXIT_CODE=""
PRIOR_LOG_PATH=""
PRIOR_RESULT_PATH=""
FINGERPRINT=""
NORMALIZED_ARGS=""
CARGO_TARGET_DIR_RESOLVED=""
FORCE=0
DURATION_SECONDS=0
STARTED_ISO=""
FINISHED_ISO=""
COMMAND=""
ARGS_DISPLAY=""

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

json_escape() {
    # Minimal JSON string escape for envelope/ledger values
    local s="${1-}"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

pid_alive() {
    local pid="${1:-}"
    [[ -n "$pid" && "$pid" =~ ^[0-9]+$ ]] || return 1
    kill -0 "$pid" 2>/dev/null
}

fp_path_for() {
    local fp="$1"
    local hh="${fp:0:2}"
    printf '%s/%s/%s.json\n' "$FP_DIR" "$hh" "$fp"
}

default_cargo_target_dir() {
    # Canonical sole target directory for this project (never target-<task>).
    realpath -m "$PROJECT_ROOT/target"
}

resolve_cargo_target_dir() {
    # Always report the canonical default after policy enforcement.
    default_cargo_target_dir
}

# Fail closed on custom target dirs, --target-dir, and orphan target-* trees.
# On success: unset CARGO_TARGET_DIR so cargo uses the default ./target under PROJECT_ROOT.
enforce_cargo_target_policy() {
    local default_td custom_td tok prev orphan orphans msg
    default_td="$(default_cargo_target_dir)"

    if [[ -n "${CARGO_TARGET_DIR:-}" ]]; then
        custom_td="$(realpath -m "$CARGO_TARGET_DIR")"
        if [[ "$custom_td" != "$default_td" ]]; then
            msg="[cargo-queue] ❌ CARGO_TARGET_DIR refused: '$CARGO_TARGET_DIR' → $custom_td (only $default_td is allowed). Unset CARGO_TARGET_DIR and use cargo-queue with the default target/."
            echo "$msg" >&2
            return 1
        fi
    fi

    prev=""
    for tok in "$@"; do
        if [[ "$tok" == --target-dir || "$tok" == --target-dir=* ]]; then
            msg="[cargo-queue] ❌ --target-dir is forbidden (only project-root target/ is allowed)."
            echo "$msg" >&2
            return 1
        fi
        if [[ "$prev" == --target-dir ]]; then
            msg="[cargo-queue] ❌ --target-dir is forbidden (only project-root target/ is allowed)."
            echo "$msg" >&2
            return 1
        fi
        prev="$tok"
    done

    orphans=()
    shopt -s nullglob
    for orphan in "$PROJECT_ROOT"/target-* "$PROJECT_ROOT"/.tmp-target-*; do
        [[ -e "$orphan" ]] || continue
        orphans+=("$(basename "$orphan")")
    done
    shopt -u nullglob
    if ((${#orphans[@]} > 0)); then
        msg="[cargo-queue] ❌ Orphan cargo target dirs at project root (remove before running; only target/ is allowed): ${orphans[*]}"
        echo "$msg" >&2
        return 1
    fi

    # Normalize: never leave a custom dir exported for child cargo.
    unset CARGO_TARGET_DIR || true
    return 0
}

# Size-gated clean of PROJECT_ROOT/target only. Echoes actions to stdout+log when log set.
run_size_gated_clean() {
    local target_dir="$PROJECT_ROOT/target"
    local target_kb msg
    if [[ ! -d "$target_dir" ]]; then
        msg="[cargo-queue] target/ missing — skipping cargo clean (threshold ${CLEAN_THRESHOLD_GB} GiB)"
        echo "$msg"
        return 0
    fi
    target_kb="$(du -sk "$target_dir" 2>/dev/null | awk 'END {print $1}')" || true
    target_kb="${target_kb:-0}"
    if [[ ! "$target_kb" =~ ^[0-9]+$ ]]; then
        target_kb=0
    fi
    if [[ "$target_kb" -le "$CLEAN_THRESHOLD_KB" ]]; then
        msg="[cargo-queue] target/ is ${target_kb} KiB (<= ${CLEAN_THRESHOLD_KB} KiB / ${CLEAN_THRESHOLD_GB} GiB) — skipping cargo clean"
        echo "$msg"
        return 0
    fi
    msg="[cargo-queue] target/ is ${target_kb} KiB (> ${CLEAN_THRESHOLD_KB} KiB / ${CLEAN_THRESHOLD_GB} GiB) — running cargo clean"
    echo "$msg"
    cargo clean
}

# Emit normalized args from remaining "$@" (order-preserving, path realpath when under PROJECT_ROOT)
emit_normalized_args() {
    local -a out=()
    local tok resolved
    for tok in "$@"; do
        # Collapse internal whitespace runs inside a single token is unusual;
        # trim ends and collapse spaces only for multi-space tokens.
        tok="$(printf '%s' "$tok" | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//')"
        if [[ -z "$tok" ]]; then
            continue
        fi
        if [[ "$tok" == --manifest-path ]]; then
            out+=("$tok")
            continue
        fi
        # Previous token was --manifest-path → realpath when possible
        if [[ ${#out[@]} -gt 0 && "${out[-1]}" == "--manifest-path" ]]; then
            if [[ -e "$tok" ]]; then
                resolved="$(realpath -m "$tok" 2>/dev/null || printf '%s' "$tok")"
                out+=("$resolved")
            else
                out+=("$tok")
            fi
            continue
        fi
        if [[ -e "$tok" ]]; then
            resolved="$(realpath -m "$tok" 2>/dev/null || printf '%s' "$tok")"
            # Only rewrite if under PROJECT_ROOT
            case "$resolved" in
                "$PROJECT_ROOT"|"$PROJECT_ROOT"/*) out+=("$resolved") ;;
                *) out+=("$tok") ;;
            esac
        else
            out+=("$tok")
        fi
    done
    # Join with single spaces
    local joined=""
    local i
    for i in "${!out[@]}"; do
        if [[ $i -eq 0 ]]; then
            joined="${out[$i]}"
        else
            joined+=" ${out[$i]}"
        fi
    done
    printf '%s' "$joined"
}

compute_fingerprint() {
    local cmd="$1"
    local nargs="$2"
    local target_dir="$3"
    local clean_token=""
    if [[ "$cmd" == "clean" ]]; then
        clean_token="clean_gb=${CLEAN_THRESHOLD_GB}"
    fi
    local rustc_token=""
    if [[ "$FP_INCLUDE_RUSTC" == "1" ]]; then
        rustc_token="$(rustc -vV 2>/dev/null | sha256sum | awk '{print $1}' | head -c 16 || true)"
    fi
    # Pipe NUL-delimited material directly — bash $(...) strips NULs.
    printf 'v1\0%s\0%s\0%s\0%s\0%s\0%s' \
        "$PROJECT_ROOT" \
        "$cmd" \
        "$nargs" \
        "$target_dir" \
        "$clean_token" \
        "$rustc_token" | sha256sum | awk '{print $1}'
}

# Load FP record fields into named globals.
# Sets: _FP_STATUS _FP_PID _FP_EXIT _FP_REQUEST_ID _FP_TS _FP_LOG _FP_RESULT _FP_FINISHED_EPOCH _FP_FINISHED_ISO
load_fp_record() {
    local fp="$1"
    local path
    path="$(fp_path_for "$fp")"
    _FP_STATUS=""
    _FP_PID=""
    _FP_EXIT=""
    _FP_REQUEST_ID=""
    _FP_TS=""
    _FP_LOG=""
    _FP_RESULT=""
    _FP_FINISHED_EPOCH=""
    _FP_FINISHED_ISO=""
    [[ -f "$path" ]] || return 1
    if ! command -v python3 >/dev/null 2>&1; then
        echo "[cargo-queue] WARN: python3 required for FP index parse" >&2
        return 1
    fi
    # 9 lines: status pid exit request_id ts log result finished_epoch finished_at
    local parsed
    parsed="$(python3 -c '
import json, sys
try:
    with open(sys.argv[1]) as f:
        d = json.load(f)
except Exception:
    sys.exit(1)
def g(k):
    v = d.get(k)
    if v is None:
        return ""
    return str(v).replace("\n", " ")
print(g("status"))
print(g("pid"))
print(g("exit_code"))
print(g("request_id"))
print(g("timestamp") or g("finished_at") or g("started_at"))
print(g("log_path"))
print(g("result_path"))
print(g("finished_epoch"))
print(g("finished_at"))
' "$path")" || return 1
    {
        IFS= read -r _FP_STATUS
        IFS= read -r _FP_PID
        IFS= read -r _FP_EXIT
        IFS= read -r _FP_REQUEST_ID
        IFS= read -r _FP_TS
        IFS= read -r _FP_LOG
        IFS= read -r _FP_RESULT
        IFS= read -r _FP_FINISHED_EPOCH
        IFS= read -r _FP_FINISHED_ISO
    } <<<"$parsed"
    return 0
}

write_fp_record() {
    # Args via env-like locals: write atomic JSON for fingerprint pointer
    local fp="$1"
    local status="$2"
    local exit_code="${3:-}"
    local pid="${4:-}"
    local path tmp hh
    path="$(fp_path_for "$fp")"
    hh="${fp:0:2}"
    mkdir -p "$(dirname "$path")"
    tmp="${path}.tmp.$$"
    local finished_at finished_epoch
    finished_at="$(ISO_TS)"
    finished_epoch="$(EPOCH_NOW)"
    if [[ "$status" == "running" ]]; then
        finished_at=""
        finished_epoch=""
    fi
    cat > "$tmp" <<EOF
{
  "schema": 1,
  "fingerprint": "$(json_escape "$fp")",
  "status": "$(json_escape "$status")",
  "request_id": "$(json_escape "$REQUEST_ID")",
  "pid": $([[ -n "$pid" ]] && printf '%s' "$pid" || printf 'null'),
  "exit_code": $([[ -n "$exit_code" ]] && printf '%s' "$exit_code" || printf 'null'),
  "timestamp": "$(json_escape "$(ISO_TS)")",
  "started_at": "$(json_escape "${STARTED_ISO:-$(ISO_TS)}")",
  "finished_at": $([[ -n "$finished_at" ]] && printf '"%s"' "$(json_escape "$finished_at")" || printf 'null'),
  "finished_epoch": $([[ -n "$finished_epoch" ]] && printf '%s' "$finished_epoch" || printf 'null'),
  "command": "$(json_escape "$COMMAND")",
  "args": "$(json_escape "$ARGS_DISPLAY")",
  "project_root": "$(json_escape "$PROJECT_ROOT")",
  "cargo_target_dir": "$(json_escape "$CARGO_TARGET_DIR_RESOLVED")",
  "log_path": "$(json_escape "$LOG_FILE")",
  "result_path": "$(json_escape "$RESULT_FILE")",
  "agent": "$(json_escape "$AGENT_NAME")",
  "task_id": "$(json_escape "$TASK_ID")"
}
EOF
    mv -f "$tmp" "$path"
}

# Validity: TTL + root Cargo.toml / Cargo.lock mtime vs finished_epoch
fp_record_valid() {
    # Uses loaded _FP_* globals
    local now finished_epoch
    now="$(EPOCH_NOW)"
    finished_epoch="${_FP_FINISHED_EPOCH:-}"
    if [[ -z "$finished_epoch" || ! "$finished_epoch" =~ ^[0-9]+$ ]]; then
        # try parse ISO
        if [[ -n "${_FP_FINISHED_ISO:-}" ]]; then
            finished_epoch="$(date -d "$_FP_FINISHED_ISO" +%s 2>/dev/null || true)"
        fi
    fi
    if [[ -z "$finished_epoch" || ! "$finished_epoch" =~ ^[0-9]+$ ]]; then
        return 1
    fi
    if (( now - finished_epoch > DEDUP_TTL_SEC )); then
        return 1
    fi
    local mtime
    if [[ -f "$PROJECT_ROOT/Cargo.toml" ]]; then
        mtime="$(stat -c %Y "$PROJECT_ROOT/Cargo.toml" 2>/dev/null || echo 0)"
        if (( mtime > finished_epoch )); then
            return 1
        fi
    fi
    if [[ -f "$PROJECT_ROOT/Cargo.lock" ]]; then
        mtime="$(stat -c %Y "$PROJECT_ROOT/Cargo.lock" 2>/dev/null || echo 0)"
        if (( mtime > finished_epoch )); then
            return 1
        fi
    fi
    return 0
}

append_ledger() {
    # Fail-open: ledger errors must not block cargo
    local event="$1"
    local exit_code="${2:-}"
    local force_flag=false
    [[ "$FORCE" -eq 1 ]] && force_flag=true
    local line
    line="$(cat <<EOF
{"schema":1,"ts":"$(json_escape "$(ISO_TS)")","request_id":"$(json_escape "$REQUEST_ID")","fingerprint":"$(json_escape "$FINGERPRINT")","event":"$(json_escape "$event")","command":"$(json_escape "$COMMAND")","args":"$(json_escape "$ARGS_DISPLAY")","project_root":"$(json_escape "$PROJECT_ROOT")","cargo_target_dir":"$(json_escape "$CARGO_TARGET_DIR_RESOLVED")","agent":"$(json_escape "$AGENT_NAME")","task_id":"$(json_escape "$TASK_ID")","exit_code":$([[ -n "$exit_code" ]] && printf '%s' "$exit_code" || printf 'null'),"log_path":"$(json_escape "$LOG_FILE")","result_path":"$(json_escape "$RESULT_FILE")","prior_request_id":$([[ -n "$PRIOR_REQUEST_ID" ]] && printf '"%s"' "$(json_escape "$PRIOR_REQUEST_ID")" || printf 'null'),"force":${force_flag},"duration_seconds":${DURATION_SECONDS}}
EOF
)"
    {
        if (
            exec 201>>"$LEDGER_FILE"
            flock -w 5 201 || exit 1
            printf '%s\n' "$line" >&201
        ) 2>/dev/null; then
            :
        else
            printf '%s\n' "$line" >>"$LEDGER_FILE" 2>/dev/null || \
                echo "[cargo-queue] WARN: ledger append failed (fail-open)" >&2
        fi
    } || true
}

emit_envelope() {
    local status="$1"
    local exit_code="${2:-}"
    ENVELOPE_STATUS="$status"
    ENVELOPE_EXIT="$exit_code"
    cat <<EOF
=== CARGO_QUEUE_ENVELOPE ===
schema: 1
request_id: $REQUEST_ID
timestamp: $(ISO_TS)
status: $status
fingerprint: ${FINGERPRINT:-}
command: ${COMMAND:-}
args: ${ARGS_DISPLAY:-}
project_root: $PROJECT_ROOT
cargo_target_dir: ${CARGO_TARGET_DIR_RESOLVED:-}
log_path: $LOG_FILE
result_path: $RESULT_FILE
exit_code: ${exit_code}
dedup: ${ENVELOPE_DEDUP}
prior_request_id: ${PRIOR_REQUEST_ID}
prior_timestamp: ${PRIOR_TIMESTAMP}
prior_status: ${PRIOR_STATUS}
prior_exit_code: ${PRIOR_EXIT_CODE}
prior_log_path: ${PRIOR_LOG_PATH}
prior_result_path: ${PRIOR_RESULT_PATH}
force: ${FORCE}
hint: ${ENVELOPE_HINT}
=== END_CARGO_QUEUE_ENVELOPE ===
EOF
}

write_result_json() {
    local status="$1"
    local exit_code="$2"
    local success="false"
    [[ "$exit_code" == "0" ]] && success="true"
    cat > "$RESULT_FILE" <<EOF
{
  "schema": 1,
  "request_id": "$(json_escape "$REQUEST_ID")",
  "fingerprint": "$(json_escape "$FINGERPRINT")",
  "success": ${success},
  "exit_code": ${exit_code},
  "status": "$(json_escape "$status")",
  "command": "$(json_escape "$COMMAND")",
  "args": "$(json_escape "$ARGS_DISPLAY")",
  "project_root": "$(json_escape "$PROJECT_ROOT")",
  "cargo_target_dir": "$(json_escape "$CARGO_TARGET_DIR_RESOLVED")",
  "agent": "$(json_escape "$AGENT_NAME")",
  "task_id": "$(json_escape "$TASK_ID")",
  "duration_seconds": ${DURATION_SECONDS},
  "log_path": "$(json_escape "$LOG_FILE")",
  "result_path": "$(json_escape "$RESULT_FILE")",
  "started_at": "$(json_escape "${STARTED_ISO:-}")",
  "finished_at": "$(json_escape "${FINISHED_ISO:-$(ISO_TS)}")",
  "dedup": "$(json_escape "$ENVELOPE_DEDUP")",
  "force": $([[ "$FORCE" -eq 1 ]] && echo true || echo false),
  "prior_request_id": $([[ -n "$PRIOR_REQUEST_ID" ]] && printf '"%s"' "$(json_escape "$PRIOR_REQUEST_ID")" || printf 'null')
}
EOF
}

fill_prior_from_fp() {
    PRIOR_REQUEST_ID="${_FP_REQUEST_ID:-}"
    PRIOR_TIMESTAMP="${_FP_TS:-}"
    PRIOR_STATUS="${_FP_STATUS:-}"
    PRIOR_EXIT_CODE="${_FP_EXIT:-}"
    PRIOR_LOG_PATH="${_FP_LOG:-}"
    PRIOR_RESULT_PATH="${_FP_RESULT:-}"
}

# ---------------------------------------------------------------------------
# status command (thin envelope)
# ---------------------------------------------------------------------------

if [[ "${1:-}" == "status" ]]; then
    COMMAND="status"
    ARGS_DISPLAY=""
    CARGO_TARGET_DIR_RESOLVED="$(resolve_cargo_target_dir)"
    FINGERPRINT=""
    echo "=== Cargo Queue Status ==="
    echo ""
    echo "Queue Directory: $QUEUE_DIR"
    echo "Lock File: $LOCK_FILE"
    echo "Project Root: $PROJECT_ROOT"
    echo "Cargo Target Dir (canonical): $CARGO_TARGET_DIR_RESOLVED"
    echo "Clean Threshold (GiB): $CLEAN_THRESHOLD_GB"
    echo "Dedup: enabled=$([[ "$DEDUP_ENABLED" != "0" ]] && echo yes || echo no) ttl=${DEDUP_TTL_SEC}s"
    echo ""
    # Report orphans (status does not hard-fail — agents still see the defect)
    shopt -s nullglob
    _orphan_status=()
    for _o in "$PROJECT_ROOT"/target-* "$PROJECT_ROOT"/.tmp-target-*; do
        [[ -e "$_o" ]] || continue
        _orphan_status+=("$(basename "$_o")")
    done
    shopt -u nullglob
    if ((${#_orphan_status[@]} > 0)); then
        echo "⚠️  Orphan target dirs (will block check/test/build/clippy/clean): ${_orphan_status[*]}"
        echo ""
    fi
    if ! flock -n "$LOCK_FILE" -c "true" 2>/dev/null; then
        echo "🔒 Lock Status: LOCKED (build in progress)"
    else
        echo "🔓 Lock Status: FREE"
    fi
    echo ""
    if [[ -f "$QUEUE_DIR/current.json" ]]; then
        echo "Current:"
        cat "$QUEUE_DIR/current.json"
        echo ""
    fi
    echo "Recent Executions:"
    ls -1t "$LOGS_DIR" 2>/dev/null | head -10 | while read -r log; do
        echo "  • $log"
    done
    ENVELOPE_DEDUP="none"
    ENVELOPE_HINT="status only — no cargo executed"
    # Ensure log/result paths exist for status (touch empty markers optional)
    : >>"$LOG_FILE" 2>/dev/null || true
    emit_envelope "completed" "0"
    exit 0
fi

# ---------------------------------------------------------------------------
# Parse command + force flags
# ---------------------------------------------------------------------------

COMMAND="${1:-}"
if [[ ! "$COMMAND" =~ ^(check|test|clippy|build|clean)$ ]]; then
    echo "❌ Unknown command: ${COMMAND:-<empty>}" >&2
    echo "Usage: $0 {check|test|clippy|build|clean|status} [args...] [--force]" >&2
    COMMAND="${COMMAND:-unknown}"
    ARGS_DISPLAY="$*"
    FINGERPRINT=""
    CARGO_TARGET_DIR_RESOLVED="$(resolve_cargo_target_dir)"
    : >>"$LOG_FILE" 2>/dev/null || true
    emit_envelope "error" "1"
    exit 1
fi
shift

# Strip --force from argv; also honor env
FORCE=0
if [[ "$FORCE_ENV" == "1" ]]; then
    FORCE=1
fi
FILTERED_ARGS=()
for tok in "$@"; do
    if [[ "$tok" == "--force" ]]; then
        FORCE=1
        continue
    fi
    FILTERED_ARGS+=("$tok")
done
if ((${#FILTERED_ARGS[@]})); then
    set -- "${FILTERED_ARGS[@]}"
else
    set --
fi

if [[ "$COMMAND" == "clean" ]]; then
    if [[ ! "$CLEAN_THRESHOLD_GB" =~ ^[0-9]+$ ]]; then
        echo "❌ Invalid CARGO_QUEUE_CLEAN_THRESHOLD_GB: must be a non-negative integer (got: ${CLEAN_THRESHOLD_GB})" >&2
        ARGS_DISPLAY="$*"
        CARGO_TARGET_DIR_RESOLVED="$(resolve_cargo_target_dir)"
        : >>"$LOG_FILE" 2>/dev/null || true
        emit_envelope "error" "1"
        exit 1
    fi
fi
CLEAN_THRESHOLD_KB=$((CLEAN_THRESHOLD_GB * 1024 * 1024))

# Target policy: fail closed before queue mutation / fingerprint (except we may emit error envelope).
if ! enforce_cargo_target_policy "$@"; then
    ARGS_DISPLAY="$(emit_normalized_args "$@" 2>/dev/null || printf '%s' "$*")"
    CARGO_TARGET_DIR_RESOLVED="$(resolve_cargo_target_dir)"
    FINGERPRINT=""
    : >>"$LOG_FILE" 2>/dev/null || true
    ENVELOPE_HINT="Target policy violation: only project-root target/ is allowed; remove target-* orphans; never set CARGO_TARGET_DIR/--target-dir."
    emit_envelope "error" "1"
    exit 1
fi

CARGO_TARGET_DIR_RESOLVED="$(resolve_cargo_target_dir)"
NORMALIZED_ARGS="$(emit_normalized_args "$@")"
ARGS_DISPLAY="$NORMALIZED_ARGS"
FINGERPRINT="$(compute_fingerprint "$COMMAND" "$NORMALIZED_ARGS" "$CARGO_TARGET_DIR_RESOLVED")"
STARTED_ISO="$(ISO_TS)"

# ---------------------------------------------------------------------------
# Pre-lock dedup short-circuit (instant; no flock wait)
# ---------------------------------------------------------------------------

if [[ "$DEDUP_ENABLED" != "0" && "$FORCE" -eq 0 ]]; then
    if load_fp_record "$FINGERPRINT"; then
        if [[ "$_FP_STATUS" == "running" ]] && pid_alive "${_FP_PID:-}"; then
            fill_prior_from_fp
            ENVELOPE_DEDUP="running"
            ENVELOPE_HINT="Identical request currently running (pid ${_FP_PID}). Poll status, wait, or --force if justified."
            append_ledger "dedup_running" "75" || true
            # Do not create full result for this request as a cargo run; still write a small result
            write_result_json "dedup_running" "75"
            emit_envelope "dedup_running" "75"
            exit 75
        fi
        if [[ "$_FP_STATUS" == "completed" || "$_FP_STATUS" == "failed" || "$_FP_STATUS" == "success" ]]; then
            if fp_record_valid; then
                fill_prior_from_fp
                local_exit="${_FP_EXIT:-1}"
                if [[ ! "$local_exit" =~ ^[0-9]+$ ]]; then
                    local_exit=1
                fi
                ENVELOPE_DEDUP="hit"
                ENVELOPE_HINT="Identical prior result reused (exit ${local_exit}). Inspect prior_log_path; never auto-claim task PASS from a failure. Use --force to re-run."
                # Point this request's envelope log/result to prior artifacts for convenience
                # Keep our REQUEST_ID but surface prior paths in prior_* fields
                if [[ -n "${_FP_LOG:-}" ]]; then
                    LOG_FILE="$_FP_LOG"
                fi
                if [[ -n "${_FP_RESULT:-}" ]]; then
                    RESULT_FILE="$_FP_RESULT"
                fi
                append_ledger "dedup_hit" "$local_exit" || true
                emit_envelope "dedup_hit" "$local_exit"
                exit "$local_exit"
            fi
        fi
        # running but dead PID → fall through and re-run
    fi
fi

# ---------------------------------------------------------------------------
# Enqueue path: prepare log + waiting status
# ---------------------------------------------------------------------------

echo "=== Cargo Queue Request ===" > "$LOG_FILE"
{
    echo "Request ID: $REQUEST_ID"
    echo "Agent: $AGENT_NAME"
    echo "Task: $TASK_ID"
    echo "Command: cargo $COMMAND $ARGS_DISPLAY"
    echo "Fingerprint: $FINGERPRINT"
    echo "Force: $FORCE"
    echo "Project Root: $PROJECT_ROOT"
    echo "Cargo Target Dir: ${CARGO_TARGET_DIR_RESOLVED:-<default>}"
    if [[ "$COMMAND" == "clean" ]]; then
        echo "Clean threshold: ${CLEAN_THRESHOLD_GB} GiB (${CLEAN_THRESHOLD_KB} KiB)"
    fi
    echo "Started: $STARTED_ISO"
    echo ""
} >> "$LOG_FILE"

cat > "$QUEUE_DIR/current.json" <<EOF
{
  "request_id": "$(json_escape "$REQUEST_ID")",
  "fingerprint": "$(json_escape "$FINGERPRINT")",
  "agent": "$(json_escape "$AGENT_NAME")",
  "task_id": "$(json_escape "$TASK_ID")",
  "command": "$(json_escape "$COMMAND")",
  "args": "$(json_escape "$ARGS_DISPLAY")",
  "started_at": "$(json_escape "$STARTED_ISO")",
  "status": "waiting_for_lock",
  "force": $([[ "$FORCE" -eq 1 ]] && echo true || echo false)
}
EOF

append_ledger "accepted" "" || true

# ---------------------------------------------------------------------------
# Acquire lock and run cargo (hold flock for entire cargo lifetime)
# ---------------------------------------------------------------------------

CARGO_EXIT=1
RUN_START_EPOCH="$(EPOCH_NOW)"

# Subshell holds exclusive lock on FD 200 until exit — do NOT close 200 early.
set +e
(
    exec 200>"$LOCK_FILE"
    if ! flock -w "$TIMEOUT" 200; then
        echo "[cargo-queue] ⏰ TIMEOUT: Could not acquire lock after ${TIMEOUT}s" >&2
        exit 1
    fi

    # Post-lock re-check: peer may have completed same FP while we waited
    if [[ "$DEDUP_ENABLED" != "0" && "$FORCE" -eq 0 ]]; then
        if load_fp_record "$FINGERPRINT"; then
            if [[ "$_FP_STATUS" == "completed" || "$_FP_STATUS" == "failed" || "$_FP_STATUS" == "success" ]]; then
                if fp_record_valid; then
                    # Signal dedup_hit to parent via special exit + marker file
                    printf '%s\n' "${_FP_EXIT:-0}" > "$QUEUE_DIR/.dedup_hit_exit.$$"
                    printf '%s\n' "${_FP_REQUEST_ID:-}" > "$QUEUE_DIR/.dedup_hit_rid.$$"
                    printf '%s\n' "${_FP_LOG:-}" > "$QUEUE_DIR/.dedup_hit_log.$$"
                    printf '%s\n' "${_FP_RESULT:-}" > "$QUEUE_DIR/.dedup_hit_res.$$"
                    printf '%s\n' "${_FP_TS:-}" > "$QUEUE_DIR/.dedup_hit_ts.$$"
                    printf '%s\n' "${_FP_STATUS:-}" > "$QUEUE_DIR/.dedup_hit_st.$$"
                    exit 74  # internal: post-lock dedup_hit
                fi
            fi
        fi
    fi

    echo "[cargo-queue] ✅ Lock acquired. Running cargo $COMMAND..."
    cat > "$QUEUE_DIR/current.json" <<EOF
{
  "request_id": "$(json_escape "$REQUEST_ID")",
  "fingerprint": "$(json_escape "$FINGERPRINT")",
  "agent": "$(json_escape "$AGENT_NAME")",
  "task_id": "$(json_escape "$TASK_ID")",
  "command": "$(json_escape "$COMMAND")",
  "args": "$(json_escape "$ARGS_DISPLAY")",
  "started_at": "$(json_escape "$(ISO_TS)")",
  "status": "running",
  "pid": $$
}
EOF

    # Mark FP as running (pid of this subshell)
    write_fp_record "$FINGERPRINT" "running" "" "$$"

    cd "$PROJECT_ROOT" || exit 1
    {
        echo ""
        echo "=== Cargo Output ==="
    } >> "$LOG_FILE"

    # IMPORTANT: do not close FD 200 here — flock must cover cargo lifetime (T9).
    # sccache/cargo may inherit FD 200; acceptable tradeoff for correctness.

    if [[ "$COMMAND" == "clean" ]]; then
        # Explicit clean: size-gated against PROJECT_ROOT/target only (no custom dirs).
        # Extra args after clean are ignored for safety (no --target-dir passthrough).
        run_size_gated_clean 2>&1 | tee -a "$LOG_FILE"
        CARGO_EXIT=${PIPESTATUS[0]}
    else
        cargo "$COMMAND" "$@" 2>&1 | tee -a "$LOG_FILE"
        CARGO_EXIT=${PIPESTATUS[0]}
        # Post-run size gate: if target/ ballooned past threshold, reclaim under the same lock.
        {
            echo ""
            echo "=== Post-run target/ size gate ==="
        } >> "$LOG_FILE"
        run_size_gated_clean 2>&1 | tee -a "$LOG_FILE"
        # Do not overwrite cargo's exit with clean's; log clean failures but keep primary exit.
        _clean_exit=${PIPESTATUS[0]}
        if [[ "${_clean_exit:-0}" -ne 0 ]]; then
            echo "[cargo-queue] ⚠️ post-run size-gated clean exited ${_clean_exit} (primary cargo exit remains ${CARGO_EXIT})" | tee -a "$LOG_FILE"
        fi
    fi

    # Persist exit for parent (subshell exit alone is enough, but keep marker)
    printf '%s\n' "$CARGO_EXIT" > "$QUEUE_DIR/.cargo_exit.$$"
    exit "$CARGO_EXIT"
)
CARGO_EXIT=$?
set -e

# Post-lock dedup_hit path (marker file is authoritative; exit 74 is advisory)
if [[ -f "$QUEUE_DIR/.dedup_hit_exit.$$" ]]; then
    local_exit="$(cat "$QUEUE_DIR/.dedup_hit_exit.$$")"
    PRIOR_REQUEST_ID="$(cat "$QUEUE_DIR/.dedup_hit_rid.$$" 2>/dev/null || true)"
    PRIOR_LOG_PATH="$(cat "$QUEUE_DIR/.dedup_hit_log.$$" 2>/dev/null || true)"
    PRIOR_RESULT_PATH="$(cat "$QUEUE_DIR/.dedup_hit_res.$$" 2>/dev/null || true)"
    PRIOR_TIMESTAMP="$(cat "$QUEUE_DIR/.dedup_hit_ts.$$" 2>/dev/null || true)"
    PRIOR_STATUS="$(cat "$QUEUE_DIR/.dedup_hit_st.$$" 2>/dev/null || true)"
    PRIOR_EXIT_CODE="$local_exit"
    rm -f "$QUEUE_DIR/.dedup_hit_exit.$$" "$QUEUE_DIR/.dedup_hit_rid.$$" \
          "$QUEUE_DIR/.dedup_hit_log.$$" "$QUEUE_DIR/.dedup_hit_res.$$" \
          "$QUEUE_DIR/.dedup_hit_ts.$$" "$QUEUE_DIR/.dedup_hit_st.$$" 2>/dev/null || true
    ENVELOPE_DEDUP="hit"
    ENVELOPE_HINT="Identical prior result reused after lock wait (exit ${local_exit}). Inspect prior_log_path; never auto-claim task PASS from a failure."
    if [[ -n "$PRIOR_LOG_PATH" ]]; then LOG_FILE="$PRIOR_LOG_PATH"; fi
    if [[ -n "$PRIOR_RESULT_PATH" ]]; then RESULT_FILE="$PRIOR_RESULT_PATH"; fi
    append_ledger "dedup_hit" "$local_exit" || true
    emit_envelope "dedup_hit" "$local_exit"
    exit "$local_exit"
fi

# Timeout path
if [[ $CARGO_EXIT -eq 1 ]] && [[ ! -f "$QUEUE_DIR/.cargo_exit.$$" ]]; then
    # Could be real cargo exit 1 OR lock timeout. Distinguish via log/current.
    if ! grep -q "=== Cargo Output ===" "$LOG_FILE" 2>/dev/null; then
        echo "[cargo-queue] ⏰ TIMEOUT: Could not acquire lock after ${TIMEOUT}s" | tee -a "$LOG_FILE"
        echo "[cargo-queue]    Another cargo process is running." | tee -a "$LOG_FILE"
        FINISHED_ISO="$(ISO_TS)"
        DURATION_SECONDS=$(( $(EPOCH_NOW) - RUN_START_EPOCH ))
        cat > "$QUEUE_DIR/current.json" <<EOF
{
  "request_id": "$(json_escape "$REQUEST_ID")",
  "fingerprint": "$(json_escape "$FINGERPRINT")",
  "agent": "$(json_escape "$AGENT_NAME")",
  "task_id": "$(json_escape "$TASK_ID")",
  "command": "$(json_escape "$COMMAND")",
  "status": "timeout",
  "error": "Lock acquisition timeout after ${TIMEOUT}s"
}
EOF
        write_result_json "timeout" "1"
        append_ledger "timeout" "1" || true
        emit_envelope "timeout" "1"
        exit 1
    fi
fi

if [[ -f "$QUEUE_DIR/.cargo_exit.$$" ]]; then
    CARGO_EXIT="$(cat "$QUEUE_DIR/.cargo_exit.$$")"
    rm -f "$QUEUE_DIR/.cargo_exit.$$"
fi

FINISHED_ISO="$(ISO_TS)"
DURATION_SECONDS=$(( $(EPOCH_NOW) - RUN_START_EPOCH ))

if [[ $CARGO_EXIT -eq 0 ]]; then
    STATUS="success"
    STATUS_EMOJI="✅"
    FP_STATUS="completed"
    ENV_STATUS="completed"
else
    STATUS="failure"
    STATUS_EMOJI="❌"
    FP_STATUS="completed"  # completed with fail — still a terminal prior
    ENV_STATUS="failed"
fi

# Update FP index with completed result (any exit)
write_fp_record "$FINGERPRINT" "completed" "$CARGO_EXIT" ""

cat > "$QUEUE_DIR/current.json" <<EOF
{
  "request_id": "$(json_escape "$REQUEST_ID")",
  "fingerprint": "$(json_escape "$FINGERPRINT")",
  "agent": "$(json_escape "$AGENT_NAME")",
  "task_id": "$(json_escape "$TASK_ID")",
  "command": "$(json_escape "$COMMAND")",
  "args": "$(json_escape "$ARGS_DISPLAY")",
  "started_at": "$(json_escape "$STARTED_ISO")",
  "finished_at": "$(json_escape "$FINISHED_ISO")",
  "duration_seconds": $DURATION_SECONDS,
  "status": "$STATUS",
  "exit_code": $CARGO_EXIT
}
EOF

write_result_json "$ENV_STATUS" "$CARGO_EXIT"
append_ledger "completed" "$CARGO_EXIT" || true

{
    echo ""
    echo "=== Cargo Queue Complete ==="
    echo "Finished: $FINISHED_ISO"
    echo "Duration: ${DURATION_SECONDS}s"
    echo "Exit Code: $CARGO_EXIT"
    echo "Status: $STATUS"
    echo "Fingerprint: $FINGERPRINT"
} >> "$LOG_FILE"

echo "[cargo-queue] $STATUS_EMOJI Complete: cargo $COMMAND (exit: $CARGO_EXIT, duration: ${DURATION_SECONDS}s)"

ENVELOPE_DEDUP="none"
emit_envelope "$ENV_STATUS" "$CARGO_EXIT"
exit "$CARGO_EXIT"
