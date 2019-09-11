FROM bitnami/minideb
MAINTAINER Brandon B. Jozsa <b@tigera.io>

RUN install_packages curl bash openssl ca-certificates telnet make

RUN curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash

RUN \
 set -e; \
 v=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt); \
 curl -LO https://storage.googleapis.com/kubernetes-release/release/$v/bin/linux/amd64/kubectl; \
 chmod +x kubectl; \
 mv kubectl /usr/local/bin/

COPY demo/ /demo/

RUN chmod +x /demo/*
RUN mv /demo/* /usr/local/bin/

COPY pwnchart /pwnchart/
COPY tls.make /usr/local/bin/
