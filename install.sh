#!/bin/bash

set -eEuo pipefail

error() {
    local exit_code=$1
    local line=$2

    echo "ERROR: command failed with exit code ${exit_code} on line ${line}" >&2
    rm -f /tmp/pw.sh
    exit "$exit_code"
}

trap 'error $? $LINENO' ERR

if [[ $OSTYPE == 'darwin'* ]]; then 

    # keep awake 
    caffeinate -i &
    CAFF_PID=$!
    trap 'kill $CAFF_PID 2>/dev/null' EXIT

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
        azure-cli
        bash
        bash-completion@2
        coreutils
        curl
        fzf
        grep
        htop
        ipcalc
        jq
        kubernetes-cli
        nmap
        proxychains-ng
        sevenzip
        shellcheck
        tfenv
        tmux
        tree
    )

    # These aren't needed for Rosetta
    BREW_CASKS=(
        1password
        alt-tab
        brave-browser
        burp-suite
        docker
        firefox
        google-chrome
        gpg-suite
        iterm2
        little-snitch
        lm-studio
        obsidian
        powershell
        signal
        slack
        spotify
        utm
        visual-studio-code
        windows-app
        wireguard-tools
        wireshark
        xquartz
    )

    # Brew requires SUDO_ASKPASS for NONINTERACTIVE installs
    # This isn't ideal...
    echo "Enter your password. It will be stored temporarily in order to install Brew."
    read -rs PASS
    cat << EOF >> "/tmp/pw.sh"
#!/bin/bash
echo $(printf "%q\n" "$PASS")
EOF
    
    chmod +x /tmp/pw.sh

    export SUDO_ASKPASS=/tmp/pw.sh
    export NONINTERACTIVE=1
    export HOMEBREW_NO_ENV_HINTS=1 

    # Brew for both M1 and Rosetta
    if [[ "$(uname -m)" == "arm64" ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        /opt/homebrew/bin/brew install -y "${BREW_FORMULAS[@]}"
        /opt/homebrew/bin/brew install --cask -y "${BREW_CASKS[@]}"

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
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        /usr/local/bin/brew install "${BREW_FORMULAS[@]}"
        /usr/local/bin/brew install --cask "${BREW_CASKS[@]}"      
    fi

    cp ./.bash_profile "${HOME}/.bash_profile"
    cp ./.vimrc "${HOME}/.vimrc"
    cp ./.tmux.conf "${HOME}/.tmux.conf"

    sudo -A cp ./.bash_profile /var/root/.bash_profile
    sudo -A cp ./.vimrc /var/root/.vimrc
    sudo -A cp ./.tmux.conf /var/root/.tmux.conf
    
    plutil -convert binary1 ./iterm/com.googlecode.iterm2.plist
    cp ./iterm/com.googlecode.iterm2.plist "${HOME}/Library/Preferences/"

    # Set shells for root and user
    if ! grep -qxF '/opt/homebrew/bin/bash' /etc/shells; then
        echo "/opt/homebrew/bin/bash" | sudo -A tee -a /etc/shells
        sudo -A chsh -s /opt/homebrew/bin/bash
        sudo -A chsh -s /opt/homebrew/bin/bash "${USER}"
    fi

    # VS Code settings
    mkdir -p "${HOME}/Library/Application Support/Code/User"
    cp ./vscode/settings.json "${HOME}/Library/Application Support/Code/User/settings.json"
    /opt/homebrew/bin/code \
        --install-extension docker.docker \
        --install-extension donjayamanne.githistory \
        --install-extension hashicorp.terraform \
        --install-extension mechatroner.rainbow-csv \
        --install-extension ms-azuretools.vscode-containers \
        --install-extension ms-azuretools.vscode-docker \
        --install-extension ms-python.autopep8 \
        --install-extension ms-python.debugpy \
        --install-extension ms-python.python \
        --install-extension ms-python.vscode-pylance \
        --install-extension ms-python.vscode-python-envs \
        --install-extension ms-vscode-remote.remote-containers \
        --install-extension ms-vscode-remote.remote-ssh \
        --install-extension ms-vscode-remote.remote-ssh-edit \
        --install-extension ms-vscode.cmake-tools \
        --install-extension ms-vscode.hexeditor \
        --install-extension ms-vscode.powershell \
        --install-extension ms-vscode.remote-explorer \
        --install-extension redhat.vscode-yaml \
        --install-extension sebastienma.ansi-color-code \
        --install-extension timonwong.shellcheck
    
    # Cleanup
    rm /tmp/pw.sh

elif [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    . /etc/os-release

    if [[ "${ID_LIKE:-}" == "debian" || "$ID" == "debian" ]]; then

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
            bash-completion \
            ca-certificates \
            curl \
            fzf \
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
        if ! command -v docker >/dev/null 2>&1; then
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
fi

mkdir -p "${HOME}/.config/bash"

vim +'PlugInstall --sync' +qall &> /dev/null

if [[ ! -d "${HOME}/.tmux/plugins/tpm" ]]; then
    git clone --depth 1 https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
fi

# TPM install requires tmux to be running
tmux new-session -d
tmux source-file "${HOME}/.tmux.conf"
"${HOME}/.tmux/plugins/tpm/scripts/install_plugins.sh"
tmux kill-server

echo "Done."
