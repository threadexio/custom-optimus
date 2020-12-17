#!/usr/bin/bash

servicepath='/etc/systemd/system'

# Copy the service
cp optimus.service $servicepath/optimus.service

# Fix the permissions on the service file
chown root:root $servicepath/optimus.service
chown 644 $servicepath/optimus.service

# Install the dependencies
pacman -S nvidia nvidia-prime bbswitch

echo "Done! Rebooting now is strongly recommended"