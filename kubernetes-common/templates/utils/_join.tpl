{{- /*
usage: {{ tuple (tuple $leadingSeparator $trailingSeparator) (tuple $list $separator) context | template "kubernetes-helm.kubernetes-common.utils.join" }}
returns: a string where each element $i of $list is printed with $separator between them, optionally with leading and trailing separators
*/ -}}

{{- define "kubernetes-helm.kubernetes-common.utils.join" -}}
    {{- /*includes*/ -}}
    {{- $reduce := "kubernetes-helm.kubernetes-common.utils.reduce" -}}
    {{- $bifunction := "kubernetes-helm.kubernetes-common.utils.join.bifunction" -}}

    {{- /*local variables*/ -}}
    {{- $metadata := index . 0 -}}
    {{- $separator := $metadata.separatorchar}}
    {{- $list := index . 1 0 -}}
    {{- $context := index . 2 -}}

    {{- /*pipeline*/ -}}
    {{- if $metadata.leadingSeparator -}}
        {{- $separator }}
    {{- end -}}

    {{ tuple (tuple $separator) (tuple $list $bifunction) . | include $reduce }}

    {{- if $metadata.trailingSeparator -}}
        {{- $separator -}}
    {{- end -}}

{{- end -}}

{{- define "kubernetes-helm.kubernetes-common.utils.join.bifunction" -}}

    {{- $metadata := index . 0 -}}
    {{- $separator := index $metadata 0 -}}
    {{- $a := index . 1 0 -}}
    {{- $b := index . 1 1 -}}

    {{ $a }}{{ $separator }}{{ $b }}

{{- end -}}