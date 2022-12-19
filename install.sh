#!/bin/bash

set -eEuo pipefail
trap 'error $? $LINENO' ERR 

function error() {
    echo "ERROR: $1 on line $2"
    test -e /tmp/pw.sh && rm /tmp/pw.sh
}

if [[ $OSTYPE == 'darwin'* ]]; then 
    if [[ ! -f "${HOME}/.ssh/config" ]]; then
    mkdir -p "${HOME}/.ssh/"
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

    # Brew requires SUDO_ASKPASS for NONINTERACTIVE installs
    # This isn't ideal...
    echo "Enter your password. It will be stored temporarily in order to install Brew."
    read -rs PASS
    cat << EOF >> "/tmp/pw.sh"
#!/bin/bash
echo $PASS
EOF
    
    chmod +x /tmp/pw.sh

    export SUDO_ASKPASS=/tmp/pw.sh
    export NONINTERACTIVE=1

    # Brew for both M1 and Rosetta
    if [[ "$(uname -m)" == "arm64" ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        /opt/homebrew/bin/brew install "${BREW_FORMULAS[@]}"
        /opt/homebrew/bin/brew install --cask "${BREW_CASKS[@]}"

        if ! pgrep -x "oahd" >/dev/null; then
            echo "Installing Rosetta..."
            /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        fi

        # BUG: This fails with a strange sudo error when executing the curl output directly
        arch -x86_64 /bin/bash -l <<EOF
            curl -o /tmp/install.sh -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh
            chmod +x /tmp/install.sh
            /bin/bash -c /tmp/install.sh
            /usr/local/bin/brew install ${BREW_FORMULAS[@]}
EOF

    else
        /bin/bash "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        /usr/local/bin/brew install "${BREW_FORMULAS[@]}"
        /usr/local/bin/brew install --cask "${BREW_CASKS[@]}"      
    fi

    export PATH="/usr/local/sbin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

    cp ./.bash_profile "${HOME}/.bash_profile"
    cp ./.vimrc "${HOME}/.vimrc"
    cp ./.tmux.conf "${HOME}/.tmux.conf"

    sudo cp ./.bash_profile /var/root/.bash_profile
    sudo cp ./.vimrc /var/root/.vimrc
    sudo cp ./.tmux.conf /var/root/.tmux.conf
    
    plutil -convert binary1 ./iterm/com.googlecode.iterm2.plist
    cp ./iterm/com.googlecode.iterm2.plist "${HOME}/Library/Preferences/"

    sudo chsh -s /bin/bash "${USER}"

    # Cleanup
    rm /tmp/pw.sh

elif [ -f /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release

    if [ "$ID_LIKE" == "debian" ]; then

        export DEBIAN_FRONTEND=noninteractive

        # Install container specific requirements
        # WARNING: This may not work in other container types
        # WARNING: This section is not idempotent
        if test -f "/.dockerenv"; then
            ln -snf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && echo America/Los_Angeles > /etc/timezone
            apt update -y
            apt install -y sudo locales

            # Locales needed to properly display utf-8
            locale-gen en_US.UTF-8
            update-locale LANG=en_US.UTF-8

            # shellcheck disable=SC2129
            echo "" >> "${HOME}/.bashrc"
            echo 'export LANG="en_US.utf8"' >> "${HOME}/.bashrc"
            echo 'export LANGUAGE="en_US.utf8"' >> "${HOME}/.bashrc"
            echo 'export LC_ALL="en_US.utf8"' >> "${HOME}/.bashrc"
        fi

        # Warning: This will break without passwordless sudo
        sudo apt update -y
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
        if test -f "/etc/ssh/sshd_config"; then
            sudo sed -i 's/#X11Forwarding\ no/X11Forwarding\ yes/;s/#X11UseLocalhost/X11UseLocalhost/;s/#AddressFamily\ any/AddressFamily\ inet/' /etc/ssh/sshd_config
        fi
        
        # Docker
        curl -fsSL https://get.docker.com | sudo /bin/bash
        sudo usermod -aG docker "$(whoami)"
    fi

    cp ./.bash_profile "${HOME}/.bash_profile"
    cp ./.vimrc "${HOME}/.vimrc"
    cp ./.tmux.conf "${HOME}/.tmux.conf"

    sudo cp ./.bash_profile /root/.bash_profile
    sudo cp ./.vimrc /root/.vimrc
    sudo cp ./.tmux.conf /root/.tmux.conf
fi

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

echo "Done."