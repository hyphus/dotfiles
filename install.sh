#!/bin/bash

set -x

if [[ $OSTYPE == 'darwin'* ]]; then 
    if [[ ! -f "${HOME}/.ssh/config" ]]; then
    cat << EOF >> "${HOME}/.ssh/config"
Host git*
    ForwardX11 no
    ForwardX11Trusted no

Host *
    ForwardX11 yes
    ForwardX11Trusted yes
    ServerAliveInterval 60
EOF
    fi

    BREW_FORMULAS=(
        awscli
        bash
        bash-completion
        curl
        docker
        grep
        htop
        jq
        kubernetes-cli
        nmap
        proxychains-ng
        shellcheck
        terraform
        tmux
        tree
        whatmask
    )

    # These aren't needed for Rosetta
    BREW_CASKS=(
        alt-tab
        discord
        firefox
        google-chrome
        gpg-suite
        iterm2
        little-snitch
        microsoft-remote-desktop
        rectangle
        signal
        slack
        spotify
        utm
        visual-studio-code
        wireshark
        xquartz
    )

    # Brew for both M1 and Rosetta
    export NONINTERACTIVE=1
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    /usr/local/bin/brew install "${BREW_FORMULAS[@]}"
    /usr/local/bin/brew install --cask "${BREW_CASKS[@]}"
        
    if [[ "$(uname -m)" == "arm64" ]]; then
        arch -x86_64 -e /bin/bash <<EOF
        export NONINTERACTIVE=1
        /bin/bash "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        /opt/homebrew/bin/brew install "${BREW_FORMULAS[@]}"
EOF
    fi

    mkdir -p "${HOME}/.iterm2"
    cp ./com.googlecode.iterm2.plist "${HOME}/.iterm2/"

elif [ -f /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release

    if [ "$ID_LIKE" == "debian" ]; then
        sudo apt update -y && \
            sudo apt install -y \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg-agent \
                software-properties-common \
                tmux \
                htop \
                python3 \
                python3-pip \
                tree \
                git \
                jq \
                net-tools \
                vim \
                xclip \
                unzip

        # x11
        sudo sed -i 's/#X11Forwarding\ no/X11Forwarding\ yes/;s/#X11UseLocalhost/X11UseLocalhost/;s/#AddressFamily\ any/AddressFamily\ inet/' /etc/ssh/sshd_config

        # Docker
        curl -fsSL https://get.docker.com | sudo /bin/bash
        sudo usermod -aG docker "$(whoami)"
    fi
fi

cp ./.bash_profile "${HOME}/.bash_profile"
cp ./.vimrc "${HOME}/.vimrc"
cp ./.tmux.conf "${HOME}/.tmux.conf"

sudo cp ./.bash_profile /root/.bash_profile
sudo cp ./.vimrc /root/.vimrc
sudo cp ./.tmux.conf /root/.tmux.conf

vim +'PlugInstall --sync' +qall &> /dev/null

if [[ ! -f "${HOME}/.tmux/plugins/tpm" ]]; then
    git clone --depth 1 https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
fi

# TPM install requires tmux to be running
tmux start-server
tmux new-session -d
sleep 1 # to give new-session time to init
tmux source "${HOME}/.tmux.conf"
"${HOME}"/.tmux/plugins/tpm/scripts/install_plugins.sh
tmux kill-server