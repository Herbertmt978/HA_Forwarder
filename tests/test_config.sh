#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_PATH="${ROOT_DIR}/ha_forwarder/config.yaml"

fail() {
    printf 'FAIL: %s\n' "${1}" >&2
    exit 1
}

target_host_schema="$(
    awk '
        /^schema:$/ { in_schema = 1; next }
        in_schema && $1 == "target_host:" { print $2; exit }
    ' "${CONFIG_PATH}"
)"

# Supervisor 2026.06.2 applies numeric Range validation to str(min,max),
# causing valid hostnames and IP addresses to fail option validation.
[[ "${target_host_schema}" == "str" ]] ||
    fail "target_host schema must be 'str' for current Supervisor compatibility; got '${target_host_schema}'"

printf 'All config compatibility tests passed.\n'
