#!/bin/bash

# if /backup/full/xtrabackup_checkpoints does not exist, do a full backup
if [ ! -f /backup/full/xtrabackup_checkpoints ]; then
    full_backup
else
    incr_backup
fi

if [ "$SQLDUMP" == "true" ]; then
    sqldump
fi