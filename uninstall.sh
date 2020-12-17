#!/usr/bin/bash

# Disable the service
systemctl disable optimus.service

# Delete the service the service 
rm /etc/systemd/system/optimus.service

# Delete all configuration files
rm /etc/X11/xorg.conf.d/10-nvidia.conf
rm /etc/modules-load.d/bbswitch.conf
rm /etc/modprobe.d/nvidia-optimus.conf