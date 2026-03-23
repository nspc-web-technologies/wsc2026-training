#!/bin/bash
# =============================================================================
# setup.sh - VM initial setup script
# Run on the GCP VM after SCP deployment
# Expects .env to already exist (uploaded by gce-setup.sh)
# Usage: cd ~/project && ./setup.sh
# =============================================================================

set -euo pipefail

if [ ! -f .env ]; then
  echo "ERROR: .env not found. Run gce-setup.sh or create .env from .env.example"
  exit 1
fi

echo "=== Updating system packages ==="
sudo apt-get update && sudo apt-get upgrade -y

echo "=== Installing Docker ==="
curl -fsSL https://get.docker.com | sudo sh

if ! sudo docker --version &>/dev/null; then
  echo "ERROR: Docker installation failed"
  exit 1
fi

echo "=== Installing Docker Compose plugin ==="
sudo apt-get install -y docker-compose-plugin

if ! sudo docker compose version &>/dev/null; then
  echo "ERROR: Docker Compose plugin installation failed"
  exit 1
fi

echo "=== Adding user to docker group ==="
sudo usermod -aG docker "$USER"

echo "=== Starting containers ==="
sudo docker compose up -d --build

echo "=== Waiting for containers to be healthy ==="
MAX_WAIT=90
INTERVAL=5
ELAPSED=0

while [ $ELAPSED -lt $MAX_WAIT ]; do
  UNHEALTHY=$(sudo docker compose ps -q | xargs sudo docker inspect --format '{{.State.Health.Status}}' 2>/dev/null | grep -c 'unhealthy\|starting' || true)
  RUNNING=$(sudo docker compose ps -q | xargs sudo docker inspect --format '{{.State.Status}}' 2>/dev/null | grep -c 'running' || true)

  if [ "$RUNNING" -ge 4 ] && [ "$UNHEALTHY" -eq 0 ]; then
    echo "All containers are healthy"
    break
  fi

  echo "Waiting... (${ELAPSED}s / ${MAX_WAIT}s)"
  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
  echo "WARNING: Timeout reached — some containers may still be starting"
fi

sudo docker compose ps

echo ""
echo "=== Setup complete ==="
echo "Run 'newgrp docker' or re-login to use docker without sudo"
