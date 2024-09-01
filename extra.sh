# see what changes would be made, returns nonzero returncode if different
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system

# actually apply the changes, returns nonzero returncode on errors only
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system



# Install MetalLB for external IP management
echo "Installing MetalLB for external IP management..."
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml

kubectl create secret generic memberlist --from-literal=secretkey="$(openssl rand -base64 128)" -n metallb-system

# Configure MetalLB
echo "Configuring MetalLB..."
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: cheap
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.1/24
EOF
# Verify installation
echo "Verifying Kubernetes installation..."
kubectl get nodes

echo "Kubernetes installation and setup with external IP configuration is complete."
