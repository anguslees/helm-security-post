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
  Creates a manifest for a service's public TLS secret. Default values will be
  used when not provided for generation of CA cert and key and TLS cert and key.

  1. Given a base64 encoded TLS cert and key, the TLS cert and key will be added
     to the secret.
  2. Given a base64 encoded CA cert and key but not a TLS cert and key, the TLS
     cert and key will be generated with the CA and added to the secret.
  3. Given no CA cert and key and no TLS cert and key, the CA cert and key will
     be generated and the TLS cert and key will be generated and added to the
     secret.

  To disable TLS cert and key usage set security.tls.<APPLICATION>.public to false.
values: |
  security:
    tls:
      weave-scope:
        app:
          public:
            name: weavescope-tls-public
            ca:
              cn: fake-ca
              expire_days: 365
              data:
                crt: |
                  base64 encoded ...
                key: |
                  base64 encoded ...
            crt:
              cn: fake.com
              expire_days: 365
              ips:
                - 0.0.0.0
              dns_names:
                - "*.fake.com"
              data: |
                base64 encoded ...
            key:
              data: |
                base64 encoded ...
usage: |
  {{- tuple . "weave-scope" "app" | include "kubernetes-common.manifests.secret_ingress_tls" -}}
return: |
  ---
  apiVersion: v1
  kind: Secret
  metadata:
    name: weavescope-tls-public
  type: kubernetes.io/tls
  data:
    tls.crt: ...
    tls.key: ...
*/}}

{{- define "kubernetes-common.manifests.secret_ingress_tls" -}}
{{- $values := (index . 0).Values -}}
{{- $application := index . 1 -}}
{{- $component := index . 2 -}}

{{- $endpoint := "public" -}}
{{- if gt (len .) 3 -}}
{{- $endpoint = index . 3 -}}
{{- end -}}

{{- $confApplication := default (dict) (index $values "security" "tls" $application) -}}
{{- $confComponent := default (dict) (index $confApplication $component) -}}

{{- if not $confComponent -}}
{{- fail (printf "No configuration found for security.tls.%s.%s" $application $component) -}}
{{- end -}}

{{- $conf := default (dict) (index $confComponent $endpoint) -}}
{{- if $conf -}}

{{/* Read CA configuration with defaults */}}
{{- $caConf   := default (dict) (index $conf "ca") -}}
{{- $caData   := default (dict) (index $caConf "data") -}}
{{- $caCrt    := index $caData "crt" -}}
{{- $caKey    := index $caData "key" -}}
{{- $caCN     := default "fake-ca" (index $caConf "cn") -}}
{{- $caExpire := default 365 (index $caConf "expire_days") -}}
{{- $ca       := false -}}

{{/* Read Cert configuration with defaults */}}
{{- $crtConf     := default (dict) (index $conf "crt") -}}
{{- $crtData     := index $crtConf "data" -}}
{{- $crtCN       := default "fake.com" (index $crtConf "cn") -}}
{{- $crtExpire   := default 365 (index $crtConf "expire_days") -}}
{{- $crtIPs      := default (list "0.0.0.0") (index $crtConf "ips") -}}
{{- $crtDNSNames := default (list "*.fake.com") (index $crtConf "dns_names") -}}

{{/* Read Key configuration with defaults */}}
{{- $keyConf := default (dict) (index $conf "key") -}}
{{- $keyData := index $keyConf "data" -}}

{{/* Generate CA if necessary */}}
{{- if not (and $caCrt $caKey) -}}
{{- $ca = genCA $caCN $caExpire -}}
{{- else -}}
{{- $ca = buildCustomCert $caCrt $caKey -}}
{{- end -}}

{{/* Generate Cert and Key if necessary */}}
{{- if not (and $crtData $keyData) -}}
{{- $crt := genSignedCert $crtCN $crtIPs $crtDNSNames $crtExpire $ca -}}
{{- $crtData = $crt.Cert | b64enc -}}
{{- $keyData = $crt.Key | b64enc -}}
{{- end -}}

---
apiVersion: v1
kind: Secret
metadata:
  name: {{ index $conf "name" | default (printf "%s-%s-%s-tls" $application $component $endpoint) }}
type: kubernetes.io/tls
data:
  tls.crt: {{ $crtData }}
  tls.key: {{ $keyData }}

{{- end -}}
{{- end -}}
