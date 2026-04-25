#!/usr/bin/env sh
set -eu

CONFIG_PATH=/data/options.json

LISTEN_PORT="$(jq -r '.listen_port // 5279' "${CONFIG_PATH}")"
TARGET_HOST="$(jq -r '.target_host // ""' "${CONFIG_PATH}")"
TARGET_PORT="$(jq -r '.target_port // 5279' "${CONFIG_PATH}")"

if [ -z "${TARGET_HOST}" ] || [ "${TARGET_HOST}" = "null" ]; then
    echo "[ERROR] target_host must be set in the add-on configuration."
    exit 1
fi

echo "[INFO] Forwarding TCP ${LISTEN_PORT} to ${TARGET_HOST}:${TARGET_PORT}"
exec socat -d -d "TCP-LISTEN:${LISTEN_PORT},fork,reuseaddr" "TCP:${TARGET_HOST}:${TARGET_PORT}"
