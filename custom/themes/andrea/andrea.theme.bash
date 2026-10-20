# shellcheck shell=bash
# Tema personale leggero: percorso, stato Git e codice dell'ultimo comando.

andrea_prompt_command() {
    local exit_code=$?
    local git_part=''
    local branch=''
    local marker=''

    if [[ "${ANDREA_PROMPT_GIT:-true}" == 'true' ]] && command -v git >/dev/null 2>&1 \
        && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)"
        if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
            marker='*'
        fi
        git_part=" ${purple-}[git:${branch}${marker}]${reset_color-}"
    fi

    local status_color="${bold_green-}"
    [[ "$exit_code" -eq 0 ]] || status_color="${bold_red-}"

    PS1="${bold_blue-}\u@\h${reset_color-} ${bold_cyan-}\w${reset_color-}${git_part}"
    PS1+="\n${status_color}${exit_code}${reset_color-} ${bold_green-}❯${reset_color-} "
}

safe_append_prompt_command andrea_prompt_command

