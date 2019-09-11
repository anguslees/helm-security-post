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
Create chart name and version as used by the chart label.
*/}}
{{- define "kubernetes-common.utils.chart_label" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
