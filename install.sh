#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

echo "Instalando utils-bash em $INSTALL_DIR/utils-bash/ ..."

mkdir -p "$INSTALL_DIR/utils-bash"

cp -r "$SCRIPT_DIR/utils" "$SCRIPT_DIR/lib" "$SCRIPT_DIR/modules" "$INSTALL_DIR/utils-bash/"

chmod +x "$INSTALL_DIR/utils-bash/utils"

ln -sf "$INSTALL_DIR/utils-bash/utils" "$INSTALL_DIR/utils"

echo "Instalação concluída!"

echo
echo "--- Dependências ---"
missing_deps=0
for dep in ffmpeg pandoc yt-dlp convert zip unzip; do
    if command -v "$dep" &>/dev/null; then
        info "$dep: OK"
    else
        error "$dep: não encontrado"
        warn "  $(pkg_suggest "$dep")"
        missing_deps=1
    fi
done

if ! command -v pdflatex &>/dev/null; then
    error "pdflatex: não encontrado (necessário para converter .md → pdf)"
    warn "  $(pkg_suggest texlive-extra)"
    missing_deps=1
elif ! kpsewhich xcolor.sty &>/dev/null; then
    error "Pacotes LaTeX adicionais necessários para gerar PDF."
    warn "  $(pkg_suggest texlive-extra)"
    missing_deps=1
fi

if command -v 7z &>/dev/null; then
    info "7z: OK"
else
    warn "7z: não encontrado (opcional, necessário apenas para formato 7z)"
    warn "  $(pkg_suggest 7z)"
fi

if [[ $missing_deps -eq 0 ]]; then
    info "Todas as dependências estão instaladas!"
fi

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo
    warn "$INSTALL_DIR não está no PATH."
    echo "Adicione ao seu ~/.bashrc ou ~/.zshrc:"
    echo "  export PATH=\"\$PATH:$INSTALL_DIR\""
fi
