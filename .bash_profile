[[ -s "$HOME/.bashrc" ]] && source "$HOME/.bashrc"

#┌─[12/25/20 21:08:33] user@host ~
#└╼ $
if [[ $EUID -eq 0 ]]; then
    PS1='\e[36m┌─[\D{%m/%d/%y %T}]\] \e[31m\]\u@\h\[\e[m\] \w\n\e[36m└╼ \$\[\e[0m\] '
else
    PS1='\e[36m┌─[\D{%m/%d/%y %T}]\] \e[32m\]\u@\h\[\e[m\] \w\n\e[36m└╼ \$\[\e[0m\] '
fi

function random {
    openssl rand -base64 $1
}

function nocomment {
  grep -v '^$\|^\s*\#' $1
}
