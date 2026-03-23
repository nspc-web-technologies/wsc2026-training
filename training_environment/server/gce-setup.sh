#!/bin/bash
# =============================================================================
# gce-setup.sh - Full GCP deployment from local machine
# Creates VM, firewall rules, uploads files, and runs setup
# Requires: .env (copy from .env.example and fill in values)
# Usage: ./gce-setup.sh
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
for var in GCP_PROJECT GCP_ZONE GCP_VM_NAME GCP_MACHINE_TYPE \
           MYSQL_ROOT_PASSWORD MYSQL_USER MYSQL_PASSWORD \
           SSH_USER SSH_PASSWORD HTTP_PORT SSH_PORT MARIADB_PORT PMA_PORT; do
  if [ -z "${!var:-}" ]; then
    echo "ERROR: ${var} is not set in .env"
    exit 1
  fi
done
if [ "$GCP_PROJECT" = "changeme" ]; then
  echo "ERROR: Update placeholder values in .env (GCP_PROJECT is still 'changeme')"
  exit 1
fi

# --- Check dependencies -----------------------------------------------------
if ! command -v gcloud &>/dev/null; then
  echo "ERROR: gcloud CLI is not installed"
  exit 1
fi

# --- Colors ------------------------------------------------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
INFO="${YELLOW}[INFO]${NC}"
DONE="${GREEN}[DONE]${NC}"

