#!/bin/bash


PWD=`pwd`
cd $(dirname $0)

java -Dace.gogo.script=default-mapping.gosh -Dgosh.args=--nointeractive -jar server-allinone.jar

cd $PWD
