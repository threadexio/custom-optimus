#!/usr/bin/bash

confpath='CONFIGURATION_PATH'

# Check if we are running as root
if [[ $EUID != '0' ]]; then
	echo "Run $0 with root permissions to continue"
	exit 1
fi

# Check if the config file is present
if [[ -f $confpath ]]; then
	source $confpath
else
	echo "Could not find the config file at $confpath. Getting a new config file from the installer will fix this problem"
	exit 3
fi

# Indicates if the script is currently running as a daemon
: ${daemon:=false}

# Command to daemonize the script
daemonize="env -i --block-signal=SIGHUP --block-signal=SIGTERM daemon=true $0 $@"

if [[ $daemon == "true" ]]; then

	# Get the session ID from loginctl
	session=$(loginctl | awk '$NR > 3 && $5 == "" {print $1}')

	if [[ $1 == 'igpu' ]]; then

		# Gracefully stop X11
		loginctl terminate-session $session
		sleep 2
		systemctl stop $displaymng
		sleep 1

		# Remove the X11 config file
		# that loads the nvidia drivers
		rm $X11conf

		# Add a file in /etc/modprobe.d so the
		# nvidia drivers don't load on boot
		cat << EOF | tee $modprobeconf
# Automatically added
#######################
# DO NOT EDIT BY HAND #
#######################

blacklist nvidia
blacklist nvidia_modeset
blacklist nvidia_drm
EOF

		# Unload the nvidia drivers
		while [[ ! -z "$(lsmod | grep nvidia)" ]]; do
			modprobe -r nvidia_drm
			modprobe -r nvidia_modeset
			modprobe -r nvidia
			sleep 1
		done


		# Power off the card
		tee /proc/acpi/bbswitch <<< OFF

		# Disable the GPU on boot
		systemctl enable optimus.service

		# Start X11
		systemctl start $displaymng

		clear
		exit 0

	elif [[ $1 == 'dgpu' ]]; then

		# Gracefully stop X11
		loginctl terminate-session $session
		sleep 2
		systemctl stop $displaymng
		sleep 1

		# Add an X11 config file that loads
		# the nvidia drivers on X11 start
		cat << EOF | tee $X11conf
# Automatically added

Section "Device"
  Identifier "dGPU"
  Driver "nvidia"
EndSection
EOF

		# Autoload the nvidia drivers on boot
		cat << EOF | tee $modprobeconf
# Automatically added
# Add more options for the drivers here

options nvidia "NVreg_DynamicPowerManagement=0x02"
EOF

		# Power on the card
		tee /proc/acpi/bbswitch <<< ON
		sleep 1

		# Load the drivers
		while [[ -z "$(lsmod | grep nvidia)" ]]; do
			modprobe nvidia_drm
			modprobe nvidia_modeset
			modprobe nvidia
			sleep 1
		done

		# Don't disable the GPU on boot
		systemctl disable optimus.service

		# Start X11
		systemctl start $displaymng

		clear
		exit 0
	fi

else

	if [[ $1 == "igpu" ]]; then

		$daemonize

	elif [[ $1 == "dgpu" ]]; then

		$daemonize

	else
		echo "Usage: $0 [igpu/dgpu]"
		echo ""
		echo "igpu | Turn off the discrete GPU"
		echo "dgpu | Turn on the discrete GPU"
		exit 0
	fi

fi
