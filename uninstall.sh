#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${BASH_IT_CONFIG_FILE:-${HOME}/.bashrc}"
TARGET_DIR="${ANDREA_BASH_HOME:-${HOME}/.bash_it_andrea}"
MARKER_START='# >>> Andrea Bash environment >>>'
MARKER_END='# <<< Andrea Bash environment <<<'

[[ -f "$CONFIG_FILE" ]] || { printf 'File non trovato: %s\n' "$CONFIG_FILE" >&2; exit 1; }
grep -Fq "$MARKER_START" "$CONFIG_FILE" || {
    printf 'Blocco Andrea Bash non trovato in %s.\n' "$CONFIG_FILE"
    exit 0
}

backup="${CONFIG_FILE}.pre-uninstall.$(date +%Y%m%d_%H%M%S)"
cp -a "$CONFIG_FILE" "$backup"
tmp="$(mktemp)"
awk -v start="$MARKER_START" -v end="$MARKER_END" '
    $0 == start { skip=1; next }
    $0 == end { skip=0; next }
    !skip { print }
' "$CONFIG_FILE" > "$tmp"
mv "$tmp" "$CONFIG_FILE"

printf 'Configurazione ripristinata. Backup: %s\n' "$backup"
printf 'La cartella %s non è stata cancellata: puoi rimuoverla manualmente quando hai verificato che tutto funziona.\n' "$TARGET_DIR"

