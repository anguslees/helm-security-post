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
  Renders kubernetes resource limits
values: |
  pod:
    resources:
      enabled: true
      rook_ceph_operator:
        requests:
          memory: "128Mi"
          cpu: "100m"
        limits:
          memory: "1024Mi"
          cpu: "500m"
usage: |
  {{ tuple $envAll $envAll.Values.pod.resources.rook_ceph_operator | include "kubernetes-common.snippets.kubernetes_resources" }}
return: |
  resources:
    limits:
      cpu: "500m"
      memory: "1024Mi"
    requests:
      cpu: "100m"
      memory: "128Mi"
*/}}

{{- define "kubernetes-common.snippets.kubernetes_resources" -}}
{{- $envAll := index . 0 -}}
{{- $component := index . 1 -}}
{{- if $envAll.Values.pod.resources.enabled -}}
resources:
  limits:
    cpu: {{ $component.limits.cpu | quote }}
    memory: {{ $component.limits.memory | quote }}
  requests:
    cpu: {{ $component.requests.cpu | quote }}
    memory: {{ $component.requests.memory | quote }}
{{- end -}}
{{- end -}}

{{/*
abstract: |
  Renders kubernetes resource limits
values: |
  cluster:
    resources:
      rook_ceph_mgr:
        enabled: true
        requests:
          memory: "1024Mi"
          cpu: "500m"
        limits:
          memory: "1024Mi"
          cpu: "500m"
usage: |
  {{ dict "component" $envAll.Values.cluster.resources.rook_ceph_mgr | include "kubernetes-common.snippets.kubernetes_cluster_resources" }}
return: |
  limits:
    cpu: "500m"
    memory: "1024Mi"
  requests:
    cpu: "500m"
    memory: "1024Mi"
*/}}

{{- define "kubernetes-common.snippets.kubernetes_cluster_resources" -}}
{{- $component := index . "component" -}}
{{- if $component.enabled -}}
limits:
  cpu: {{ $component.limits.cpu | quote }}
  memory: {{ $component.limits.memory | quote }}
requests:
  cpu: {{ $component.requests.cpu | quote }}
  memory: {{ $component.requests.memory | quote }}
{{- end -}}
{{- end -}}
