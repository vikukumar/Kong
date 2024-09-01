kubectl apply -f https://raw.githubusercontent.com/kumahq/kuma-counter-demo/master/demo.yaml
kubectl wait -n kuma-demo --for=condition=ready pod --selector=app=demo-app --timeout=90s


kexip redis kuma-demo
kexip demo-app kuma-demo
