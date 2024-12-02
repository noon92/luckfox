#!/bin/bash
printf "[1;32m*** Starting Femtofox install script. \e[1;31mNETWORK CONNECTIVITY REQUIRED! ***\e[0m\n"

sudo timedatectl set-timezone UTC   #Set timezone to UTC.
sudo date --set="$(wget --method=HEAD -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f4-10)"   #Set time/date.
printf "[1;32m*** Got network time ***\e[0m\n"

# Set the timezone
printf "\n[1;32m*** Setting timezone ***\e[0m\n"
timezone=$(tzselect)
sudo ln -sf "/usr/share/zoneinfo/$timezone" /etc/localtime
echo "$timezone" | sudo tee /etc/timezone
echo "\n[1;32m*** $(date "+%H:%M:%S %Z"): Timezone set to $timezone ***\e[0m\n"

read -p "Enter wifi SSID: " SSID
echo -n "Enter wifi password: "
stty -echo  # Disable terminal echo
read PASSWORD
stty echo  # Re-enable terminal echo
printf "\n[1;32m*** $(date "+%H:%M:%S %Z"): SSID saved. Wifi requires adapter ***\e[0m\n"

if ! grep -q "tmpfs /run tmpfs size=32M,nosuid,noexec,relatime,mode=755 0 0" /etc/fstab; then
	sudo mount -t tmpfs tmpfs /run -o remount,size=32M,nosuid,noexec,relatime,mode=755   #Embiggen tmpfs - prevents problems.
  sudo sh -c 'echo "tmpfs /run tmpfs size=32M,nosuid,noexec,relatime,mode=755 0 0" >> /etc/fstab'
	printf "[1;32m*** $(date "+%H:%M:%S %Z"): Enlarged tmpfs ***\e[0m\n"
else
	printf "[1;32m*** $(date "+%H:%M:%S %Z"): tmpfs already enlarged, skipping ***\e[0m\n"
fi

