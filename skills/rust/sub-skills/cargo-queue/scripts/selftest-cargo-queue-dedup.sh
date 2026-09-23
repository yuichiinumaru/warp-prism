#!/bin/bash
#
# selftest-cargo-queue-dedup.sh — P0/P1 acceptance tests for cargo-queue dedup
# Uses fake cargo + isolated CARGO_QUEUE_DIR. Does not require real rustc builds.
#
# Usage:
#   bash selftest-cargo-queue-dedup.sh
#   bash selftest-cargo-queue-dedup.sh T2 T4   # subset by id
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUEUE_SH="$SCRIPT_DIR/cargo-queue.sh"
if [[ ! -x "$QUEUE_SH" ]]; then
    chmod +x "$QUEUE_SH" || true
fi

PASS=0
FAIL=0
SKIP=0
RESULTS=()

log() { printf '[selftest] %s\n' "$*"; }

assert_eq() {
    local name="$1" got="$2" want="$3"
    if [[ "$got" == "$want" ]]; then
        return 0
    fi
    printf 'ASSERT FAIL %s: got=%q want=%q\n' "$name" "$got" "$want" >&2
    return 1
}

assert_contains() {
    local name="$1" hay="$2" needle="$3"
    if [[ "$hay" == *"$needle"* ]]; then
        return 0
    fi
    printf 'ASSERT FAIL %s: missing %q in output\n' "$name" "$needle" >&2
    return 1
}

envelope_field() {
    local out="$1" key="$2"
    printf '%s\n' "$out" | awk -F': ' -v k="$key" '
        $0 == "=== CARGO_QUEUE_ENVELOPE ===" {in_e=1; next}
        $0 == "=== END_CARGO_QUEUE_ENVELOPE ===" {in_e=0}
        in_e && $1 == k { sub(/^[^:]+: /,""); print; exit }
    '
}

count_cargo_starts() {
    local marker_dir="$1"
    local n=0
    if [[ -d "$marker_dir" ]]; then
        n="$(find "$marker_dir" -type f -name 'start-*' 2>/dev/null | wc -l | tr -d ' ')"
    fi
    printf '%s' "${n:-0}"
}

# Build isolated workspace + fake cargo
setup_env() {
    WORK="$(mktemp -d /tmp/cargo-queue-selftest.XXXXXX)"
    PROJECT="$WORK/project"
    QUEUE_DIR="$WORK/queue"
    FAKE_BIN="$WORK/bin"
    MARKER_DIR="$WORK/markers"
    mkdir -p "$PROJECT" "$QUEUE_DIR" "$FAKE_BIN" "$MARKER_DIR"
    printf '[package]\nname = "selftest"\nversion = "0.1.0"\nedition = "2021"\n' >"$PROJECT/Cargo.toml"
    touch "$PROJECT/Cargo.lock"

    # Fake cargo: records starts; optional sleep/exit via env
    cat >"$FAKE_BIN/cargo" <<'EOF'
#!/bin/bash
set -euo pipefail
MARKER_DIR="${CARGO_QUEUE_SELFTEST_MARKERS:?}"
ts="$(date +%s%N)"
echo "$ts" >"$MARKER_DIR/start-$ts-$$"
# optional end marker for serialization tests
sleep_s="${CARGO_QUEUE_FAKE_SLEEP:-0}"
exit_code="${CARGO_QUEUE_FAKE_EXIT:-0}"
if [[ "$sleep_s" != "0" ]]; then
    sleep "$sleep_s"
fi
echo "fake-cargo: $* exit=$exit_code" >&2
echo "$ts" >"$MARKER_DIR/end-$ts-$$"
exit "$exit_code"
EOF
    chmod +x "$FAKE_BIN/cargo"

    export PATH="$FAKE_BIN:$PATH"
    export CARGO_QUEUE_DIR="$QUEUE_DIR"
    export CARGO_QUEUE_PROJECT_ROOT="$PROJECT"
    export CARGO_QUEUE_SELFTEST_MARKERS="$MARKER_DIR"
    export CARGO_QUEUE_TIMEOUT="${CARGO_QUEUE_TIMEOUT:-30}"
    export AGENT_NAME="selftest"
    export TASK_ID="8700"
    unset CARGO_TARGET_DIR || true
    unset CARGO_QUEUE_FORCE || true
    export CARGO_QUEUE_DEDUP=1
    export CARGO_QUEUE_DEDUP_TTL_SEC=3600
    export CARGO_QUEUE_FAKE_EXIT=0
    export CARGO_QUEUE_FAKE_SLEEP=0
}

teardown_env() {
    if [[ -n "${WORK:-}" && -d "${WORK:-}" ]]; then
        rm -rf "$WORK"
    fi
}

