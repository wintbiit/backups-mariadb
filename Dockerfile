FROM debian:bookworm-slim
ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    mariadb-client \
    cron \
    tzdata \
    wget \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://downloads.percona.com/downloads/Percona-XtraBackup-8.4/Percona-XtraBackup-8.4.0-1/binary/debian/bookworm/x86_64/percona-xtrabackup-84_8.4.0-1-1.bookworm_amd64.deb && \
    dpkg -i percona-xtrabackup-84_8.4.0-1-1.bookworm_amd64.deb && \
    rm -f percona-xtrabackup-84_8.4.0-1-1.bookworm_amd64.deb

COPY entrypoint.sh /entrypoint.sh
COPY backup.sh /backup.sh

RUN chmod +x /entrypoint.sh /backup.sh

WORKDIR /backup

ENTRYPOINT ["/entrypoint.sh"]