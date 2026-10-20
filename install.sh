#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${ANDREA_BASH_HOME:-${HOME}/.bash_it_andrea}"
CONFIG_FILE="${BASH_IT_CONFIG_FILE:-${HOME}/.bashrc}"
MARKER_START='# >>> Andrea Bash environment >>>'
MARKER_END='# <<< Andrea Bash environment <<<'

if [[ "$SOURCE_DIR" != "$TARGET_DIR" ]]; then
    mkdir -p "$TARGET_DIR"
    cp -a "$SOURCE_DIR/." "$TARGET_DIR/"
fi

mkdir -p "$TARGET_DIR/enabled"

enable_component() {
    local type="$1"
    local name="$2"
    local priority="$3"
    local suffix
    case "$type" in
        aliases) suffix='aliases' ;;
        completion) suffix='completion' ;;
        *) printf 'Tipo non valido: %s\n' "$type" >&2; return 2 ;;
    esac
    local source="${TARGET_DIR}/${type}/available/${name}.${suffix}.bash"
    local destination="${TARGET_DIR}/enabled/${priority}---${name}.${suffix}.bash"
    [[ -f "$source" ]] || { printf 'Componente mancante: %s\n' "$source" >&2; return 1; }
    ln -sfn "$source" "$destination"
}

# Profilo personale: niente base.plugin, general.aliases, git.aliases,
# sshagent e componenti legacy.
enable_component aliases bash-it 750
enable_component aliases directory 750
enable_component aliases systemd 750
enable_component completion system 325
enable_component completion git 340
enable_component completion bash-it 350
enable_component completion ssh 400
enable_component completion kubectl 410
enable_component completion helm 415
enable_component completion gcloud 420
enable_component completion github-cli 425
enable_component completion aliases 800

if [[ -f "$CONFIG_FILE" ]] && grep -Fq "$MARKER_START" "$CONFIG_FILE"; then
    printf 'Andrea Bash è già collegato a %s.\n' "$CONFIG_FILE"
else
    if [[ -f "$CONFIG_FILE" ]]; then
        backup="${CONFIG_FILE}.bak.andrea.$(date +%Y%m%d_%H%M%S)"
        cp -a "$CONFIG_FILE" "$backup"
        printf 'Backup creato: %s\n' "$backup"
    else
        mkdir -p "$(dirname "$CONFIG_FILE")"
        : > "$CONFIG_FILE"
    fi
    {
        printf '\n%s\n' "$MARKER_START"
        printf 'if [[ -r %q ]]; then\n' "${TARGET_DIR}/template/bashrc.andrea.bash"
        printf '    source %q\n' "${TARGET_DIR}/template/bashrc.andrea.bash"
        printf 'fi\n'
        printf '%s\n' "$MARKER_END"
    } >> "$CONFIG_FILE"
    printf 'Collegamento aggiunto a %s.\n' "$CONFIG_FILE"
fi

printf '\nInstallazione completata. Apri un nuovo terminale oppure esegui:\n'
printf '  source %q\n' "$CONFIG_FILE"
printf '\nDiagnostica:\n  bash-it doctor summary\n'

