#!/bin/bash
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ && \
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list && \
apt-get update && \
apt-get install -y --no-install-recommends \
   code \
   build-essential \
   virtualenv \
   tcpdump \
   strace \
   iproute2 \
   iptables \
   iputils-ping \
   dnsutils \
   netcat \
   nmap \
   unzip \
   tmux \
   jq \
   zsh \
   python-dev \
   python-pip \
   python3-dev \
   python3-pip

pip3 install setuptools
pip3 install virtualenvwrapper
curl https://github.com/kubernetes-sigs/kustomize/releases/download/v2.0.3/kustomize_2.0.3_linux_amd64 -L -o /usr/local/bin/kustomize
curl -L https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
chmod +x /usr/local/bin/kustomize
