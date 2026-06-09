#!/bin/bash
#
# audit-sqlite-abolition.sh — Compatibility launcher for the authoritative scanner
#
# Usage: bash .agents/rules/scripts/audit-sqlite-abolition.sh [--verbose]
#
# Exit codes:
#   0 — No forbidden runtime SQLite references found
#   1 — Forbidden runtime SQLite references detected
#
# The authoritative implementation is OmniRoute/scripts/sqlite-abolition-scanner.ts.
# Keep this stable shell entry point for local reviewer ergonomics only.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

exec npx --yes tsx "$REPO_ROOT/OmniRoute/scripts/sqlite-abolition-scanner.ts" "$REPO_ROOT" "$@"
