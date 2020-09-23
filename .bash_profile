# [09/23/20 14:22:45] user ~
PS1='[\D{%m/%d/%y %T}] \u \w\n\$ '

function random {
    openssl rand -base64 $1
}

function nocomment {
  grep -v '^$\|^\s*\#' $1
}