run_q() {
    # Capture stdout+stderr and exit code without set -e abort
    set +e
    OUT="$(bash "$QUEUE_SH" "$@" 2>&1)"
    EC=$?
    set -e
}

record() {
    local id="$1" ok="$2" detail="${3:-}"
    if [[ "$ok" == "pass" ]]; then
        PASS=$((PASS + 1))
        RESULTS+=("PASS $id $detail")
        log "PASS $id $detail"
    elif [[ "$ok" == "skip" ]]; then
        SKIP=$((SKIP + 1))
        RESULTS+=("SKIP $id $detail")
        log "SKIP $id $detail"
    else
        FAIL=$((FAIL + 1))
        RESULTS+=("FAIL $id $detail")
        log "FAIL $id $detail"
        if [[ -n "${OUT:-}" ]]; then
            printf '%s\n' "$OUT" | tail -40 >&2
        fi
    fi
}

# ---- Tests ----

t0_envelope() {
    setup_env
    run_q check --lib
    if assert_contains T0 "$OUT" "=== CARGO_QUEUE_ENVELOPE ===" \
        && assert_contains T0 "$OUT" "=== END_CARGO_QUEUE_ENVELOPE ===" \
        && assert_eq T0_exit "$EC" "0"; then
        local lp rp
        lp="$(envelope_field "$OUT" "log_path")"
        rp="$(envelope_field "$OUT" "result_path")"
        if [[ -f "$lp" && -f "$rp" && "$lp" == /* && "$rp" == /* ]]; then
            record T0 pass "envelope+abs paths"
        else
            record T0 fail "paths missing or not absolute lp=$lp rp=$rp"
        fi
    else
        record T0 fail "envelope/exit"
    fi
    teardown_env
}

t1_ledger() {
    setup_env
    run_q check
    if [[ -f "$QUEUE_DIR/ledger.jsonl" ]] && grep -q fingerprint "$QUEUE_DIR/ledger.jsonl"; then
        local lines
        lines="$(wc -l <"$QUEUE_DIR/ledger.jsonl" | tr -d ' ')"
        if [[ "$lines" -ge 1 ]]; then
            record T1 pass "ledger lines=$lines"
        else
            record T1 fail "empty ledger"
        fi
    else
        record T1 fail "no ledger fingerprint"
    fi
    teardown_env
}

t2_dedup_hit_success() {
    setup_env
    run_q check --lib
    local starts1
    starts1="$(count_cargo_starts "$MARKER_DIR")"
    run_q check --lib
    local starts2 status
    starts2="$(count_cargo_starts "$MARKER_DIR")"
    status="$(envelope_field "$OUT" "status")"
    if assert_eq T2_starts "$starts2" "$starts1" \
        && assert_eq T2_exit "$EC" "0" \
        && assert_eq T2_status "$status" "dedup_hit"; then
        record T2 pass "no second cargo; dedup_hit"
    else
        record T2 fail "starts1=$starts1 starts2=$starts2 ec=$EC status=$status"
    fi
    teardown_env
}

t3_dedup_hit_failure() {
    setup_env
    export CARGO_QUEUE_FAKE_EXIT=101
    run_q test --lib
    local starts1
    starts1="$(count_cargo_starts "$MARKER_DIR")"
    run_q test --lib
    local starts2 status
    starts2="$(count_cargo_starts "$MARKER_DIR")"
    status="$(envelope_field "$OUT" "status")"
    if assert_eq T3_starts "$starts2" "$starts1" \
        && assert_eq T3_exit "$EC" "101" \
        && assert_eq T3_status "$status" "dedup_hit"; then
        record T3 pass "preserves exit 101"
    else
        record T3 fail "starts1=$starts1 starts2=$starts2 ec=$EC status=$status"
    fi
    teardown_env
}

t4_dedup_running() {
    setup_env
    export CARGO_QUEUE_FAKE_SLEEP=8
    export CARGO_QUEUE_FAKE_EXIT=0
    # Start long-running in background
    set +e
    bash "$QUEUE_SH" check --lib >"$WORK/bg.out" 2>&1 &
    BG_PID=$!
    set -e
    # Wait until FP index shows running or cargo started
    local waited=0
    while (( waited < 40 )); do
        if find "$QUEUE_DIR/fp" -name '*.json' 2>/dev/null | head -1 | grep -q .; then
            local st
            st="$(python3 -c 'import json,glob,sys; fs=glob.glob(sys.argv[1]+"/*/*.json");
print(json.load(open(fs[0])).get("status","") if fs else "")' "$QUEUE_DIR/fp" 2>/dev/null || true)"
            if [[ "$st" == "running" ]]; then
                break
            fi
        fi
        sleep 0.2
        waited=$((waited + 1))
    done
    run_q check --lib
    local status
    status="$(envelope_field "$OUT" "status")"
    # Cleanup bg
    wait "$BG_PID" 2>/dev/null || true
    if assert_eq T4_exit "$EC" "75" && assert_eq T4_status "$status" "dedup_running"; then
        record T4 pass "exit 75 while peer running"
    else
        # Acceptable race: peer finished → dedup_hit; still record fail for strict T4
        record T4 fail "ec=$EC status=$status (bg may have finished early)"
        tail -20 "$WORK/bg.out" 2>/dev/null || true
    fi
    teardown_env
}

t5_force_flag() {
    setup_env
    run_q check --lib
    local starts1
    starts1="$(count_cargo_starts "$MARKER_DIR")"
    run_q check --lib --force
    local starts2 status
    starts2="$(count_cargo_starts "$MARKER_DIR")"
    status="$(envelope_field "$OUT" "status")"
    if [[ "$starts2" -gt "$starts1" ]] && assert_eq T5_exit "$EC" "0"; then
        record T5 pass "force re-ran cargo starts=$starts1->$starts2 status=$status"
    else
        record T5 fail "starts1=$starts1 starts2=$starts2 ec=$EC status=$status"
    fi
    teardown_env
}

t6_force_env() {
    setup_env
    run_q check --lib
    local starts1
    starts1="$(count_cargo_starts "$MARKER_DIR")"
    export CARGO_QUEUE_FORCE=1
    run_q check --lib
    unset CARGO_QUEUE_FORCE
    local starts2
    starts2="$(count_cargo_starts "$MARKER_DIR")"
    if [[ "$starts2" -gt "$starts1" ]] && assert_eq T6_exit "$EC" "0"; then
        record T6 pass "CARGO_QUEUE_FORCE re-ran"
    else
        record T6 fail "starts1=$starts1 starts2=$starts2 ec=$EC"
    fi
    teardown_env
}

t7_ttl_invalidate() {
    setup_env
    export CARGO_QUEUE_DEDUP_TTL_SEC=1
    run_q check --lib
    local starts1
    starts1="$(count_cargo_starts "$MARKER_DIR")"
    sleep 2
    run_q check --lib
    local starts2 status
    starts2="$(count_cargo_starts "$MARKER_DIR")"
    status="$(envelope_field "$OUT" "status")"
    if [[ "$starts2" -gt "$starts1" ]]; then
        record T7 pass "TTL miss re-ran status=$status"
    else
        record T7 fail "starts1=$starts1 starts2=$starts2 status=$status"
    fi
    teardown_env
}

t8_manifest_invalidate() {
    setup_env
    run_q check --lib
    local starts1
    starts1="$(count_cargo_starts "$MARKER_DIR")"
    sleep 1
    touch "$PROJECT/Cargo.toml"
    run_q check --lib
    local starts2 status
    starts2="$(count_cargo_starts "$MARKER_DIR")"
    status="$(envelope_field "$OUT" "status")"
    if [[ "$starts2" -gt "$starts1" ]]; then
        record T8 pass "manifest mtime miss re-ran"
    else
        record T8 fail "starts1=$starts1 starts2=$starts2 status=$status"
    fi
    teardown_env
}

t9_serialization() {
    setup_env
    export CARGO_QUEUE_FAKE_SLEEP=2
    export CARGO_QUEUE_FORCE=1
    set +e
    bash "$QUEUE_SH" check --lib >"$WORK/a.out" 2>&1 &
    PID_A=$!
    sleep 0.3
    bash "$QUEUE_SH" check --lib >"$WORK/b.out" 2>&1 &
    PID_B=$!
    wait "$PID_A"
    wait "$PID_B"
    set -e
    # Parse start/end markers: second start should be >= first end (nanoseconds)
    local ends starts
    mapfile -t starts < <(find "$MARKER_DIR" -name 'start-*' | sort)
    mapfile -t ends < <(find "$MARKER_DIR" -name 'end-*' | sort)
    if [[ ${#starts[@]} -lt 2 || ${#ends[@]} -lt 2 ]]; then
        record T9 fail "expected 2 starts/ends got ${#starts[@]}/${#ends[@]}"
        teardown_env
        return
    fi
    # Extract ns from filenames start-NS-PID
    local s1 s2 e1
    s1="$(basename "${starts[0]}" | cut -d- -f2)"
    s2="$(basename "${starts[1]}" | cut -d- -f2)"
    # end of first finished process: min end that is still before second start OR compare ordered by start
    # Robust: max(end of run that started first) <= min(start of second)
    # Order starts by timestamp in name
    mapfile -t starts_sorted < <(find "$MARKER_DIR" -name 'start-*' -printf '%f\n' | sort -t- -k2,2n)
    mapfile -t ends_sorted < <(find "$MARKER_DIR" -name 'end-*' -printf '%f\n' | sort -t- -k2,2n)
    local first_start second_start first_end
    first_start="$(echo "${starts_sorted[0]}" | cut -d- -f2)"
    second_start="$(echo "${starts_sorted[1]}" | cut -d- -f2)"
    # Matching end for first_start: end-$first_start-*
    first_end="$(find "$MARKER_DIR" -name "end-${first_start}-*" -printf '%f\n' | head -1 | cut -d- -f2)"
    if [[ -n "$first_end" && "$second_start" -ge "$first_end" ]]; then
        record T9 pass "start2($second_start) >= end1($first_end)"
    else
        # Nanosecond comparison as strings of digits works for same width
        if [[ -n "$first_end" && "$second_start" > "$first_end" || "$second_start" == "$first_end" ]]; then
            record T9 pass "start2>=end1 string"
        else
            record T9 fail "start2=$second_start end1=$first_end (lock may have been released early)"
        fi
    fi
    teardown_env
}

t10_target_dir_fp() {
    # Target policy (post-2026-07-21): refuse custom CARGO_TARGET_DIR / --target-dir /
    # orphan target-* dirs; allow only default project-root target/.
    setup_env
    local ok=1 detail=""

    export CARGO_TARGET_DIR="$WORK/target-a"
    mkdir -p "$CARGO_TARGET_DIR"
    run_q check
    if [[ "$EC" -eq 1 && "$OUT" == *"CARGO_TARGET_DIR refused"* ]]; then
        detail+="custom_env=ok "
    else
        ok=0
        detail+="custom_env=FAIL(ec=$EC) "
    fi
    unset CARGO_TARGET_DIR || true

    run_q check --target-dir "$WORK/elsewhere"
    if [[ "$EC" -eq 1 && "$OUT" == *"--target-dir is forbidden"* ]]; then
        detail+="flag=ok "
    else
        ok=0
        detail+="flag=FAIL(ec=$EC) "
    fi

    mkdir -p "$PROJECT/target-orphan-task"
    run_q check
    if [[ "$EC" -eq 1 && "$OUT" == *"Orphan cargo target"* ]]; then
        detail+="orphan=ok "
    else
        ok=0
        detail+="orphan=FAIL(ec=$EC) "
    fi
    rm -rf "$PROJECT/target-orphan-task"

    # Explicit equal-to-default is accepted (then unset for cargo).
    export CARGO_TARGET_DIR="$PROJECT/target"
    run_q check
    if [[ "$EC" -eq 0 ]]; then
        detail+="default_env=ok"
    else
        ok=0
        detail+="default_env=FAIL(ec=$EC)"
    fi
    unset CARGO_TARGET_DIR || true

    if [[ "$ok" -eq 1 ]]; then
        record T10 pass "$detail"
    else
        record T10 fail "$detail"
    fi
    teardown_env
}

t11_dedup_disabled() {
    setup_env
    run_q check --lib
    local starts1
    starts1="$(count_cargo_starts "$MARKER_DIR")"
    export CARGO_QUEUE_DEDUP=0
    run_q check --lib
    local starts2 status
    starts2="$(count_cargo_starts "$MARKER_DIR")"
    status="$(envelope_field "$OUT" "status")"
    if [[ "$starts2" -gt "$starts1" ]]; then
        record T11 pass "DEDUP=0 re-ran status=$status"
    else
        record T11 fail "starts1=$starts1 starts2=$starts2 status=$status"
    fi
    teardown_env
}

# ---- Driver ----

ALL_TESTS=(T0 T1 T2 T3 T4 T5 T6 T7 T8 T9 T10 T11)
SELECTED=("${@:-}")
if [[ ${#SELECTED[@]} -eq 0 || -z "${SELECTED[0]:-}" ]]; then
    SELECTED=("${ALL_TESTS[@]}")
fi

log "cargo-queue selftest starting"
log "script=$QUEUE_SH"

for id in "${SELECTED[@]}"; do
    case "$id" in
        T0) t0_envelope ;;
        T1) t1_ledger ;;
        T2) t2_dedup_hit_success ;;
        T3) t3_dedup_hit_failure ;;
        T4) t4_dedup_running ;;
        T5) t5_force_flag ;;
        T6) t6_force_env ;;
        T7) t7_ttl_invalidate ;;
        T8) t8_manifest_invalidate ;;
        T9) t9_serialization ;;
        T10) t10_target_dir_fp ;;
        T11) t11_dedup_disabled ;;
        *) log "unknown test $id"; FAIL=$((FAIL+1)) ;;
    esac
done

echo ""
echo "======== SELFTEST SUMMARY ========"
for r in "${RESULTS[@]}"; do
    echo "  $r"
done
echo "PASS=$PASS FAIL=$FAIL SKIP=$SKIP"
if [[ "$FAIL" -gt 0 ]]; then
    exit 1
fi
exit 0
