#!/usr/bin/bash

confpath='/etc/optimus'
servicepath='/etc/systemd/system'

if [[ "$EUID" != "0" ]]; then
	echo "Run $0 with root permissions to continue"
	exit 1
fi

displaymng="$(basename "$(readlink $servicepath/display-manager.service)" .service)"

printf "\nThis installer will:\n\tAdd a service in systemd\n\tCreate a config file in %s\n\tCopy optimus.sh to /usr/bin/optimus\n\nContinue? [Y/n] " $confpath
read -r a

if [[ "$a" == "n" || "$a" == "N" ]]; then
	echo 'Exiting...'
	exit
fi

cat << EOF > files/optimus.conf
##
##	Optimus Configuration file, generated on $(date)
##	https://github.com/threadexio/custom-optimus
##

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
mkdir -p $confpath
cp files/optimus.conf $confpath
sed -i "s%CONFIGURATION_PATH%$confpath/optimus.conf%g" optimus.sh
sed -i "s%CONFIGURATION_PATH%$confpath/optimus.conf%g" uninstall.sh

# Copy the service
cp files/optimus.service $servicepath/optimus.service

# Copy the executable
cp optimus.sh /usr/bin/optimus

# Fix the permissions
chown root:root $servicepath/optimus.service
chown 644 $servicepath/optimus.service
chown root:root $confpath/optimus.conf
chown 644 $confpath/optimus.conf
chown root:root /usr/bin/optimus
chown 754 /usr/bin/optimus

# Set bbswitch to load on boot
tee /etc/modules-load.d/bbswitch.conf <<< 'bbswitch' &>/dev/null
echo "-----------------------------------------------------------------------------------------------------"
echo "Installation finished! A reboot is recommended just to make sure, sorry for that..."
echo "-----------------------------------------------------------------------------------------------------"
