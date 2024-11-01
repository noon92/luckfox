<img src="https://github.com/noon92/luckfox/blob/main/splash.jpg" width="400">

#### The Luckfox Pico Mini is a compact and power efficient (~0.25w) linux capable board, ideal for running a [Meshtastic BBS](https://github.com/TheCommsChannel/TC2-BBS-mesh) (or anything else).

Advantages:
* Small size (~28x21mm)
* Power efficiency (~0.25w)
* Full linux (Ubuntu!)
* Cheap - $7-8 on [Waveshare](https://www.waveshare.com/luckfox-pico-min.htm)! Get the A model - the B just has added flash storage that's too small for our purposes.

Disadvantages:
* By default, no simple way to get online (no built in wifi/ble/ethernet)
* Annoying SDK for building firmware images
* No simple way to compile drivers (no available linux headers - if anyone manages to compile the headers, please let me know)

After many hours of fiddling, I've cobbled together a firmware image with support for:
* 2x UART pin pairs - both tested working for communications with meshtastic devices
* USB mass storage support (such as flash drives) - tested working
* USB ethernet adapters (sometimes needs to be unplugged and plugged back in after boot to get an IP) - tested working with RTL8152 chipset
* Ethernet support WITHOUT an adapter, soldered directly to board - see wiring diagram - tested working
* Many wifi adapter drivers - untested, data coming soon
* Drivers for CH341, CH343, CP210x and generic serial over USB - tested working: ch341 (e.g RAK)
* Drivers for several common RTCs - untested

Also, I turned off the activity LED. Every μW counts!

#### I've built three Ubuntu 22.04.5 LTS images with Luckfox's SDK:
1. [A 'fresh' image with no changes.](https://drive.google.com/file/d/1Wp0fCF9LE-x4iwPgTxnTF7eixSthc9gC/view?usp=sharing)
2. [An image preconfigured with the TC2-BBS for comms over UART4.](https://drive.google.com/file/d/1RlhRYVnvSTviAUey-cvDCM10HQMEuSvV/view?usp=drive_link)
3. [An image preconfigured with the TC2-BBS for comms over USB.](https://drive.google.com/file/d/1FeKXmsZaS6a3FwgwfjkuimlVRJ-OS4HC/view?usp=drive_link) Note that this assumes the USB device is recognized as /dev/ttyACM0.
NOTE: The preconfigured images will reboot every 24 hours, and restart the BBS every other hour. In theory, this should happen at 6am UTC, but the luckfox does not have an RTC, so it's hard to say when it'll happen. If the Luckfox has networking, it should get network time on boot.

## Installation
1. Uncompress the 7z file - will require ~29gb of space. In windows, use [7-zip](https://www.7-zip.org/).
2. Flash the image to a reasonably fast Micro-SD card of at least 32gb in size using [Balena Etcher](https://etcher.balena.io/) or your favorite flashing program. You will likely get a warning that the image appears to be invalid or has no partition table. This is normal.
3. Insert the microSD card into the Pico Mini.
4. Connect Pico Mini to Meshtastic radio via pins or USB, depending on image flashed. If using pins - use pins 10 and 11 on the luckfox board.
5. For the rak19007 (with the rak4631 daughter board):
  * In Position settings, set GPS: NOT_PRESENT
  * If using UART comms, Serial Module settings:
    * Serial: Enabled
    * Echo: off
    * RX: 15
    * TX: 16
    * Serial baud rate: 115200
    * Timeout: 0
    * Serial mode: PROTO
    * Override console serial port: off
6. Rak19003 will require different pin numbers - probably 19,20 but this is untested.
7. Remember - connect TX on the Luckfox to RX on the Meshtastic board, and vice-versa.
8. Power can be supplied to the rak via the 3.3v pin on the Luckfox.
9. If communications is via UART, you must bridge the grounds of the two boards.
10. Supply power to the Pico Mini via pins or USB.
11. It should Just Work.
12. You can connect to the Luckfox via USB Ethernet adapter or via UART serial as described [here](https://wiki.luckfox.com/Luckfox-Pico/Luckfox-Pico-RV1103/Luckfox-Pico-Login-UART/).

Login for the "fresh" image is root:root or pico:luckfox.
Login for the configured BBS images is bbs:mesh.

glhf

![pinout](https://github.com/noon92/luckfox/blob/main/modified_wiring_diagram.jpg)
![pinout](https://github.com/noon92/luckfox/blob/main/Luckfox-Pico-Mini-details-inter.jpg)
