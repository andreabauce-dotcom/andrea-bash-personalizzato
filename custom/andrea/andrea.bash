# shellcheck shell=bash
# Funzioni e impostazioni personali di Andrea Bash.

_andrea_has() {
    command -v "$1" >/dev/null 2>&1
}

_andrea_path_append() {
    local entry="$1"
    [[ -d "$entry" ]] || return 0
    case ":${PATH}:" in
        *":${entry}:"*) ;;
        *) PATH="${PATH:+${PATH}:}${entry}" ;;
    esac
}

_andrea_alias_if_free() {
    local name="$1"
    local value="$2"
    alias "$name" >/dev/null 2>&1 && return 0
    type -t "$name" >/dev/null 2>&1 && return 0
    alias "${name}=${value}"
}

# Cronologia utile, condivisa fra sessioni tramite le funzioni native di Bash-it,
# ma senza creare un secondo archivio permanente con tutti i comandi.
# Il .bashrc di Ubuntu imposta già HISTSIZE=1000 e HISTFILESIZE=2000 prima di
# questo file, quindi i valori vanno forzati; si cambiano con ANDREA_HISTSIZE e
# ANDREA_HISTFILESIZE.
HISTSIZE="${ANDREA_HISTSIZE:-50000}"
HISTFILESIZE="${ANDREA_HISTFILESIZE:-100000}"
for _andrea_hist_flag in ignoreboth erasedups; do
    if [[ ":${HISTCONTROL:-}:" != *":${_andrea_hist_flag}:"* ]]; then
        HISTCONTROL="${HISTCONTROL:+${HISTCONTROL}:}${_andrea_hist_flag}"
    fi
done
export HISTSIZE HISTFILESIZE HISTCONTROL
shopt -s histappend cmdhist lithist

# Editor e pager: vengono impostati solo se l'utente non ne ha già scelti.
if [[ -z "${EDITOR:-}" ]]; then
    if _andrea_has nvim; then
        EDITOR=nvim
    elif _andrea_has vim; then
        EDITOR=vim
    elif _andrea_has nano; then
        EDITOR=nano
    fi
fi
if [[ -n "${EDITOR:-}" && -z "${VISUAL:-}" ]]; then
    VISUAL="$EDITOR"
fi
export EDITOR VISUAL
if _andrea_has less; then
    export LESS="${LESS:--FRX}"
fi

# Android SDK: riconosce i percorsi moderni e quello storico di bash_magic,
# ma aggiunge solo directory che esistono davvero.
for _andrea_sdk in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" \
    "${HOME}/Android/Sdk" "${HOME}/apps/android-sdk-linux"; do
    [[ -n "${_andrea_sdk}" && -d "${_andrea_sdk}" ]] || continue
    if [[ -z "${ANDROID_HOME:-}" ]]; then
        export ANDROID_HOME="${_andrea_sdk}"
    fi
    _andrea_path_append "${_andrea_sdk}/platform-tools"
    _andrea_path_append "${_andrea_sdk}/emulator"
    _andrea_path_append "${_andrea_sdk}/cmdline-tools/latest/bin"
    break
done
unset _andrea_sdk _andrea_hist_flag
export PATH

# Alias brevi non distruttivi. Non sovrascrivono alias o comandi già scelti.
_andrea_alias_if_free c 'clear'
_andrea_alias_if_free cls 'clear'
_andrea_alias_if_free ll 'ls -AlF'
_andrea_alias_if_free la 'ls -A'
_andrea_alias_if_free l1 'ls -1'
_andrea_alias_if_free e '${EDITOR:-vim}'
_andrea_alias_if_free vbrc '${EDITOR:-vim} ~/.bashrc'
_andrea_alias_if_free vba '${EDITOR:-vim} "${BASH_IT}/custom/andrea/andrea.bash"'

# Alias Git volutamente limitati a operazioni di consultazione.
_andrea_alias_if_free g 'git'
_andrea_alias_if_free gs 'git status'
_andrea_alias_if_free gss 'git status --short'
_andrea_alias_if_free gd 'git diff'
_andrea_alias_if_free gds 'git diff --staged'
_andrea_alias_if_free gl 'git log --oneline --decorate --graph -20'
_andrea_alias_if_free gb 'git branch --all'
_andrea_alias_if_free grv 'git remote -v'
_andrea_alias_if_free ghm 'cd "$(git rev-parse --show-toplevel)"'

