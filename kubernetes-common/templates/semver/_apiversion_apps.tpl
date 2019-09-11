{{/*
Original work found at: https://github.com/mintel/dex-k8s-authenticator/tree/master/charts/dex
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
  Renders the appropriate apps apiVersion using the semver of the cluster.
values: NA
usage: |
{{ include "kubernetes-common.semver.apiversion-apps" . }}
return: |
  apiVersion: apps/v1
*/}}

{{- define "kubernetes-common.semver.apiversion-apps" -}}
  {{- if semverCompare ">= 1.9-0" .Capabilities.KubeVersion.GitVersion -}}
apiVersion: apps/v1
  {{- else if semverCompare ">= 1.8-0, < 1.9-0" .Capabilities.KubeVersion.GitVersion -}}
apiVersion: apps/v1beta2
  {{- else -}}
apiVersion: apps/v1beta1
  {{- end -}}
{{- end -}}

{{/*
abstract: |
  Renders the appropriate apiVersion via a given hyperkube image and tag.
  This is limited to Kubernetes components only, such as API, Scheduler, Controller, and Proxy.
values: NA
usage: |
{{ dict "imageVersion" "1.10-0" | include "kubernetes-common.semver.apiversion-apps-image-tag" }}
return: |
  apiVersion: apps/v1
*/}}

{{- define "kubernetes-common.semver.apiversion-apps-image-tag" -}}
{{- $imageVersion := index . "imageVersion" -}}
  {{- if semverCompare ">= 1.9-0" $imageVersion -}}
apiVersion: apps/v1
  {{- else if semverCompare ">= 1.8-0, < 1.9-0" $imageVersion -}}
apiVersion: apps/v1beta2
  {{- else -}}
apiVersion: apps/v1beta1
  {{- end -}}
{{- end -}}