#update system and install dependencies
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Updating and upgrading Ubuntu... ***\e[0m\n"
sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y update && sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y upgrade
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Ubuntu upgrade / update complete ***\e[0m\n"
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Getting latest Meshtasticd beta... ***\e[0m\n"
URL=$(wget -qO- https://api.github.com/repos/meshtastic/firmware/releases/latest | grep -oP '"browser_download_url": "\K[^"]*armhf\.deb' | head -n 1); FILENAME=$(basename $URL); wget -O /tmp/$FILENAME $URL
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Installing necessary packages... ***\e[0m\n"
sudo apt-get install linux-firmware wireless-tools git python3.10-venv libgpiod-dev libyaml-cpp-dev libbluetooth-dev openssl libssl-dev libulfius-dev liborcania-dev evtest /tmp/$FILENAME -y
sudo dpkg --configure -a
sudo rm /tmp/$FILENAME
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Necessary packages installed ***\e[0m\n"
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Installing pip packages... ***\e[0m\n"
pip3 install pytap2 meshtastic pypubsub
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Pip packages installed ***\e[0m\n"

printf "[1;32m*** $(date "+%H:%M:%S %Z"): Getting custom FemtoFox files... ***\e[0m\n"
sudo cp ../liborcania_2.3_armhf/* /usr/lib/arm-linux-gnueabihf/
sudo cp -n /etc/meshtasticd/config.yaml /etc/meshtasticd/config.yaml.bak
sudo cp ../meshtasticd/config.yaml /etc/meshtasticd/
sudo cp -n /etc/update-motd.d/00-header /etc/update-motd.d/00-header.bak
sudo mv 00-header /etc/update-motd.d/
sudo chmod +x /etc/update-motd.d/00-header
sudo mv /etc/update-motd.d/10-help-text /etc/update-motd.d/10-help-text.bak
sudo mv /etc/update-motd.d/60-unminimize /etc/update-motd.d/60-unminimize.bak
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Copied custom FemtoFox files ***\e[0m\n"

sudo chmod +x usbconfig.sh
sudo mv usbconfig.sh /usr/local/bin/
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Added USB configuration tool ***\e[0m\n"

#serial port permissions
sudo usermod -a -G tty $USER
sudo usermod -a -G dialout $USER
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Set serial port permissions ***\e[0m\n"

if [ ! -f /etc/systemd/system/button.service ]; then
	if ! sudo grep -q "femto ALL=(ALL) NOPASSWD: /sbin/reboot" /etc/sudoers; then
			echo "femto ALL=(ALL) NOPASSWD: /sbin/reboot" | sudo tee -a /etc/sudoers
	fi
	sudo chmod +x buttonservice.sh
	sudo mv buttonservice.sh /usr/local/bin
	sudo mv button.service /etc/systemd/system
	sudo usermod -aG input femto
	sudo systemctl daemon-reload
	sudo systemctl enable button.service
	printf "[1;32m*** $(date "+%H:%M:%S %Z"): Added reboot on BOOT button press ***\e[0m\n"
else
	printf "[1;32m*** $(date "+%H:%M:%S %Z"): Reboot on BOOT button press already added, skipping ***\e[0m\n"
fi

#disable redundant services
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Disabling and masking redundant services... ***\e[0m\n"
sudo systemctl disable vsftpd.service #we don't need this
sudo systemctl mask vsftpd.service
sudo systemctl disable ModemManager.service #or this
sudo systemctl mask ModemManager.service
sudo systemctl disable polkit.service #or this
sudo systemctl mask polkit.service
sudo systemctl disable getty@tty1.service #this is for direct console, not uart debug. We don't have one of those
sudo systemctl mask getty@tty1.service
sudo systemctl disable acpid #shutdown/sleep/hibernate: unused
sudo systemctl mask acpid
sudo systemctl disable acpid.socket
sudo systemctl mask acpid.socket
sudo systemctl disable acpid.service
sudo systemctl mask acpid.service
sudo systemctl disable alsa-restore.service #sound service
sudo systemctl mask alsa-restore.service
sudo systemctl disable alsa-state.service
sudo systemctl mask alsa-state.service
#sudo mkdir -p /etc/systemd/system/sound.target.d
#sudo echo -e "[Unit]\nConditionPathExists=!/dev/snd" | sudo tee /etc/systemd/system/sound.target.d/override.conf > /dev/null
sudo systemctl mask sound.target
sudo systemctl disable remote-fs.target #remote filesystems over network
sudo systemctl mask remote-fs.target
sudo systemctl disable veritysetup.target #we don't use this
sudo systemctl mask veritysetup.target
sudo systemctl disable cryptsetup.target #we don't have any encrypted partitions
sudo systemctl mask cryptsetup.target
sudo systemctl disable ntp.service #we are not currently using ntp
sudo systemctl mask ntp.service
sudo systemctl disable ntp-systemd-netif.path
sudo systemctl mask ntp-systemd-netif.path
sudo systemctl disable systemd-pstore.service #kernel crashes, recovery/logging, state persistence, etc. Redundant
sudo systemctl mask systemd-pstore.service
sudo systemctl daemon-reload
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Disabled and masked redundant services ***\e[0m\n"

#change luckfox system config
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Changing Luckfox system config ***\e[0m\n"
sudo mv luckfox.cfg /etc/
sudo luckfox-config load
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Set and loaded Luckfox system config ***\e[0m\n"

sudo hostname femtofox
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Set hostname to femtofox ***\e[0m\n"

#replace /etc/rc.local
if [ ! -f /etc/issue.bak ]; then
	sudo cp -n /etc/rc.local /etc/rc.local.bak
	sudo cp ./rc.local /etc/rc.local
	sudo chmod +x /etc/rc.local
	printf "[1;32m*** $(date "+%H:%M:%S %Z"): Replaced /etc/rc.local ***\e[0m\n"
else
	printf "[1;32m*** $(date "+%H:%M:%S %Z"): /etc/rc.local already replaced, skipping ***\e[0m\n"
fi

#replace /etc/issue
if [ ! -f /etc/issue.bak ]; then
	sudo cp -n /etc/issue /etc/issue.bak
	sudo cp ./issue /etc/issue
	printf "[1;32m*** $(date "+%H:%M:%S %Z"): Replaced /etc/issue ***\e[0m\n"
else
	printf "[1;32m*** $(date "+%H:%M:%S %Z"): /etc/issue already replaced, skipping ***\e[0m\n"
fi

#add daily reboot to cron
if ! sudo crontab -l | grep -q "/sbin/reboot"; then
	echo "# reboot pi every 3am. Default timezone is GMT. To change timezone run \`sudo tzselect\`
	0 3 * * * /sbin/reboot

	# restart bbs server script every odd hour
	#0 23/2 * * * sudo systemctl restart mesh-bbs.service" | sudo tee -a /var/spool/cron/crontabs/root > /dev/null
	printf "[1;32m*** $(date "+%H:%M:%S %Z"): Scheduled daily reboot at 06:00 UTC ***\e[0m\n"
else
	printf "[1;32m*** $(date "+%H:%M:%S %Z"): Daily reboot already scheduled, skipping ***\e[0m\n"
fi

printf "[1;32m*** $(date "+%H:%M:%S %Z"): Configuring networking... ***\e[0m\n"
# Replace the existing configuration for eth0 in /etc/network/interfaces
current_mac=$(cat /sys/class/net/eth0/address)
config="# interfaces(5) file used by ifup(8) and ifdown(8)
# Include files from /etc/network/interfaces.d:
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

# static mac address for onboard ethernet (castellated pins)
allow-hotplug eth0
iface eth0 inet dhcp
hwaddress ether $current_mac

allow-hotplug wlan0
iface wlan0 inet dhcp
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf"
sudo sed -i "/iface eth0 inet/d" /etc/network/interfaces
echo "$config" | sudo tee /etc/network/interfaces > /dev/null
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Replaced /etc/network/interfaces and made current ethernet MAC address ($current_mac) permanent ***\e[0m"

#wifi support
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Adding wifi support... ***\e[0m\n"
sudo mkdir /lib/modules
sudo mkdir /lib/modules/5.10.160
sudo find /oem/usr/ko/ -name '*.ko' ! -name 'ipv6.ko' -exec cp {} /lib/modules/5.10.160/ \;
sudo touch /lib/modules/5.10.160/modules.order
sudo touch /lib/modules/5.10.160/modules.builtin
sudo depmod -a 5.10.160
# replace wpa_supplicant.conf
sudo tee /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US # Change to your country code
network={
    ssid="$SSID"
    psk="$PASSWORD"
    key_mgmt=WPA-PSK
		priority=10
}
EOF
echo 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?", ATTR{type}=="1", KERNEL=="wl*", NAME="wlan%n"' | sudo tee /etc/udev/rules.d/70-network.rules > /dev/null
sudo ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager
sudo systemctl disable NetworkManager-dispatcher
sudo systemctl disable NetworkManager-wait-online
#sudo systemctl restart wpa_supplicant
#sudo wpa_cli -i wlan0 reconfigure
printf "[1;32m*** $(date "+%H:%M:%S %Z"): Added wifi support ***\e[0m\n"

printf "[1;32m*** $(date "+%H:%M:%S %Z"): Cleaning up... ***\e[0m\n"
sudo rm -rf ~/femtofox

printf "[1;32m*** $(date "+%H:%M:%S %Z"): Configuration complete... ***\e[0m\n"

printf "\e[1;31mPress any key to reboot...\e[0m\n"
read -n 1 -s && sudo reboot