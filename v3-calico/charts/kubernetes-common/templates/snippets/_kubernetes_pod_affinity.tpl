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
  Renders kubernetes affinity rules, this function supports both hard
  'requiredDuringSchedulingIgnoredDuringExecution' and soft
  'preferredDuringSchedulingIgnoredDuringExecution' types.
values: |
  pod:
    affinity:
      with:
        topologyKey:
          default: kubernetes.io/hostname
        type:
          default: requiredDuringSchedulingIgnoredDuringExecution
usage: |
  {{ tuple . "appliction_x" "component_y" | include "kubernetes-common.snippets.kubernetes_pod_affinity" }}
return: |
  podAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
          - key: release_group
            operator: In
            values:
            - RELEASE-NAME
          - key: application
            operator: In
            values:
            - appliction_x
          - key: component
            operator: In
            values:
            - component_y
          topologyKey: kubernetes.io/hostname
*/}}

{{- define "kubernetes-common.snippets.kubernetes_pod_affinity.match_expressions" -}}
{{- $envAll := index . "envAll" -}}
{{- $application := index . "application" -}}
{{- $component := index . "component" -}}
{{- $expressionRelease := dict "key" "release_group" "operator" "In"  "values" ( list ( $envAll.Values.release_group | default $envAll.Release.Name ) ) -}}
{{- $expressionApplication := dict "key" "application" "operator" "In"  "values" ( list $application ) -}}
{{- $expressionComponent := dict "key" "component" "operator" "In"  "values" ( list $component ) -}}
{{- list $expressionRelease $expressionApplication $expressionComponent | toYaml }}
{{- end -}}

{{- define "kubernetes-common.snippets.kubernetes_pod_affinity" -}}
{{- $envAll := index . 0 -}}
{{- $application := index . 1 -}}
{{- $component := index . 2 -}}
{{- $affinityType := index $envAll.Values.pod.affinity.with.type $component | default $envAll.Values.pod.affinity.with.type.default }}
{{- $affinityKey := index $envAll.Values.pod.affinity.with.topologyKey $component | default $envAll.Values.pod.affinity.with.topologyKey.default }}
podAffinity:
{{- $matchExpressions := include "kubernetes-common.snippets.kubernetes_pod_affinity.match_expressions" ( dict "envAll" $envAll "application" $application "component" $component ) -}}
{{- if eq $affinityType "preferredDuringSchedulingIgnoredDuringExecution" }}
  {{ $affinityType }}:
  - podAffinityTerm:
      labelSelector:
        matchExpressions:
{{ $matchExpressions | indent 10 }}
      topologyKey: {{ $affinityKey }}
    weight: 10
{{- else if eq $affinityType "requiredDuringSchedulingIgnoredDuringExecution" }}
  {{ $affinityType }}:
  - labelSelector:
      matchExpressions:
{{ $matchExpressions | indent 8 }}
    topologyKey: {{ $affinityKey }}
{{- end -}}
{{- end -}}

{{/*
abstract: |
  Renders kubernetes affinity rules, this function supports both hard
  'requiredDuringSchedulingIgnoredDuringExecution' and soft
  'preferredDuringSchedulingIgnoredDuringExecution' types.
values: |
  cluster:
    affinity:
      rook_ceph_osd:
        with:
          type:
            default: requiredDuringSchedulingIgnoredDuringExecution
          topologyKey:
            default: kubernetes.io/hostname
          weight: "100"
usage: |
  {{ dict "envAll" $envAll "appIndex" .Values.cluster.affinity.rook_ceph_osd "application" "rook-storage" "component" "rook-ceph-operator" | include "kubernetes-common.snippets.kubernetes_pod_affinity_dict" }}
return: |
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
            - key: release_group
              operator: In
              values:
              - rook-ceph
            - key: application
              operator: In
              values:
              - rook-storage
            - key: component
              operator: In
              values:
              - rook-ceph-operator
        topologyKey: kubernetes.io/hostname
      weight: 100
*/}}

{{- define "kubernetes-common.snippets.kubernetes_pod_affinity_dict" -}}
{{- $envAll := index . "envAll" -}}
{{- $appIndex := index . "appIndex" -}}
{{- $application := index . "application" -}}
{{- $component := index . "component" -}}
{{- $affinityType := index $appIndex.with.type $component | default $appIndex.with.type.default }}
{{- $affinityKey := index $appIndex.with.topologyKey $component | default $appIndex.with.topologyKey.default }}
podAffinity:
{{- $matchExpressions := include "kubernetes-common.snippets.kubernetes_pod_affinity.match_expressions" ( dict "envAll" $envAll "application" $application "component" $component ) -}}
{{- if eq $affinityType "preferredDuringSchedulingIgnoredDuringExecution" }}
  {{ $affinityType }}:
  - podAffinityTerm:
      labelSelector:
        matchExpressions:
{{ $matchExpressions | indent 10 }}
      topologyKey: {{ $affinityKey }}
    weight: {{ $appIndex.anti.weight | default 10 }}
{{- else if eq $affinityType "requiredDuringSchedulingIgnoredDuringExecution" }}
  {{ $affinityType }}:
  - labelSelector:
      matchExpressions:
{{ $matchExpressions | indent 8 }}
    topologyKey: {{ $affinityKey }}
    weight: {{ $appIndex.anti.weight | default 10}}
{{- end -}}
{{- end -}}
