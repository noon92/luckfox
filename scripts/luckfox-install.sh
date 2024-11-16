sudo mount -t tmpfs tmpfs /run -o remount,size=32M,nosuid,noexec,relatime,mode=755   #Embiggen tmpfs - prevents problems.
sudo sh -c 'echo "tmpfs /run tmpfs size=32M,nosuid,noexec,relatime,mode=755 0 0" >> /etc/fstab'   #Embiggen tmpfs - for future boots.
echo "[1;32m*** Enlarged tmpfs ***\e[0m"

sudo timedatectl set-timezone UTC   #Set timezone to UTC.
date -d "$(wget --method=HEAD -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f4-10)"   #Set time/date.
echo "[1;32m*** Changed timezone to UTC and got network time ***\e[0m"

#update system and install dependencies
echo "[1;32m*** Updating Ubuntu and installing dependencies... ***\e[0m"
sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y update && sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y upgrade
sudo apt-get install linux-firmware wireless-tools git python3.10-venv libgpiod-dev libyaml-cpp-dev libbluetooth-dev openssl libssl-dev libulfius-dev liborcania-dev -y
pip3 install pytap2 meshtastic pypubsub
echo "[1;32m*** Done updating and installing dependencies ***\e[0m"

#get latest meshtasticd beta
echo "[1;32m*** Getting latest Meshtasticd beta... ***\e[0m"
URL=$(wget -qO- https://api.github.com/repos/meshtastic/firmware/releases/latest | grep -oP '"browser_download_url": "\K[^"]*armhf\.deb' | head -n 1); FILENAME=$(basename $URL); wget -O /tmp/$FILENAME $URL && sudo apt install /tmp/$FILENAME -y && sudo rm /tmp/$FILENAME
echo "[1;32m*** Installed latest Meshtasticd beta ***\e[0m"

echo "[1;32m*** Getting custom FemtoFox files... ***\e[0m"
git clone https://github.com/noon92/femtofox.git
sudo cp ../liborcania_2.3_armhf/* /usr/lib/arm-linux-gnueabihf/
sudo mv /etc/meshtasticd/config.yaml /etc/meshtasticd/config.yaml.bak
sudo cp ../meshtasticd/config.yaml /etc/meshtasticd/
sudo cp /etc/update-motd.d/00-header /etc/update-motd.d/00-header.bak
sudo mv 00-header /etc/update-motd.d/
sudo chmod +x /etc/update-motd.d/00-header
echo "[1;32m*** Installed custom FemtoFox files ***\e[0m"

#serial port permissions
sudo usermod -a -G tty $USER
sudo usermod -a -G dialout $USER
echo "[1;32m*** Set serial port permissions ***\e[0m"


#disable redundant services
sudo systemctl disable vsftpd.service
sudo systemctl disable ModemManager.service
sudo systemctl disable polkit.service
sudo systemctl disable getty@tty1.service
sudo systemctl disable alsa-restore.service
echo "[1;32m*** Disabled redundant services ***\e[0m"


#change luckfox system config
echo "[1;32m*** Changing Luckfox system config ***\e[0m"
sudo mv luckfox.cfg /etc/
sudo luckfox-config load
echo "[1;32m*** Set Luckfox system config ***\e[0m"

sudo chmod +x networkinterfaces.sh
sudo ./networkinterfaces.sh

#replace /etc/rc.local
sudo cp /etc/rc.local /etc/rc.local.bak
sudo cp ./rc.local /etc/rc.local
sudo chmod +x /etc/rc.local
echo "[1;32m*** Replaced /etc/rc.local system config ***\e[0m"

#replace /etc/issue
sudo cp /etc/issue /etc/issue.bak
sudo cp ./issue /etc/issue
echo "[1;32m*** Replaced /etc/issue ***\e[0m"

#add daily reboot to cron
echo -e "# reboot pi every 7. Default timezone is GMT. To change timezone run \`sudo tzselect\`\n0 6 * * * /sbin/reboot\n\n# restart bbs server script every odd hour\n#0 23/2 * * * sudo systemctl restart mesh-bbs.service" | sudo tee -a /var/spool/cron/crontabs/root > /dev/null
echo "[1;32m*** Scheduled daily reboot at 06:00 UTC ***\e[0m"

#wifi support
echo "[1;32m*** Adding wifi support... ***\e[0m"
sudo mkdir /lib/modules
sudo mkdir /lib/modules/5.10.160
sudo find /oem/usr/ko/ -name '*.ko' ! -name 'ipv6.ko' -exec cp {} /lib/modules/5.10.160/ \;
sudo touch /lib/modules/5.10.160/modules.order
sudo touch /lib/modules/5.10.160/modules.builtin
sudo depmod -a 5.10.160
ead -p "Enter your SSID: " SSID
read -sp "Enter your password: " PASSWORD
# Append to wpa_supplicant.conf
sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US # Change to your country code
network={
    ssid="$SSID"
    psk="$PASSWORD"
    key_mgmt=WPA-PSK
}
EOF
echo 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?", ATTR{type}=="1", KERNEL=="wl*", NAME="wlan%n"' | sudo tee /etc/udev/rules.d/70-network.rules > /dev/null
sudo ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager
echo "[1;32m*** Added wifi support ***\e[0m"

sudo rm -rf ~/femtofox
echo "[1;32m*** Cleaning up... ***\e[0m"

echo "[1;32m*** Configuration complete, rebooting... ***\e[0m"

sudo sleep 5 && sudo reboot