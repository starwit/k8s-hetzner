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
kubectl apply -f kube-flannel.yml
#kubectl apply -f /root/kube-flannel.yaml

# remove when creating a real cluster
kubectl taint nodes --all node-role.kubernetes.io/master-


echo "********************* add floating ip $3"
ip addr add $3 dev eth0

echo "********************* downloading and configuring latest helm binary"
mkdir ~/bin
wget https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz
tar -xvf helm-v3.0.2-linux-amd64.tar.gz
mv ~/linux-amd64/helm ~/bin
rm helm-v3.0.2-linux-amd64.tar.gz
rm -r ~/linux-amd64

source ~/bash-config.sh

helm repo add stable https://kubernetes-charts.storage.googleapis.com/


# install ingress controller 
helm install my-nginx stable/nginx-ingress --set controller.service.externalIPs[0]=$3

