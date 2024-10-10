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

date=$(date +%Y%m%d%H%M%S)

red_color() {
    # 
}

reset_color() {

}

full_backup () {
    echo "Performing full backup, backup dir: /backup/full"
    mariabackup --backup --target-dir /backup/full --parallel=4 --compress --compress-threads=4 --rsync
}

last_incr_dir () {
    # find latest incremental backup dir matching the pattern
    dir=$(ls -td /backup/incr/* 2>/dev/null | head -n 1)
    if [ -z "$dir" ]; then
        echo "/backup/full"
    else
        echo "$dir"
    fi
}

incr_backup () {
    lastIncr=$(last_incr_dir)
    echo "Performing incremental backup based on $lastIncr"
    mariabackup --backup --target-dir /backup/incr/$date --incremental-basedir $lastIncr --parallel=4 --compress --compress-threads=4 --rsync
}

sqldump () {
    echo "Performing SQL dump"
    mysqldump -h $MARIADB_HOST -u $MARIADB_USER -p$MARIADB_PASSWORD --all-databases > /backup/sql/$date.sql
}

# mount sshfs
if [ "$SSHFS" == "true" ]; then
    echo "Mounting SSHFS"
    sshfs $SSHFS_OPTS $SSHFS_USER@$SSHFS_HOST:$SSHFS_MARIADB_DATA /var/lib/mysql
fi

# if /backup/full/xtrabackup_checkpoints does not exist, do a full backup
if [ ! -f /backup/full/xtrabackup_checkpoints ]; then
    full_backup
else
    incr_backup
fi

if [ "$SQLDUMP" == "true" ]; then
    sqldump
fi