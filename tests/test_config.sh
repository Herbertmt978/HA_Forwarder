#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_PATH="${ROOT_DIR}/ha_forwarder/config.yaml"
APPARMOR_PATH="${ROOT_DIR}/ha_forwarder/apparmor.txt"

fail() {
    printf 'FAIL: %s\n' "${1}" >&2
    exit 1
}

failures=0
record_failure() {
    printf 'FAIL: %s\n' "${1}" >&2
    failures=$((failures + 1))
}

top_level_boolean() {
    local config_path="${2:-${CONFIG_PATH}}"

    awk -v key="${1}:" '
        /^[^[:space:]#]/ && $1 == key {
            value = tolower($2)
            if (value ~ /^(true|yes|on|1)$/) {
                print "true"
            } else if (value ~ /^(false|no|off|0)$/) {
                print "false"
            } else {
                print value
            }
            exit
        }
    ' "${config_path}"
}

for boolean_alias in true TRUE yes Yes on ON 1; do
    normalized="$(
        printf 'probe: %s\n' "${boolean_alias}" |
            top_level_boolean probe -
    )"
    [[ "${normalized}" == "true" ]] ||
        record_failure "truthy YAML alias '${boolean_alias}' normalized to '${normalized}'"
done

for boolean_alias in false FALSE no No off OFF 0; do
    normalized="$(
        printf 'probe: %s\n' "${boolean_alias}" |
            top_level_boolean probe -
    )"
    [[ "${normalized}" == "false" ]] ||
        record_failure "falsey YAML alias '${boolean_alias}' normalized to '${normalized}'"
done

host_network="$(top_level_boolean host_network)"
[[ "${host_network}" != "true" ]] ||
    record_failure "host_network must not be enabled"

mapped_port="$(
    awk '
        /^ports:[[:space:]]*($|#)/ { in_ports = 1; next }
        in_ports && /^[^[:space:]#]/ { exit }
        in_ports && $1 == "5279/tcp:" { print $2; exit }
    ' "${CONFIG_PATH}"
)"
[[ "${mapped_port}" == "5279" ]] ||
    record_failure "ports must map container 5279/tcp to host port 5279; got '${mapped_port}'"

for high_risk_flag in full_access docker_api host_pid host_uts; do
    high_risk_value="$(top_level_boolean "${high_risk_flag}")"
    [[ "${high_risk_value}" != "true" ]] ||
        record_failure "${high_risk_flag} must not be enabled"
done

[[ -s "${APPARMOR_PATH}" ]] ||
    record_failure "custom AppArmor profile must remain at ${APPARMOR_PATH}"

apparmor="$(top_level_boolean apparmor)"
[[ "${apparmor}" != "false" ]] ||
    record_failure "custom AppArmor profile must not be disabled"

[[ "${failures}" -eq 0 ]] || exit 1

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
