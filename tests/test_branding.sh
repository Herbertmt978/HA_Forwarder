#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPOSITORY_CONFIG="${ROOT_DIR}/repository.yaml"
APP_CONFIG="${ROOT_DIR}/ha_forwarder/config.yaml"
DOCKERFILE="${ROOT_DIR}/ha_forwarder/Dockerfile"
ROOT_README="${ROOT_DIR}/README.md"
APP_README="${ROOT_DIR}/ha_forwarder/README.md"

failures=0

record_failure() {
    printf 'FAIL: %s\n' "${1}" >&2
    failures=$((failures + 1))
}

assert_equal() {
    local label="${1}"
    local expected="${2}"
    local actual="${3}"

    [[ "${actual}" == "${expected}" ]] ||
        record_failure "${label}: expected '${expected}', got '${actual}'"
}

top_level_yaml_value() {
    local path="${1}"
    local key="${2}"

    awk -v expected_key="${key}" '
        /^[^[:space:]#]/ {
            separator = index($0, ":")
            if (separator == 0 || substr($0, 1, separator - 1) != expected_key) {
                next
            }

            value = substr($0, separator + 1)
            sub(/^[[:space:]]*/, "", value)
            sub(/[[:space:]]*$/, "", value)
            print value
            exit
        }
    ' "${path}"
}

yaml_section_value() {
    local path="${1}"
    local section="${2}"
    local key="${3}"

    awk -v expected_section="${section}" -v expected_key="${key}" '
        /^[^[:space:]#]/ {
            separator = index($0, ":")
            current_section = substr($0, 1, separator - 1)
            in_section = separator > 0 && current_section == expected_section
            next
        }

        in_section && /^[[:space:]]+[^[:space:]#]/ {
            entry = $0
            sub(/^[[:space:]]*/, "", entry)
            separator = index(entry, ":")
            if (separator == 0 || substr(entry, 1, separator - 1) != expected_key) {
                next
            }

            value = substr(entry, separator + 1)
            sub(/^[[:space:]]*/, "", value)
            sub(/[[:space:]]*$/, "", value)
            print value
            exit
        }
    ' "${path}"
}

docker_label_value() {
    local path="${1}"
    local key="${2}"

    awk -v expected_key="${key}" '
        {
            line = $0
            sub(/^[[:space:]]*/, "", line)
            prefix = expected_key "=\""
            if (index(line, prefix) != 1) {
                next
            }

            value = substr(line, length(prefix) + 1)
            closing_quote = index(value, "\"")
            print substr(value, 1, closing_quote - 1)
            exit
        }
    ' "${path}"
}

first_markdown_line() {
    local path="${1}"
    local pattern="${2}"

    awk -v pattern="${pattern}" '$0 ~ pattern { print; exit }' "${path}"
}

approved_description='Forward device TCP connections through Home Assistant to another host.'
repository_url='https://github.com/Herbertmt978/HA_Forwarder'

assert_equal \
    'repository.yaml name' \
    'TCP Relay for Home Assistant' \
    "$(top_level_yaml_value "${REPOSITORY_CONFIG}" name)"
assert_equal \
    'repository.yaml url' \
    "${repository_url}" \
    "$(top_level_yaml_value "${REPOSITORY_CONFIG}" url)"

assert_equal \
    'ha_forwarder/config.yaml name' \
    'TCP Relay' \
    "$(top_level_yaml_value "${APP_CONFIG}" name)"
assert_equal \
    'ha_forwarder/config.yaml version' \
    '"0.3.2"' \
    "$(top_level_yaml_value "${APP_CONFIG}" version)"
assert_equal \
    'ha_forwarder/config.yaml slug' \
    'ha_forwarder' \
    "$(top_level_yaml_value "${APP_CONFIG}" slug)"
assert_equal \
    'ha_forwarder/config.yaml description' \
    "${approved_description}" \
    "$(top_level_yaml_value "${APP_CONFIG}" description)"
assert_equal \
    'ha_forwarder/config.yaml url' \
    "${repository_url}/tree/main/ha_forwarder" \
    "$(top_level_yaml_value "${APP_CONFIG}" url)"
assert_equal \
    'ha_forwarder/config.yaml listener label' \
    'TCP Relay listener' \
    "$(yaml_section_value "${APP_CONFIG}" ports_description '5279/tcp')"

assert_equal \
    'Docker OCI title' \
    'Home Assistant App: TCP Relay' \
    "$(docker_label_value "${DOCKERFILE}" org.opencontainers.image.title)"
assert_equal \
    'Docker OCI description' \
    "${approved_description}" \
    "$(docker_label_value "${DOCKERFILE}" org.opencontainers.image.description)"
assert_equal \
    'Docker OCI source' \
    "${repository_url}" \
    "$(docker_label_value "${DOCKERFILE}" org.opencontainers.image.source)"

assert_equal \
    'root README title' \
    '# TCP Relay for Home Assistant' \
    "$(first_markdown_line "${ROOT_README}" '^# ')"
assert_equal \
    'root README tagline' \
    "**${approved_description}**" \
    "$(first_markdown_line "${ROOT_README}" '^\\*\\*.*\\*\\*$')"

assert_equal \
    'App README title' \
    '# Home Assistant App: TCP Relay' \
    "$(first_markdown_line "${APP_README}" '^# ')"
assert_equal \
    'App README tagline' \
    "_${approved_description}_" \
    "$(first_markdown_line "${APP_README}" '^_.*_$')"

[[ "${failures}" -eq 0 ]] || exit 1

printf 'All branding contract tests passed.\n'
