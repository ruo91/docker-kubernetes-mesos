#!/bin/bash
K8SM=/opt/k8sm
PATH=$PATH:$K8SM

ETCD_SERVER="http://127.0.0.1:4001"
PORTAL_NET="`ip a s docker0 | grep 'inet' | awk '{ print $2 }'`"

km apiserver \
--v=2 \
--port=8080 \
--address=0.0.0.0 \
--portal_net=$PORTAL_NET \
--etcd_servers=$ETCD_SERVER \
--cloud_provider=mesos \
--cloud_config=mesos-clould.conf \
> /tmp/api-server.log 2>&1 &