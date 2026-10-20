# shellcheck shell=bash

# Completamento leggero per i comandi ADB più usati.
if command -v adb >/dev/null 2>&1; then
    _andrea_adb_complete() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local commands='devices start-server kill-server shell logcat install uninstall push pull reboot forward reverse get-state wait-for-device'
        COMPREPLY=( $(compgen -W "${commands}" -- "${cur}") )
    }
    complete -F _andrea_adb_complete adb
fi

# Riutilizza il completamento ufficiale di kubectl anche per il wrapper k.
if declare -F __start_kubectl >/dev/null 2>&1; then
    complete -o default -o nospace -F __start_kubectl k
fi

