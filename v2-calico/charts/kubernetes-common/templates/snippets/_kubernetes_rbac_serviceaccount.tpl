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

{{- define "kubernetes-common.snippets.kubernetes_rbac_serviceaccount" -}}
{{- $envAll := index . 0 -}}
{{- $deps := index . 1 -}}
{{- $saName := index . 2 -}}
{{- $saNamespace := $envAll.Release.Namespace }}
{{- $releaseName := $envAll.Release.Name }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $saName }}
  namespace: {{ $saNamespace }}
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: {{ $releaseName }}-{{ $saName }}
  namespace: {{ $saNamespace }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ $releaseName }}-{{ $saNamespace }}-{{ $saName }}
subjects:
  - kind: ServiceAccount
    name: {{ $saName }}
    namespace: {{ $saNamespace }}
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: {{ $releaseName }}-{{ $saNamespace }}-{{ $saName }}
  namespace: {{ $saNamespace }}
rules:
{{range $k, $v := $deps -}}
- apiGroups: {{ if typeIs "[]interface {}" $v.apigroups }}{{ include "kubernetes-common.utils.joinListWithCommaAndBrackets" $v.apigroups }} {{ else -}} [{{ $v.apigroups | quote }}] {{ end }}
  resources: {{ if typeIs "[]interface {}" $v.resources }}{{ include "kubernetes-common.utils.joinListWithCommaAndBrackets" $v.resources }} {{ else -}} [{{ $v.resources | quote }}] {{ end }}
  verbs: {{ if typeIs "[]interface {}" $v.verbs }}{{ include "kubernetes-common.utils.joinListWithCommaAndBrackets" $v.verbs }} {{ else -}} [{{ $v.verbs | quote }}] {{ end }}
{{end -}}
{{- end -}}