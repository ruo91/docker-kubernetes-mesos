#!/bin/bash
# etcd
ETCD="/opt/etcd"
PATH=$PATH:$ETCD

# cluster
LOCAL_IP="`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }'`"

# Issue: connection refused
# Solutions: --listen-client-urls http://0.0.0.0:4001
etcd \
--data-dir "/tmp/etcd" \
> /tmp/etcd-cluster.log 2>&1 &
