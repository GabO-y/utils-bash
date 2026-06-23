#!/usr/bin/env bash

cmd_resize() {
    if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_resize_help
        return 0
    fi

    [[ $# -lt 2 ]] && die "Uso: utils resize <imagem> <dimensão> [-o <nome>]"

    local input="$1"
    local dimension="$2"
    local output_name=""
    shift 2

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o) shift; output_name="$1" ;;
            *) die "Argumento desconhecido: $1" ;;
        esac
        shift
    done

    [[ ! -f "$input" ]] && die "Arquivo não encontrado: $input"

    check_deps convert

    local ext="${input##*.}"
    local basename="${input%.*}"

    if [[ -n "$output_name" ]]; then
        local output="${output_name}.${ext}"
    else
        local dim_safe="${dimension//\//_}"
        local output="${basename}-${dim_safe}.${ext}"
    fi

    info "Redimensionando $input → $output ($dimension) ..."
    convert "$input" -resize "$dimension" "$output"
    info "OK: $output"
}

show_resize_help() {
    cat <<EOF
 Uso: utils resize <imagem> <dimensão> [-o <nome>]

 Redimensiona imagens usando ImageMagick.

 Dimensões aceitas:
   800x600   Largura x Altura
   800       Apenas largura (altura proporcional)
   x600      Apenas altura (largura proporcional)
   50%       Percentual

 Opções:
   -o <nome>   Nome personalizado para o arquivo de saída

 Exemplos:
   utils resize foto.jpg 800x600
   utils resize foto.jpg 800
   utils resize foto.jpg x600
   utils resize foto.jpg 50%
   utils resize foto.jpg 800 -o nova

EOF
}