# --- Track created resources for cleanup hints on failure --------------------
CREATED_RESOURCES=()
cleanup_hint() {
  if [ ${#CREATED_RESOURCES[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}[ERROR]${NC} Setup failed. The following resources were created and may need manual cleanup:"
    for res in "${CREATED_RESOURCES[@]}"; do
      echo "  - ${res}"
    done
  fi
}
trap cleanup_hint ERR

# =============================================================================
# 1. Create VM Instance
# =============================================================================
echo -e "${INFO} Creating VM instance: ${GCP_VM_NAME}"
if gcloud compute instances describe "$GCP_VM_NAME" --project="$GCP_PROJECT" --zone="$GCP_ZONE" &>/dev/null; then
  echo -e "${INFO} VM ${GCP_VM_NAME} already exists, skipping creation"
else
  gcloud compute instances create "$GCP_VM_NAME" \
    --project="$GCP_PROJECT" \
    --zone="$GCP_ZONE" \
    --machine-type="$GCP_MACHINE_TYPE" \
    --image-family=ubuntu-2404-lts-amd64 \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=30GB \
    --boot-disk-type=pd-standard \
    --tags="${GCP_VM_NAME}"
  CREATED_RESOURCES+=("VM: ${GCP_VM_NAME}")
  echo -e "${DONE} VM created"
fi

# =============================================================================
# 2. Create Firewall Rules
# =============================================================================
echo -e "${INFO} Creating firewall rules"

if gcloud compute firewall-rules describe "${GCP_VM_NAME}-allow-http" --project="$GCP_PROJECT" &>/dev/null; then
  echo -e "${INFO} Firewall rule ${GCP_VM_NAME}-allow-http already exists, skipping"
else
  gcloud compute firewall-rules create "${GCP_VM_NAME}-allow-http" \
    --project="$GCP_PROJECT" \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:${HTTP_PORT} \
    --source-ranges=0.0.0.0/0 \
    --target-tags="${GCP_VM_NAME}"
  CREATED_RESOURCES+=("Firewall: ${GCP_VM_NAME}-allow-http")
fi

if gcloud compute firewall-rules describe "${GCP_VM_NAME}-allow-ssh" --project="$GCP_PROJECT" &>/dev/null; then
  echo -e "${INFO} Firewall rule ${GCP_VM_NAME}-allow-ssh already exists, skipping"
else
  gcloud compute firewall-rules create "${GCP_VM_NAME}-allow-ssh" \
    --project="$GCP_PROJECT" \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:${SSH_PORT} \
    --source-ranges=0.0.0.0/0 \
    --target-tags="${GCP_VM_NAME}"
  CREATED_RESOURCES+=("Firewall: ${GCP_VM_NAME}-allow-ssh")
fi

if gcloud compute firewall-rules describe "${GCP_VM_NAME}-allow-mariadb" --project="$GCP_PROJECT" &>/dev/null; then
  echo -e "${INFO} Firewall rule ${GCP_VM_NAME}-allow-mariadb already exists, skipping"
else
  gcloud compute firewall-rules create "${GCP_VM_NAME}-allow-mariadb" \
    --project="$GCP_PROJECT" \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:${MARIADB_PORT} \
    --source-ranges=0.0.0.0/0 \
    --target-tags="${GCP_VM_NAME}"
  CREATED_RESOURCES+=("Firewall: ${GCP_VM_NAME}-allow-mariadb")
fi

if gcloud compute firewall-rules describe "${GCP_VM_NAME}-allow-pma" --project="$GCP_PROJECT" &>/dev/null; then
  echo -e "${INFO} Firewall rule ${GCP_VM_NAME}-allow-pma already exists, skipping"
else
  gcloud compute firewall-rules create "${GCP_VM_NAME}-allow-pma" \
    --project="$GCP_PROJECT" \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:${PMA_PORT} \
    --source-ranges=0.0.0.0/0 \
    --target-tags="${GCP_VM_NAME}"
  CREATED_RESOURCES+=("Firewall: ${GCP_VM_NAME}-allow-pma")
fi

echo -e "${DONE} Firewall rules created"

# =============================================================================
# 3. Wait for VM to be ready
# =============================================================================
echo -e "${INFO} Waiting for VM SSH to be ready..."
MAX_ATTEMPTS=30
ATTEMPT=0
until gcloud compute ssh "$GCP_VM_NAME" \
  --project="$GCP_PROJECT" --zone="$GCP_ZONE" \
  --command="echo ready" &>/dev/null; do
  ATTEMPT=$((ATTEMPT + 1))
  if [ $ATTEMPT -ge $MAX_ATTEMPTS ]; then
    echo "ERROR: VM SSH not ready after $((MAX_ATTEMPTS * 5))s"
    exit 1
  fi
  sleep 5
done
echo -e "${DONE} VM is ready"

# =============================================================================
# 4. Upload project files
# =============================================================================
echo -e "${INFO} Uploading project files"
gcloud compute ssh "$GCP_VM_NAME" \
  --project="$GCP_PROJECT" --zone="$GCP_ZONE" \
  --command="rm -rf ~/project"
gcloud compute scp --recurse \
  "${SCRIPT_DIR}/vm/" \
  "${GCP_VM_NAME}:~/project" \
  --zone="$GCP_ZONE" --project="$GCP_PROJECT"
gcloud compute scp \
  "${SCRIPT_DIR}/.env" \
  "${GCP_VM_NAME}:~/project/.env" \
  --zone="$GCP_ZONE" --project="$GCP_PROJECT"
echo -e "${DONE} Files uploaded"

# =============================================================================
# 5. Run setup on VM
# =============================================================================
echo -e "${INFO} Running setup on VM"
gcloud compute ssh "$GCP_VM_NAME" \
  --project="$GCP_PROJECT" --zone="$GCP_ZONE" \
  --command="cd ~/project && chmod +x setup.sh && ./setup.sh"
echo -e "${DONE} Setup complete"

# =============================================================================
# 6. Get external IP and show summary
# =============================================================================
VM_IP=$(gcloud compute instances describe "$GCP_VM_NAME" \
  --project="$GCP_PROJECT" --zone="$GCP_ZONE" \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo ""
echo "============================================="
echo " Deployment Complete"
echo "============================================="
echo "VM External IP : ${VM_IP}"
echo "HTTP           : http://${VM_IP}:${HTTP_PORT}"
echo "phpMyAdmin     : http://${VM_IP}:${PMA_PORT}"
echo "SSH            : ssh -p ${SSH_PORT} ${SSH_USER}@${VM_IP}"
echo "MariaDB        : ${VM_IP}:${MARIADB_PORT}"
echo ""
echo "Run verification:"
echo "  ./gce-check.sh ${VM_IP}"
