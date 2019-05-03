#!/bin/bash
sudo apt update
sudo apt install docker
sudo usermod -aG docker ${USER}
sudo curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod 755 /usr/local/bin/docker-compose
