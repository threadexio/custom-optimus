#!/usr/bin/bash

confdir="/etc/optimus"
confpath="$confdir/optimus.conf"

# Check if we are running as root
root_needed() {
	if [ "$EUID" != '0' ]; then
		echo "Run $0 with root permissions to continue"
		exit 1
	fi
}

# Check if the config file is present
if [ -f "$confpath" ]; then
	source "$confpath"
else
	echo "Could not find the config file at $confpath. Getting a new config file from the installer will fix this problem"
	exit 1
fi

# Indicates if the script is currently running as a daemon
: "${daemon:=false}"

# Command to daemonize the script
# basically detach it, so it doesn't
# get killed by X11
daemonize="env -i --block-signal=SIGHUP --block-signal=SIGTERM daemon=true $0 $@"

# Stop X11 gracefully
x11_exit() {
	systemctl stop display-manager
	sleep 1
}

# Used to unload drivers
unload_drivers() {
	# Continue running until all modules
	# with nvidia in their name are unloaded
	while lsmod | grep -q "nvidia"; do
		m=$(lsmod | awk '{print $1}' | grep nvidia)
		for i in $m; do
			modprobe -r "$i"
		done
		sleep 1
	done
	sleep 1
}

# Used to load drivers
# $1 - specify parameters to the nvidia driver
load_drivers() {
	modprobe nvidia_drm
	modprobe nvidia_modeset
	modprobe nvidia "$1"
}

set_card_state() {
	if [ "$1" == "ON" ] || [ "$1" == "OFF" ]; then
		tee /proc/acpi/bbswitch <<<"$1"
		sleep 1
	else
		echo "Invalid card state: $1"
	fi
}

if [ "$daemon" == "true" ]; then

	if [ "$1" == 'igpu' ]; then

		x11_exit

		# Remove the X11 config file
		# that loads the nvidia drivers
		rm "$X11conf"

		# Add a file in /etc/modprobe.d so the
		# nvidia drivers don't load on boot
		cp "$confdir/other/blacklist_nvidia.conf" "$modprobeconf"

		# Disable the GPU on boot
		systemctl enable optimus.service

		# Unload the nvidia drivers
		unload_drivers

		# Power off the card
		set_card_state OFF

		# Start X11
		systemctl start display-manager

		exit 0

	elif [[ $1 == 'dgpu' ]]; then

		x11_exit

		# Add an X11 config file that loads
		# the nvidia drivers on X11 start
		cp "$confdir/other/X11.conf" "$X11conf"

		# Autoload the nvidia drivers on boot
		cp "$confdir/other/load_nvidia.conf" "$modprobeconf"
		cp "$confdir/other/nvidia_modules.conf" "$modulesloadconf"

		# Don't disable the GPU on boot
		systemctl disable optimus.service

		# Power on the card
		set_card_state ON

		# Load the drivers
		load_drivers "NVreg_DynamicPowerManagement=0x02"

		# Start X11
		systemctl start display-manager

		exit 0
	fi

else

	if [ "$1" == "igpu" ] || [ "$1" == "dgpu" ]; then
		root_needed
		$daemonize
	elif [ "$1" == "state" ]; then
		if lsmod | grep -q "nvidia"; then
			echo 1
		else
			echo 0
		fi
		exit 0
	else
		echo "Usage: $0 [igpu/dgpu]"
		echo ""
		echo "igpu	| Turn off the discrete GPU"
		echo "dgpu	| Turn on the discrete GPU"
		echo "state	| Get state of discrete GPU (0 = OFF, 1 = ON)"
		exit 0
	fi

fi
