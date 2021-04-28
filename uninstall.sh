#!/usr/bin/bash

confpath="/etc/optimus/optimus.conf"

if [[ $EUID != '0' ]]; then
	echo "Run $0 with root permissions to continue"
	exit 1
fi

# Check if the config file is present
if [[ -f $confpath ]]; then
	source $confpath
else
	echo "Could not find the config file at $confpath. Cannot continue"
	exit 1
fi

# Remove any symlinks systemd has made
systemctl disable optimus.service

# Remove all related files
rm -f $servicepath/optimus.service
rm -f $X11conf
rm -f $modprobeconf
rm -f /usr/bin/optimus
rm -drf $(dirname $confpath)

echo "Done!"
