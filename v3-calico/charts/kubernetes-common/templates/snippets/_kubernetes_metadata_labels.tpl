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
  Creates metadata labels for a chart based on release_group, date, application name, component, and values.yaml
  Default values can be disabled by setting them to boolean false (I.E. date: false)
  Full documentation can be seen at: TBD
values: |
  labels:
    datacenter: us-east-1
    agent:
      version: 1.9.0
    other_component:
      component_key: value
usage: |
  {{ tuple $envAll "weave-scope" "agent" | include "kubernetes-common.snippets.kubernetes_metadata_labels" }}
return: |
  release_group: release-name
  date: 2019-02-04
  app: weave-scope
  component: agent
  datacenter: us-east-1
  version: 1.9.0
*/}}

{{- define "kubernetes-common.snippets.kubernetes_metadata_labels" -}}
{{- $envAll := index . 0 -}}
{{- $application := index . 1 -}}
{{- $component := index . 2 -}}
{{- $release_group := true -}}
{{- $date := true -}}
{{- $app := true -}}
{{- $component_label := true -}}
{{- if index $envAll.Values "labels" -}}
  {{- range $key, $value := (index $envAll.Values "labels") -}}
    {{- if eq $key "release_group" -}}
      {{- $release_group = $value -}}
    {{- end -}}
    {{- if eq $key "date" -}}
      {{- $date = $value -}}
    {{- end -}}
    {{- if eq $key "app" -}}
      {{- $app = $value -}}
    {{- end -}}
    {{- if eq $key "component" -}}
      {{- $component_label = $value -}}
    {{- end -}}
  {{- end -}}
  {{- if index $envAll.Values "labels" $component -}}
    {{- range $key, $value := (index $envAll.Values "labels" $component) -}}
      {{- if eq $key "release_group" -}}
        {{- $release_group = $value -}}
      {{- end -}}
      {{- if eq $key "date" -}}
        {{- $date = $value -}}
      {{- end -}}
      {{- if eq $key "app" -}}
        {{- $app = $value -}}
      {{- end -}}
      {{- if eq $key "component" -}}
        {{- $component_label = $value -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- if $release_group -}}
  {{- if kindIs "bool" $release_group -}}
    {{- $release_group = $envAll.Values.release_group | default $envAll.Release.Name -}}
  {{- end }}
release_group: {{ $release_group }}
{{- end -}}
{{- if $date -}}
  {{- if kindIs "bool" $date -}}
    {{- $date = now | htmlDate -}}
  {{- end }}
date: {{ $date }}
{{- end -}}
{{- if $app -}}
  {{- if kindIs "bool" $app -}}
    {{- $app = $application -}}
  {{- end }}
app: {{ $app }}
{{- end -}}
{{- if $component_label -}}
  {{- if kindIs "bool" $component_label -}}
    {{- $component_label = $component -}}
  {{- end }}
component: {{ $component_label }}
{{- end -}}
{{- if $envAll.Values.labels -}}
{{ tuple $envAll.Values.labels (list "release_group" "date" "app" "component") | include "kubernetes-common.utils.print_map_shallow" }}
{{- if index $envAll.Values.labels $component -}}
{{ tuple (index $envAll.Values.labels $component) (list "release_group" "date" "app" "component") | include "kubernetes-common.utils.print_map_shallow" }}
{{- end -}}
{{- end -}}
{{- end -}}
