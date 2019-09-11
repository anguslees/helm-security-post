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
abstract:
  Renders application selector based on values.yaml
example in values.yaml:
selectors:
  service:
    component: app
usage in template:
{{ dict "envAll" $envAll "selectors" "service" | include "kubernetes-common.snippets.kubernetes_selector" | indent 4 }}
return rendered manifest: |
  selector:
    component: app
*/}}
{{- define "kubernetes-common.snippets.kubernetes_selector" -}}
{{- $envAll := index . "envAll" -}}
{{- $selectors := index . "selectors" -}}
{{ index $envAll.Values.selectors $selectors | toYaml }}
{{- end -}}
