# Title: Testing scripts
# Maintainer: Yongbok Kim (ruo91@yongbok.net)
#!/bin/bash

# Linux Distributions
DEBIAN=`cat /etc/issue | head -n 1 | awk '{printf $1}'`
REDHAT=`cat /etc/*-release | head -n 1 | awk '{printf $1}'`

function f_build {
  # ETCD
  echo "BUild ETCD..." && sleep 1
      docker build --rm -t k8sm:etcd -f 00_cluster_of_etcd .
  echo "Done."
  echo

  # Mesos Master
  echo "Build Mesos Master..." && sleep 1
      docker build --rm -t k8sm:mesos-master -f 01_cluster_of_mesos_master .
  echo "Done."
  echo

  # Kubernetes Mesos
  echo "Build Kubernetes Mesos..." && sleep 1
      docker build --rm -t k8sm:framework -f 02_kubernetes_mesos_framework .
  echo "Done."
  echo

  # Kubernetes Minion & Mesos Slave
  echo "Build Kubernetes Minion & Mesos Slave..." && sleep 1
      docker build --rm -t k8sm:minion-slave -f 03_kubernetes_minion_and_mesos_slave .
  echo "Done."
  echo

  # Kubernetes Client
  echo "build Kubernetes Client..." && sleep 1
      docker build --rm -t k8sm:client -f 04_kubernetes_client .
  echo "Done"
  echo
}

function f_run {
  # ETCD
  for ((i=0; i<3; i++)); do
      echo "Run ETCD... #$i" && sleep 1
          docker run -d --name="etcd-$i" -h "etcd-$i" k8sm:etcd
      echo "Done."
      echo
  done

  # Mesos Master
  for ((i=0; i<3; i++)); do
      echo "Run Mesos Master... #$i" && sleep 1
          docker run -d --name="mesos-master-$i" -h "mesos-master-$i" -p 505$i:5050 k8sm:mesos-master
      echo "Done."
      echo
  done

  # Kubernetes Mesos
  echo "Run Kubernetes Mesos..." && sleep 1
      docker run -d --name="kubernetes-mesos" -h "kubernetes-mesos" -p 8080:8080 --privileged=true -v /dev:/dev -v /lib/modules:/lib/modules k8sm:framework
  echo "Done."
  echo

  # Kubernetes Minion & Mesos Slave
  for ((i=0; i<4; i++)); do
      echo "Run Kubernetes Minion & Mesos Slave... #$i" && sleep 1
          docker run -d --name="kubernetes-minion-$i" -h "kubernetes-minion-$i" --privileged=true -v /dev:/dev -v /lib/modules:/lib/modules k8sm:minion-slave
      echo "Done."
      echo
  done

  # Kubernetes Client
  echo "Run Kubernetes Client" && sleep 1
      docker run -d --name="kubernetes-client" -h "kubernetes-client" k8sm:client
  echo "Done"
  echo
}

