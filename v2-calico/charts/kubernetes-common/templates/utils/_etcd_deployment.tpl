{{- define "kubernetes-helm.kubernetes-common.utils.etcd_deployment" -}}
    {{- /*includes*/ -}}
    {{- $map := "kubernetes-helm.kubernetes-common.utils.map" -}}
    {{- $join := "kubernetes-helm.kubernetes-common.utils.join" -}}
    {{- $format_url_pipeline := "kubernetes-helm.kubernetes-common.utils.etcd_deployment.format_url"}}

    {{- /*local variables*/ -}}
    {{- $client_port := .Values.network.etcd.client_port -}}
    {{- $tls_enabled := .Values.network.tls_enabled -}}
    {{- $etcd_servers := .Values.endpoints.etcd -}}

    {{- $protocol := dict "value" "" -}}
    {{- if $tls_enabled -}}
        {{- $_ := set $protocol "value" "https" -}}
    {{- else -}}
        {{- $_ := set $protocol "value" "http" -}}
    {{- end -}}

    {{- /*pipeline*/ -}}
    {{- $etcd_servers := tuple (dict "protocol" $protocol.value "port" $client_port) (tuple $etcd_servers $format_url_pipeline) . | include $map -}}
    {{- /*TODO: Find a more elegant way to do this*/ -}}
    {{- $etcd_servers := $etcd_servers | trimPrefix "[" | trimSuffix "]" | splitList " " -}}
    {{- $output := tuple (dict "leadingseparator" false "trailingseparator" true "separatorchar" ",") (tuple $etcd_servers) . | include $join -}}
    {{ $output }}
{{- end -}}

{{- define "kubernetes-helm.kubernetes-common.utils.etcd_deployment.format_url" -}}
    {{- $protocol := (index . 0).protocol -}}
    {{- $port := (index . 0).port -}}
    {{- $server := index . 1 -}}
    {{- $protocol -}}{{- print "://" -}}{{- $server -}}{{- print ":" -}}{{- $port -}}
{{- end -}}