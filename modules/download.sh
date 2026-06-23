#!/usr/bin/env bash

cmd_download() {
    if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_download_help
        return 0
    fi

    local mode="video"
    local url=""
    local output_name=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -youtube)
                shift
                url="$1"
                ;;
            -mp3)
                mode="audio"
                ;;
            -o)
                shift
                output_name="$1"
                ;;
            *)
                die "Argumento desconhecido: $1"
                ;;
        esac
        shift
    done

    [[ -z "$url" ]] && die "Uso: utils download -youtube <url> [-mp3] [-o <nome>]"

    check_deps yt-dlp ffmpeg

    info "Baixando: $url"

    local yt_args=()

    if [[ "$mode" == "audio" ]]; then
        yt_args+=(-x --audio-format mp3 --embed-thumbnail --add-metadata)
    else
        yt_args+=(-f "bestvideo+bestaudio/best" --merge-output-format mp4)
    fi

    if [[ -n "$output_name" ]]; then
        yt_args+=(-o "$output_name.%(ext)s")
    fi

    yt-dlp "${yt_args[@]}" "$url"

    info "Download concluído!"
}

show_download_help() {
    cat <<EOF
 Uso: utils download -youtube <url> [-mp3] [-o <nome>]

 Baixa vídeos do YouTube usando yt-dlp.

 Opções:
   -youtube <url>  Link do vídeo (obrigatório)
   -mp3            Extrair apenas o áudio em MP3
   -o <nome>       Nome personalizado para o arquivo baixado

 Exemplos:
   utils download -youtube https://youtube.com/watch?v=dQw4w9WgXcQ
   utils download -youtube https://youtu.be/dQw4w9WgXcQ -mp3
   utils download -youtube https://youtube.com/watch?v=xxx -o meu_video

EOF
}
