#!/bin/bash

## install master for k8s

TOKEN=${1}
HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $2}')

echo "Start master install script for - " $IP

echo "[0]: reset cluster if exist"
kubeadm reset -f

echo "[1]: kubadm init"
kubeadm init --apiserver-advertise-address=$IP --token="$TOKEN" --pod-network-cidr=10.244.0.0/16


echo "[2]: create config file"
mkdir $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#echo "[3]: create flannel pods network"
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml

echo "[3]: create calico pods network"
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
echo "[3][1]: use custom resources"
kubectl create -f /data/calico/manifests/custom-resources.yaml

#to check : watch kubectl get pods -n calico-system
# check step 4,5 on : https://docs.projectcalico.org/getting-started/kubernetes/quickstart

echo "[4]: restart and enable kubelet"
systemctl enable kubelet
service kubelet restart

echo "End master install script for - " $IP