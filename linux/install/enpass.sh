#!/bin/bash
echo "deb https://apt.enpass.io/ stable main" | sudo tee -a /etc/apt/sources.list.d/enpass.list
wget -O - https://apt.enpass.io/keys/enpass-linux.key | sudo apt-key add -
apt-get update
apt-get install enpass
