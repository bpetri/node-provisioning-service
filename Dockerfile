# Dockerfile for inaetics/node-provisioning-service
FROM ubuntu:14.04
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

# Node agent resources
ADD resources /tmp
