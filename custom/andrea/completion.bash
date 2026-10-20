# shellcheck shell=bash

# Completamento leggero per i comandi ADB più usati, solo se il sistema non ne
# fornisce già uno più completo (bash-completion lo carica alla prima Tab).
if command -v adb >/dev/null 2>&1 \
    && [[ ! -r /usr/share/bash-completion/completions/adb ]] \
    && ! complete -p adb >/dev/null 2>&1; then
    _andrea_adb_complete() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local commands='devices start-server kill-server shell logcat install uninstall push pull reboot forward reverse get-state wait-for-device connect disconnect exec-out'
        COMPREPLY=( $(compgen -W "${commands}" -- "${cur}") )
    }
    complete -F _andrea_adb_complete adb
fi

# Completamento gcloud senza "gcloud info": cerca il file nei percorsi noti
# (snap, pacchetto apt, installazione manuale).
if command -v gcloud >/dev/null 2>&1; then
    for _andrea_gcloud_root in "${GOOGLE_SDK_ROOT:-}" /snap/google-cloud-cli/current \
        /snap/google-cloud-sdk/current /usr/lib/google-cloud-sdk \
        /usr/share/google-cloud-sdk "${HOME}/google-cloud-sdk"; do
        if [[ -n "${_andrea_gcloud_root}" && -r "${_andrea_gcloud_root}/completion.bash.inc" ]]; then
            # shellcheck disable=SC1090,SC1091
            source "${_andrea_gcloud_root}/completion.bash.inc"
            break
        fi
    done
    unset _andrea_gcloud_root
fi

# Riutilizza il completamento ufficiale di kubectl anche per il wrapper k.
if declare -F __start_kubectl >/dev/null 2>&1; then
    complete -o default -o nospace -F __start_kubectl k
fi

# Completamento dei nomi delle unit systemd per log-servizio.
_andrea_unit_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}" scope='--user'
    [[ " ${COMP_WORDS[*]} " == *' --system '* ]] && scope='--system'
    COMPREPLY=( $(compgen -W "$(systemctl "$scope" list-units --all --plain --no-legend 2>/dev/null | awk '{print $1}') --system" -- "${cur}") )
}
complete -F _andrea_unit_complete log-servizio
