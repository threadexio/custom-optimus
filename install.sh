#!/usr/bin/bash

confpath="/etc/optimus"
servicepath="/etc/systemd/system"

if [[ "$EUID" != "0" ]]; then
	echo "Run $0 with root permissions to continue"
	exit 1
fi

print_center() {
	printf "%*s\n" $(((${#1}+$(tput cols))/2)) "$1"
}

echo -e "\nThis installer will:"
echo -e "\tAdd a service in systemd"
echo -e "\tCreate a config file in $confpath"
echo -e "\tCopy optimus.sh to /usr/bin/optimus"
read -n 1 -r -p "Continue [Y/n]? "
if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
	echo -e "\nExiting..."
	exit 1
fi

echo ""

# Make the config directory
mkdir -p $confpath/other

cat << EOF > $confpath/optimus.conf
##
##	Optimus Configuration file, generated on $(date)
##	https://github.com/threadexio/custom-optimus
##

## This is the file that holds the configuration
## for the nvidia card. Usually you don't have to
## change the location, only the contents
X11conf='/etc/X11/xorg.conf.d/10-nvidia.conf'

##################################################

##
##	Advanced
##

## The location where systemd keeps services
## DO NOT CHANGE AFTER INSTALL!!!
servicepath='$servicepath'

## This is the file that tells the Linux kernel
## if it should load the nvidia drivers on boot
## Should be in /etc/modprobe.d
## Change this ONLY if you know what you're doing
modprobeconf='/etc/modprobe.d/nvidia-optimus.conf'

## This is the file that tells the Linux kernel
## to load the modules described on boot
## Should be in /etc/modules-load.d
modulesloadconf='/etc/modules-load.d'

EOF

# Copy other config files
install -Dm644 files/blacklist_nvidia.conf $confpath/other/blacklist_nvidia.conf
install -Dm644 files/load_nvidia.conf $confpath/other/load_nvidia.conf
install -Dm644 files/X11.conf $confpath/other/X11.conf
install -Dm644 files/nvidia_modules.conf $confpath/other/nvidia_modules.conf

# Install the service
install -Dm644 files/optimus.service $servicepath/optimus.service

# Install the executable
install -Dm755 optimus.sh /usr/bin/optimus

# Set bbswitch to load on boot
tee /etc/modules-load.d/bbswitch.conf <<< 'bbswitch' &>/dev/null

# Make systemd recognize the added service
systemctl daemon-reload

printf '=%.0s' $(seq 1 $(tput cols))
print_center "Installation finished! A quick reboot is recommended"
print_center "You can uninstall this script by running uninstall.sh"
printf '=%.0s' $(seq 1 $(tput cols))