git-root() {
    _andrea_has git || { printf 'Git non è installato.\n' >&2; return 127; }
    git rev-parse --show-toplevel
}

git-info() {
    _andrea_has git || { printf 'Git non è installato.\n' >&2; return 127; }
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
        printf 'La directory corrente non è un repository Git.\n' >&2
        return 1
    }
    printf 'Repository: '
    git rev-parse --show-toplevel
    printf 'Branch: '
    git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null
    printf '\nStato:\n'
    git status --short
    printf '\nUltimi commit:\n'
    git log --oneline --decorate -5
}

# Funzioni generiche riprese da bash_magic, corrette e senza eval.
mkcd() {
    [[ $# -gt 0 ]] || { printf 'Uso: mkcd directory [...]\n' >&2; return 2; }
    mkdir -p -- "$@" && cd -- "${!#}"
}

repeat() {
    local count="${1:-}"
    [[ $# -gt 1 ]] || { printf 'Uso: repeat numero comando [argomenti]\n' >&2; return 2; }
    shift
    [[ "$count" =~ ^[0-9]+$ ]] || {
        printf 'Il numero di ripetizioni deve essere un intero non negativo.\n' >&2
        return 2
    }
    while (( count > 0 )); do
        "$@" || return
        ((count--))
    done
}

extract() {
    local file="${1:-}" tool
    [[ -f "$file" ]] || { printf 'Archivio non trovato: %s\n' "$file" >&2; return 2; }
    case "$file" in
        *.tar|*.tar.*|*.tgz|*.tbz|*.tbz2|*.txz|*.tzst) tool=tar ;;
        *.zip) tool=unzip ;;
        *.7z) tool=7z ;;
        *.rar) tool=unrar ;;
        *.gz) tool=gunzip ;;
        *.bz2) tool=bunzip2 ;;
        *.xz) tool=unxz ;;
        *.zst) tool=unzstd ;;
        *.Z) tool=uncompress ;;
        *) printf 'Formato non gestito: %s\n' "$file" >&2; return 1 ;;
    esac
    _andrea_has "$tool" || { printf 'Serve il programma %s.\n' "$tool" >&2; return 127; }
    case "$tool" in
        tar) tar -xf "$file" ;;
        7z|unrar) "$tool" x -- "$file" ;;
        *) "$tool" -- "$file" ;;
    esac || { printf 'Estrazione non riuscita: %s\n' "$file" >&2; return 1; }
}

backup() {
    local file="${1:-}"
    [[ $# -eq 1 && -e "$file" ]] || { printf 'Uso: backup file_o_directory\n' >&2; return 2; }
    local stamp
    stamp="$(date +%Y%m%d_%H%M%S)"
    cp -a -- "$file" "${file}.bak.${stamp}"
}

path() {
    local i=0 entry
    local old_ifs="$IFS"
    IFS=':'
    for entry in $PATH; do
        ((i++))
        printf '%2d  %s\n' "$i" "$entry"
    done
    IFS="$old_ifs"
}

lsnew() {
    ls -lt -- "${1:-.}" | head -20
}

dir-size() {
    du -sh -- "${1:-.}"
}

psgrep() {
    [[ $# -gt 0 ]] || { printf 'Uso: psgrep parola\n' >&2; return 2; }
    _andrea_has pgrep || { printf 'pgrep non è disponibile.\n' >&2; return 127; }
    pgrep -af -- "$*"
}

net-info() {
    if _andrea_has ip; then
        printf '%s\n' 'Indirizzi:'
        ip -brief address
        printf '\nRouting:\n'
        ip route
    else
        hostname -I 2>/dev/null || true
    fi
}

wifi-info() {
    if _andrea_has nmcli; then
        nmcli -f DEVICE,TYPE,STATE,CONNECTION device status
        printf '\nReti visibili senza nuova scansione:\n'
        nmcli -f IN-USE,SSID,SIGNAL,RATE,CHAN,DEVICE device wifi list --rescan no
    elif _andrea_has iw; then
        iw dev
    else
        printf 'Servono nmcli o iw.\n' >&2
        return 127
    fi
}

listen-ports() {
    _andrea_has ss || { printf 'ss non è disponibile.\n' >&2; return 127; }
    ss -tulpen
}

public-ip() {
    _andrea_has curl || { printf 'curl non è installato.\n' >&2; return 127; }
    curl -4fsS --max-time 5 https://api.ipify.org
    printf '\n'
}

_andrea_clip_backend() {
    if _andrea_has wl-copy && _andrea_has wl-paste; then
        printf 'wl-copy'
    elif _andrea_has xclip; then
        printf 'xclip'
    elif _andrea_has xsel; then
        printf 'xsel'
    fi
}

clip-copy() {
    local backend
    backend="$(_andrea_clip_backend)"
    case "$backend" in
        wl-copy) cat | wl-copy ;;
        xclip) cat | xclip -selection clipboard ;;
        xsel) cat | xsel --clipboard --input ;;
        *) printf 'Installa wl-clipboard, xclip oppure xsel.\n' >&2; return 127 ;;
    esac
}

