{{- /*
usage: {{ tuple (tuple flag1 flag2 ...) (tuple $list $pipeline) context | template "kubernetes-helm.kubernetes-common.utils.reduce" }}
returns: a single element which is the result of successively applying $pipeline to the elements of $data
    ex: {{ tuple (tuple) (tuple (list 1 2 3 4 5) "bifunctionadder") . | include "kubernetes-helm.kubernetes-common.utils.reduce" }}
        would return 15 (equal to 1+2+3+4+5); "bifunctionadder" needs to have the same form as all other functions in this
        library, i.e. - tuple $metadata $arguments . | "bifunctionadder"

        {{- define "bifunctionadder" -}}
            {{- $metadata := index . 0 -}}
            {{- $a := index . 1 0 -}}
            {{- $b := index . 1 1 -}}
            {{- $output := add a b -}}
            {{ $output }}
        {{- end -}}

*/ -}}
{{- define "kubernetes-helm.kubernetes-common.utils.reduce" -}}
    {{- /*local variables*/ -}}
    {{- $metadata := index . 0 -}}
    {{- $data := index . 1 0 -}}
    {{- $bifunction := index . 1 1 -}}
    {{- $context := index . 2 -}}

    {{- $local := dict "first" true "acc" (index $data 0) -}}
    {{- range $i := $data | rest | len | until -}}
        {{- $val := index $data (add1 $i) -}}
        {{- $combined := tuple $metadata (tuple $local.acc $val) . | include $bifunction -}}
        {{- $_ := set $local "acc" $combined -}}
    {{- end -}}

    {{ $local.acc }}
{{- end -}}