#/bin/bash

set -x

if [[ $OSTYPE == 'darwin'* ]]; then 
    # TODO: Brew and other things

    cat << EOF >> $HOME/.ssh/config
Host *
    ForwardX11 yes
    ForwardX11Trusted yes
    ServerAliveInterval 60
EOF

elif [ -f /etc/os-release ]; then
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

        echo "alias pbcopy='xclip -sel clip'" >> $HOME/.bash_aliases

        # x11
        sudo sed -i 's/#X11Forwarding\ no/X11Forwarding\ yes/;s/#X11UseLocalhost/X11UseLocalhost/;s/#AddressFamily\ any/AddressFamily\ inet/' /etc/ssh/sshd_config

        # Docker
        curl -fsSL https://get.docker.com | sudo bash
        sudo usermod -aG docker ubuntu

        # FPP - used with tmux
        pushd /tmp/
        git clone --depth 1 https://github.com/facebook/PathPicker.git
        cd PathPicker/debian
        ./package.sh
        sudo dpkg -i ../pathpicker*.deb
        popd
    fi
fi

cp ./.bash_profile $HOME/.bash_profile
cp ./.vimrc $HOME/.vimrc
cp ./.tmux.conf $HOME/.tmux.conf

sudo cp ./.bash_profile /root/.bash_profile
sudo cp ./.vimrc /root/.vimrc
sudo cp ./.tmux.conf /root/.tmux.conf

vim +'PlugInstall --sync' +qall &> /dev/null

# TPM install requires tmux to be running
git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux start-server
tmux new-session -d
sleep 1 # to give new-session time to init
tmux source ~/.tmux.conf
~/.tmux/plugins/tpm/scripts/install_plugins.sh
tmux kill-server
