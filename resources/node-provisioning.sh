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

start_etcd () {
	/bin/etcd &
	sleep 1
}

start_provisioning () {
  provisioning_pid=$!
  java $JAVA_PROPS -jar server-allinone.jar &
  etcd/put "/inaetics/node-provisioning-service/$provisioning_id" "$provisioning_ipv4:8080"
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

provisioning_id=$(hostname)
#if [ "$provisioning_id" = "" ]; then
#  echo "provisioning_id param required!"
#  exit 1
#fi

provisioning_ipv4=$(ifconfig eth0 | grep 'inet ' | awk '{print $2}' | sed 's/addr://')
#if [ "$provisioning_ipv4" = "" ]; then
#  echo "provisioning_ipv4 param required!"
#  exit 1
#fi

JAVA_PROPS="-Dace.gogo.script=default-mapping.gosh"
if $GOSH_NONINTERACTIVE; then
  JAVA_PROPS="$JAVA_PROPS -Dgosh.args=--nointeractive"
fi

start_etcd
start_provisioning

while true; do
  #TODO monitor JVM?
  sleep 5 &
  wait $!
done
