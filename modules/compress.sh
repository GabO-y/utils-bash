#!/usr/bin/env bash

cmd_compress() {
    if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_compress_help
        return 0
    fi

    [[ $# -lt 2 ]] && die "Uso: utils compress <origem> <formato> [-o <nome>]"

    local input="$1"
    local format="$2"
    local output_name=""
    shift 2

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o) shift; output_name="$1" ;;
            *) die "Argumento desconhecido: $1" ;;
        esac
        shift
    done

    [[ ! -e "$input" ]] && die "Arquivo/pasta não encontrado: $input"

    if [[ -n "$output_name" ]]; then
        local output="${output_name}.${format}"
    else
        local input_base
        input_base=$(basename "$input")
        local output="${input_base}.${format}"
    fi

    case "$format" in
        tar.gz|tgz)
            check_deps tar gzip
            info "Compactando $input → $output ..."
            tar czf "$output" "$input"
            info "OK: $output"
            ;;
        tar.bz2|tbz2)
            check_deps tar bzip2
            info "Compactando $input → $output ..."
            tar cjf "$output" "$input"
            info "OK: $output"
            ;;
        tar.xz|txz)
            check_deps tar xz
            info "Compactando $input → $output ..."
            tar cJf "$output" "$input"
            info "OK: $output"
            ;;
        zip)
            check_deps zip
            info "Compactando $input → $output ..."
            if [[ -d "$input" ]]; then
                zip -r "$output" "$input"
            else
                zip "$output" "$input"
            fi
            info "OK: $output"
            ;;
        7z)
            check_deps 7z
            info "Compactando $input → $output ..."
            7z a "$output" "$input"
            info "OK: $output"
            ;;
        *)
            die "Formato não suportado: $format"
            ;;
    esac
}

show_compress_help() {
    cat <<EOF
 Uso: utils compress <origem> <formato> [-o <nome>]

 Compacta arquivos ou pastas.

 Formatos suportados:
   tar.gz, tar.bz2, tar.xz, zip, 7z

 Opções:
   -o <nome>   Nome personalizado para o arquivo de saída

 Exemplos:
   utils compress pasta/ tar.gz
   utils compress pasta/ zip
   utils compress pasta/ tar.gz -o backup
   utils compress arquivo.txt tar.gz

EOF
}
