#!/bin/bash
# Create application user, databases, and grant privileges
# This runs only on first container initialization (empty data volume)
# MYSQL_USER and MYSQL_PASSWORD are passed via environment variables
# Create 20 default databases (${MYSQL_USER}_01 ~ ${MYSQL_USER}_20)
for i in $(seq -w 1 20); do
  mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_USER}_${i};"
done

# Create application user with per-database privileges (no global GRANT OPTION)
GRANT_STATEMENTS=""
for i in $(seq -w 1 20); do
  GRANT_STATEMENTS="${GRANT_STATEMENTS}GRANT ALL PRIVILEGES ON ${MYSQL_USER}_${i}.* TO '${MYSQL_USER}'@'%';"
done

mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" <<SQL
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
${GRANT_STATEMENTS}
FLUSH PRIVILEGES;
SQL
