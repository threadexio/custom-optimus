#!/usr/bin/bash

confpath='/etc/optimus'
servicepath='/etc/systemd/system'

if [[ $(logname) != $USER ]]; then
	echo 'Run as your main user'
	exit 1
fi

printf "What display manager do you use? "
read displaymng

sudo systemctl status $displaymng &>/dev/null
if [[ $? -eq 4 ]]; then
	echo "Display manager $displaymng could not be found. Are you sure this is your display manager?"
	exit 1
fi

printf "\nThis installer will:\n\tAdd a service in systemd\n\tCreate a config file in $confpath\n\tCopy optimus.sh to /usr/bin/optimus\n\tInstall: nvidia nvidia-prime bbswitch\n\nContinue? [Y/n] "
read a

if [[ $a == "" || $(grep -oi "y" <<< $a) ]]; then

	# Write config based on DE
	if [[ $XDG_CURRENT_DESKTOP == "GNOME" ]]; then
		logoutcmd='gnome-session-quit'
	elif [[ $XDG_CURRENT_DESKTOP == "KDE" ]]; then
		logoutcmd='qdbus org.kde.ksmserver /KSMServer logout 0 0 0'
	elif [[ $XDG_CURRENT_DESKTOP == "XFCE" ]]; then
		logoutcmd='xfce4-session-logout --logout'
	elif [[ $XDG_CURRENT_DESKTOP == "MATE" ]]; then
		logoutcmd='mate-session-save --force-logout'
	else
		echo "The installer couldn't recognise your Desktop Environment, please set logoutcmd in the configuration manually"
		logoutcmd=''
fi

	
	cat << EOF > files/optimus.conf
##
##	Optimus Configuration file, generated on $(date)
##	https://github.com/threadexio/custom-optimus
##

## The command your Desktop Environment 
## uses to logout the user
## Examples
## GNOME 11.10 and above:	gnome-session-quit
## KDE Plasma:	qdbus org.kde.ksmserver /KSMServer logout 0 0 0
## Xfce4:	xfce4-session-logout --logout
## Mate:	mate-session-save --force-logout
logoutcmd='$logoutcmd'

## This is the name of the display manager
## you chose during the installation
## If for any reason you have switched display
## managers, change this aswell
displaymng='$displaymng'

## This is the file that holds the configuration
## for the nvidia card. Usually you don't have to
## change the location, only the contents
X11conf='/etc/X11/xorg.conf.d/10-nvidia.conf'

##################################################

##
##	Advanced
##

## The location where systemd keeps services
servicepath='$servicepath'

## This is the file that tells the Linux kernel
## if it should load the nvidia drivers on boot
## Should be in /etc/modprobe.d
## Change this ONLY if you know what you're doing
modprobeconf='/etc/modprobe.d/nvidia-optimus.conf'

EOF

	# Copy the config
	sudo mkdir -p $confpath
	sudo cp files/optimus.conf $confpath
	sed -i "s%CONFIGURATION_PATH%$confpath/optimus.conf%g" optimus.sh
	sed -i "s%CONFIGURATION_PATH%$confpath/optimus.conf%g" uninstall.sh

	# Copy the service
	sudo cp files/optimus.service $servicepath/optimus.service

	# Copy the executable
	sudo cp optimus.sh /usr/bin/optimus

	# Fix the permissions
	sudo chown root:root $servicepath/optimus.service
	sudo chown 644 $servicepath/optimus.service
	sudo chown root:root $confpath/optimus.conf
	sudo chown 644 $confpath/optimus.conf
	sudo chown root:root /usr/bin/optimus
	sudo chown 754 /usr/bin/optimus

	# Install the dependencies
	sudo pacman -S nvidia nvidia-prime bbswitch

	# Set bbswitch to load on boot
	sudo tee /etc/modules-load.d/bbswitch.conf <<< 'bbswitch' &>/dev/null

	echo "----------------------------------------------------------------------------------------------------------"
	echo "Installation finished! Edit the configuration file ($confpath/optimus.conf) for any incorrect values and reboot"
	echo "----------------------------------------------------------------------------------------------------------"
else
	echo "Installation aborted!"
	exit 1
fi
