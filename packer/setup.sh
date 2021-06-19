#!/bin/bash

set -eouf pipefail

CTFD_VERSION=${CTFD_VERSION}

# update and install os packages
sudo apt update -y &&
    sudo apt install -y python3-pip \
        make \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        wget \
        curl \
        llvm \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libxml2-dev \
        libxmlsec1-dev \
        libffi-dev \
        liblzma-dev


# configure pip
export PATH=$PATH:$HOME/.local/bin
echo "PATH=$PATH:$HOME/.local/bin" >> ~/.bashrc

# install ansible
pip install ansible

# get ctfd source
wget https://github.com/CTFd/CTFd/archive/refs/tags/${CTFD_VERSION}.tar.gz
sudo tar xzvf ${CTFD_VERSION}.tar.gz -C /opt

sudo useradd ctfd -d /opt/CTFd-${CTFD_VERSION}

# fix permissions
sudo chown -R ctfd.ctfd /opt/CTFd-${CTFD_VERSION}
sudo chmod 775 /opt/CTFd-${CTFD_VERSION}/.

#install pyenv
sudo su ctfd -c "curl https://pyenv.run | bash"

# add vars and evals to all shells
echo "export PYENV_ROOT=\"$HOME/.pyenv\"" >> /etc/profile.d/pyenv.sh
echo "export PATH=\"$PYENV_ROOT/bin:$PATH\"" >> /etc/profile.d/pyenv.sh
echo "eval \"$(pyenv init --path)\""  >> /etc/profile.d/pyenv.sh
echo "eval \"$(pyenv virtualenv-init -)\"" >> /etc/profile.d/pyenv.sh
sudo chmod +x /etc/profile.d/pyenv.sh

# set up matching py
sudo su - ctfd -c "pyenv install 3.7.10"
sudo su - ctfd -c "pyenv virtualenv 3.7.10 ctfd"

cd /opt/CTFd-${CTFD_VERSION}/
/opt/ctfd-test/.pyenv/bin/pyenv local ctfd

