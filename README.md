<img src="https://github.com/noon92/luckfox/blob/main/luckfox_pico_mini_tiny_linux_board.jpg" width="400">

#### The Luckfox Pico Mini is a compact and power efficient (~0.25w) linux capable board, ideal for running [TC2 Meshtastic BBS](https://github.com/TheCommsChannel/TC2-BBS-mesh) (or anything else).

Advantages:
* Small size (~28x21mm)
* Power efficiency (~0.25w)
* Full linux (Ubuntu!)
* USB host support
* Cheap - $7-8 on [Waveshare](https://www.waveshare.com/luckfox-pico-min.htm) (more on Amazon)! Get the A model - the B just has added flash storage that's too small for our purposes.

Disadvantages:
* By default, no simple way to get online (no built in wifi/ble/ethernet)
* Annoying SDK for building firmware images
* No simple way to compile drivers (no available linux headers - if anyone manages to compile the headers, please let me know)

Issues / to do
* USB wifi adapter
* Meshtasticd to run lora radio over SPI

After many hours of fiddling, I've cobbled together a firmware image with support for:
* 2x UART pin pairs - both tested working for communications with meshtastic devices
* USB mass storage support (such as flash drives) - tested working
* USB ethernet adapters (sometimes needs to be unplugged and plugged back in after boot to get an IP) - tested working with RTL8152 chipset, should work with most others
* Ethernet support WITHOUT an adapter, soldered directly to board - see wiring diagram - tested working
* Many wifi adapter drivers - untested, data coming soon
* Drivers for CH341, CH343, CP210x and generic serial over USB - tested working: ch341 (e.g RAK)
* Drivers for real time clock over i2c - tested working with [DS3231](https://aliexpress.com/item/1005007143842437.html) with DS1307 driver (should be compatible with DS1307, DS1337 and DS3231).

Also, I turned off the activity LED. Every μW counts!

#### I've built three Ubuntu 22.04.5 LTS images with Luckfox's SDK:
1. [A 'fresh' image with no changes.](https://drive.google.com/file/d/17ofd-bt6IVE3EDBe9cu1_IK2BuYEeg_a/view?usp=sharing)
2. [An image preconfigured with the TC2-BBS for comms over UART4.](https://drive.google.com/file/d/1YSlR-At4rCv29A_f9hgME6Z_D2mZ1WO3/view?usp=drive_link)
3. [An image preconfigured with the TC2-BBS for comms over USB.](https://drive.google.com/file/d/1iXApWAXAhl-iirATAJVD0Ilr2K8OdY3i/view?usp=sharing) This assumes the USB device is recognized as /dev/ttyACM0.

Login for the "fresh" image is root:root or pico:luckfox.  Login for the configured BBS images is bbs:mesh.

The preconfigured images will reboot every 24 hours, and restart the BBS every other hour. In theory, this should happen at 6am UTC (because both the US and . Time is set on boot with the following logic:
1. If the system recognizes an RTC module connected via i2c, it will use that.
2. If no RTC module is recognized, time will be set to midnight 24/1/1.
3. If network is available, time will be retrieved from google and system time (and RTC time if present) will be set from that.

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





glhf

![pinout](https://github.com/noon92/luckfox/blob/main/luckfox_pico_mini_wiring_diagram.png)
![pinout](https://github.com/noon92/luckfox/blob/main/luckfox_pico_mini_original_wiring_diagram.jpg)
