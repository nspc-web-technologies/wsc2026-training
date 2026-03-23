#!/bin/bash
# =============================================================================
# local-setup.sh - Start training environment with local Docker Compose
# Builds and starts all containers (Apache+PHP, MariaDB, SSH)
# Requires: .env (copy from .env.example and fill in values)
# Usage: ./local-setup.sh
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Load .env ---------------------------------------------------------------
if [ ! -f "${SCRIPT_DIR}/.env" ]; then
  echo "ERROR: .env not found. Copy .env.example to .env and fill in values"
  exit 1
fi
set -a
source "${SCRIPT_DIR}/.env"
set +a

# --- Validate .env variables ------------------------------------------------
for var in MYSQL_ROOT_PASSWORD MYSQL_USER MYSQL_PASSWORD \
           SSH_USER SSH_PASSWORD HTTP_PORT SSH_PORT MARIADB_PORT PMA_PORT; do
  if [ -z "${!var:-}" ]; then
    echo "ERROR: ${var} is not set in .env"
    exit 1
  fi
done

# --- Check dependencies ------------------------------------------------------
if ! command -v docker &>/dev/null; then
  echo "ERROR: docker is not installed"
  exit 1
fi

if ! docker compose version &>/dev/null; then
  echo "ERROR: docker compose plugin is not available"
  exit 1
fi

# --- Colors ------------------------------------------------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
INFO="${YELLOW}[INFO]${NC}"
DONE="${GREEN}[DONE]${NC}"

# --- Docker Compose command --------------------------------------------------
DC="docker compose -f ${SCRIPT_DIR}/vm/docker-compose.yml --env-file ${SCRIPT_DIR}/.env"

# --- Helpers -----------------------------------------------------------------
print_header() {
  echo ""
  echo "============================================="
  echo " $1"
  echo "============================================="
}

# =============================================================================
# 1. Build and start containers
# =============================================================================
print_header "Starting Docker Compose"
echo -e "${INFO} Building and starting containers..."
$DC up -d --build
echo -e "${DONE} Containers started"

# =============================================================================
# 2. Wait for healthy status
# =============================================================================
print_header "Waiting for containers to be healthy"
MAX_WAIT=60
INTERVAL=5
ELAPSED=0

while [ $ELAPSED -lt $MAX_WAIT ]; do
  UNHEALTHY=$($DC ps -q | xargs docker inspect --format '{{.State.Health.Status}}' 2>/dev/null | grep -c 'unhealthy\|starting' || true)
  RUNNING=$($DC ps -q | xargs docker inspect --format '{{.State.Status}}' 2>/dev/null | grep -c 'running' || true)

  if [ "$RUNNING" -ge 4 ] && [ "$UNHEALTHY" -eq 0 ]; then
    echo -e "${DONE} All containers are healthy"
    break
  fi

  echo -e "${INFO} Waiting... (${ELAPSED}s / ${MAX_WAIT}s)"
  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
  echo -e "${INFO} Timeout reached — some containers may still be starting"
fi

# =============================================================================
# 3. Show container status
# =============================================================================
print_header "Container Status"
$DC ps

# =============================================================================
# 4. Connection summary
# =============================================================================
print_header "Setup Complete"
echo "HTTP           : http://localhost:${HTTP_PORT}"
echo "phpMyAdmin     : http://localhost:${PMA_PORT}"
echo "SSH            : ssh -p ${SSH_PORT} ${SSH_USER}@localhost"
echo "MariaDB        : localhost:${MARIADB_PORT}"
echo ""
echo "Run verification:"
echo "  ./local-check.sh"
