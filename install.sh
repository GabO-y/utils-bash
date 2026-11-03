#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
INSTALL_DIR="${INSTALL_DIR%/}"
if [[ -z "$INSTALL_DIR" ]]; then
    INSTALL_DIR="/"
fi
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=lib/config.sh
source "$SCRIPT_DIR/lib/config.sh"

path_has_install_dir() {
    local entry
    local IFS=:

    for entry in $PATH; do
        [[ "$entry" == "$INSTALL_DIR" ]] && return 0
    done

    return 1
}

rc_has_install_dir() {
    local rc_file="$1"
    local rel_path=""
    local content=""

    [[ -f "$rc_file" ]] || return 1

    content="$(grep -v '^[[:space:]]*#' "$rc_file" 2>/dev/null || true)"

    if [[ "$INSTALL_DIR" == "$HOME/"* ]]; then
        rel_path="${INSTALL_DIR#"$HOME/"}"
    fi

    grep -Fq -- "$INSTALL_DIR" <<< "$content" && return 0

    if [[ -n "$rel_path" ]]; then
        grep -Fq -- "\$HOME/$rel_path" <<< "$content" && return 0
        grep -Fq -- "\${HOME}/$rel_path" <<< "$content" && return 0
        grep -Fq -- "~/$rel_path" <<< "$content" && return 0
    fi

    return 1
}

print_manual_path_hint() {
    warn "Adicione manualmente ao arquivo de inicialização do seu shell:"
    printf '  export PATH="$PATH":%q\n' "$INSTALL_DIR"
}

configure_path() {
    local shell_path="${SHELL:-}"
    local shell_name=""
    local rc_file=""
    local backup=""
    local current_utils=""
    local current_real=""
    local installed_real=""
    local rc_existed=0

    if [[ -z "$shell_path" ]] && command -v getent &>/dev/null; then
        shell_path="$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f7)"
    fi

    shell_name="${shell_path##*/}"

    case "$shell_name" in
        zsh)  rc_file="${ZDOTDIR:-$HOME}/.zshrc" ;;
        bash) rc_file="$HOME/.bashrc" ;;
        *)
            echo
            echo "--- PATH ---"
            warn "Shell não suportado para configuração automática: ${shell_name:-desconhecido}"
            warn "Adicione $INSTALL_DIR ao PATH no arquivo de inicialização do seu shell."
            return 0
            ;;
    esac

    echo
    echo "--- PATH ---"

    if rc_has_install_dir "$rc_file"; then
        info "PATH já configurado em $rc_file"
    elif grep -Fq "# >>> utils-bash >>>" "$rc_file" 2>/dev/null; then
        warn "Já existe um bloco utils-bash em $rc_file."
        echo "  Verifique manualmente se o PATH está correto ou remova o bloco e rode novamente."
    else
        if [[ -e "$rc_file" ]]; then
            rc_existed=1
        fi

        if [[ $rc_existed -eq 1 && ! -f "$rc_file" ]]; then
            warn "$rc_file existe, mas não é um arquivo regular."
            print_manual_path_hint
            return 0
        fi

        if [[ $rc_existed -eq 0 ]]; then
            mkdir -p "$(dirname "$rc_file")"
            if ! touch "$rc_file"; then
                warn "Não foi possível criar $rc_file."
                print_manual_path_hint
                return 0
            fi
        fi

        if [[ ! -w "$rc_file" ]]; then
            warn "Sem permissão de escrita em $rc_file."
            print_manual_path_hint
            return 0
        fi

        if [[ $rc_existed -eq 1 ]]; then
            backup="${rc_file}.bak.$(date +%Y%m%d%H%M%S)"
            if ! cp -p "$rc_file" "$backup"; then
                warn "Não foi possível criar backup de $rc_file."
                print_manual_path_hint
                return 0
            fi
            info "Backup criado: $backup"
        fi

        {
            echo
            echo "# >>> utils-bash >>>"
            printf 'export PATH="$PATH":%q\n' "$INSTALL_DIR"
            echo "# <<< utils-bash <<<"
        } >> "$rc_file"

        if ! grep -Fq "# >>> utils-bash >>>" "$rc_file" 2>/dev/null; then
            warn "Não foi possível atualizar $rc_file."
            print_manual_path_hint
            return 0
        fi

        info "PATH adicionado em $rc_file"
    fi

    if path_has_install_dir; then
        info "$INSTALL_DIR já está no PATH desta sessão."
    else
        warn "$INSTALL_DIR não está no PATH desta sessão."
        echo "  Abra um novo terminal ou execute: source \"$rc_file\""
    fi

    current_utils="$(command -v utils 2>/dev/null || true)"
    installed_real="$(readlink -f "$INSTALL_DIR/utils" 2>/dev/null || true)"

    if [[ -n "$current_utils" ]]; then
        current_real="$(readlink -f "$current_utils" 2>/dev/null || true)"
        if [[ -n "$installed_real" && "$current_real" == "$installed_real" ]]; then
            info "utils disponível em $current_utils"
        else
            warn "Já existe outro comando utils em $current_utils."
            echo "  Para priorizar o utils-bash, coloque $INSTALL_DIR no início do PATH."
        fi
    fi

    return 0
}

echo "Instalando utils-bash em $INSTALL_DIR/utils-bash/ ..."

mkdir -p "$INSTALL_DIR/utils-bash"

if [[ "$INSTALL_DIR" != /* ]]; then
    INSTALL_DIR="$(cd "$INSTALL_DIR" && pwd)"
fi

cp -r "$SCRIPT_DIR/utils" "$SCRIPT_DIR/lib" "$SCRIPT_DIR/modules" "$INSTALL_DIR/utils-bash/"

chmod +x "$INSTALL_DIR/utils-bash/utils"

ln -sf "$INSTALL_DIR/utils-bash/utils" "$INSTALL_DIR/utils"

echo "Instalação concluída!"

echo
echo "--- Configuração ---"
if [[ ! -f "$UTILS_CONFIG_FILE" ]]; then
    mkdir -p "$UTILS_CONFIG_DIR"
    cat > "$UTILS_CONFIG_FILE" <<'EOF'
# Configuração do utils-bash
# Diretório onde ficam os templates de projeto.
: "${CODE_TEMPLATE_DIR:=$HOME/CodeTemplates}"
EOF
    info "Config criada em $UTILS_CONFIG_FILE"
else
    info "Config existente mantida: $UTILS_CONFIG_FILE"
fi

if [[ -d "$CODE_TEMPLATE_DIR" ]]; then
    info "Templates: $CODE_TEMPLATE_DIR"
else
    warn "Diretório de templates não encontrado: $CODE_TEMPLATE_DIR"
    echo "  Crie com: mkdir -p \"$CODE_TEMPLATE_DIR\""
fi

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

configure_path
