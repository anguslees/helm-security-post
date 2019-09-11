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
  Renders a security context for specified pod.

values: |
security:
  pods:
    mongodb:
      security_context:
        fsGroup: 999
        runAsUser: 999
        allowPrivilegeEscalation: false
        capabilities:
          add: ["NET_ADMIN", "SYS_TIME"]
        seLinuxOptions:
          level: "s0:c123,c456"

usage: |
{{ dict "envAll" . "pod" "mongodb" | include "kubernetes-common.snippets.security-context-pod" }}

return: |
securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    add:
    - NET_ADMIN
    - SYS_TIME
  fsGroup: 999
  runAsUser: 999
  seLinuxOptions:
    level: s0:c123,c456

*/}}
{{- define "kubernetes-common.snippets.security-context-pod" -}}
{{- $envAll := index . "envAll" }}
{{- $pod := index . "pod" }}
{{- $isSecurityContextEnabled := index $envAll.Values.security "pods" $pod "security_context" "enabled" }}
  {{- if $isSecurityContextEnabled  }}
securityContext:
{{- $cleanMap := unset (index $envAll.Values.security "pods" $pod "security_context") "enabled" }}
{{ toYaml $cleanMap | indent 2 }}
  {{- end}}
{{- end -}}

{{/*
abstract: |
  Renders a security context for a given container.

values: |
security:
  container:
    mongodb:
      security_context:
        fsGroup: 999
        runAsUser: 999
        allowPrivilegeEscalation: false
        capabilities:
          add: ["NET_ADMIN", "SYS_TIME"]
        seLinuxOptions:
          level: "s0:c123,c456"

usage: |
{{ dict "envAll" . "container" "mongodb" | include "kubernetes-common.snippets.security-context-container" }}

return: |
securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    add:
    - NET_ADMIN
    - SYS_TIME
  fsGroup: 999
  runAsUser: 999
  seLinuxOptions:
    level: s0:c123,c456

*/}}

{{- define "kubernetes-common.snippets.security-context-container" -}}
{{- $envAll := index . "envAll" }}
{{- $container := index . "container" }}
{{- $isSecurityContextEnabled := index $envAll.Values.security "containers" $container "security_context" "enabled" }}
  {{- if $isSecurityContextEnabled  }}
securityContext:
{{- $cleanMap := unset (index $envAll.Values.security "containers" $container "security_context") "enabled" }}
{{ toYaml $cleanMap | indent 2 }}
  {{- end}}
{{- end -}}
