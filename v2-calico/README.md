# Calico Network

[Project Calico](https://www.projectcalico.org/), from [Tigera](https://www.tigera.io/). Secure networking for the cloud native era.

## Quick Notes:

For now, use the following commands to install this chart:
```
wget -O calico-testing-v3.8.2-0.tgz https://github.com/v1k0d3n/chartsv3/blob/gh-pages/calico-testing-v3.8.2-0.tgz?raw=true
helm install --namespace kube-system calico-v3.8.2-0 calico-testing-v3.8.2-0.tgz
```