clip-paste() {
    local backend
    backend="$(_andrea_clip_backend)"
    case "$backend" in
        wl-copy) wl-paste ;;
        xclip) xclip -selection clipboard -o ;;
        xsel) xsel --clipboard --output ;;
        *) printf 'Installa wl-clipboard, xclip oppure xsel.\n' >&2; return 127 ;;
    esac
}

_andrea_alias_if_free pbcopy 'clip-copy'
_andrea_alias_if_free pbpaste 'clip-paste'

# Supporto Kubernetes/k3s. Il comando k usa kubectl quando esiste, altrimenti
# ripiega su "k3s kubectl" senza installare o modificare nulla.
k() {
    if _andrea_has kubectl; then
        command kubectl "$@"
    elif _andrea_has k3s; then
        command k3s kubectl "$@"
    else
        printf 'Né kubectl né k3s sono disponibili.\n' >&2
        return 127
    fi
}

_andrea_alias_if_free kgp 'k get pods'
_andrea_alias_if_free kgs 'k get services'
_andrea_alias_if_free kgn 'k get nodes'
_andrea_alias_if_free kga 'k get all'
_andrea_alias_if_free kctx 'k config current-context'
_andrea_alias_if_free kns 'k config view --minify --output=jsonpath={..namespace}'

adb-devices() {
    _andrea_has adb || { printf 'adb non è disponibile nel PATH.\n' >&2; return 127; }
    adb devices -l
}

adb-shell() {
    _andrea_has adb || { printf 'adb non è disponibile nel PATH.\n' >&2; return 127; }
    adb shell "$@"
}

adb-logcat() {
    _andrea_has adb || { printf 'adb non è disponibile nel PATH.\n' >&2; return 127; }
    adb logcat "$@"
}

adb-wifi() {
    _andrea_has adb || { printf 'adb non è disponibile nel PATH.\n' >&2; return 127; }
    if [[ $# -gt 0 ]]; then
        adb connect "$1"
    elif _andrea_has redmi-wifi.sh; then
        redmi-wifi.sh --just-connect
    else
        printf 'Uso: adb-wifi IP:PORTA\n' >&2
        return 2
    fi
}

adb-screenshot() {
    _andrea_has adb || { printf 'adb non è disponibile nel PATH.\n' >&2; return 127; }
    local file="${1:-screenshot-$(date +%Y%m%d_%H%M%S).png}"
    adb exec-out screencap -p > "$file" && [[ -s "$file" ]] || {
        printf 'Screenshot non riuscito.\n' >&2
        rm -f -- "$file"
        return 1
    }
    printf '%s\n' "$file"
}

# Sistema: servizi, log, spazio, GPU e audio.
servizi() {
    _andrea_has systemctl || { printf 'systemctl non è disponibile.\n' >&2; return 127; }
    printf 'Servizi di sistema falliti:\n'
    systemctl --failed --no-legend --plain
    printf '\nServizi utente falliti:\n'
    systemctl --user --failed --no-legend --plain
    printf '\nProssimi timer utente:\n'
    systemctl --user list-timers --no-pager | head -15
}

log-servizio() {
    local scope='--user' unit=''
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --system) scope='--system' ;;
            *) unit="$1" ;;
        esac
        shift
    done
    [[ -n "$unit" ]] || { printf 'Uso: log-servizio NOME [--system]\n' >&2; return 2; }
    if [[ "$scope" == '--user' ]]; then
        journalctl --user -u "$unit" -n 50 -f
    else
        journalctl -u "$unit" -n 50 -f
    fi
}

