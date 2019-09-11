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
  Renders the fqdn for a given app, allows for overrides.
  Full description can be seen at: TBD
values: |
endpoints:
  cluster_domain_suffix: "cluster.local"
  app_name:
    namespace: "kube-system"
    hosts:
      public: "app-0"
    host_fqdn_override: {}
usage: |
{{- $envAll := . }}
{{- tuple "app_name" "public" $envAll | include "kubernetes-common.endpoints.hostname_fqdn_endpoint_lookup" }}
return: |
"app-0.kube-system.svc.cluster.local"
*/}}

{{- define "kubernetes-common.endpoints.hostname_fqdn_endpoint_lookup" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $context := index . 2 -}}
{{- $typeYamlSafe := $type | replace "-" "_" }}
{{- $clusterSuffix := printf "%s.%s" "svc" $context.Values.endpoints.cluster_domain_suffix }}
{{- $endpointMap := index $context.Values.endpoints $typeYamlSafe }}
{{- with $endpointMap -}}
{{- $namespace := .namespace | default $context.Release.Namespace }}
{{- $endpointScheme := .scheme }}
{{- $endpointHost := index .hosts $endpoint | default .hosts.default }}
{{- $endpointClusterHostname := printf "%s.%s.%s" $endpointHost $namespace $clusterSuffix }}
{{- $endpointHostname := index .host_fqdn_override $endpoint | default .host_fqdn_override.default | default $endpointClusterHostname }}
{{- printf "%s" $endpointHostname -}}
{{- end -}}
{{- end -}}
