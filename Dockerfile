# Dockerfile for inaetics/node-provisioning-service
FROM slintes/jre8 

MAINTAINER Marc Sluiter <marc.sluiter@luminis.eu>

# Install etcdctl
RUN cd /tmp \
  && curl -k -L https://github.com/coreos/etcd/releases/download/v0.4.9/etcd-v0.4.9-linux-amd64.tar.gz | gunzip | tar xf - \
  && cp etcd-v0.4.9-linux-amd64/etcdctl /bin/

# Add resources
ADD resources /tmp
