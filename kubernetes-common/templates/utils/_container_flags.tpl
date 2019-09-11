{{/*
Copyright 2019 Brandon B. Jozsa/JinkIT and its authors.
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

{{- define "kubernetes-common.utils.container_flags" -}}
{{- range $key, $value := . -}}
{{- if typeIs "[]interface {}" $value -}}
- -- {{- $key | replace "_" "-" -}} = {{- include "kubernetes-common.utils.joinListWithComma" $value }}
{{else -}}
- -- {{- $key | replace "_" "-" -}} = {{- $value }}
{{end -}}
{{end -}}
{{- end -}}


{{/*
abstract: |
  Renders single dash arugments patterns for
values: |
  args:
   consul_sync_catalog:
     http_addr: "${HOST_IP}:8500"
     k8s_default_sync: true
     consul_domain: consul
     k8s_write_namespace: "${NAMESPACE}"
usage: |
{{  include "kubernetes-common.utils.container_flags_single_dash" .Values.args.consul_sync_catalog | trim | indent 4 }}
return:
    -consul-domain=consul
    -http-addr=${HOST_IP}:8500
    -k8s-default-sync=true
    -k8s-write-namespace=${NAMESPACE}
*/}}

{{- define "kubernetes-common.utils.container_flags_single_dash" -}}
{{- range $key, $value := . -}}
{{- if typeIs "[]interface {}" $value -}}
-{{- $key | replace "_" "-" -}}="{{- include "kubernetes-common.utils.joinListWithComma" $value }}" \
{{else -}}
-{{- $key | replace "_" "-" -}}="{{- $value }}" \
{{end -}}
{{end -}}
{{- end -}}
