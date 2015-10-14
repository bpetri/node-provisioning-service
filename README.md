Node Provisioning Service [![Build Status](https://travis-ci.org/INAETICS/node-provisioning-service.svg?branch=master)](https://travis-ci.org/INAETICS/node-provisioning-service)
=========================

Run [Apache ACE Server] (https://ace.apache.org/) inside a Docker container.

Be sure to either uncomment the "ADD bundles /bundles" line in the Dockerfile,
or map the "bundles" folder as a docker volume to /bundles when starting the container! 

