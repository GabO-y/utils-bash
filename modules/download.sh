#!/usr/bin/env bash

cmd_download() {
    if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_download_help
        return 0
    fi

    local mode="video"
    local url=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -youtube)
                shift
                url="$1"
                ;;
            -mp3)
                mode="audio"
                ;;
            *)
                die "Argumento desconhecido: $1"
                ;;
        esac
        shift
    done

    [[ -z "$url" ]] && die "Uso: utils download -youtube <url> [-mp3]"

    check_deps yt-dlp ffmpeg

    info "Baixando: $url"

    if [[ "$mode" == "audio" ]]; then
        yt-dlp -x --audio-format mp3 --embed-thumbnail --add-metadata "$url"
    else
        yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 "$url"
    fi

    info "Download concluído!"
}

show_download_help() {
    cat <<EOF
 Uso: utils download -youtube <url> [-mp3]

 Baixa vídeos do YouTube usando yt-dlp.

 Opções:
   -youtube <url>  Link do vídeo (obrigatório)
   -mp3            Extrair apenas o áudio em MP3

 Exemplos:
   utils download -youtube https://youtube.com/watch?v=dQw4w9WgXcQ
   utils download -youtube https://youtu.be/dQw4w9WgXcQ -mp3

EOF
}
