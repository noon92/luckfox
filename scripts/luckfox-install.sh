sudo mount -t tmpfs tmpfs /run -o remount,size=32M,nosuid,noexec,relatime,mode=755   #Embiggen tmpfs - prevents problems.
sudo sh -c 'echo "tmpfs /run tmpfs size=32M,nosuid,noexec,relatime,mode=755 0 0" >> /etc/fstab'   #Embiggen tmpfs - for future boots.
echo "Enlarged tmpfs"

sudo timedatectl set-timezone UTC   #Set timezone to UTC.
date -d "$(wget --method=HEAD -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f4-10)"   #Set time/date.
echo "Changed timezone to UTC and got network time"

#update system and install dependencies
echo "Updating Ubuntu and installing dependencies..."
sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y update && sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y upgrade
sudo apt-get install linux-firmware wireless-tools git python3.10-venv libgpiod-dev libyaml-cpp-dev libbluetooth-dev openssl libssl-dev libulfius-dev liborcania-dev -y
pip3 install pytap2 meshtastic pypubsub
echo "Done updating and installing dependencies"

#get latest meshtasticd beta
echo "Getting latest Meshtasticd beta..."
URL=$(wget -qO- https://api.github.com/repos/meshtastic/firmware/releases/latest | grep -oP '"browser_download_url": "\K[^"]*armhf\.deb' | head -n 1); FILENAME=$(basename $URL); wget -O /tmp/$FILENAME $URL && sudo apt install /tmp/$FILENAME -y && sudo rm /tmp/$FILENAME
echo "Installed latest Meshtasticd beta"

echo "Getting custom FemtoFox files..."
git clone https://github.com/noon92/femtofox.git
sudo cp ../liborcania_2.3_armhf/* /usr/lib/arm-linux-gnueabihf/
sudo mv /etc/meshtasticd/config.yaml /etc/meshtasticd/config.yaml.bak
sudo cp ../meshtasticd/config.yaml /etc/meshtasticd/
sudo cp /etc/update-motd.d/00-header /etc/update-motd.d/00-header.bak
sudo mv 00-header /etc/update-motd.d/
sudo chmod +x /etc/update-motd.d/00-header
echo "Installed custom FemtoFox files"

#serial port permissions
sudo usermod -a -G tty $USER
sudo usermod -a -G dialout $USER
echo "Set serial port permissions"


#disable redundant services
sudo systemctl disable vsftpd.service
sudo systemctl disable ModemManager.service
sudo systemctl disable polkit.service
sudo systemctl disable getty@tty1.service
sudo systemctl disable alsa-restore.service
echo "Disabled redundant services"


#change luckfox system config
echo "Changing Luckfox system config"
sudo mv luckfox.cfg /etc/
sudo luckfox-config load
echo "Set Luckfox system config"

sudo chmod +x networkinterfaces.sh
sudo ./networkinterfaces.sh

#replace /etc/rc.local
sudo cp /etc/rc.local /etc/rc.local.bak
sudo cp ./rc.local /etc/rc.local
sudo chmod +x /etc/rc.local
echo "Replaced /etc/rc.local system config"

#replace /etc/issue
sudo cp /etc/issue /etc/issue.bak
sudo cp ./issue /etc/issue
echo "Replaced /etc/issue"

#add daily reboot to cron
echo -e "# reboot pi every 7. Default timezone is GMT. To change timezone run \`sudo tzselect\`\n0 6 * * * /sbin/reboot\n\n# restart bbs server script every odd hour\n#0 23/2 * * * sudo systemctl restart mesh-bbs.service" | sudo tee -a /var/spool/cron/crontabs/root > /dev/null
echo "Scheduled daily reboot at 06:00 UTC"

#wifi support
echo "Adding wifi support..."
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
echo "Added wifi support"

sudo rm -rf ~/femtofox
echo "Cleaning up..."

echo "Configuration complete, rebooting..."

sudo sleep 5 && sudo reboot