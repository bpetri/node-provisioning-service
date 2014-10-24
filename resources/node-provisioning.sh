#!/bin/bash

cd $(dirname $0)

#
# Config
#
GOSH_NONINTERACTIVE=true
DEBUG_LOG=true

#
# Libs
#
source etcdctl.sh

MAX_RETRY_ETCD_REPO=10
RETRY_ETCD_REPO_INTERVAL=5

#
# Functions
#

# Wraps a function call to redirect or filter stdout/stderr
# depending on the debug setting
#   args: $@ - the wrapped call
#   return: the wrapped call's return
_call () {
  if [ "$DEBUG_LOG" != "true"  ]; then
    $@ &> /dev/null
    return $?
  else
    $@ 2>&1 | awk '{print "[DEBUG] "$0}' >&2
    return ${PIPESTATUS[0]}
  fi
}

# Echo a debug message to stderr, perpending each line
# with a debug prefix.
#   args: $@ - the echo args
_dbg() {
  if [ "$DEBUG_LOG" == "true" ]; then
    echo $@ | awk '{print "[DEBUG] "$0}' >&2
  fi
}

# Echo a log message to stderr, perpending each line
# with a info prefix.
#   args: $@ - the echo args
_log() {
  echo $@ | awk '{print "[INFO] "$0}' >&2
}

function store_etcd_data(){

  PROVISIONING_ETCD_PATH_FOUND=0
  RETRY=1
  while [ $RETRY -le $MAX_RETRY_ETCD_REPO ] && [ $PROVISIONING_ETCD_PATH_FOUND -eq 0 ]
  do
    etcd/put "/inaetics/node-provisioning-service/$provisioning_id" "$provisioning_ipv4:$provisioning_port"

    if [ $? -ne 0 ]; then
        echo "Tentative $RETRY of storing Provisioning Server to etcd failed. Retrying..."
        ((RETRY+=1))
        sleep $RETRY_ETCD_REPO_INTERVAL
    else
        _log "Pair </inaetics/node-provisioning-service/$provisioning_id,$provisioning_ipv4:$provisioning_port> stored in etcd"
        PROVISIONING_ETCD_PATH_FOUND=1
    fi
  done

  if [ $PROVISIONING_ETCD_PATH_FOUND -eq 0 ]; then
    echo "Cannot store pair </inaetics/node-provisioning-service/$provisioning_id,$provisioning_ipv4:$provisioning_port> stored in etcd"
  fi

}

start_provisioning () {
  provisioning_pid=$!
  java $JAVA_PROPS -jar server-allinone.jar &
  store_etcd_data
  #etcd/put "/inaetics/node-provisioning-service/$provisioning_id" "$provisioning_ipv4:$provisioning_port"
}

stop_provisioning () {
  etcd/rm "/inaetics/node-provisioning-service/$provisioning_id"
  if [ "$provisioning_pid" != "" ]; then
    kill -SIGTERM $provisioning_pid
    provisioning_pid=""
  fi
}

clean_up () {
  stop_provisioning
  exit
}

#
# Main
#
trap clean_up SIGHUP SIGINT SIGTERM

provisioning_id=$1
if [ "$provisioning_id" == "" ]; then
  # get docker id
  provisioning_id=`cat /proc/self/cgroup | grep -o  -e "docker-.*.scope" | head -n 1 | sed "s/docker-\(.*\).scope/\\1/"`
fi
if [ "$provisioning_id" == "" ]; then
  echo "provisioning_id param required!"
  exit 1
fi

provisioning_ipv4=$2
if [ "$provisioning_ipv4" == "" ]; then
  # get ip from env variable set by kubernetes
  provisioning_ipv4=$SERVICE_HOST
fi
if [ "$provisioning_ipv4" == "" ]; then
  echo "provisioning_ipv4 param required!"
  exit 1
fi

# get port from env variable set by kubernetes pod config
provisioning_port=$HOSTPORT
if [ "$provisioning_port" == "" ]; then
  provisioning_port=8080
fi

JAVA_PROPS="-Dace.gogo.script=default-mapping.gosh"
if $GOSH_NONINTERACTIVE; then
  JAVA_PROPS="$JAVA_PROPS -Dgosh.args=--nointeractive"
fi
start_provisioning

while true; do
  #TODO monitor JVM?
  sleep 5 &
  wait $!
done
