# Calico Network

[Project Calico](https://www.projectcalico.org/), from [Tigera](https://www.tigera.io/). Secure networking for the cloud native era.

## Introduction

This [Helm](https://helm.sh/) chart provides a comprehensive deployment of Calico SDN for Kubernetes. Since an SDN is required for the initialization of a Kubernetes cluster, most people will likely use this chart to [template](https://helm.sh/docs/helm/#helm-template) a manifest that can then be deployed via a Kubernetes YAML or JSON file. You can also use a Helm rendered manifest of Tiller, wait for it to properly initalize, and then use Helm to deploy this Chart. If you've found yourself here, then you will likely know how to use this Chart for your environment.

## Core Concepts

Calico is a collection of services that can be deployed with countless configuration options. The goal is to simplify the following main components:
- Datastore - Kubernetes (via Typha), or etcd (v3)
- Operational Mode - Calico (L3), or Canal (L2)
- Typha Autoscaling - Horizontally and Vertically

The goal is also to allow flexible and sensible overrides, without compromising the overall service. Various configuration options will be included in further documentation at a later time.

### Chart Design

The chart design is one that needs to clarified for any future development, or pull requests. Starting with the `values.yaml`, you will notice a deliberate operational workflow. Our charts are designed so that all features are accessible at the time of instantiation. This creates a significate amount of thought when working with the chart, but the tradeoff is that the operator can access all typical configuration flags (such as [custom labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) with [operator-driven selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors), access to [container-level resource limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) and [per-pod dns policies](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)) that they may not have otherwise in other chart implementations.

**Simplistic Switches**

This chart supplies a simple, easy-to-implement, operational workflow by incorporating high-level switches for the most common Calico reference implementations. When looking over the `values.yaml` file, fine the section entitled `config`. This section will control _how_ Calico is implemented. Some of these options include the following:

- `config.common.datastore` - datastore type options: `kubernetes` (Typha), `etcd` (v3)
- `config.common.network_mode` - networking mode options: `calico` (L3), `canal` (L2)
- `config.common.autoscaling.typha.horizontal.enabled` - `true`, `false`
- `config.common.autoscaling.typha.vertical.enabled` - `true`, `false`

These switches will have top-level control over all other options, with the exection of the `manifests` section at the bottom of the `values.yaml` declaration file. Other high-level configuration options will be added soon, such as setting up etcd as part of the deployment.

**Labels**

Labels are treated as first class citizens in our Helm charts. By default, there is a common list of labels that can be left "as is", turned of, or overriden at the time of instantiation. These common labels are:
- `release_group` - Dynamically assigned based on the release-name provided via Helm
- `component` - Component is the individual application component of the application (such as "typha")
- `date` - Dynamically assigned via the deployment date
- `app` - Unlike component, this is the application name as a whole (such as "calico")

While these labels are provided globally, and enabled by default, they can be enabled selectively as in our example below:
```
labels:
  release_group: false
  date: false
```
In the example above, the `release_group` and `date` labels will not be applied at the global level.

You can also choose to add your own custom labels, either gloablly or per component.
```
labels:
  release_group: false
  component: false
  date: false
  typha_datastore:
    app: false
    k8s-app: calico-typha
  calico_node:
    app: false
    k8s-app: calico-node
  typha_autoscale_horz:
    app: false
    k8s-app: calico-typha-autoscaler
  typha_autoscale_vert:
    app: false
    k8s-app: calico-typha-autoscaler
```
In the example above, we're adding the `k8s-app` label to each of our components, but we are removing our global label of `app` individually per each component.

So as you can see, this level of methodical design on labels provides you with the most options available while retaining the integrity of the application (per our original design specification).

**Containers and Pods**

When looking at a simple [deployment manifest](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#creating-a-deployment) in Kubernetes, you will notice that there are two `spec` fields, which separate `pod` instructions from individual `containers` instructions. Our charts take a similar design approach.

### PLEASE NOTE:
If you run into an issue where an artifact "already exists", use the following workaround:
```
helm install --set vars.calico_node.calico_node.CALICO_IPV4POOL_CIDR="10.25.0.0/22" --namespace kube-system --name calico-v3.4.2 cni-calico-0.1.0.tgz
```

#### NOTES:
Workaround for "resource already exists::
```
helm upgrade \
  --install \
  --set vars.calico_node.calico_node.CALICO_IPV4POOL_CIDR="10.25.0.0/22" \
  --namespace kube-system calico-v3.4.2 \
  cni-calico-0.1.0.tgz \
  --force
```
