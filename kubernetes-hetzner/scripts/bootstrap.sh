#!/bin/bash
set -eu

sleep 30 # TODO check why this is neccesary

# use noninteractive to disable prompts during apt install
export DEBIAN_FRONTEND=noninteractive

function main {
  update-system
  config-firewall
  install-docker
  install-kubernetes
}

function update-system {
  echo "********************** updating packages"
  apt-get -qq update && apt-get -qq upgrade -y
  sleep 2
  echo "********************** install basic packages"
  apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    inetutils-traceroute

  #apt-get dist-upgrade -y

  sleep 20
}

function config-firewall {
  echo "********************** config firewall"
  ufw allow ssh
  ufw allow from 10.0.0.0/8
  ufw allow from 192.168.2.0/24
  ufw --force enable
}

function install-docker {
  echo "********************** install docker"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
  # apt-cache madison docker-ce
  apt-get install -y docker-ce

  sudo mkdir -p /etc/docker
  cp daemon.json /etc/docker/daemon.json

  sudo systemctl enable docker
  sudo systemctl daemon-reload
  sudo systemctl restart docker

}

function install-kubernetes {
  echo "********************** install k8s packages"
  # Disable swap
  swapoff -a

  # Install kubelet, kubeadm, kubectl
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
  deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

  apt-get -qq update && apt-get -qq install -y kubelet kubeadm
}

main
