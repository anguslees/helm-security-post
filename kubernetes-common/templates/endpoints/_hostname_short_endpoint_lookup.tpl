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
  Renders the appropriate name for a network endpoint:
    If "example-value" is an IPv4 Address or the endpoint is not defined,
      $backendServiceType will be returned as a yaml-safe value ("-" to "_")
    Otherwise "example-value" will be returned
values: |
endpoints:
  example_service:
    hosts:
      example_endpoint: "example-value"
usage: |
{{ $backendServiceType := "example-service" }}
{{ $endpoint := "example-endpoint" }}
{{ $envAll := . }}
{{ tuple $backendServiceType $endpoint $envAll | include "kubernetes-common.endpoints.hostname_short_endpoint_lookup" }}
return: |
example-value
*/}}

{{- define "kubernetes-common.endpoints.hostname_short_endpoint_lookup" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $context := index . 2 -}}
{{- $typeYamlSafe := $type | replace "-" "_" }}
{{- $endpointMap := index $context.Values.endpoints $typeYamlSafe }}
{{- with $endpointMap -}}
{{- $endpointScheme := .scheme }}
{{- $endpointHost := index .hosts $endpoint | default .hosts.default}}
{{- if regexMatch "[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+" $endpointHost }}
{{- printf "%s" $typeYamlSafe -}}
{{- else }}
{{- $endpointHostname := printf "%s" $endpointHost }}
{{- printf "%s" $endpointHostname -}}
{{- end }}
{{- end -}}
{{- end -}}
