# [09/25/20 16:41:28] user@host ~
if [[ $EUID -eq 0 ]]; then
    PS1='[\D{%m/%d/%y %T}] \[\e[31m\]\u@\h\[\e[m\] \w\n\$ '
else
    PS1='[\D{%m/%d/%y %T}] \[\e[32m\]\u@\h\[\e[m\] \w\n\$ '
fi

function random {
    openssl rand -base64 $1
}

function nocomment {
  grep -v '^$\|^\s*\#' $1
}