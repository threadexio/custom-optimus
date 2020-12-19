#!/usr/bin/bash

confpath='CONFIGURATION_PATH'

# Check if we are running as our user,
# DBus won't let us logout if we are another user
if [[ $(logname) != $USER ]]; then
	echo 'Run as your main user'
	exit 1
fi

# Check if we're runnining in tty
if [[ ! $(tty) =~ 'tty' ]]; then
	echo 'This script must be ran in a TTY env'
	exit 1
fi

# Check if the config file is present
if [[ -f $confpath ]]; then
	source $confpath
else
	echo "Could not find the config file at $confpath. Getting a new config file from the installer will fix this problem"
	exit 1
fi

if [[ $1 == 'igpu' ]]; then

	# This is here just to ask for the sudo password
	sudo echo 'Logging off...'

	# Gracefully stop X11
	eval "$logoutcmd"
	sleep 15 # Make sure everything has finished
	sudo systemctl stop $displaymng
	sleep 1

	# Remove the X11 config file
	# that loads the nvidia drivers
	sudo rm $X11conf

	# Add a file in /etc/modprobe.d so the
	# nvidia drivers don't load on boot
	cat << EOF | sudo tee $modprobeconf
# Automatically added
#######################
# DO NOT EDIT BY HAND #
#######################

blacklist nvidia
blacklist nvidia_modeset
blacklist nvidia_drm
EOF

	# Unload the nvidia drivers
	sudo modprobe -r nvidia_drm 
	sudo modprobe -r nvidia_modeset 
	sudo modprobe -r nvidia
	sleep 5

	# Power off the card
	sudo tee /proc/acpi/bbswitch <<< OFF

	# Disable the GPU on boot
	sudo systemctl enable optimus.service

	# Start X11
	sudo systemctl start $displaymng

	clear
	exit
	
elif [[ $1 == 'dgpu' ]]; then

	# This is here just to ask for the sudo password
	sudo echo 'Logging off...'

	# Gracefully stop X11
	eval "$logoutcmd"
	sleep 15
	sudo systemctl stop $displaymng
	sleep 1

	# Add an X11 config file that loads
	# the nvidia drivers on X11 start
	cat << EOF | sudo tee $X11conf
# Automatically added

Section "Device"
  Identifier "dGPU"
  Driver "nvidia"
EndSection
EOF

	# Autoload the nvidia drivers on boot
	cat << EOF | sudo tee $modprobeconf
# Automatically added
# Add more options for the drivers here

options nvidia "NVreg_DynamicPowerManagement=0x02"
EOF

	# Power on the card
	sudo tee /proc/acpi/bbswitch <<< ON
	sleep 1

	# Load the drivers
	sudo modprobe nvidia_drm 
	sudo modprobe nvidia_modeset
	sudo modprobe nvidia "NVreg_DynamicPowerManagement=0x02"
	sleep 5

	# Don't disable the GPU on boot
	sudo systemctl disable optimus.service

	# Start X11
	sudo systemctl start $displaymng

	clear
	exit

else
	echo "Usage: $0 [igpu/dgpu]"
	exit
fi