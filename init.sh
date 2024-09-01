#!/bin/bash

set -e

### Disable SELINUX ####

cat /etc/sysconfig/selinux | grep SELINUX=
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
cat /etc/sysconfig/selinux | grep SELINUX=
setenforce 0
######################

#cat <<EOF>>  /etc/hosts
#192.168.1.18  labs.vik.in localhost
#EOF
######################

### Check the connectivity of your cluster nodes #########
ping -c 2 labs.vik.in
ping -c 2 lab1.vik.in
######################

### Disable the Firewall ########
systemctl stop firewalld.service
systemctl disable firewalld
######################

### Kubernetes prerequisite #######
RAM=`cat /proc/meminfo | grep MemTotal | awk '{print ($2 / 1024) / 1024 ,"GiB"}'`
CPU=`cat /proc/cpuinfo | grep processor`

sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
swapoff -a
echo "Your system RAM is $RAM"
echo "Your system CPU are $CPU"
######################

# Update the system
echo "Updating system..."
dnf update -y

yum install kernel-devel-$(uname -r)

sudo modprobe br_netfilter
sudo modprobe ip_vs
sudo modprobe ip_vs_rr
sudo modprobe ip_vs_wrr
sudo modprobe ip_vs_sh
sudo modprobe overlay

cat > /etc/modules-load.d/k8s.conf << EOF
br_netfilter
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
overlay
EOF

cat > /etc/sysctl.d/k8s.conf << EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

### Preparation for Docker installation #########
modprobe br_netfilter
lsmod | grep br_netfilter

echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
sysctl -a | grep net.bridge.bridge-nf-call-iptables
######################




# Install prerequisites
echo "Installing prerequisites..."
### Docker installation steps #######
sudo yum -y remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine buildah
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin iptables 
containerd config default | sudo tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl enable --now containerd.service

systemctl start docker
systemctl enable docker


# Start and enable Docker
echo "Starting and enabling Docker service..."
systemctl start docker
systemctl enable docker



### Kubernetes installation steps #####
sudo cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
EOF


yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable kubelet
systemctl start kubelet
#####################

kubeadm config images pull



swapoff -a
kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
### You should now deploy a Pod network to the cluster. ####
kubctl taint nodes $(hostname) node-role.kubernetes.io/control-plane:NoSchedule-

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml

curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml

sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.244.0.0\/16/g' custom-resources.yaml

kubectl create -f custom-resources.yaml
