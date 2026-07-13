#!/bin/sh
set -eu

CONFIG_PATH="${CONFIG_PATH:-/data/options.json}"
LISTEN_PORT=5279

fail() {
    printf '[ERROR] %s\n' "${1}" >&2
    exit 1
}

validate_integer_range() {
    case "${2}" in
        "" | *[!0-9]*)
            fail "${1} must be an integer between ${3} and ${4}."
            ;;
    esac

    if [ "${2}" -lt "${3}" ] || [ "${2}" -gt "${4}" ]; then
        fail "${1} must be between ${3} and ${4}."
    fi
}

if [ ! -r "${CONFIG_PATH}" ]; then
    fail "Configuration file ${CONFIG_PATH} is not readable."
fi

if ! TARGET_HOST="$(jq -er '.target_host // ""' "${CONFIG_PATH}")"; then
    fail "Unable to read target_host from ${CONFIG_PATH}."
fi
if ! TARGET_PORT="$(jq -er '.target_port // 5279' "${CONFIG_PATH}")"; then
    fail "Unable to read target_port from ${CONFIG_PATH}."
fi
if ! MAX_CONNECTIONS="$(jq -er '.max_connections // 64' "${CONFIG_PATH}")"; then
    fail "Unable to read max_connections from ${CONFIG_PATH}."
fi
if ! CONNECT_TIMEOUT="$(jq -er '.connect_timeout // 15' "${CONFIG_PATH}")"; then
    fail "Unable to read connect_timeout from ${CONFIG_PATH}."
fi

case "${TARGET_HOST}" in
    "" | "null")
        fail "target_host must be set in the app configuration."
        ;;
    *[[:space:]]* | *,*)
        fail "target_host must not contain whitespace or commas."
        ;;
esac

validate_integer_range "target_port" "${TARGET_PORT}" 1 65535
validate_integer_range "max_connections" "${MAX_CONNECTIONS}" 1 256
validate_integer_range "connect_timeout" "${CONNECT_TIMEOUT}" 1 300

NORMALIZED_TARGET_HOST="$(printf '%s' "${TARGET_HOST}" | tr '[:upper:]' '[:lower:]')"
if [ "${LISTEN_PORT}" = "${TARGET_PORT}" ]; then
    case "${NORMALIZED_TARGET_HOST}" in
        "localhost" | "localhost." | "localhost.localdomain" | "localhost.localdomain." | "0.0.0.0" | 127.* | "::1" | "[::1]")
            fail "target_host and target_port would forward the listener back to itself."
            ;;
    esac
fi

SOCAT_TARGET_HOST="${TARGET_HOST}"
case "${SOCAT_TARGET_HOST}" in
    *:*)
        case "${SOCAT_TARGET_HOST}" in
            "["*"]") ;;
            *) SOCAT_TARGET_HOST="[${SOCAT_TARGET_HOST}]" ;;
        esac
        ;;
esac

printf '[INFO] Forwarding TCP %s to %s:%s (max %s connections, %ss connect timeout)\n' \
    "${LISTEN_PORT}" \
    "${TARGET_HOST}" \
    "${TARGET_PORT}" \
    "${MAX_CONNECTIONS}" \
    "${CONNECT_TIMEOUT}"

exec socat -d -d \
    "TCP-LISTEN:${LISTEN_PORT},fork,reuseaddr,max-children=${MAX_CONNECTIONS}" \
    "TCP:${SOCAT_TARGET_HOST}:${TARGET_PORT},connect-timeout=${CONNECT_TIMEOUT}"
