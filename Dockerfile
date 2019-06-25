ARG target=amd64
FROM ${target}/alpine:latest

ENV BASE_DIR=/usr/lib/unifi \
    DATA_DIR=/unifi/data \
    LOG_DIR=/unifi/logs \
    RUN_DIR=/unifi/run \
    PIDFILE=/unifi/run/unifi.pid \
    JAVA_HOME=/usr/lib/jvm/default-jvm \
    UNIFI_GID=998 \
    UNIFI_UID=998

RUN apk add --update --no-cache \
    bash \
    binutils \
    coreutils \
    curl \
    libcap \
    openjdk8-jre \
    && apk add --update --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted jsvc

RUN addgroup -g ${UNIFI_GID} -S unifi \
    && adduser -G unifi -S -D -H -u ${UNIFI_UID} unifi \
    && mkdir -p ${DATA_DIR} ${LOG_DIR} ${RUN_DIR} ${BASE_DIR} \
    && ln -s ${DATA_DIR} ${BASE_DIR}/data \
    && ln -s ${LOG_DIR} ${BASE_DIR}/logs \
    && ln -s ${RUN_DIR} ${BASE_DIR}/run \
    && ln -s ${DATA_DIR} /var/lib/unifi \
    && ln -s ${LOG_DIR} /var/log/unifi \
    && ln -s ${RUN_DIR} /var/run/unifi \
    && ln -s /dev/stdout ${LOG_DIR}/server.log \
    && chown -R unifi:unifi /unifi

VOLUME [ "/unifi" ]

EXPOSE 6789/tcp 8080/tcp 8443/tcp 8880/tcp 8843/tcp 3478/udp

ARG version=5.10.25
RUN cd / \
    && curl -O https://dl.ubnt.com/unifi/${version}/unifi_sysvinit_all.deb \
    && ar p unifi_sysvinit_all.deb data.tar.xz | unxz | tar x \
    && rm -f unifi_sysvinit_all.deb \
    && chown -R unifi:unifi ${BASE_DIR}
USER unifi

COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD [ "unifi" ]

WORKDIR ${BASE_DIR}
