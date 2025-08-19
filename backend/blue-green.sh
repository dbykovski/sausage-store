#!/usr/bin/env bash
set -euo pipefail

# Usage: ./blue-green.sh [VERSION]
COMPOSE_FILE="docker-compose-backend.yml"
SERVICE_BASE="sausage-store-backend"
SERVICE="backend"
TIMEOUT_SEC=120
SLEEP_SEC=2

# версия (аргумент или переменная окружения)
if [[ ${1-} != "" ]]; then
  VERSION="$1"
fi
if [[ -z "${VERSION-}" ]]; then
  echo "VERSION is not set. Pass it as an argument or export VERSION."
  exit 1
fi
echo "[i] Using VERSION=${VERSION}"

is_running() {
  docker ps --filter "name=${1}$" --format '{{.Names}}' | grep -q "${1}"
}

health_status() {
  docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$1" 2>/dev/null || echo "unknown"
}

# Определяем active (предпочитаем healthy)
active=""
hb=""
hg=""
if is_running "${SERVICE_BASE}-blue"; then hb=$(health_status "${SERVICE_BASE}-blue"); fi
if is_running "${SERVICE_BASE}-green"; then hg=$(health_status "${SERVICE_BASE}-green"); fi

if [[ "${hg}" == "healthy" && "${hb}" != "healthy" ]]; then
  active="green"
elif [[ "${hb}" == "healthy" && "${hg}" != "healthy" ]]; then
  active="blue"
elif [[ -n "${hg}" && -z "${hb}" ]]; then
  active="green"
elif [[ -n "${hb}" && -z "${hg}" ]]; then
  active="blue"
else
  active=""  # ни один не работает или оба нездоровы — будем разворачивать default target
fi

target="blue"
if [[ "${active}" == "blue" ]]; then target="green"; fi
echo "[i] Active: ${active:-none}, Target: ${target}"

CNAME="${SERVICE_BASE}-${target}"

# Останавливаем/удаляем старую цель (если есть)
if is_running "${CNAME}"; then
  echo "[i] Stopping old target ${CNAME}..."
  docker compose -f "$COMPOSE_FILE" stop "${SERVICE}-${target}" || true
  docker rm -f "${CNAME}" || true
fi

echo "[i] Pulling image for ${SERVICE}-${target}..."
docker compose -f "$COMPOSE_FILE" pull "${SERVICE}-${target}"

echo "[i] Starting ${SERVICE}-${target}..."
docker compose -f "$COMPOSE_FILE" up -d "${SERVICE}-${target}"

# Ждём healthy
echo -n "[i] Waiting for ${CNAME} to become healthy"
elapsed=0
while (( elapsed < TIMEOUT_SEC )); do
  status=$(health_status "${CNAME}" | tr -d '\r')
  if [[ "${status}" == "healthy" ]]; then
    echo -e "\n[i] ${CNAME} is healthy."
    break
  fi
  sleep "$SLEEP_SEC"
  elapsed=$(( elapsed + SLEEP_SEC ))
  echo -n "."
done

if (( elapsed >= TIMEOUT_SEC )); then
  echo -e "\n[!] ${CNAME} did not become healthy within ${TIMEOUT_SEC}s. Showing logs and aborting."
  docker logs "${CNAME}" || true
  exit 2
fi

# Останавливаем предыдущий active (если был)
if [[ -n "${active}" ]]; then
  echo "[i] Stopping previously active ${SERVICE_BASE}-${active}..."
  docker compose -f "$COMPOSE_FILE" stop "${SERVICE}-${active}" || true
fi

echo "[✓] Blue-green deployment complete. Active is now: ${target}"