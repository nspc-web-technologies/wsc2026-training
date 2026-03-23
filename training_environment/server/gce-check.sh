#!/bin/bash
# =============================================================================
# gce-check.sh - Post-deployment connectivity test script
# Runs from local machine against a GCP VM running Docker Compose
# Usage: ./gce-check.sh <VM_EXTERNAL_IP>
# =============================================================================

set -euo pipefail

# --- Load .env if present ----------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "${SCRIPT_DIR}/.env" ]; then
  set -a
  source "${SCRIPT_DIR}/.env"
  set +a
fi

# --- Configuration -----------------------------------------------------------
VM_IP="${1:-}"
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

# --- Argument check ----------------------------------------------------------
if [[ -z "$VM_IP" ]]; then
  echo -e "${FAIL} Usage: $0 <VM_EXTERNAL_IP>"
  echo "  Example: $0 34.123.45.67"
  exit 1
fi

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
  --max-time "$TIMEOUT" "http://${VM_IP}:${HTTP_PORT}" || echo "000")

if [[ "$HTTP_STATUS" =~ ^(200|301|302|403)$ ]]; then
  echo -e "${PASS} Apache is responding (HTTP $HTTP_STATUS)"
else
  echo -e "${FAIL} Apache is not responding (HTTP $HTTP_STATUS)"
  echo -e "${INFO} Check: docker compose logs apache"
fi

# =============================================================================
# 2. PHP operation check (via HTTP)
# =============================================================================
print_header "2. PHP Operation"

# Create a temporary phpinfo endpoint check via curl
PHP_RESPONSE=$(curl -o /dev/null -s -w "%{http_code}" \
  --max-time "$TIMEOUT" "http://${VM_IP}:${HTTP_PORT}/phpinfo.php" || echo "000")

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

if nc -z -w "$TIMEOUT" "$VM_IP" "$SSH_PORT" 2>/dev/null; then
  echo -e "${PASS} SSH port $SSH_PORT is open"

  # Attempt SSH banner grab to confirm OpenSSH
  BANNER=$(ssh -o ConnectTimeout="$TIMEOUT" \
               -o StrictHostKeyChecking=no \
               -o UserKnownHostsFile=/dev/null \
               -o BatchMode=yes \
               -p "$SSH_PORT" \
               "${SSH_USER}@${VM_IP}" exit 2>&1 || true)

  if echo "$BANNER" | grep -qi "openssh\|permission denied\|publickey\|password"; then
    echo -e "${PASS} SSH server is responding (OpenSSH confirmed)"
  else
    echo -e "${INFO} SSH port open but banner unrecognised — may still be starting up"
  fi
else
  echo -e "${FAIL} SSH port $SSH_PORT is not reachable"
  echo -e "${INFO} Check GCP firewall rule: ${GCP_VM_NAME}-allow-ssh"
  echo -e "${INFO} Check: docker compose logs ssh"
fi

# =============================================================================
# 4. MariaDB port check
# =============================================================================
print_header "4. MariaDB (port $MARIADB_PORT)"

if nc -z -w "$TIMEOUT" "$VM_IP" "$MARIADB_PORT" 2>/dev/null; then
  echo -e "${PASS} MariaDB port $MARIADB_PORT is open"
else
  echo -e "${FAIL} MariaDB port $MARIADB_PORT is not reachable"
  echo -e "${INFO} Check GCP firewall rule: ${GCP_VM_NAME}-allow-mariadb"
  echo -e "${INFO} Check: docker compose logs mariadb"
fi

# =============================================================================
# 5. phpMyAdmin check
# =============================================================================
print_header "5. phpMyAdmin (port $PMA_PORT)"

PMA_STATUS=$(curl -o /dev/null -s -w "%{http_code}" \
  --max-time "$TIMEOUT" "http://${VM_IP}:${PMA_PORT}" || echo "000")

if [[ "$PMA_STATUS" =~ ^(200|301|302)$ ]]; then
  echo -e "${PASS} phpMyAdmin is responding (HTTP $PMA_STATUS)"
else
  echo -e "${FAIL} phpMyAdmin is not responding (HTTP $PMA_STATUS)"
  echo -e "${INFO} Check: docker compose logs phpmyadmin"
fi

# =============================================================================
# Summary
# =============================================================================
print_header "Check Complete"
echo -e "Target VM : ${VM_IP}"
echo -e "Timestamp : $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo -e "${INFO} For detailed logs: ssh -p ${SSH_PORT} ${SSH_USER}@${VM_IP}"
echo -e "${INFO} Then run: docker compose logs -f"
echo ""
