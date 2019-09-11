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
  Renders pod-level volumes via Chart values.
values: |
volumes:
  pod:
    coredns:
    - name: config-volume
      configMap:
        name: coredns-etc
        items:
        - key: Corefile
          path: Corefile
usage: |
{{ dict "envAll" . "pod" "coredns" | include "kubernetes-common.snippets.volumes" }}
return: |
- configMap:
    items:
    - key: Corefile
      path: Corefile
    name: coredns-etc
  name: config-volume
*/}}

{{- define "kubernetes-common.snippets.volumes" -}}
{{- $envAll := index . "envAll" -}}
{{- $pod := index . "pod" -}}
{{ index $envAll.Values.volumes.pods $pod | toYaml }}
{{- end -}}

{{/*
abstract: |
  Renders container-level mountPath via Chart values.
values: |
volumes:
  container:
    coredns:
    - name: config-volume
      mountPath: /etc/coredns
usage: |
{{ dict "envAll" . "container" "coredns" | include "kubernetes-common.snippets.volume-mount" -}}
return: |
- mountPath: /etc/coredns
  name: config-volume
*/}}

{{- define "kubernetes-common.snippets.volume-mount" -}}
{{- $envAll := index . "envAll" -}}
{{- $container := index . "container" -}}
{{ index $envAll.Values.volumes.containers $container | toYaml }}
{{- end -}}
