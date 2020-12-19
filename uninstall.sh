#!/usr/bin/bash

confpath='CONFIGURATION_PATH'

if [[ $(id -u) != '0' ]]; then
	echo "Run $0 with root permissions to continue"
	exit 1
fi

# Check if the config file is present
if [[ -f $confpath ]]; then
	source $confpath
else
	echo "Could not find the config file at $confpath. Cannot"
	exit 1
fi

# Remove any symlinks systemd has made
systemctl disable optimus.service

# Remove all related files
rm -f $X11conf
rm -f $servicepath/optimus.service
rm -f $modprobeconf
rm -f /usr/bin/optimus

echo "Uninstalled!"
