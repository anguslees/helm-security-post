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
  Renders PersistentVolumeClaim template
values: |
volumes:
  pvc:
    consul_server:
      name: consul-server
      storage_class_name: rook-ceph-block
      access_modes: ReadWriteOnce
      size: 5Gi
      labels:
        application: consul-server
        component: service-mesh
usage: |
{{  dict "envAll" . "context" .Values.volumes.pvc.consul_server | include "kubernetes-common.manifests.kubernetes_persistent_volume_claim" }}
return: |
  kind: PersistentVolumeClaim
  apiVersion: v1
  metadata:
    name: consul-server
    labels:
      release_group: consul
      k8s-app: consul-server
      component: service-mesh
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: "5Gi"
    storageClassName: "rook-ceph-block"
*/}}

{{- define "kubernetes-common.manifests.kubernetes_persistent_volume_claim" -}}
{{- $envAll := index . "envAll" -}}
{{- $context := index . "context" -}}

---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: {{ $context.name | replace "_" "-" }}
{{- if $context.annotations }}
  annotations:
{{ toYaml $context.annotations | indent 4 }}
{{- end }}
  labels:
{{ tuple $envAll $context.labels.application $context.labels.component | include "kubernetes-common.snippets.kubernetes_metadata_labels" | indent 4 }}
spec:
  accessModes:
    - {{ $context.access_modes }}
{{- if $context.volume_mode }}
  volumeMode: {{ $context.volume_mode }}
{{- end }}
  resources:
    requests:
      storage: {{ $context.size | quote }}
  storageClassName: "{{ $context.storage_class_name }}"
{{- if $context.selector }}
  selector:
{{ toYaml $context.selector | indent 4 }}
{{- end }}
{{- end }}
