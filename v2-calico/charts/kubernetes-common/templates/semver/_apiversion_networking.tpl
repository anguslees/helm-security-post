{{/*
Original work found at: https://github.com/kubernetes/charts/tree/master/stable/minio
Although subject to change.
*/}}

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
  Renders the appropriate networkpolicy apiVersion using the semver of the cluster.
values: NA
usage: |
{{ include "kubernetes-common.semver.apiversion-networking" . }}
return: |
  apiVersion: networking.k8s.io/v1
*/}}

{{- define "kubernetes-common.semver.apiversion-networking" -}}
  {{- if semverCompare ">=1.4-0, <1.7-0" .Capabilities.KubeVersion.GitVersion -}}
apiVersion: extensions/v1beta1
  {{- else if semverCompare "^1.7-0" .Capabilities.KubeVersion.GitVersion -}}
apiVersion: networking.k8s.io/v1
  {{- end -}}
{{- end -}}
