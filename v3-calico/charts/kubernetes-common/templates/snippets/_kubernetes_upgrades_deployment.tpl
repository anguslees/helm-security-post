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

{{- define "kubernetes-common.snippets.kubernetes_upgrades_deployment" -}}
{{- $envAll := index . 0 -}}
{{- $pod := index . 1 -}}
{{- with (index $envAll.Values.pod.lifecycle $pod "upgrades" "deployments") -}}
revisionHistoryLimit: {{ .revision_history }}
minReadySeconds: {{ .min_ready_seconds | default "0" }}
strategy:
  type: {{ .pod_replacement_strategy }}
  {{- if eq .pod_replacement_strategy "RollingUpdate" }}
  rollingUpdate:
    maxUnavailable: {{ .rolling_update.max_unavailable | default "1" }}
    maxSurge: {{ .rolling_update.max_surge | default "3" }}
  {{- end }}
{{- end -}}
{{- end -}}