function f_static_ip {
  # Pipework (Static IP)
  if [[ -f "$(which docker-pipework)" || -f "$(which pipework)" ]]; then
      # ETCD
      echo "Setting of Static IP - Mesos Slave #0" && sleep 1
          docker-pipework docker0 etcd-0 172.17.1.1/16
      echo "Done."
      echo

      echo "Setting of Static IP - Mesos Slave #1" && sleep 1
          docker-pipework docker0 etcd-1 172.17.1.2/16
      echo "Done."
      echo

      echo "Setting of Static IP - Mesos Slave #2" && sleep 1
          docker-pipework docker0 etcd-2 172.17.1.3/16
      echo "Done."
      echo

      # Mesos Master
      echo "Setting of Static IP - Mesos Master #0" && sleep 1
          docker-pipework docker0 mesos-master-0 172.17.1.4/16
      echo "Done."
      echo

      echo "Setting of Static IP - Mesos Master #1" && sleep 1
          docker-pipework docker0 mesos-master-1 172.17.1.5/16
      echo "Done."
      echo

      echo "Setting of Static IP - Mesos Master #2" && sleep 1
          docker-pipework docker0 mesos-master-2 172.17.1.6/16
      echo "Done."
      echo

      # Kubernetes Mesos
      echo "Setting of Static IP - Kubernetes Mesos" && sleep 1
          docker-pipework docker0 kubernetes-mesos 172.17.1.7/16
      echo "Done."
      echo

      # Kubernetes Minion & Mesos Slave
      echo "Setting of Static IP - Kubernetes Minion & Mesos Slave #0" && sleep 1
          docker-pipework docker0 kubernetes-minion-0 172.17.1.8/16
      echo "Done."
      echo

      echo "Setting of Static IP - Kubernetes Minion & Mesos Slave #1" && sleep 1
          docker-pipework docker0 kubernetes-minion-1 172.17.1.9/16
      echo "Done."
      echo

      echo "Setting of Static IP - Kubernetes Minion & Mesos Slave #2" && sleep 1
          docker-pipework docker0 kubernetes-minion-2 172.17.1.10/16
      echo "Done."
      echo

      echo "Setting of Static IP - Kubernetes Minion & Mesos Slave #3" && sleep 1
          docker-pipework docker0 kubernetes-minion-3 172.17.1.11/16
      echo "Done."
      echo

      # Kubernetes Client
      echo "Setting of Static IP - Kubernetes Client" && sleep 1
          docker-pipework docker0 kubernetes-client 172.17.1.12/16
      echo "Done"
      echo

  else
      CURL_CHECK="$(which curl)"
      if [ -f "$CURL_CHECK" ]; then
          # Install Pipework
          echo "Install pipework..." && sleep 1
              curl -o /usr/bin/pipework -L "https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework"
              chmod a+x /usr/bin/pipework
              ln -s /usr/bin/pipework /usr/bin/docker-pipework
          echo "Done."
          echo

      else
          if [[ "$DEBIAN" == "Debian" || "$DEBIAN" == "Ubuntu" ]]; then
              # Install Curl
              apt-get install -y curl

              # Install Pipework
              echo "Install pipework..." && sleep 1
                  curl -o /usr/bin/pipework -L "https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework"
                  chmod a+x /usr/bin/pipework
                  ln -s /usr/bin/pipework /usr/bin/docker-pipework
              echo "Done."
              echo

          elif [[ "$REDHAT" == "CentOS" || "$REDHAT" == "Fedora" ]]; then
              # Install Curl
              yum install -y curl

              # Install Pipework
              echo "Install pipework..." && sleep 1
                  curl -o /usr/bin/pipework -L "https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework"
                  chmod a+x /usr/bin/pipework
                  ln -s /usr/bin/pipework /usr/bin/docker-pipework
              echo "Done."
              echo

          else
                echo "Does not support."
          fi
      fi

      # Recursive
      f_static_ip
  fi
}

function f_rm {
  echo "Step #1 - Stop all containers"
      docker stop \
        etcd-0 etcd-1 etcd-2 \
        mesos-master-0 mesos-master-1 mesos-master-2 \
        kubernetes-mesos kubernetes-minion-0 kubernetes-minion-1 kubernetes-minion-2 kubernetes-minion-3 kubernetes-client \
        > /dev/null
  echo "Done."
  echo

  echo "Step #2 - Remove all containers"
      docker rm \
        etcd-0 etcd-1 etcd-2 \
        mesos-master-0 mesos-master-1 mesos-master-2 \
        kubernetes-mesos kubernetes-minion-0 kubernetes-minion-1 kubernetes-minion-2 kubernetes-minion-3 kubernetes-client \
        > /dev/null
  echo "Done."
  echo
}

function f_rm_none_images {
  DOCKER_IMAGES_NONE_CHECK="$(docker images | grep "<none>" | head -n 1 | awk '{ printf $1 "\n" }')"
  if [ "$DOCKER_IMAGES_NONE_CHECK" == "<none>" ]; then
      echo "Step #3 - Remove <none> images"
          docker rmi $(docker images | grep "<none>" | awk '{ printf $3 " " }')
      echo "Done."
      echo
  else
      echo
  fi
}

function f_help {
  echo "Usage: $ARG_0 [Options]"
  echo
  echo "- Options"
  echo "b, build     : Build images"
  echo "r, run       : Run containers"
  echo "rm           : Stop and remove container & images"
  echo "h, help      : Help"
  echo
}

# Main
ARG_0="$0"
ARG_1="$1"

case $ARG_1 in
    b|build)
        f_build
        f_rm_none_images
    ;;

    r|run)
        f_run
        f_static_ip
    ;;


    rm)
        f_rm
        f_rm_none_images
    ;;

    *|h|help)
      f_help
    ;;
esac
