#!/usr/bin/env bash

cmd_code_template() {
    if [[ $# -eq 0 ]]; then
        list_code_templates "${CODE_TEMPLATE_DIR:-$HOME/CodeTemplates}"
        return 0
    fi

    local template=""
    local project_name=""
    local force=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_code_template_help
                return 0
                ;;
            -l|--list)
                list_code_templates "${CODE_TEMPLATE_DIR:-$HOME/CodeTemplates}"
                return 0
                ;;
            -f|--force)
                force=1
                ;;
            -*)
                die "Argumento desconhecido: $1"
                ;;
            *)
                if [[ -z "$template" ]]; then
                    template="$1"
                elif [[ -z "$project_name" ]]; then
                    project_name="$1"
                else
                    die "Argumento desconhecido: $1"
                fi
                ;;
        esac
        shift
    done

    [[ -z "$template" ]] && die "Uso: utils code-template <template> [nome-do-projeto] [-f|--force]"

    validate_template_name "$template"

    local template_root="${CODE_TEMPLATE_DIR:-$HOME/CodeTemplates}"
    local source_dir="$template_root/$template"

    [[ -d "$template_root" ]] || die "Diretório de templates não encontrado: $template_root
  Crie o diretório ou defina CODE_TEMPLATE_DIR em ${UTILS_CONFIG_FILE:-$HOME/.config/utils-bash/config.sh}."

    [[ -d "$source_dir" ]] || die "Template não encontrado: $template
  Disponíveis: $(available_templates "$template_root")"

    [[ -z "$project_name" ]] && project_name="new-project-${template,,}"

    local dest="$project_name"
    if [[ "$dest" != */* && "$dest" != "." && "$dest" != ".." ]]; then
        dest="./$dest"
    fi

    local source_real dest_real
    source_real="$(realpath -e "$source_dir")" || die "Não foi possível resolver o template: $source_dir"
    dest_real="$(realpath -m "$dest")" || die "Não foi possível resolver o destino: $dest"

    [[ "$source_real" == "$dest_real" ]] && die "O destino não pode ser o próprio template."

    local source_prefix="${source_real%/}/"
    local dest_prefix="${dest_real%/}/"

    [[ "$dest_prefix" == "$source_prefix"* ]] && die "O destino não pode ficar dentro do template."
    [[ "$source_prefix" == "$dest_prefix"* ]] && die "O destino não pode conter o template."

    if [[ -e "$dest" && ! -d "$dest" ]]; then
        die "O destino existe e não é um diretório: $dest"
    fi

    if [[ -d "$dest" ]] && ! is_dir_empty "$dest" && [[ $force -eq 0 ]]; then
        die "O destino não está vazio: $dest
  Use -f para sobrescrever ou escolha outro nome."
    fi

    mkdir -p "$dest"

    info "Criando projeto a partir do template '$template' em $dest ..."
    cp -a -- "$source_dir/." "$dest/" || die "Falha ao copiar o template."
    info "OK: template '$template' aplicado em $dest"
}

validate_template_name() {
    local name="$1"

    [[ -n "$name" ]] || die "Nome do template não pode ser vazio."
    [[ "$name" == .* ]] && die "Nome de template inválido: $name"
    [[ "$name" == -* ]] && die "Nome de template inválido: $name"
    [[ "$name" == */* ]] && die "Nome de template inválido: $name (use apenas o nome da pasta)"

    return 0
}

list_code_templates() {
    local root="$1"

    [[ -d "$root" ]] || die "Diretório de templates não encontrado: $root
  Crie o diretório ou defina CODE_TEMPLATE_DIR em ${UTILS_CONFIG_FILE:-$HOME/.config/utils-bash/config.sh}."

    local found=0
    local dir

    echo "Templates disponíveis em $root:"
    for dir in "$root"/*/; do
        [[ -d "$dir" ]] || continue
        printf '  %s\n' "$(basename "$dir")"
        found=1
    done

    [[ $found -eq 1 ]] || warn "Nenhum template encontrado."
}

available_templates() {
    local root="$1"
    local dirs=()
    local dir

    for dir in "$root"/*/; do
        [[ -d "$dir" ]] || continue
        dirs+=("$(basename "$dir")")
    done

    if [[ ${#dirs[@]} -eq 0 ]]; then
        echo "nenhum"
    else
        local joined=""
        local item

        for item in "${dirs[@]}"; do
            joined+="${joined:+, }$item"
        done

        echo "$joined"
    fi
}

is_dir_empty() {
    [[ -z "$(find "$1" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]
}

show_code_template_help() {
    local template_root="${CODE_TEMPLATE_DIR:-$HOME/CodeTemplates}"
    local config_file="${UTILS_CONFIG_FILE:-$HOME/.config/utils-bash/config.sh}"

    cat <<EOF
 Uso: utils code-template <template> [nome-do-projeto] [-f|--force]
      utils code-template --list

 Cria um projeto copiando o conteúdo de um template.

 Os templates são lidos de:
   $template_root

 Sem nome-do-projeto, o destino é:
   new-project-<template>

 Opções:
   -f, --force    Sobrescreve arquivos se o destino não estiver vazio
   -l, --list     Lista os templates disponíveis

 Exemplos:
   utils code-template C
   utils code-template C meu-projeto
   utils code-template C ~/projetos/meu-projeto
   utils code-template --list

 Configuração:
   $config_file
   CODE_TEMPLATE_DIR=\$HOME/CodeTemplates

EOF
}
