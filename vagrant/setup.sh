#!/bin/bash

set -eouf pipefail

CTFD_VERSION=3.3.0

# update and install os packages
sudo apt update -y &&
    sudo apt install -y python3-pip

# configure pip
export PATH=$PATH:$HOME/.local/bin
echo "PATH=$PATH:$HOME/.local/bin" >> ~/.bashrc

# install ansible
pip install ansible

# get ctfd source
wget https://github.com/CTFd/CTFd/archive/refs/tags/${CTFD_VERSION}.tar.gz
sudo tar xzvf ${CTFD_VERSION}.tar.gz -C /opt

# fix permissions
sudo chown -R $USER.$USER /opt/CTFd-${CTFD_VERSION}
sudo chmod 775 /opt/CTFd-${CTFD_VERSION}/.

# install docker
sudo bash /opt/CTFd-${CTFD_VERSION}/scripts/install_docker.sh

# build and pull all the containers
cd /opt/CTFd-${CTFD_VERSION}
sudo docker-compose pull
sudo docker build .
