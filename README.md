# Containered Backup
> For MariaDB

Based on mariadb-backup (xtrabackup)

`Containered Backup` aims to provide containers to backup datasets on a different machine.

## Usage
1. create volume
You need to create volume to mount `/var/lib/mysql` on remote database host machine in the container in order to make `xtrabackup` work properly. For example you can use rclone docker plugin along with sftp to create a docker volume

With `docker volume create` command:
```bash
docker volume create --driver rclone --opt type=sftp --opt user=backup --opt pass=backup --opt host="$REMOTE_HOST" --opt path="$REMOTE_PATH" --name mysql-backup
```

With `docker-compose.yml`:
```yaml
volume:
  mysql-backup:
    driver: rclone
    driver_opts:
      type: sftp
      user: backup
      pass: backup
      host: $REMOTE_HOST
```

2. run container
You need to set environment variables to configure the backup process. For example:
```env
MARIADB_HOST=
MARIADB_PORT=
MARIADB_USER=
MARIADB_PASSWORD=
CRON=
```

**Note**: According to [mariabackup docs](https://mariadb.com/kb/en/mariabackup-overview/), the user should have the following privileges:
```sql
CREATE USER 'mariabackup'@'localhost' IDENTIFIED BY 'mypassword';
GRANT RELOAD, PROCESS, LOCK TABLES, BINLOG MONITOR ON *.* TO 'mariabackup'@'localhost';
```

