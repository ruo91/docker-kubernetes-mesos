#!/bin/bash
K8SM=/opt/k8sm
PATH=$PATH:$K8SM

km controller-manager \
--v=2 \
--master=127.0.0.1:8080 \
--cloud_config=mesos-clould.conf \
> /tmp/controller-manager.log 2>&1 &
