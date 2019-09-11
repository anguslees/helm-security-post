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

{{- define "kubernetes-common.snippets.kubernetes_rbac" -}}
---
{{- $envAll := index . 0 -}}
{{- $deps := index . 1 -}}
{{- $saName := index . 2 -}}
{{- $saNamespace := $envAll.Release.Namespace }}
{{- $releaseName := $envAll.Release.Name }}
{{- $clusterBinding := false }}
{{- $roleName := printf "%s-%s-%s" $releaseName $saNamespace $saName }}
{{- $clusterroleName := printf "%s-%s" $releaseName $saName }}

{{ tuple $saName $saNamespace $releaseName $clusterBinding $roleName $clusterroleName | include "kubernetes-common.snippets.kubernetes_rbac_binding" }}
{{ tuple $saName $saNamespace $releaseName $clusterBinding $deps $roleName $clusterroleName | include "kubernetes-common.snippets.kubernetes_rbac_role" }}

{{- end -}}

{{- define "kubernetes-common.snippets.kubernetes_rbac_cluster" -}}
---
{{- $envAll := index . 0 -}}
{{- $deps := index . 1 -}}
{{- $saName := index . 2 -}}
{{- $saNamespace := $envAll.Release.Namespace }}
{{- $releaseName := $envAll.Release.Name }}
{{- $clusterBinding := true }}
{{- $roleName := printf "%s-%s-%s" $releaseName $saNamespace $saName }}
{{- $clusterroleName := printf "%s-%s" $releaseName $saName }}

{{ tuple $saName $saNamespace $releaseName $clusterBinding $roleName $clusterroleName | include "kubernetes-common.snippets.kubernetes_rbac_binding" }}
{{ tuple $saName $saNamespace $releaseName $clusterBinding $deps $roleName $clusterroleName | include "kubernetes-common.snippets.kubernetes_rbac_role" }}

{{- end -}}

{{- define "kubernetes-common.snippets.kubernetes_rbac_existing_role" -}}
---
{{- $envAll := index . 0 -}}
{{- $roleName := index . 1 -}}
{{- $saName := index . 2 -}}
{{- $saNamespace := $envAll.Release.Namespace }}
{{- $releaseName := $envAll.Release.Name }}
{{- $clusterBinding := true }}

{{ tuple $saName $saNamespace $releaseName $clusterBinding $roleName | include "kubernetes-common.snippets.kubernetes_rbac_binding_existing_role" }}

{{- end -}}


{{- define "kubernetes-common.snippets.kubernetes_rbac_sa" -}}
---
{{- $saName := index . 0 -}}
{{- $saNamespace := index . 1 }}

apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $saName }}
  namespace: {{ $saNamespace }}
{{- end -}}

{{- define "kubernetes-common.snippets.kubernetes_rbac_binding" -}}
---
{{- $saName := index . 0 -}}
{{- $saNamespace := index . 1 -}}
{{- $releaseName := index . 2 -}}
{{- $clusterBinding := index . 3 -}}
{{- $roleName := index . 4 -}}
{{- $clusterroleName := index . 5 -}}

{{ if $clusterBinding }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ $releaseName }}-{{ $saName }}-crb
{{- else }}
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: {{ $releaseName }}-{{ $saName }}-rb
  namespace: {{ $saNamespace }}
{{- end }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  {{- if $clusterBinding }}
  kind: ClusterRole
  name: {{ $clusterroleName }}-clusterrole
  {{- else }}
  kind: Role
  name: {{ $roleName }}-role
  {{- end }}
subjects:
  - kind: ServiceAccount
    name: {{ $saName }}
    namespace: {{ $saNamespace }}
{{- end }}


{{- define "kubernetes-common.snippets.kubernetes_rbac_binding_diffsa" -}}
---
{{- $name := index . 0 -}}
{{- $deps := index . 1 -}}
{{- $saNamespace := index . 2 -}}
{{- $releaseName := index . 3 -}}
{{- $clusterBinding := index . 4 -}}
{{- $roleName := index . 5 -}}
{{- $clusterroleName := index . 6 -}}

{{ if $clusterBinding }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ $releaseName }}-{{ $name }}-crb
{{- else }}
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: {{ $releaseName }}-{{ $name }}-rb
  namespace: {{ $saNamespace }}
{{- end }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  {{- if $clusterBinding }}
  kind: ClusterRole
  name: {{ $clusterroleName }}-clusterrole
  {{- else }}
  kind: Role
  name: {{ $roleName }}-role
  {{- end }}
subjects:
  {{range $k, $v := $deps -}}
  - kind: ServiceAccount
    name: {{ $v }}
    namespace: {{ $saNamespace }}
  {{end -}}
{{- end -}}

{{- define "kubernetes-common.snippets.kubernetes_rbac_binding_existing_role" -}}
---
{{- $saName := index . 0 -}}
{{- $saNamespace := index . 1 -}}
{{- $releaseName := index . 2 -}}
{{- $clusterBinding := index . 3 -}}
{{- $roleName := index . 4 -}}

{{ if $clusterBinding }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ $releaseName }}-{{ $saName }}-crb
{{- else }}
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: {{ $releaseName }}-{{ $saName }}-rb
  namespace: {{ $saNamespace }}
{{- end }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  {{- if $clusterBinding }}
  kind: ClusterRole
  name: {{ $roleName }}
  {{- else }}
  kind: Role
  name: {{ $roleName }}
  {{- end }}
subjects:
  - kind: ServiceAccount
    name: {{ $saName }}
    namespace: {{ $saNamespace }}
{{- end -}}

{{- define "kubernetes-common.snippets.kubernetes_rbac_role" -}}
---
{{- $saName := index . 0 -}}
{{- $saNamespace := index . 1 -}}
{{- $releaseName := index . 2 -}}
{{- $clusterBinding := index . 3 -}}
{{- $deps := index . 4 -}}
{{- $roleName := index . 5 -}}
{{- $clusterroleName := index . 6 -}}

{{ if $clusterBinding }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ $clusterroleName }}-clusterrole
{{- else }}
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: {{ $roleName }}-role
  namespace: {{ $saNamespace }}
{{- end }}
rules:
{{range $k, $v := $deps -}}
- apiGroups: {{ if typeIs "[]interface {}" $v.apigroups }}{{ include "kubernetes-common.utils.joinListWithCommaAndBrackets" $v.apigroups }} {{ else -}} [{{ $v.apigroups | quote }}] {{ end }}
  resources: {{ if typeIs "[]interface {}" $v.resources }}{{ include "kubernetes-common.utils.joinListWithCommaAndBrackets" $v.resources }} {{ else -}} [{{ $v.resources | quote }}] {{ end }}
  verbs: {{ if typeIs "[]interface {}" $v.verbs }}{{ include "kubernetes-common.utils.joinListWithCommaAndBrackets" $v.verbs }} {{ else -}} [{{ $v.verbs | quote }}] {{ end }}
{{end -}}
{{- end }}
