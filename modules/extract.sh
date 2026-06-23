#!/usr/bin/env bash

cmd_extract() {
    if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_extract_help
        return 0
    fi

    local input="$1"
    local output_dir=""
    shift

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o) shift; output_dir="$1" ;;
            *) die "Argumento desconhecido: $1" ;;
        esac
        shift
    done

    [[ ! -f "$input" ]] && die "Arquivo não encontrado: $input"

    local ext_flags=()
    if [[ -n "$output_dir" ]]; then
        mkdir -p "$output_dir"
    fi

    case "$input" in
        *.tar.gz|*.tgz)
            check_deps tar
            info "Extraindo $input ..."
            if [[ -n "$output_dir" ]]; then
                tar xzf "$input" -C "$output_dir"
            else
                tar xzf "$input"
            fi
            info "OK"
            ;;
        *.tar.bz2|*.tbz2)
            check_deps tar
            info "Extraindo $input ..."
            if [[ -n "$output_dir" ]]; then
                tar xjf "$input" -C "$output_dir"
            else
                tar xjf "$input"
            fi
            info "OK"
            ;;
        *.tar.xz|*.txz)
            check_deps tar
            info "Extraindo $input ..."
            if [[ -n "$output_dir" ]]; then
                tar xJf "$input" -C "$output_dir"
            else
                tar xJf "$input"
            fi
            info "OK"
            ;;
        *.tar)
            check_deps tar
            info "Extraindo $input ..."
            if [[ -n "$output_dir" ]]; then
                tar xf "$input" -C "$output_dir"
            else
                tar xf "$input"
            fi
            info "OK"
            ;;
        *.zip)
            check_deps unzip
            info "Extraindo $input ..."
            if [[ -n "$output_dir" ]]; then
                unzip -q "$input" -d "$output_dir"
            else
                unzip -q "$input"
            fi
            info "OK"
            ;;
        *.7z)
            check_deps 7z
            info "Extraindo $input ..."
            if [[ -n "$output_dir" ]]; then
                7z x "$input" -o"$output_dir"
            else
                7z x "$input"
            fi
            info "OK"
            ;;
        *.gz)
            check_deps gunzip
            info "Extraindo $input ..."
            if [[ -n "$output_dir" ]]; then
                cp "$input" "$output_dir/"
                (cd "$output_dir" && gunzip "$(basename "$input")")
            else
                gunzip "$input"
            fi
            info "OK"
            ;;
        *.bz2)
            check_deps bunzip2
            info "Extraindo $input ..."
            if [[ -n "$output_dir" ]]; then
                cp "$input" "$output_dir/"
                (cd "$output_dir" && bunzip2 "$(basename "$input")")
            else
                bunzip2 "$input"
            fi
            info "OK"
            ;;
        *.xz)
            check_deps unxz
            info "Extraindo $input ..."
            if [[ -n "$output_dir" ]]; then
                cp "$input" "$output_dir/"
                (cd "$output_dir" && unxz "$(basename "$input")")
            else
                unxz "$input"
            fi
            info "OK"
            ;;
        *)
            die "Formato não reconhecido: $input"
            ;;
    esac
}

show_extract_help() {
    cat <<EOF
 Uso: utils extract <arquivo> [-o <destino>]

 Extrai arquivos compactados. O formato é detectado automaticamente.

 Formatos suportados:
   tar, tar.gz, tar.bz2, tar.xz, zip, 7z, gz, bz2, xz

 Opções:
   -o <destino>   Diretório para extrair os arquivos

 Exemplos:
   utils extract arquivo.tar.gz
   utils extract arquivo.zip
   utils extract arquivo.tar.gz -o pasta/

EOF
}
