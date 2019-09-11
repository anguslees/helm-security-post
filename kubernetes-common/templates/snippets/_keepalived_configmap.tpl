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

{{- define "kubernetes-common.snippets.keepalived_configmap" -}}
{{- $envAll := index . 0 -}}
{{- $component := index . 1 -}}
{{- $servicename := index . 2 -}}
{{- $serviceNamespace := index . 3 -}}
{{- $namespace := $envAll.Release.Namespace }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: vip-configmap
  namespace: {{ $namespace }}
data:
  {{ $component.virtual_ip }}: {{ $serviceNamespace }}/{{ $servicename }}:{{ $component.forwarding_method }}
{{- end -}}
