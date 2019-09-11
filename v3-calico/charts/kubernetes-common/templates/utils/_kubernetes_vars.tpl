{{/*
Copyright 2017 The Openstack-Helm Authors.
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

{{- define "kubernetes-common.utils.kubernetes_vars" -}}
{{ range $key, $value := . -}}
{{- if kindIs "slice" $value -}}
- name: {{ $key }}
  value: {{ include "kubernetes-common.utils.joinListWithComma" $value | quote }}
{{ else if kindIs "map" $value -}}
- name: {{ $key }}
{{ toYaml $value | trim | indent 2 }}
{{ else -}}
- name: {{ $key }}
  value: {{ $value | quote }}
{{ end -}}
{{- end -}}
{{- end -}}
