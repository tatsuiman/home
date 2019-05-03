#!/bin/bash
sudo apt update
sudo apt install docker.io
sudo usermod -aG docker ${USER}
sudo curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod 755 /usr/local/bin/docker-compose
