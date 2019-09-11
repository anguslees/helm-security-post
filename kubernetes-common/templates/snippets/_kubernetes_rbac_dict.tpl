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
  Renders kubernetes RBAC rules, this function supports both
  application roles and cluster roles.
values: |
security:
  rbac:
    rook_ceph_cluster_mgmt:
      - apigroups:
          - ""
        resources:
          - secrets
          - pods
          - services
          - configmaps
        verbs:
          - get
          - list
          - watch
          - patch
          - create
          - update
          - delete
      - apigroups:
          - extensions
        resources:
          - deployments
          - daemonsets
          - replicasets
        verbs:
          - get
          - list
          - watch
          - create
          - update
          - delete
usage: |
{{- $envAll := . }}
{{- $rbacRules := .Values.security.rbac.rook_ceph_cluster_mgmt }}
{{- $serviceAccountName := "rook-ceph-system" }}
{{- $namespace := "rook-ceph-system" }}
{{  dict "envAll" $envAll "rbacRules" $rbacRules "serviceAccountName" $serviceAccountName "clusterBinding" "true" "namespace" $namespace "roleName" "rook-ceph-cluster-mgmt" | include "kubernetes-common.snippets.kubernetes_rbac_dict" }}
return: |
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRoleBinding
  metadata:
    name: rook-ceph-cluster-mgmt-crb
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: rook-ceph-cluster-mgmt-clusterrole
  subjects:
    - kind: ServiceAccount
      name: rook-ceph-system
      namespace: rook-ceph-system

  ---

  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRole
  metadata:
    name: rook-ceph-cluster-mgmt-clusterrole
    namespace: rook-ceph-system
  rules:
  - apiGroups: [""]
    resources: ["secrets","pods","services","configmaps"]
    verbs: ["get","list","watch","patch","create","update","delete"]
  - apiGroups: ["extensions"]
    resources: ["deployments","daemonsets","replicasets"]
    verbs: ["get","list","watch","create","update","delete"]
*/}}

{{- define "kubernetes-common.snippets.kubernetes_rbac_dict" -}}
{{- $envAll := index . "envAll" -}}
{{- $deps := index . "rbacRules" -}}
{{- $saName := index . "serviceAccountName" -}}
{{- $namespace := index . "namespace" | default $envAll.Release.Namespace }}
{{- $releaseName := index . "releaseName" | default $envAll.Release.Name }}
{{- $clusterBinding := index . "clusterBinding" }}
{{- $userName := index . "userName" }}
{{- $defaultRoleName := printf "%s-%s-%s" $releaseName $namespace $saName }}
{{- $roleName := index . "roleName" | default $defaultRoleName }}

{{- $rbacOpts := dict "serviceAccountName" $saName "userName" $userName "namespace" $namespace "releaseName" $releaseName "clusterBinding" $clusterBinding "roleName" $roleName }}
{{- $dictDeps := dict "deps" $deps  }}
{{- $rbacOptsWithDeps := merge $rbacOpts $dictDeps }}
{{ $rbacOpts | include "kubernetes-common.snippets.kubernetes_rbac_binding_dict" }}
{{ $rbacOptsWithDeps | include "kubernetes-common.snippets.kubernetes_rbac_role_dict" }}

{{- end -}}

{{- define "kubernetes-common.snippets.kubernetes_rbac_sa_dict" -}}
{{- $saName := index . "serviceAccountName" -}}
{{- $namespace := index . "namespace" -}}

apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $saName }}
  namespace: {{ $namespace }}
---
{{- end -}}

{{- define "kubernetes-common.snippets.kubernetes_rbac_user_dict" -}}
{{- $userName := index . "userName" -}}
{{- $namespace := index . "namespace" -}}

apiVersion: v1
kind: User
metadata:
  name: {{ $userName }}
  namespace: {{ $namespace }}
---
{{- end -}}

{{- define "kubernetes-common.snippets.kubernetes_rbac_binding_dict" -}}
{{- $saName := index . "serviceAccountName" -}}
{{- $namespace := index . "namespace" -}}
{{- $userName := index . "userName" }}
{{- $releaseName := index . "releaseName" -}}
{{- $clusterBinding := index . "clusterBinding" -}}
{{- $roleName := index . "roleName" -}}

{{ if eq $clusterBinding "true" }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ $roleName }}-crb
{{- else }}
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: {{ $roleName }}-rb
  namespace: {{ $namespace }}
{{- end }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  {{- if eq $clusterBinding "true" }}
  kind: ClusterRole
  name: {{ $roleName }}-clusterrole
  {{- else }}
  kind: Role
  name: {{ $roleName }}-role
  {{- end }}
subjects:
  {{ if $saName }}
  - kind: ServiceAccount
    name: {{ $saName }}
    namespace: {{ $namespace }}
  {{ end }}
  {{ if $userName }}
  - kind: User
    name: {{ $userName }}
    namespace: {{ $namespace }}
  {{- end }}
---
{{- end -}}

{{- define "kubernetes-common.snippets.kubernetes_rbac_role_dict" -}}
{{- $saName := index . "serviceAccountName" -}}
{{- $namespace := index . "namespace" -}}
{{- $releaseName := index . "releaseName" -}}
{{- $clusterBinding := index . "clusterBinding" -}}
{{- $deps := index . "deps" -}}
{{- $roleName := index . "roleName" -}}

{{ if eq $clusterBinding "true" }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ $roleName }}-clusterrole
{{- else }}
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: {{ $roleName }}-role
{{- end }}
  namespace: {{ $namespace }}
rules:
{{range $k, $v := $deps -}}
- apiGroups: {{ if typeIs "[]interface {}" $v.apigroups }}{{ include "kubernetes-common.utils.joinListWithCommaAndBrackets" $v.apigroups }} {{ else -}} [{{ $v.apigroups | quote }}] {{ end }}
  resources: {{ if typeIs "[]interface {}" $v.resources }}{{ include "kubernetes-common.utils.joinListWithCommaAndBrackets" $v.resources }} {{ else -}} [{{ $v.resources | quote }}] {{ end }}
  verbs: {{ if typeIs "[]interface {}" $v.verbs }}{{ include "kubernetes-common.utils.joinListWithCommaAndBrackets" $v.verbs }} {{ else -}} [{{ $v.verbs | quote }}] {{ end }}
{{end -}}
---
{{- end -}}
