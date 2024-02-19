#!/bin/bash

## install nodes for k8s
HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $2}')
TOKEN=${1}
MASTER_IP=${2}:6443

echo "Start node install script for - "$IP

echo "[0]: reset cluster if exist"
kubeadm reset -f

echo "[1]: kubadm join"
kubeadm join --ignore-preflight-errors=all --token="$TOKEN" $MASTER_IP --discovery-token-unsafe-skip-ca-verification

echo "[2]: restart and enable kubelet"
systemctl enable kubelet
service kubelet restart

echo "End node install script for - " $IP
