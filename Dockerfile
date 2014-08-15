# Dockerfile for inaetics/node-provisioning-service
FROM ubuntu:14.04
#FROM coreos/etcd:latest
MAINTAINER Bram de Kruijff <bdekruijff@gmail.com> (@bdekruijff)

##APT_PROXY - allow builder to inject a proxy dynamically

# Generic update & tooling
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get upgrade -yq && apt-get install -yq --no-install-recommends \
  build-essential \
  java-common \
  golang \
  curl \
  git && apt-get clean

##JDK_INSTALL - instruct builder to install a JDK
RUN apt-get install -yq --no-install-recommends openjdk-7-jre-headless && apt-get clean

##ETCDCTL_INSTALL - instruct builder to install etcdctl
#RUN cd /tmp && git config --global http.sslVerify false && git clone https://github.com/coreos/etcd && cd etcd && ./build
RUN cd /tmp && curl -k -L https://github.com/coreos/etcd/releases/download/v0.4.6/etcd-v0.4.6-linux-amd64.tar.gz | tar xzf - && \
	cp etcd-v0.4.6-linux-amd64/etcd /bin/ && cp etcd-v0.4.6-linux-amd64/etcdctl /bin/ 


# Node agent resources
ADD resources /tmp

CMD /bin/bash /tmp/node-provisioning.sh
