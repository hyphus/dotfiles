#!/bin/bash

if [ -f "${HOME}/.bashrc" ]; then
    # shellcheck source=/dev/null
    . "${HOME}/.bashrc"
fi

# Functions
function random {
    openssl rand -base64 "$1"
}

function lower {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

function nocomment {
  grep -v '^$\|^\s*\#' "$1"
}

# Sync history between shells
HISTSIZE=900000
HISTFILESIZE=$HISTSIZE
HISTCONTROL=ignorespace:ignoredups

_bash_history_sync() {
    builtin history -a
    HISTFILESIZE=$HISTSIZE
    builtin history -c
    builtin history -r
}
history() {
    _bash_history_sync
    builtin history "$@"
}

PROMPT_COMMAND=_bash_history_sync

# shellcheck source=/dev/null
test -e "$(which kubectl)" && source <(kubectl completion bash)
# shellcheck source=/dev/null
test -e "${HOME}/.cargo/env" && source "${HOME}/.cargo/env"

# [09/25/20 16:41:28] user@host ~
ROOT_PS1='┌─[\D{%m/%d/%y %T}] \[\e[31m\]\u@\h\[\e[m\] \w\n└╼ \[\e[90m\]\$\[\e[0m\] '
USER_PS1='┌─[\D{%m/%d/%y %T}] \[\e[32m\]\u@\h\[\e[m\] \w\n└╼ \[\e[90m\]\$\[\e[0m\] '

# macOS specific
if [[ $OSTYPE == 'darwin'* ]]; then 
    # I want bash dammit
    export BASH_SILENCE_DEPRECATION_WARNING=1

    function x86 {
        arch -x86_64 /bin/bash -l
    }

    # Rosetta Specific
    if [[ "$(uname -m)" == "x86_64" ]]; then
        export PATH="/usr/local/sbin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

        # (x86_x64) [09/25/20 16:41:28] user@host ~
        if [[ $EUID -eq 0 ]]; then
            PS1='┌─\[\e[1;36m(x86_x64)\] \[\e[0m\][\D{%m/%d/%y %T}] \[\e[31m\]\u@\h\[\e[m\] \w\n└╼ \[\e[90m\]\$\[\e[0m\] '
        else
            PS1='┌─\[\e[1;36m(x86_x64)\] \[\e[0m\][\D{%m/%d/%y %T}] \[\e[32m\]\u@\h\[\e[m\] \w\n└╼ \[\e[90m\]\$\[\e[0m\] '
        fi
    # General
    else
        export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"


        if [[ $EUID -eq 0 ]]; then
            PS1="${ROOT_PS1}"
        else
            PS1="${USER_PS1}"
        fi
    fi

    complete -C "$(brew --prefix)/bin/aws_completer" aws
    if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
        # shellcheck source=/dev/null
        . "$(brew --prefix)/etc/bash_completion"
    fi

    # Aliases
    alias tf='$(brew --prefix)/bin/terraform'
    alias proxychains='$(brew --prefix)/proxychains4 -q'

    if pgrep -x "Xquartz" >/dev/null; then
        /opt/X11/bin/xhost >/dev/null
        /opt/X11/bin/xhost +localhost >/dev/null
    fi
else
    alias pbcopy='xclip -sel clip'
    
    if [[ $EUID -eq 0 ]]; then
        PS1="${ROOT_PS1}"
    else
        PS1="${USER_PS1}"
    fi
fi