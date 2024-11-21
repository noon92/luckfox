echo "[1;32m*** $(date "+%H:%M:%S %Z"): Starting Femtofox install script. \e[1;31mNETWORK CONNECTIVITY REQUIRED! ***\e[0m\n"

read -p "Enter wifi SSID: " SSID
echo -n "Enter wifi password: "
stty -echo  # Disable terminal echo
read PASSWORD
stty echo  # Re-enable terminal echo
echo "\n[1;32m*** SSID saved. Wifi requires adapter ***\e[0m\n"


sudo mount -t tmpfs tmpfs /run -o remount,size=32M,nosuid,noexec,relatime,mode=755   #Embiggen tmpfs - prevents problems.
sudo sh -c 'echo "tmpfs /run tmpfs size=32M,nosuid,noexec,relatime,mode=755 0 0" >> /etc/fstab'   #Embiggen tmpfs - for future boots.
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Enlarged tmpfs ***\e[0m\n"

sudo timedatectl set-timezone UTC   #Set timezone to UTC.
date -d "$(wget --method=HEAD -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f4-10)"   #Set time/date.
echo "[1;32m*** $(date "+%H:%M:%S %Z")  Changed timezone to UTC and got network time ***\e[0m\n"

#update system and install dependencies
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Updating and upgrading Ubuntu... ***\e[0m\n"
sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y update && sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y upgrade
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Ubuntu upgrade / update complete ***\e[0m\n"
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Installing necessary packages... ***\e[0m\n"
sudo apt-get install linux-firmware wireless-tools git python3.10-venv libgpiod-dev libyaml-cpp-dev libbluetooth-dev openssl libssl-dev libulfius-dev liborcania-dev evtest -y
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Necessary packages installed ***\e[0m\n"
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Installing pip packages... ***\e[0m\n"
pip3 install pytap2 meshtastic pypubsub
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Pip packages installed ***\e[0m\n"

#get latest meshtasticd beta
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Getting latest Meshtasticd beta... ***\e[0m\n"
URL=$(wget -qO- https://api.github.com/repos/meshtastic/firmware/releases/latest | grep -oP '"browser_download_url": "\K[^"]*armhf\.deb' | head -n 1); FILENAME=$(basename $URL); wget -O /tmp/$FILENAME $URL && sudo apt install /tmp/$FILENAME -y && sudo rm /tmp/$FILENAME
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Installed latest Meshtasticd beta ***\e[0m\n"

echo "[1;32m*** $(date "+%H:%M:%S %Z"): Getting custom FemtoFox files... ***\e[0m\n"
sudo cp ../liborcania_2.3_armhf/* /usr/lib/arm-linux-gnueabihf/
sudo mv /etc/meshtasticd/config.yaml /etc/meshtasticd/config.yaml.bak
sudo cp ../meshtasticd/config.yaml /etc/meshtasticd/
sudo cp /etc/update-motd.d/00-header /etc/update-motd.d/00-header.bak
sudo mv 00-header /etc/update-motd.d/
sudo chmod +x /etc/update-motd.d/00-header
sudo mv /etc/update-motd.d/10-help-text /etc/update-motd.d/10-help-text.bak
sudo mv /etc/update-motd.d/60-unminimize /etc/update-motd.d/60-unminimize.bak
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Copied custom FemtoFox files ***\e[0m\n"

sudo mv usbconfig.sh /usr/local/bin/
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Added USB configuration tool ***\e[0m\n"

#serial port permissions
sudo usermod -a -G tty $USER
sudo usermod -a -G dialout $USER
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Set serial port permissions ***\e[0m\n"

sudo chmod +x buttonservice.sh
sudo mv buttonservice.sh /usr/local/bin
sudo mv button.service /etc/systemd/system
sudo usermod -aG input femto
echo "femto ALL=(ALL) NOPASSWD: /sbin/reboot" | sudo tee -a /etc/sudoers
sudo systemctl daemon-reload
sudo systemctl enable button.service
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Added reboot on BOOT button press ***\e[0m\n"

#disable redundant services
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Disabling redundant services... ***\e[0m\n"
sudo systemctl disable vsftpd.service
sudo systemctl disable ModemManager.service
sudo systemctl disable polkit.service
sudo systemctl disable getty@tty1.service
sudo systemctl disable alsa-restore.service
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Disabled redundant services ***\e[0m\n"

#change luckfox system config
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Changing Luckfox system config ***\e[0m\n"
sudo mv luckfox.cfg /etc/
sudo luckfox-config load
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Set and loaded Luckfox system config ***\e[0m\n"

sudo hostname femtofox
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Set hostname to femtofox ***\e[0m\n"

#replace /etc/rc.local
sudo cp /etc/rc.local /etc/rc.local.bak
sudo cp ./rc.local /etc/rc.local
sudo chmod +x /etc/rc.local
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Replaced /etc/rc.local ***\e[0m\n"

#replace /etc/issue
sudo cp /etc/issue /etc/issue.bak
sudo cp ./issue /etc/issue
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Replaced /etc/issue ***\e[0m\n"

#add daily reboot to cron
echo -e "# reboot pi every 7. Default timezone is GMT. To change timezone run \`sudo tzselect\`\n0 6 * * * /sbin/reboot\n\n# restart bbs server script every odd hour\n#0 23/2 * * * sudo systemctl restart mesh-bbs.service" | sudo tee -a /var/spool/cron/crontabs/root > /dev/null
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Scheduled daily reboot at 06:00 UTC ***\e[0m\n"

echo "[1;32m*** $(date "+%H:%M:%S %Z"): Configuring networking... ***\e[0m\n"
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
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Replaced /etc/network/interfaces and made current ethernet MAC address ($current_mac) permanent ***\e[0m"

#wifi support
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Adding wifi support... ***\e[0m\n"
sudo mkdir /lib/modules
sudo mkdir /lib/modules/5.10.160
sudo find /oem/usr/ko/ -name '*.ko' ! -name 'ipv6.ko' -exec cp {} /lib/modules/5.10.160/ \;
sudo touch /lib/modules/5.10.160/modules.order
sudo touch /lib/modules/5.10.160/modules.builtin
sudo depmod -a 5.10.160
# Append to wpa_supplicant.conf
sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null <<EOF
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
echo "[1;32m*** $(date "+%H:%M:%S %Z"): Added wifi support ***\e[0m\n"

echo "[1;32m*** $(date "+%H:%M:%S %Z"): Cleaning up... ***\e[0m\n"
sudo rm -rf ~/femtofox

echo "[1;32m*** $(date "+%H:%M:%S %Z"): Configuration complete, rebooting... ***\e[0m\n"

sudo sleep 5 && sudo reboot