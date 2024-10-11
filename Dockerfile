FROM alpine:3.14
ENV TZ=Asia/Shanghai

RUN apk add --no-cache mariadb-client bash curl rsync tzdata mariadb-backup openssh-client sshfs

COPY entrypoint.sh /entrypoint.sh
COPY backup.sh /backup.sh

RUN chmod +x /entrypoint.sh /backup.sh

WORKDIR /backup

ENTRYPOINT ["/entrypoint.sh"]