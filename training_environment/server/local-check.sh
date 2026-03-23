#!/bin/bash
# =============================================================================
# local-check.sh - Connectivity test for local Docker Compose environment
# Runs against localhost to verify all services are working
# Usage: ./local-check.sh
# =============================================================================

set -euo pipefail

# --- Load .env ---------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ ! -f "${SCRIPT_DIR}/.env" ]; then
  echo -e "\033[0;31m[FAIL]\033[0m .env not found. Copy .env.example to .env and fill in values"
  exit 1
fi
set -a
source "${SCRIPT_DIR}/.env"
set +a

# --- Validate .env variables ------------------------------------------------
for var in MYSQL_ROOT_PASSWORD MYSQL_USER MYSQL_PASSWORD \
           SSH_USER SSH_PASSWORD HTTP_PORT SSH_PORT MARIADB_PORT PMA_PORT; do
  if [ -z "${!var:-}" ]; then
    echo -e "\033[0;31m[FAIL]\033[0m ${var} is not set in .env"
    exit 1
  fi
done

# --- Configuration -----------------------------------------------------------
HOST="localhost"
TIMEOUT=5

# --- Colors ------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS="${GREEN}[PASS]${NC}"
FAIL="${RED}[FAIL]${NC}"
INFO="${YELLOW}[INFO]${NC}"

# --- Helpers -----------------------------------------------------------------
require_cmd() {
  if ! command -v "$1" &>/dev/null; then
    echo -e "${FAIL} Required command not found: $1"
    exit 1
  fi
}

print_header() {
  echo ""
  echo "============================================="
  echo " $1"
  echo "============================================="
}

# --- Docker Compose command --------------------------------------------------
DC="docker compose -f ${SCRIPT_DIR}/vm/docker-compose.yml --env-file ${SCRIPT_DIR}/.env"

# --- Dependency check --------------------------------------------------------
print_header "Checking required commands"
require_cmd curl
require_cmd nc
require_cmd ssh
echo -e "${PASS} All required commands are available"

# =============================================================================
# 1. Apache / HTTP check
# =============================================================================
print_header "1. Apache HTTP (port $HTTP_PORT)"

HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" \
  --max-time "$TIMEOUT" "http://${HOST}:${HTTP_PORT}" || echo "000")

if [[ "$HTTP_STATUS" =~ ^(200|301|302|403)$ ]]; then
  echo -e "${PASS} Apache is responding (HTTP $HTTP_STATUS)"
else
  echo -e "${FAIL} Apache is not responding (HTTP $HTTP_STATUS)"
  echo -e "${INFO} Check: $DC logs apache"
fi

# =============================================================================
# 2. PHP operation check (via HTTP)
# =============================================================================
print_header "2. PHP Operation"

PHP_RESPONSE=$(curl -o /dev/null -s -w "%{http_code}" \
  --max-time "$TIMEOUT" "http://${HOST}:${HTTP_PORT}/phpinfo.php" || echo "000")

if [[ "$PHP_RESPONSE" == "200" ]]; then
  echo -e "${PASS} phpinfo endpoint responded (HTTP 200)"
elif [[ "$PHP_RESPONSE" == "404" ]]; then
  echo -e "${INFO} phpinfo endpoint not found (HTTP 404) — Apache is up but phpinfo.php is missing"
else
  echo -e "${FAIL} PHP check failed (HTTP $PHP_RESPONSE)"
fi

# =============================================================================
# 3. SSH port check
# =============================================================================
print_header "3. SSH Port ($SSH_PORT)"

if nc -z -w "$TIMEOUT" "$HOST" "$SSH_PORT" 2>/dev/null; then
  echo -e "${PASS} SSH port $SSH_PORT is open"

  # Attempt SSH banner grab to confirm OpenSSH
  BANNER=$(ssh -o ConnectTimeout="$TIMEOUT" \
               -o StrictHostKeyChecking=no \
               -o UserKnownHostsFile=/dev/null \
               -o BatchMode=yes \
               -p "$SSH_PORT" \
               "${SSH_USER}@${HOST}" exit 2>&1 || true)

  if echo "$BANNER" | grep -qi "openssh\|permission denied\|publickey\|password"; then
    echo -e "${PASS} SSH server is responding (OpenSSH confirmed)"
  else
    echo -e "${INFO} SSH port open but banner unrecognised — may still be starting up"
  fi

  # Verify SSH password login
  if command -v sshpass &>/dev/null; then
    if sshpass -p "${SSH_PASSWORD}" ssh -o ConnectTimeout="$TIMEOUT" \
         -o StrictHostKeyChecking=no \
         -o UserKnownHostsFile=/dev/null \
         -p "$SSH_PORT" \
         "${SSH_USER}@${HOST}" exit 2>/dev/null; then
      echo -e "${PASS} SSH login successful (user: ${SSH_USER})"
    else
      echo -e "${FAIL} SSH login failed (user: ${SSH_USER})"
    fi
  else
    echo -e "${INFO} sshpass not installed — skipping SSH login test"
  fi
