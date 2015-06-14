#!/bin/bash
K8SM=/opt/k8sm
PATH=$PATH:$K8SM

ETCD_SERVER="http://localhost:4001"
PORTAL_NET="10.0.42.1/16"

km apiserver \
--v=2 \
--port=8080 \
--address=0.0.0.0 \
--portal_net=$PORTAL_NET \
--etcd_servers=$ETCD_SERVER \
--cloud_provider=mesos \
--cloud_config=mesos-clould.conf \
> /tmp/api-server.log 2>&1 &
