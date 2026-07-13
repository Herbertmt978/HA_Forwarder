#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_SCRIPT="${ROOT_DIR}/ha_forwarder/run.sh"
TEST_DIR="$(mktemp -d)"
FAKE_BIN="${TEST_DIR}/bin"

cleanup() {
    rm -rf "${TEST_DIR}"
}
trap cleanup EXIT

fail() {
    printf 'FAIL: %s\n' "${1}" >&2
    exit 1
}

assert_contains() {
    local actual="${1}"
    local expected="${2}"

    [[ "${actual}" == *"${expected}"* ]] ||
        fail "expected output to contain: ${expected}"
}

mkdir -p "${FAKE_BIN}"
cat >"${FAKE_BIN}/socat" <<'EOF'
#!/bin/sh
set -eu
: "${SOCAT_ARGS_FILE:?}"
printf '%s\n' "$@" >"${SOCAT_ARGS_FILE}"
EOF
chmod 0755 "${FAKE_BIN}/socat"

run_success() {
    local name="${1}"
    local json="${2}"
    local expected_log="${3}"
    local expected_listener="${4}"
    local expected_target="${5}"
    local options_file="${TEST_DIR}/${name}.json"
    local args_file="${TEST_DIR}/${name}.args"
    local output
    local -a args

    printf '%s\n' "${json}" >"${options_file}"
    output="$(
        PATH="${FAKE_BIN}:${PATH}" \
            CONFIG_PATH="${options_file}" \
            SOCAT_ARGS_FILE="${args_file}" \
            "${RUN_SCRIPT}" 2>&1
    )"

    assert_contains "${output}" "${expected_log}"
    mapfile -t args <"${args_file}"
    [[ "${#args[@]}" -eq 4 ]] || fail "${name}: expected four socat arguments"
    [[ "${args[0]}" == "-d" && "${args[1]}" == "-d" ]] ||
        fail "${name}: expected socat debug flags"
    [[ "${args[2]}" == "${expected_listener}" ]] ||
        fail "${name}: unexpected listener argument: ${args[2]}"
    [[ "${args[3]}" == "${expected_target}" ]] ||
        fail "${name}: unexpected target argument: ${args[3]}"
}

expect_failure() {
    local name="${1}"
    local json="${2}"
    local expected_error="${3}"
    local options_file="${TEST_DIR}/${name}.json"
    local args_file="${TEST_DIR}/${name}.args"
    local output

    printf '%s\n' "${json}" >"${options_file}"
    if output="$(
        PATH="${FAKE_BIN}:${PATH}" \
            CONFIG_PATH="${options_file}" \
            SOCAT_ARGS_FILE="${args_file}" \
            "${RUN_SCRIPT}" 2>&1
    )"; then
        fail "${name}: expected run.sh to fail"
    fi

    assert_contains "${output}" "${expected_error}"
    [[ ! -e "${args_file}" ]] || fail "${name}: socat should not have started"
}

run_success \
    "configured" \
    '{"listen_port":1234,"target_host":"example.local","target_port":5678,"max_connections":12,"connect_timeout":9}' \
    "[INFO] Forwarding TCP 5279 to example.local:5678 (max 12 connections, 9s connect timeout)" \
    "TCP-LISTEN:5279,fork,reuseaddr,max-children=12" \
    "TCP:example.local:5678,connect-timeout=9"

run_success \
    "defaults" \
    '{"target_host":"example.local"}' \
    "[INFO] Forwarding TCP 5279 to example.local:5279 (max 64 connections, 15s connect timeout)" \
    "TCP-LISTEN:5279,fork,reuseaddr,max-children=64" \
    "TCP:example.local:5279,connect-timeout=15"

run_success \
    "absolute-hostname" \
    '{"target_host":"example.local."}' \
    "[INFO] Forwarding TCP 5279 to example.local.:5279 (max 64 connections, 15s connect timeout)" \
    "TCP-LISTEN:5279,fork,reuseaddr,max-children=64" \
    "TCP:example.local.:5279,connect-timeout=15"

run_success \
    "absolute-localhost-different-port" \
    '{"target_host":"localhost.","target_port":5280}' \
    "[INFO] Forwarding TCP 5279 to localhost.:5280 (max 64 connections, 15s connect timeout)" \
    "TCP-LISTEN:5279,fork,reuseaddr,max-children=64" \
    "TCP:localhost.:5280,connect-timeout=15"

run_success \
    "ipv6-target" \
    '{"listen_port":5279,"target_host":"2001:db8::10","target_port":6000}' \
    "[INFO] Forwarding TCP 5279 to 2001:db8::10:6000" \
    "TCP-LISTEN:5279,fork,reuseaddr,max-children=64" \
    "TCP:[2001:db8::10]:6000,connect-timeout=15"

expect_failure \
    "missing-target" \
    '{"target_host":null}' \
    "target_host must be set"

expect_failure \
    "invalid-limit" \
    '{"target_host":"example.local","max_connections":0}' \
    "max_connections must be between 1 and 256"

expect_failure \
    "socat-options" \
    '{"target_host":"example.local,bind=127.0.0.1"}' \
    "target_host must not contain whitespace or commas"

expect_failure \
    "self-loop" \
    '{"listen_port":5279,"target_host":"LOCALHOST","target_port":5279}' \
    "would forward the listener back to itself"

expect_failure \
    "absolute-localhost-self-loop" \
    '{"target_host":"localhost.","target_port":5279}' \
    "would forward the listener back to itself"

expect_failure \
    "absolute-localdomain-self-loop" \
    '{"target_host":"LOCALHOST.LOCALDOMAIN.","target_port":5279}' \
    "would forward the listener back to itself"

printf 'All run.sh tests passed.\n'