porta() {
    [[ "${1:-}" =~ ^[0-9]+$ ]] || { printf 'Uso: porta NUMERO\n' >&2; return 2; }
    _andrea_has ss || { printf 'ss non è disponibile.\n' >&2; return 127; }
    ss -tulpn "( sport = :$1 )"
}

spazio() {
    df -h -x tmpfs -x devtmpfs -x squashfs -x overlay -x efivarfs 2>/dev/null
}

grandi() {
    local dir="${1:-.}" count="${2:-15}"
    du -xah --max-depth=1 -- "$dir" 2>/dev/null | sort -rh | head -n "$count"
}

gpu() {
    _andrea_has nvidia-smi || { printf 'nvidia-smi non è disponibile.\n' >&2; return 127; }
    nvidia-smi --query-gpu=name,driver_version,temperature.gpu,utilization.gpu,memory.used,memory.total \
        --format=csv,noheader
    nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader 2>/dev/null
}

audio-info() {
    _andrea_has pactl || { printf 'pactl non è disponibile.\n' >&2; return 127; }
    printf 'Uscita predefinita:  %s\n' "$(pactl get-default-sink)"
    printf 'Ingresso predefinito: %s\n' "$(pactl get-default-source)"
    printf '\nUscite:\n'
    pactl list short sinks
    printf '\nIngressi:\n'
    pactl list short sources | grep -v '\.monitor'
}

# Ricerca di file e testo.
trova() {
    [[ $# -gt 0 ]] || { printf 'Uso: trova NOME [directory]\n' >&2; return 2; }
    find "${2:-.}" -iname "*$1*" -not -path '*/.git/*' 2>/dev/null
}

cerca() {
    [[ $# -gt 0 ]] || { printf 'Uso: cerca TESTO [directory]\n' >&2; return 2; }
    if _andrea_has rg; then
        rg -n --smart-case -- "$1" "${2:-.}"
    else
        grep -rIn --exclude-dir=.git -i -- "$1" "${2:-.}"
    fi
}

ultimi() {
    local dir="${1:-.}" minutes="${2:-60}"
    find "$dir" -xdev -type f -mmin "-${minutes}" -not -path '*/.git/*' -printf '%TY-%Tm-%Td %TH:%TM  %p\n' 2>/dev/null \
        | sort -r | head -30
}

# Condivide la directory corrente via HTTP: solo su questo PC, salvo --lan.
serve() {
    local port=8000 bind=127.0.0.1
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --lan) bind=0.0.0.0 ;;
            *) port="$1" ;;
        esac
        shift
    done
    _andrea_has python3 || { printf 'python3 non è disponibile.\n' >&2; return 127; }
    printf 'http://%s:%s/  (Ctrl+C per fermare)\n' "$bind" "$port"
    python3 -m http.server --bind "$bind" "$port"
}

# Elenco degli script personali con la prima riga di commento.
miei-script() {
    local dir="${1:-${HOME}/.local/bin}" file desc
    for file in "$dir"/*; do
        [[ -f "$file" && -x "$file" ]] || continue
        desc="$(grep -m1 -E '^#[^!]' "$file" 2>/dev/null | sed -E 's/^#+[[:space:]]*//')"
        printf '%-28s %s\n' "${file##*/}" "${desc:0:90}"
    done
}

comandi() {
    cat <<'TESTO'
Andrea Bash — comandi personali

Git (sola lettura)  g gs gss gd gds gl gb grv ghm, git-info, git-root
File                extract, backup, mkcd, trova, cerca, ultimi, grandi, lsnew, dir-size
Sistema             servizi, log-servizio, porta, spazio, gpu, audio-info, psgrep, path
Rete                net-info, wifi-info, listen-ports, public-ip, serve [--lan]
Android             adb-devices, adb-shell, adb-logcat, adb-wifi, adb-screenshot
Kubernetes          k, kgp, kgs, kgn, kga, kctx, kns
Appunti             clip-copy, clip-paste (pbcopy, pbpaste)
Altro               repeat, miei-script, comandi
TESTO
}

unset -f _andrea_alias_if_free _andrea_path_append

