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
  Renders the appropriate host rules using a given dictionary.
values: N/A
usage: |
{{- $hostRules := dict "vHost" "host" "backendName" "service_name" "backendPort" 8080 }}
{{ $hostRules | include "kubernetes-common.snippets.kubernetes_ingress._host_rules" }}
return: |
- host: host
  http:
    paths:
      - path: /
        backend:
          serviceName: service_name
          servicePort: 8080
*/}}

{{- define "kubernetes-common.snippets.kubernetes_ingress._host_rules" -}}
{{- $vHost := index . "vHost" -}}
{{- $backendName := index . "backendName" -}}
{{- $backendPort := index . "backendPort" -}}
- host: {{ $vHost }}
  http:
    paths:
      - path: /
        backend:
          serviceName: {{ $backendName }}
          servicePort: {{ $backendPort }}
{{- end }}

{{/*
abstract: |
  Generates an ingress for the chart, must have a matching service.
  Read the full documentation at: TBD
values: |
  networks:
    k8s_dashboard:
      ingress:
        public: true
        classes:
          cluster: "nginx"
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /
          nginx.ingress.kubernetes.io/secure-backends: "true"
          ingress.kubernetes.io/ssl-passthrough: "true"
      svc_port: 8443

  endpoints:
    cluster_domain_suffix: cluster.local
    k8s_dashboard:
      name: kubernetes-dashboard
      hosts:
        default: kubernetes-dashboard
        public: kubernetes-dashboard
      host_fqdn_override:
        default: kubernetes-dashboard.jinkit.com
      host_fqdn_tls:
        public:
          tls: true

  services:
    kubernetes_dashboard:
      name: kubernetes-dashboard
      type: ClusterIP
      labels:
        application: kubernetes-dashboard
        component: dashboard-ui
      ports:
      - name: http
        port: 8443
        targetport: 8443
Usage: |
  ingress.yaml:
    {{- $ingressOpts := dict "envAll" . "backendService" "k8s_dashboard" "backendServiceType" "k8s_dashboard" "backendPort"  .Values.networks.k8s_dashboard.svc_port -}}
    {{ $ingressOpts | include "kubernetes-common.snippets.kubernetes_ingress" }}
  service.yaml:
    {{- $serviceOpts := dict "envAll" . "context" .Values.service.kubernetes_dashboard "application" "kubernetes-dashboard" "component"  "dashboard-ui" -}}
    {{ $serviceOpts | include "kubernetes-common.manifests.kubernetes_service" }}
Return: |
  A nginx based ingress for your application. (See full documentation for more info)
*/}}

{{- define "kubernetes-common.snippets.kubernetes_ingress" -}}
{{- $envAll := index . "envAll" -}}
{{- $backendService := index . "backendService" | default "api" -}}
{{- $backendServiceType := index . "backendServiceType" -}}
{{- $backendPort := index . "backendPort" -}}
{{- $ingressName := tuple $backendServiceType "public" $envAll | include "kubernetes-common.endpoints.hostname_short_endpoint_lookup" }}
{{- $backendName := tuple $backendServiceType "internal" $envAll | include "kubernetes-common.endpoints.hostname_short_endpoint_lookup" }}
{{- $hostName := tuple $backendServiceType "public" $envAll | include "kubernetes-common.endpoints.hostname_short_endpoint_lookup" }}
{{- $hostNameFull := tuple $backendServiceType "public" $envAll | include "kubernetes-common.endpoints.hostname_fqdn_endpoint_lookup" }}
{{- $tlsSecretName := index . "secretName" | default (list $backendName "tls" | join "-") }}
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ $ingressName }}
  annotations:
    kubernetes.io/ingress.class: {{ index $envAll.Values.networks $backendService "ingress" "classes" "namespace" | quote }}
{{ toYaml (index $envAll.Values.networks $backendService "ingress" "annotations") | indent 4 }}
spec:
  rules:
{{- range $key1, $vHost := tuple $hostName (printf "%s.%s" $hostName $envAll.Release.Namespace) (printf "%s.%s.svc.%s" $hostName $envAll.Release.Namespace $envAll.Values.endpoints.cluster_domain_suffix)}}
{{- $hostRules := dict "vHost" $vHost "backendName" $backendName "backendPort" $backendPort }}
{{ $hostRules | include "kubernetes-common.snippets.kubernetes_ingress._host_rules" | indent 4}}
{{- end }}
{{- if not ( hasSuffix ( printf ".%s.svc.%s" $envAll.Release.Namespace $envAll.Values.endpoints.cluster_domain_suffix) $hostNameFull) }}
{{- $hostNameFullRules := dict "vHost" $hostNameFull "backendName" $backendName "backendPort" $backendPort }}
{{ $hostNameFullRules | include "kubernetes-common.snippets.kubernetes_ingress._host_rules" | indent 4}}
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ printf "%s-%s" $ingressName "fqdn" }}
  annotations:
    kubernetes.io/ingress.class: {{ index $envAll.Values.networks $backendService "ingress" "classes" "cluster" | quote }}
{{ toYaml (index $envAll.Values.networks $backendService "ingress" "annotations") | indent 4 }}
spec:
{{- $host := index $envAll.Values.endpoints ( $backendServiceType | replace "-" "_" ) "host_fqdn_tls" }}
{{- if hasKey $host "public" }}
{{- if $host.public.tls }}
  tls:
    - hosts:
        - {{ index $hostNameFullRules "vHost" }}
      secretName: {{ $tlsSecretName }}
{{- end }}
{{- end }}
  rules:
{{ $hostNameFullRules | include "kubernetes-common.snippets.kubernetes_ingress._host_rules" | indent 4}}
{{- end }}
{{- end }}
