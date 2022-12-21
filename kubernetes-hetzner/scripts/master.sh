#!/bin/bash
set -eu

# because freakin K8s just can't let go primary interface
echo "********************* allowing traffic from self $2"
ufw allow from $2
ufw allow http
ufw allow https

echo "********************* setup master with ip $1"
sed -i "s/KUBELET_EXTRA_ARGS/KUBELET_EXTRA_ARGS --node-ip ${1}/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

echo "setting node ip"

systemctl daemon-reload
systemctl restart kubelet

apt-get install -qq -y kubectl

echo "Initialize the master"
kubeadm init --config /root/kubeconf.yaml
systemctl enable docker kubelet

# Store join command in temporary file
kubeadm token create --print-join-command > /tmp/cluster_join

echo "********************* generated join command ***************"
cat /tmp/cluster_join
echo "********************* generated join command ***************"

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install weave as cni addon
sysctl net.bridge.bridge-nf-call-iptables=1
kubectl apply -f kube-flannel.yaml
#kubectl apply -f /root/kube-flannel.yaml

# remove when creating a real cluster
kubectl taint nodes --all node-role.kubernetes.io/master-


echo "********************* add floating ip $3 *****************"
ip addr add $3 dev eth0

echo "******************** install helm ****************************"
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

source ~/bash-config.sh

