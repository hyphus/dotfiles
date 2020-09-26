# [09/25/20 16:41:28] user@host ~
PS1='[\D{%m/%d/%y %T}] \u@\h \w\n\$ '

function random {
    openssl rand -base64 $1
}

function nocomment {
  grep -v '^$\|^\s*\#' $1
}