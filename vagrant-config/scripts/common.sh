#!/bin/bash

## install common for k8s


HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $2}')
echo "Start common install script for - "$IP

echo "[1]: add host name for ip"
host_exist=$(cat /etc/hosts | grep -i "$IP" | wc -l)
if [ "$host_exist" == "0" ];then
echo "$IP $HOSTNAME " >> /etc/hosts
fi

echo "[2]: disable swap"
# swapoff -a to disable swapping
swapoff -a
# sed to comment the swap partition in /etc/fstab
sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab

echo "[3]: install utils"
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq && apt-get install -y apt-transport-https curl ca-certificates gnupg lsb-release > /dev/null


echo "[4]: install docker if not exist"
if [ ! -f "/usr/bin/docker" ];then
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -qq && apt-get install -y docker-ce docker-ce-cli containerd.io > /dev/null
systemctl start docker
docker --version

sudo usermod -aG docker ${USER}

#Securing Docker
#groupadd -g 500000 dockremap && groupadd -g 501000 dockremap-user && useradd -u 500000 -g dockremap -s /bin/false dockremap && useradd -u 501000 -g dockremap-user -s /bin/false dockremap-user
#
#echo "dockremap:500000:65536" >> /etc/subuid &&
#echo "dockremap:500000:65536" >>/etc/subgid
#
#cat <<EOF | sudo tee /etc/docker/daemon.json
#{
#  "serns-remap": "default",
#  "exec-opts": ["native.cgroupdriver=systemd"],
#  "log-driver": "json-file",
#  "log-opts": {
#    "max-size": "100m"
#  },
#  "storage-driver": "overlay2"
#}
#EOF
#
#systemctl daemon-reload && systemctl restart docker

fi

echo "[5]: add kubernetes repository to source.list"
if [ ! -f "/etc/apt/sources.list.d/kubernetes.list" ];then
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
#curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
#echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
fi

echo "[6]: install kubelet / kubeadm / kubectl / kubernetes-cni"
apt-get update -qq && apt-get install -y kubelet kubeadm kubectl kubernetes-cni >/dev/null

echo "[7]: Add kubectl autocompletion"
apt-get install -y bash-completion > /dev/null
echo "source <(kubectl completion bash)" >> ~/.bashrc

echo "End common install script for - " $IP
