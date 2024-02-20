#!/bin/bash

if [ -f "${HOME}/.bashrc" ]; then
    # shellcheck source=/dev/null
    . "${HOME}/.bashrc"
fi

# Functions
function random {
    if [ -z "${1}" ]; then 
        openssl rand -base64 32
    else 
        openssl rand -base64 "$1"
    fi
}

function lower {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

function nocomment {
  grep -v '^$\|^\s*\#' "$1"
}

function complete_me {
    if [[ -r "$BREW_PREFIX/etc/profile.d/bash_completion.sh" ]]; then
        # shellcheck source=/dev/null
        . "$BREW_PREFIX/etc/profile.d/bash_completion.sh"
    fi

    # awscli completion doesn't work using the brew installed version
    test -e "$BREW_PREFIX/bin/aws_completer" && complete -C "$BREW_PREFIX/bin/aws_completer" aws
}

# Sync history between shells
HISTSIZE=900000
HISTFILESIZE=$HISTSIZE
HISTCONTROL=ignorespace:ignoredups
HISTTIMEFORMAT="[%m/%d/%y %T] "

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

    BREW_PREFIX=$(brew --prefix)
    export BREW_PREFIX

    function x86 {
        arch -x86_64 /bin/bash -l
    }

    # Rosetta Specific
    if [[ "$(uname -m)" == "x86_64" && "$(sysctl -n machdep.cpu.brand_string)" = Apple* ]]; then
        export PATH="$BREW_PREFIX/sbin:$BREW_PREFIX/bin:$BREW_PREFIX/opt/coreutils/libexec/gnubin:$BREW_PREFIX/opt/curl/bin:$BREW_PREFIX/opt/grep/libexec/gnubin:$PATH"
        
        # (x86_x64) [09/25/20 16:41:28] user@host ~
        if [[ $EUID -eq 0 ]]; then
            PS1='┌─\[\e[1;36m(x86_x64)\] \[\e[0m\][\D{%m/%d/%y %T}] \[\e[31m\]\u@\h\[\e[m\] \w\n└╼ \[\e[90m\]\$\[\e[0m\] '
        else
            PS1='┌─\[\e[1;36m(x86_x64)\] \[\e[0m\][\D{%m/%d/%y %T}] \[\e[32m\]\u@\h\[\e[m\] \w\n└╼ \[\e[90m\]\$\[\e[0m\] '
        fi
    # General
    else
        export PATH="/opt/homebrew/sbin:/opt/homebrew/bin:/opt/homebrew/opt/coreutils/libexec/gnubin:$BREW_PREFIX/opt/curl/bin:$BREW_PREFIX/opt/grep/libexec/gnubin:$PATH"
        if [[ $EUID -eq 0 ]]; then
            PS1="${ROOT_PS1}"
        else
            PS1="${USER_PS1}"
        fi
    fi

    # Bash completion
    complete_me

    # Aliases
    alias tf='$BREW_PREFIX/bin/terraform'
    alias proxychains='$BREW_PREFIX/bin/proxychains4 -q'
    alias netstat='lsof -i -nPR'
    alias pip='$BREW_PREFIX/bin/pip3'
    alias python='$BREW_PREFIX/bin/python3'
    
    if pgrep -x "Xquartz" >/dev/null; then
        /opt/X11/bin/xhost >/dev/null
        /opt/X11/bin/xhost +localhost >/dev/null
    fi
else
    alias pbcopy="xclip -sel clip"
    alias python="/usr/bin/python3"
    alias pip="/usr/bin/pip3"
    alias proxychains="/usr/bin/proxychains4 -q"

    # Bash completion
    complete_me

    if [[ $EUID -eq 0 ]]; then
        PS1="${ROOT_PS1}"
    else
        PS1="${USER_PS1}"
    fi
fi
