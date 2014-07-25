#!/bin/bash

GOSH_NONINTERACTIVE=true
PWD=`pwd`

for var in "$@"; do
  if [ "$var" == "-i" ]; then
    GOSH_NONINTERACTIVE=false
  fi
done

JAVA_PROPS="-Dace.gogo.script=default-mapping.gosh"

if $GOSH_NONINTERACTIVE; then
  JAVA_PROPS="$JAVA_PROPS -Dgosh.args=--nointeractive"
fi

cd $(dirname $0)
java $JAVA_PROPS -jar server-allinone.jar
cd $PWD
