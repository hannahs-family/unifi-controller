ARG target=amd64
FROM ${target}/openjdk:8-jre-slim

ENV BASE_DIR=/usr/lib/unifi \
    DATA_DIR=/unifi/data \
    LOG_DIR=/unifi/logs \
    RUN_DIR=/unifi/run \
    PIDFILE=/unifi/run/unifi.pid \
    LOG_TO_STDOUT=true \
    UNIFI_GID=998 \
    UNIFI_UID=998

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bash \
    binutils \
    coreutils \
    curl \
    jsvc \
    libcap2 \
    && rm -rf /var/lib/apt/lists/*

RUN addgroup --gid ${UNIFI_GID} --system unifi \
    && adduser --gid ${UNIFI_GID} --system --disabled-password --no-create-home --uid ${UNIFI_UID} unifi \
    && mkdir -p ${DATA_DIR} ${LOG_DIR} ${RUN_DIR} ${BASE_DIR} \
    && ln -s ${DATA_DIR} ${BASE_DIR}/data \
    && ln -s ${LOG_DIR} ${BASE_DIR}/logs \
    && ln -s ${RUN_DIR} ${BASE_DIR}/run \
    && ln -s ${DATA_DIR} /var/lib/unifi \
    && ln -s ${LOG_DIR} /var/log/unifi \
    && ln -s ${RUN_DIR} /var/run/unifi \
    && chown -R unifi:unifi /unifi

VOLUME [ "/unifi" ]

EXPOSE 6789/tcp 8080/tcp 8443/tcp 8880/tcp 8843/tcp 3478/udp

ARG version=5.10.25
RUN cd / \
    && curl -O https://dl.ubnt.com/unifi/${version}/unifi_sysvinit_all.deb \
    && dpkg --ignore-depends=mongodb-server,java8-runtime-headless -i unifi_sysvinit_all.deb \
    && rm -f unifi_sysvinit_all.deb \
    && chown -R unifi:unifi ${BASE_DIR} \
    && rm -rf /var/cache/* /var/lib/dpkg/status* /var/log/lastlog /var/log/dpkg.log /var/log/apt
USER unifi

COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD [ "unifi" ]

WORKDIR ${BASE_DIR}
