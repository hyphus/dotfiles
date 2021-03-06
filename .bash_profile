[[ -s "$HOME/.bashrc" ]] && source "$HOME/.bashrc"

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

#┌─[12/25/20 21:08:33] user@host ~
#└╼ $
if [[ $EUID -eq 0 ]]; then
    PS1='┌─[\D{%m/%d/%y %T}] \[\e[31m\]\u@\h\[\e[m\] \w\n└╼ \[\e[90m\]\$\[\e[0m\] '
else
    PS1='┌─[\D{%m/%d/%y %T}] \[\e[32m\]\u@\h\[\e[m\] \w\n└╼ \[\e[90m\]\$\[\e[0m\] '
fi

function random {
    openssl rand -base64 $1
}

function nocomment {
  grep -v '^$\|^\s*\#' $1
}
