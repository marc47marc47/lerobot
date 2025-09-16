#!/bin/sh
sudo chmod 666 /dev/video*
#sudo chown root:ub22 /dev/video0
sudo usermod -aG video ub22
