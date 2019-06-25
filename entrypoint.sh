#!/usr/bin/env bash

exit_handler() {
    java -jar ${BASE_DIR}/lib/ace.jar stop
    for i in `seq 1 10` ; do
        [ -z "$(pgrep -f ${BASE_DIR}/lib/ace.jar)" ] && break
        # graceful shutdown
        [ $i -gt 1 ] && [ -d ${BASE_DIR}/run ] && touch ${BASE_DIR}/run/server.stop || true
        # savage shutdown
        [ $i -gt 7 ] && pkill -f ${BASE_DIR}/lib/ace.jar || true
        sleep 1
    done

    exit ${?};
}

trap 'kill ${!}; exit_handler' SIGHUP SIGINT SIGQUIT SIGTERM

# Used to generate simple key/value pairs, for example system.properties
confSet() {
  file=$1
  key=$2
  value=$3
  if [ "$newfile" != true ] && grep -q "^${key} *=" "$file"; then
    ekey=$(echo "$key" | sed -e 's/[]\/$*.^|[]/\\&/g')
    evalue=$(echo "$value" | sed -e 's/[\/&]/\\&/g')
    sed -i "s/^\(${ekey}\s*=\s*\).*$/\1${evalue}/" "$file"
  else
    echo "${key}=${value}" >> "$file"
  fi
}

JVM_MAX_HEAP_SIZE=${JVM_MAX_HEAP_SIZE:-1024M}
JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS} -Dunifi.datadir=${DATA_DIR} -Dunifi.logdir=${LOG_DIR} -Dunifi.rundir=${RUN_DIR}"

if [ ! -z "${JVM_MAX_HEAP_SIZE}" ]; then
    JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS} -Xmx${JVM_MAX_HEAP_SIZE}"
fi

if [ ! -z "${JVM_INIT_HEAP_SIZE}" ]; then
    JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS} -Xms${JVM_INIT_HEAP_SIZE}"
fi

if [ ! -z "${JVM_MAX_THREAD_STACK_SIZE}" ]; then
    JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS} -Xss${JVM_MAX_THREAD_STACK_SIZE}"
fi

JVM_OPTS="${JVM_EXTRA_OPTS} -Djava.awt.headless=true -Dfile.encoding=UTF-8"

rm -f $PIDFILE

confFile="${DATA_DIR}/system.properties"
if [ -e "$confFile" ]; then
    newfile=false
else
    newfile=true
fi

declare -A settings

if [ ! -z "${LOTSOFDEVICES}" ]; then
    settings["unifi.G1GC.enabled"]="true"
    settings["unifi.xms"]="$(h2mb ${JVM_INIT_HEAP_SIZE})"
    settings["unifi.xmx"]="$(h2mb ${JVM_MAX_HEAP_SIZE})"
fi

if ! [[ -z "${DB_URI}" || -z "${STATDB_URI}" || -z "${DB_NAME}" ]]; then
    settings["db.mongo.local"]="false"
    settings["db.mongo.uri"]="${DB_URI}"
    settings["statdb.mongo.uri"]="${STATDB_URI}"
    settings["unifi.db.name"]="$DB_NAME"
fi

for key in "${!settings[@]}"; do
    confSet "$confFile" "$key" "${settings[$key]}"
done

UNIFI_CMD="java ${JVM_OPTS} -jar ${BASE_DIR}/lib/ace.jar start"

if [[ "${@}" == "unifi" ]]; then
    ${UNIFI_CMD} &
    wait
else
    exec ${@}
fi
