#! /bin/bash

kubeadm reset

rm -rf $HOME/.kube

kubeadm config images pull

swapoff -a
kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

### You should now deploy a Pod network to the cluster. ####

sleep 5

hostname=$(hostname)
echo $hostname
kubectl taint nodes $hostname node-role.kubernetes.io/control-plane:NoSchedule-

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml

curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml

sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.244.0.0\/16/g' custom-resources.yaml

kubectl create -f custom-resources.yaml

kexip kubernetes

kexip kube-dns kube-system
