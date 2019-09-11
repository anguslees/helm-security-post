{{/*
Copyright 2019 Brandon B. Jozsa/JinkIT and its Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

{{/*
abstract: |
  Renders kubernetes service object
values: |
  service:
    controller_service:
      name: nginx-ingress-controller
      type: LoadBalancer
      loadbalancer_ip: 146.148.47.155
      labels:
        application: nginx-ingress
        component: nginx-controller
      ports:
      - name: http
        port: 80
        protocol: TCP
        targetport: http
      - name: https
        port: 443
        protocol: TCP
        targetport: https
      annotations:
        metallb.universe.tf/allow-shared-ip: "true"

usage: |
{{ dict "envAll" . "context" .Values.services.controller_service | include "kubernetes-common.manifests.kubernetes_service" }}
return: |
  apiVersion: v1
  kind: Service
  metadata:
    name: nginx-ingress-controller
    annotations:
      metallb.universe.tf/allow-shared-ip: "true"
    labels:
      release_group: ingress-controller
      k8s-app: nginx-ingress
      component: nginx-controller
  spec:
    ports:
    - name: http
      port: 80
      protocol: TCP
      targetport: http
    - name: https
      port: 443
      protocol: TCP
      targetport: https
    selector:
      release_group: ingress-controller
      k8s-app: nginx-ingress
      component: nginx-controller
    sessionAffinity: None
    loadBalancerIP: 146.148.47.155
    type: LoadBalancer

*/}}

{{- define "kubernetes-common.manifests.kubernetes_service" -}}
{{- $envAll := index . "envAll" -}}
{{- $context := index . "context" -}}

---
apiVersion: v1
kind: Service
metadata:
  name: {{ $context.name | replace "_" "-" }}
  annotations:
{{ toYaml $context.annotations | indent 4 }}
  labels:
{{ tuple $envAll $context.labels.application $context.labels.component | include "kubernetes-common.snippets.kubernetes_metadata_labels" | indent 4 }}
spec:
  ports:
{{ toYaml $context.ports | indent 2 }}
  selector:
{{ tuple $envAll $context.labels.application $context.labels.component | include "kubernetes-common.snippets.kubernetes_metadata_labels" | indent 4 }}
  sessionAffinity: None
  type: {{ $context.type }}
{{- if $context.loadbalancer_ip }}
  loadBalancerIP: {{ $context.loadbalancer_ip }}
{{- end }}
{{- if $context.cluster_ip }}
  clusterIP: {{ $context.cluster_ip }}
{{- end }}
{{- if $context.publish_not_ready_ddresses }}
  publishNotReadyAddresses: {{ $context.publish_not_ready_ddresses }}
{{- end }}
{{- if $context.external_traffic_policy }}
  externalTrafficPolicy: {{ $context.external_traffic_policy }}
{{- end }}
{{- end }}
