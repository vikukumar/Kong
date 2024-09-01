curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh


[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64


helm repo add kong-mesh https://kong.github.io/kong-mesh-charts
helm repo update

cd $HOME/kong

kubectl create namespace kong-mesh-system

kubectl create secret generic kong-mesh-license -n kong-mesh-system --from-file=license.json

echo 'kuma:
 controlPlane:
   secrets:
     - Env: "KMESH_LICENSE_INLINE"
       Secret: "kong-mesh-license"
       Key: "license.json"' > values.yaml


helm install --namespace kong-mesh-system kong-mesh kong-mesh/kong-mesh -f values.yaml

sleep 10

kexip kong-mesh-control-plane kong-mesh-system
