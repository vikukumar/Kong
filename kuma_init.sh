curl -L https://docs.konghq.com/mesh/installer.sh | VERSION=2.8.2 sh -


cd kong-mesh-2.8.2/bin
export PATH=$(pwd):$PATH

cp kuma-cp /usr/bin/kuma-cp
cp kuma-dp /usr/bin/kuma-dp
cp kumactl /usr/bin/kumactl
cp envoy /usr/bin/envoy
cp coredns /usr/bin/coredns
