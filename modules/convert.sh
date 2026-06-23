#!/usr/bin/env bash

cmd_convert() {
    if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_convert_help
        return 0
    fi

    [[ $# -lt 2 ]] && die "Uso: utils convert <arquivo> <formato>"

    local input="$1"
    local format="$2"

    [[ ! -f "$input" ]] && die "Arquivo não encontrado: $input"

    local basename="${input%.*}"
    local ext="${input##*.}"
    local output="${basename}.${format}"

    [[ "$ext" == "$format" ]] && die "O arquivo já está no formato $format."

    case "$format" in
        mp3|wav|ogg|aac|flac)
            check_deps ffmpeg
            info "Convertendo $input → $output ..."
            ffmpeg -i "$input" -vn "$output" -y
            info "OK: $output"
            ;;
        pdf)
            check_deps pandoc
            if ! command -v pdflatex &>/dev/null; then
                die "pdflatex não encontrado.\n  $(pkg_suggest texlive-extra)"
            fi
            if ! kpsewhich xcolor.sty &>/dev/null; then
                die "Pacotes LaTeX adicionais necessários.\n  $(pkg_suggest texlive-extra)"
            fi
            info "Convertendo $input → $output ..."
            pandoc "$input" -o "$output"
            info "OK: $output"
            ;;
        html|docx|epub|odt)
            check_deps pandoc
            info "Convertendo $input → $output ..."
            pandoc "$input" -o "$output"
            info "OK: $output"
            ;;
        mp4|mov|avi|mkv|webm)
            check_deps ffmpeg
            info "Convertendo $input → $output ..."
            ffmpeg -i "$input" "$output" -y
            info "OK: $output"
            ;;
        *)
            die "Formato não suportado: $format"
            ;;
    esac
}

show_convert_help() {
    cat <<EOF
 Uso: utils convert <arquivo> <formato>

 Converte arquivos entre formatos.

 Formatos de saída suportados:

   Áudio:     mp3, wav, ogg, aac, flac  (ffmpeg)
   Vídeo:     mp4, mov, avi, mkv, webm  (ffmpeg)
   Documento: pdf, html, docx, epub, odt (pandoc)

 Exemplos:
   utils convert video.mp4 mp3
   utils convert doc.md pdf
   utils convert doc.md html

EOF
}
