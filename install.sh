#/bin/bash

if [ -f /etc/os-release ]; then
    . /etc/os-release

    if [ "$ID_LIKE" == "debian" ]; then
        sudo apt update -y && \
            apt install -y \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg-agent \
                software-properties-common \
                tmux \
                htop \
                python3 \
                python3-pip \
                tree

        curl -fsSL https://get.docker.com | sudo bash
    fi
fi

cp ./.bash_profile $HOME/.bash_profile
cp ./.vimrc $HOME/.vimrc
cp ./.tmux.conf $HOME/.tmux.conf