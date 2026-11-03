#!/usr/bin/env bash

RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'

die() {
    echo -e "${RED}[ERRO]${RESET} $*" >&2
    exit 1
}

error() {
    echo -e "${RED}[ERRO]${RESET} $*" >&2
}

info() {
    echo -e "${GREEN}[INFO]${RESET} $*"
}

warn() {
    echo -e "${YELLOW}[AVISO]${RESET} $*"
}

detect_pkg_install() {
    if command -v apt &>/dev/null; then
        echo "sudo apt install"
    elif command -v pacman &>/dev/null; then
        echo "sudo pacman -S"
    elif command -v dnf &>/dev/null; then
        echo "sudo dnf install"
    elif command -v zypper &>/dev/null; then
        echo "sudo zypper install"
    elif command -v brew &>/dev/null; then
        echo "brew install"
    else
        echo "instale com seu gerenciador de pacotes"
    fi
}

pkg_suggest() {
    local cmd="$1"
    local pkg_install
    pkg_install=$(detect_pkg_install)

    case "$cmd" in
        pdflatex)
            case "$pkg_install" in
                *pacman*) echo "$pkg_install texlive-core" ;;
                *apt*)    echo "$pkg_install texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended" ;;
                *dnf*)    echo "$pkg_install texlive-latex" ;;
                *brew*)   echo "$pkg_install texlive" ;;
                *)        echo "$pkg_install texlive-latex-base" ;;
            esac ;;
        ffmpeg)   echo "$pkg_install ffmpeg" ;;
        pandoc)   echo "$pkg_install pandoc" ;;
        yt-dlp)   echo "$pkg_install yt-dlp" ;;
        convert)  echo "$pkg_install imagemagick" ;;
        zip)      echo "$pkg_install zip" ;;
        unzip)    echo "$pkg_install unzip" ;;
        7z)       echo "$pkg_install p7zip-full" ;;
        texlive-extra)
            case "$pkg_install" in
                *pacman*) echo "$pkg_install texlive-core" ;;
                *apt*)    echo "$pkg_install texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended" ;;
                *dnf*)    echo "$pkg_install texlive-latex" ;;
                *brew*)   echo "$pkg_install texlive" ;;
                *)        echo "$pkg_install texlive-latex-extra" ;;
            esac ;;
        *)        echo "$pkg_install $cmd" ;;
    esac
}

check_deps() {
    local missing=0
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            error "$cmd não encontrado. $(pkg_suggest "$cmd")"
            missing=1
        fi
    done
    [[ $missing -eq 0 ]] || die "Dependências faltando."
}

show_help() {
    cat <<EOF
 Uso: utils <comando> [argumentos]

 Comandos:

    convert <arquivo> <formato> [-o <nome>]
        Converte arquivos entre formatos.

    download -youtube <url> [-mp3] [-o <nome>]
        Baixa mídia da internet.

    resize <imagem> <dimensão> [-o <nome>]
        Redimensiona imagens (ImageMagick).

    compress <origem> <formato> [-o <nome>]
        Compacta arquivos/pastas (tar.gz, zip, ...).

    extract <arquivo> [-o <destino>]
        Extrai arquivos compactados.

    code-template <template> [nome] [-f]
        Cria um projeto a partir de um template.

   help, -h, --help
       Mostra esta mensagem.

 Instalação:
   ./install.sh    Instala em ~/.local/bin/utils

EOF
}
