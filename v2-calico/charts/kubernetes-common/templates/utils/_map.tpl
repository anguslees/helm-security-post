{{- /*
usage: {{ tuple (tuple flag1 flag2 ...) (tuple $list $pipeline) context | template "kubernetes-helm.kubernetes-common.utils.map" }}
returns: a list where each element $i is the result of applying the pipeline to $i
    {{ $metadata $i $context | template $pipeline }}
*/ -}}

{{- define "kubernetes-helm.kubernetes-common.utils.map" -}}
    {{- /*local variables*/ -}}
    {{- $metadata := index . 0 -}}
    {{- $data := index . 1 0 -}}
    {{- $pipeline := index . 1 1 -}}
    {{- $context := index . 2 -}}

    {{- /*pipeline*/ -}}
    {{- $local := dict "output" (list) -}}
    {{- range $datum := $data -}}
        {{- $result := tuple $metadata $datum $context | include $pipeline -}}
        {{- $aggregate := append $local.output $result -}}
        {{- $_ := set $local "output" $aggregate -}}
    {{- end -}}

    {{ $local.output }}

{{- end -}}

{{- define "kubernetes-common.utils.print_map_shallow" -}}
  {{- $map := index . 0 -}}
  {{- $ignoredKeys := index . 1 -}}
  {{- range $key, $value := $map -}}
    {{- if not (has $key $ignoredKeys) -}}
      {{- if kindIs "map" $value -}}
      {{- else -}}
        {{- if kindIs "slice" $value }}
{{ $key }}: {{ include "kubernetes-common.utils.joinListWithCommaAndBrackets" $value }}
        {{- else }}
{{ $key }}: {{ toYaml $value | trim }}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
