#!/usr/bin/bash

displaymng='DISPLAY_MANAGER'
X11conf='/etc/X11/xorg.conf.d/10-nvidia.conf'


# Change this only if you know what you're doing
modprobeconf='/etc/modprobe.d/nvidia-optimus.conf'

if [[ $(id -u) -ne 0 ]]; then
	echo 'This script needs root permissions';
	exit
fi

# Check if we're runnining in tty
if [[ ! $(tty) =~ 'tty' ]]; then
	echo 'This script must be ran in a TTY env'
	exit
fi


if [[ $1 == 'igpu' ]]; then

	# Stop X11
	systemctl stop $displaymng
	sleep 1

	# Remove the X11 config file
	#  that loads the nvidia drivers
	rm $X11conf

	# Add a file in /etc/modprobe.d so the
	# nvidia drivers don't load on boot
	cat << EOF > $modprobeconf
# Automatically added
#######################
# DO NOT EDIT BY HAND #
#######################

blacklist nvidia
blacklist nvidia_modeset
blacklist nvidia_drm
EOF

	# Unload the nvidia drivers
	modprobe -r nvidia_drm 
	modprobe -r nvidia_modeset 
	modprobe -r nvidia
	sleep 5

	# Power off the card
	tee /proc/acpi/bbswitch <<< OFF

	# Disable the GPU on boot
	systemctl enable optimus.service

	# Start X11
	systemctl start $displaymng
	
elif [[ $1 == 'dgpu' ]]; then

	# Stop X11
	systemctl stop $displaymng
	sleep 1

	# Add an X11 config file that loads
	# the nvidia drivers on X11 start
	cat << EOF > $X11conf
# Automatically added

Section "Device"
  Identifier "dGPU"
  Driver "nvidia"
EndSection
EOF

	# Autoload the nvidia drivers on boot
	cat << EOF > $modprobeconf
# Automatically added
# Add more options for the drivers here

options nvidia "NVreg_DynamicPowerManagement=0x02"
EOF

	# Power on the card
	tee /proc/acpi/bbswitch <<< ON
	sleep 1

	# Load the drivers
	modprobe nvidia_drm 
	modprobe nvidia_modeset
	modprobe nvidia "NVreg_DynamicPowerManagement=0x02"
	sleep 5

	# Don't disable the GPU on boot
	systemctl disable optimus.service

	# Start X11
	systemctl start $displaymng

	exit

else
	echo 'Usage: $0 [igpu] [dgpu]'
	exit
fi
