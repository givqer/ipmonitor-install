#!/bin/bash

sudo rm -rf /opt/ipmonitor
sudo apt-get remove -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-ce-rootless-extras docker-buildx-plugin
