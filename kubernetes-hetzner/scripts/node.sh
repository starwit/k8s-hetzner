#!/bin/bash
set -eu

echo "********************* allow traffic from master $2"
ufw allow from $2

echo "********************* setup node with ip $1"

sed -i "s/KUBELET_EXTRA_ARGS/KUBELET_EXTRA_ARGS --node-ip ${1}/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

echo "setting node ip"

systemctl daemon-reload
echo "systemd daemons reloaded"

systemctl restart kubelet

# Run the join command and enable docker, kubelet
eval "$(cat /tmp/cluster_join)"

systemctl enable docker kubelet
