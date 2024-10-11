#!/bin/bash

# if MARIADB_HOST is not set exit
if [ -z "$MARIADB_HOST" ]; then
  echo "MARIADB_HOST is not set. Exiting."
  exit 1
fi

# if MARIADB_PORT is not set, set it to 3306
if [ -z "$MARIADB_PORT" ]; then
  MARIADB_PORT=3306
fi

# if MARIADB_USER is not set, exit
if [ -z "$MARIADB_USER" ]; then
  echo "MARIADB_USER is not set. Exiting."
  exit 1
fi

# if MARIADB_PASSWORD is not set, exit
if [ -z "$MARIADB_PASSWORD" ]; then
  echo "MARIADB_PASSWORD is not set. Exiting."
  exit 1
fi

# if CRON is not set, exit
if [ -z "$CRON" ]; then
  echo "CRON is not set. Exiting."
  exit 1
fi

echo "MARIADB_HOST: $MARIADB_HOST"
echo "MARIADB_PORT: $MARIADB_PORT"
echo "MARIADB_USER: $MARIADB_USER"
echo "CRON: $CRON"

mariadb --version
mariadb-backup --version
mariadb-dump --version

# write mariadb credentials as option file
rm -rf /etc/mysql
cat <<EOF > /etc/my.cnf
[client]
host=$MARIADB_HOST
port=$MARIADB_PORT
user=$MARIADB_USER
password=$MARIADB_PASSWORD
skip-ssl=true

[mariadb]
skip-ssl=true
EOF

# test mariadb connection
conn=$(mariadb -e "SELECT 1" 2>&1)
if [ $? -ne 0 ]; then
  echo "Failed to connect to MariaDB: $conn"
  exit 1
fi

mkdir full incr sql 2>/dev/null

# set cron job on debain based systems
echo "$CRON /usr/local/bin/backup.sh" > /etc/cron.d/backup
chmod 0644 /etc/cron.d/backup
crontab /etc/cron.d/backup

# start cron
cron -f