else
  echo -e "${FAIL} SSH port $SSH_PORT is not reachable"
  echo -e "${INFO} Check: $DC logs ssh"
fi

# =============================================================================
# 4. MariaDB port check
# =============================================================================
print_header "4. MariaDB (port $MARIADB_PORT)"

if nc -z -w "$TIMEOUT" "$HOST" "$MARIADB_PORT" 2>/dev/null; then
  echo -e "${PASS} MariaDB port $MARIADB_PORT is open"

  # Verify login with MYSQL_USER credentials
  if docker exec mariadb mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1;" &>/dev/null; then
    echo -e "${PASS} MariaDB login successful (user: ${MYSQL_USER})"
  else
    echo -e "${FAIL} MariaDB login failed (user: ${MYSQL_USER})"
  fi

  # Verify databases exist
  DB_COUNT=$(docker exec mariadb mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" -N -e "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name LIKE '${MYSQL_USER}_%';" 2>/dev/null || echo "0")
  if [ "$DB_COUNT" -ge 20 ]; then
    echo -e "${PASS} Databases found: ${DB_COUNT} (${MYSQL_USER}_01 ~ ${MYSQL_USER}_20)"
  else
    echo -e "${FAIL} Expected 20 databases, found: ${DB_COUNT}"
  fi
else
  echo -e "${FAIL} MariaDB port $MARIADB_PORT is not reachable"
  echo -e "${INFO} Check: $DC logs mariadb"
fi

# =============================================================================
# 5. phpMyAdmin check
# =============================================================================
print_header "5. phpMyAdmin (port $PMA_PORT)"

PMA_STATUS=$(curl -o /dev/null -s -w "%{http_code}" \
  --max-time "$TIMEOUT" "http://${HOST}:${PMA_PORT}" || echo "000")

if [[ "$PMA_STATUS" =~ ^(200|301|302)$ ]]; then
  echo -e "${PASS} phpMyAdmin is responding (HTTP $PMA_STATUS)"
else
  echo -e "${FAIL} phpMyAdmin is not responding (HTTP $PMA_STATUS)"
  echo -e "${INFO} Check: $DC logs phpmyadmin"
fi

# =============================================================================
# 6. PHP-to-MariaDB connection
# =============================================================================
print_header "6. PHP-to-MariaDB Connection"

PHP_DB_CHECK=$(docker exec apache_php php -r "
try {
    new PDO('mysql:host=mariadb;port=3306;dbname=${MYSQL_USER}_01', '${MYSQL_USER}', '${MYSQL_PASSWORD}');
    echo 'ok';
} catch (Exception \$e) {
    echo 'fail';
}
" 2>/dev/null || echo "fail")

if [ "$PHP_DB_CHECK" = "ok" ]; then
  echo -e "${PASS} PHP can connect to MariaDB (${MYSQL_USER}_01)"
else
  echo -e "${FAIL} PHP cannot connect to MariaDB"
fi

# =============================================================================
# 7. Timezone
# =============================================================================
print_header "7. Timezone"

for container in apache_php mariadb ssh_server; do
  CTZ=$(docker exec "$container" date '+%Z' 2>/dev/null || echo "unknown")
  if [ "$CTZ" = "UTC" ]; then
    echo -e "${PASS} ${container}: UTC"
  else
    echo -e "${FAIL} ${container}: ${CTZ} (expected UTC)"
  fi
done

# =============================================================================
# Summary
# =============================================================================
print_header "Check Complete"
echo -e "Environment : local Docker Compose"
echo -e "Timestamp   : $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo -e "${INFO} View logs: $DC logs -f"
echo ""
