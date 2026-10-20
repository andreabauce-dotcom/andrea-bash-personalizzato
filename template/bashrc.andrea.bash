# shellcheck shell=bash

# Non caricare configurazioni interattive in script, cron o comandi non interattivi.
case $- in
    *i*) ;;
    *) return ;;
esac

# Installazione predefinita: ~/.bash_it_andrea
BASH_IT="${ANDREA_BASH_HOME:-${HOME}/.bash_it_andrea}"
export BASH_IT

# Tema personale leggero, con stato Git e codice di uscita.
export BASH_IT_THEME="${BASH_IT_THEME:-andrea}"
export ANDREA_PROMPT_GIT="${ANDREA_PROMPT_GIT:-true}"

if [[ -r "${BASH_IT}/bash_it.sh" ]]; then
    # shellcheck disable=SC1090
    source "${BASH_IT}/bash_it.sh"
else
    printf 'Andrea Bash: directory non trovata: %s\n' "${BASH_IT}" >&2
fi

