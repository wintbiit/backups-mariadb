ARG MARIADB_VERSION=11.rolling

FROM debian:bookworm-slim
ARG MARIADB_VERSION
ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    cron \
    tzdata \
    && curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash -s -- --mariadb-server-version="mariadb-${MARIADB_VERSION}" \
    && apt-get update && apt-get install -y \
    mariadb-backup \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
COPY backup.sh /backup.sh

RUN chmod +x /entrypoint.sh /backup.sh

WORKDIR /backup

ENTRYPOINT ["/entrypoint.sh"]