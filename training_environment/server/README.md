# Training Server Setup

Docker Compose environment for WorldSkills Competition training.
Can run locally or on a GCP Compute Engine VM.

## Local Setup

### Prerequisites

- Docker with Compose plugin (`docker compose version` to confirm)

### 1. Configure .env

```bash
cp .env.example .env
```

Edit `.env` and set the following variables. `GCP_*` variables are not needed for local setup.

| Variable | Description |
|---|---|
| MYSQL_ROOT_PASSWORD | MariaDB root password |
| MYSQL_USER | Application DB username |
| MYSQL_PASSWORD | Application DB password |
| SSH_USER | SSH login username |
| SSH_PASSWORD | SSH login password |
| SSH_SUDO_ACCESS | Allow sudo in SSH container (`true` / `false`, default: `false`) |
| HTTP_PORT | Host port mapped to Apache (container port 80) |
| SSH_PORT | Host port mapped to SSH (container port 2222) |
| MARIADB_PORT | Host port mapped to MariaDB (container port 3306) |

### 2. Start

```bash
./local-setup.sh
```

All 3 containers (Apache, MariaDB, SSH) will be built/pulled and started.
The script waits for healthy status and prints connection info when ready.

### 3. Verify

```bash
./local-check.sh
```

Checks Apache, PHP, SSH, MariaDB connectivity and timezone.
All items should show `[PASS]`.

### 4. Connect

```
HTTP      http://localhost:<HTTP_PORT>
SSH       ssh -p <SSH_PORT> <SSH_USER>@localhost
MariaDB   localhost:<MARIADB_PORT>  (user: <MYSQL_USER>)
```

## GCE Setup

### Prerequisites

- Google Cloud SDK (`gcloud` CLI)
- A GCP project with Compute Engine API enabled

### 1. Configure .env

```bash
cp .env.example .env
```

Edit `.env` and set all variables:

| Variable | Description |
|---|---|
| GCP_PROJECT | GCP project ID (must not be `changeme`) |
| GCP_ZONE | VM zone (default: `us-central1-a`) |
| GCP_VM_NAME | VM instance name (default: `wsc-training`) |
| GCP_MACHINE_TYPE | Machine type (default: `e2-micro`) |
| MYSQL_ROOT_PASSWORD | MariaDB root password |
| MYSQL_USER | Application DB username |
| MYSQL_PASSWORD | Application DB password |
| SSH_USER | SSH login username |
| SSH_PASSWORD | SSH login password |
| SSH_SUDO_ACCESS | Allow sudo in SSH container (`true` / `false`, default: `false`) |
| HTTP_PORT | Host port mapped to Apache |
| SSH_PORT | Host port mapped to SSH |
| MARIADB_PORT | Host port mapped to MariaDB |

### 2. Deploy

```bash
./gce-setup.sh
```

Creates a VM, configures firewall rules, uploads files, installs Docker on the VM, and starts all containers.
The VM external IP is printed at the end.

If the script fails partway through, it prints a list of created resources that may need manual cleanup.

### 3. Verify

```bash
./gce-check.sh <VM_EXTERNAL_IP>
```

Checks Apache, PHP, SSH, MariaDB connectivity.
All items should show `[PASS]`.

### 4. Connect

```
HTTP      http://<VM_IP>:<HTTP_PORT>
SSH       ssh -p <SSH_PORT> <SSH_USER>@<VM_IP>
MariaDB   <VM_IP>:<MARIADB_PORT>  (user: <MYSQL_USER>)
```

### Firewall Rules

| Rule | Port | Source |
|---|---|---|
| `<GCP_VM_NAME>-allow-http` | HTTP_PORT | Your IP only |
| `<GCP_VM_NAME>-allow-ssh` | SSH_PORT | 0.0.0.0/0 (all IPs) |
| `<GCP_VM_NAME>-allow-mariadb` | MARIADB_PORT | Your IP only |

### Cost

All resources within GCP free tier: e2-micro (730 hrs/month), 30 GB standard disk, 1 GB egress.

## Reference

### Services

| Service | Image / Base | Container | Internal Port |
|---|---|---|---|
| Apache + PHP 8.4 | php:8.4-apache (custom build) | apache_php | 80 |
| MariaDB 11 | mariadb:11 | mariadb | 3306 |
| SSH | lscr.io/linuxserver/openssh-server:latest | ssh_server | 2222 |

All containers run in UTC timezone.

### Apache + PHP

- DocumentRoot: `/var/www/html`
- mod_rewrite enabled, AllowOverride All
- Composer installed globally
- PHP extensions: pdo_mysql, gd (freetype + jpeg), zip, opcache (mbstring and curl are built-in)
- PHP settings: `upload_max_filesize=64M`, `post_max_size=64M`, `memory_limit=128M`, `max_execution_time=120`
- Error reporting: `display_errors=On`, `error_reporting=E_ALL`
- `/phpinfo.php` available by default

### MariaDB

- On first start, `init.sh` creates 20 databases (`<MYSQL_USER>_01` ~ `<MYSQL_USER>_20`)
- `MYSQL_USER` gets `ALL PRIVILEGES` on each database (no global GRANT OPTION)
- Data persisted in `db_data` volume

### SSH

- Password authentication enabled
- Runs as UID/GID 33 (www-data) to match Apache file ownership
- Shares `/var/www/html` with Apache via `web_data` volume
- Host keys persisted in `ssh_config` volume

### local-setup.sh

1. Validates that all required .env variables are set
2. Checks that Docker and Compose plugin are installed
3. Runs `docker compose up -d --build` (builds Apache image, pulls MariaDB and SSH images)
4. Waits up to 60 seconds for all 3 containers to report healthy
5. Prints container status and connection info

### local-check.sh

Runs 6 checks against localhost:

1. Apache HTTP response (expects 200, 301, 302, or 403)
2. PHP operation (`/phpinfo.php` responds with 200)
3. SSH port open + OpenSSH banner confirmed. If `sshpass` is installed, also tests password login
4. MariaDB port open + login with `MYSQL_USER` credentials + verifies 20 databases exist
5. PHP-to-MariaDB connection via PDO from inside the Apache container
6. Timezone is UTC on all 3 containers

### gce-setup.sh

1. Validates all .env variables and checks `gcloud` CLI is installed
2. Resolves your public IP via `https://ifconfig.me`
3. Creates a VM instance (Ubuntu 24.04 LTS, 30 GB pd-standard disk). Skips if the VM already exists
4. Creates 3 firewall rules (skips existing):
   - `<GCP_VM_NAME>-allow-http` — TCP `HTTP_PORT`, source: your IP only
   - `<GCP_VM_NAME>-allow-ssh` — TCP `SSH_PORT`, source: 0.0.0.0/0 (all IPs, for participant access)
   - `<GCP_VM_NAME>-allow-mariadb` — TCP `MARIADB_PORT`, source: your IP only
5. Waits for VM SSH to be ready (up to 150 seconds)
6. Uploads `vm/` directory and `.env` to `~/project/` on the VM via `gcloud compute scp`
7. Runs `setup.sh` on the VM, which:
   - Updates system packages (`apt-get update && upgrade`)
   - Installs Docker and Compose plugin
   - Adds the user to the docker group
   - Runs `docker compose up -d --build`
   - Waits up to 90 seconds for all containers to be healthy
8. Prints the VM external IP and connection info

### gce-check.sh

Runs 4 checks against the VM:

1. Apache HTTP response
2. PHP operation (`/phpinfo.php`)
3. SSH port open + OpenSSH banner confirmed
4. MariaDB port open
