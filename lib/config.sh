#!/usr/bin/env bash

UTILS_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/utils-bash"
UTILS_CONFIG_FILE="$UTILS_CONFIG_DIR/config.sh"

if [[ -f "$UTILS_CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$UTILS_CONFIG_FILE"
fi

CODE_TEMPLATE_DIR="${CODE_TEMPLATE_DIR:-$HOME/CodeTemplates}"
