<!DOCTYPE html>
<html>

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Welcome file</title>
  <link rel="stylesheet" href="https://stackedit.io/style.css" />
</head>

<body class="stackedit">
  <div class="stackedit__left">
    <div class="stackedit__toc">
      
<ul>
<li>
<ul>
<li></li>
</ul>
</li>
</ul>

    </div>
  </div>
  <div class="stackedit__right">
    <div class="stackedit__html">
      <img src="https://github.com/noon92/luckfox/blob/main/luckfox_pico_mini_tiny_linux_board.jpg" width="400">
<h3 id="the-luckfox-pico-mini-is-a-compact-and-power-efficient-0.25w-linux-capable-board-ideal-for-running-tc2-meshtastic-bbs-or-anything-else.">The Luckfox Pico Mini is a compact and power efficient (~0.25w) linux capable board, ideal for running <a href="https://github.com/TheCommsChannel/TC2-BBS-mesh">TC2 Meshtastic BBS</a> (or anything else).</h3>
<p><strong>Advantages:</strong></p>
<ul>
<li>Small size (~28x21mm)</li>
<li>Power efficiency (~0.25w)</li>
<li>Full linux (Ubuntu!)</li>
<li>USB host support</li>
<li>Cheap - $7-8 on <a href="https://www.waveshare.com/luckfox-pico-min.htm">Waveshare</a> (more on Amazon)! Get the A model - the B just has added flash storage that’s too small for our purposes.</li>
</ul>
<p><strong>Disadvantages:</strong></p>
<ul>
<li>By default, no simple way to get online (no built in wifi/ble/ethernet). Ethernet can be easily added - wifi still work in progress)</li>
<li>Annoying SDK for building firmware images</li>
<li>No simple way to compile drivers (no available linux headers - if anyone manages to compile the headers, please let me know)</li>
</ul>
<p><strong>Issues / to do:</strong></p>
<ul>
<li>USB wifi adapter</li>
<li>Meshtasticd to run lora radio over SPI - this is a work in progress and is currently not supported</li>
<li>Test RAK19003 via uart</li>
</ul>
<h3 id="after-many-hours-of-fiddling-ive-cobbled-together-an-ubuntu-image-with-support-for">After many hours of fiddling, I’ve cobbled together an ubuntu image with support for:</h3>
<ul>
<li>2x UART pin pairs - both tested working for communications with meshtastic devices</li>
<li>USB mass storage support (such as flash drives) - tested working</li>
<li>USB ethernet adapters (sometimes needs to be unplugged and plugged back in after boot to get an IP) - tested working with RTL8152 chipset, should work with most others</li>
<li>Ethernet support WITHOUT an adapter, soldered directly to board - see wiring diagram - tested working</li>
<li>Many wifi adapter drivers - untested, data coming soon</li>
<li>Drivers for CH341, CH343, CP210x and generic serial over USB - tested working: ch341 (e.g RAK)</li>
<li>Drivers for real time clock over i2c - tested working with <a href="https://aliexpress.com/item/1005007143842437.html">DS3231</a> with DS1307 driver (should be compatible with DS1307, DS1337 and DS3231).</li>
</ul>
<p>Also, I turned off the activity LED. Every μW counts!</p>
<br>
<h3 id="ive-built-three-ubuntu-22.04.5-lts-images-with-luckfoxs-sdk">I’ve built three Ubuntu 22.04.5 LTS images with Luckfox’s SDK:</h3>
<ol>
<li><a href="https://drive.google.com/file/d/17ofd-bt6IVE3EDBe9cu1_IK2BuYEeg_a/view?usp=sharing">A ‘fresh’ image with no changes.</a></li>
<li><a href="https://drive.google.com/file/d/1YSlR-At4rCv29A_f9hgME6Z_D2mZ1WO3/view?usp=drive_link">An image preconfigured with the TC2-BBS for comms over UART4.</a></li>
<li><a href="https://drive.google.com/file/d/1iXApWAXAhl-iirATAJVD0Ilr2K8OdY3i/view?usp=sharing">An image preconfigured with the TC2-BBS for comms over USB.</a> This assumes the USB device is recognized as /dev/ttyACM0.</li>
</ol>
<p>Login for the “fresh” image is root:root or pico:luckfox.  Login for the configured BBS images is bbs:mesh.</p>
<p>The preconfigured images will reboot every 24 hours, and restart the BBS every other hour. In theory, this should happen at 7am UTC (because both the US and Europe are generally inactive at that time). Time is set on boot with the following logic:</p>
<ol>
<li>If the system recognizes an RTC module connected via i2c, it will use that.</li>
<li>If no RTC module is recognized, time will be set to midnight 24/1/1.</li>
<li>If network is available, time will be retrieved from google and system time (and RTC time if present) will be set from that.</li>
</ol>
<p>Reboot timing is set in crontab. Time logic is in rc.local.</p>
<h4 id="networking">Networking</h4>
<p>There are three methods to get online:</p>
<ol>
<li>RDNIS via usb - <a href="https://web.archive.org/web/20241006173648/https://wiki.luckfox.com/Luckfox-Pico/Luckfox-Pico-Network-Sharing-1/">see this guide</a>. Note that in the preconfigured images USB is set to host mode, so you’ll have to switch back to peripheral with <code>luckfox-config</code>.</li>
<li>Ethernet over USB - most adapters should be supported, but I’ve only tested the RTL8152 chipset.</li>
<li>Preconfigured ubuntu images: ethernet via the castellated pins at the bottom of the board. See pinout at the bottom of this page.</li>
</ol>
<h4 id="installation">Installation</h4>
<ol>
<li>Uncompress the 7z file - will require ~29gb of space. In windows, use <a href="https://www.7-zip.org/">7-zip</a>.</li>
<li>Flash the image to a reasonably fast Micro-SD card of at least 32gb in size using <a href="https://etcher.balena.io/">Balena Etcher</a> or your favorite flashing program. You will likely get a warning that the image appears to be invalid or has no partition table. This is normal.</li>
<li>Insert the microSD card into the Pico Mini.</li>
<li>Connect Pico Mini to Meshtastic radio via pins or USB, depending on image flashed. If using pins - use pins 10 and 11 on the luckfox board.</li>
<li>For the rak19007 (with the rak4631 daughter board):</li>
</ol>
<ul>
<li>In Position settings, set <code>GPS: NOT_PRESENT</code></li>
<li>If using UART comms, Serial Module settings:
<ul>
<li><code>Serial: Enabled</code></li>
<li><code>Echo: off</code></li>
<li><code>RX: 15</code></li>
<li><code>TX: 16</code></li>
<li><code>Serial baud rate: 115200</code></li>
<li><code>Timeout: 0</code></li>
<li><code>Serial mode: PROTO</code></li>
<li><code>Override console serial port: off</code></li>
</ul>
</li>
</ul>
<ol start="6">
<li>Rak19003 will require different pin numbers - probably 19,20 but this is untested.</li>
<li>Remember - connect TX on the Luckfox to RX on the Meshtastic board, and vice-versa.</li>
<li>Power can be supplied to the rak via the 3.3v pin on the Luckfox.</li>
<li>If communications is via UART, you must bridge the grounds of the two boards.</li>
<li>Supply power to the Pico Mini via pins or USB.</li>
<li>It should Just Work.</li>
<li>You can connect to the Luckfox via USB Ethernet adapter or via UART serial as described <a href="https://wiki.luckfox.com/Luckfox-Pico/Luckfox-Pico-RV1103/Luckfox-Pico-Login-UART/">here</a>.</li>
</ol>
<p>glhf</p>
<p><img src="https://github.com/noon92/luckfox/blob/main/luckfox_pico_mini_wiring_diagram.png" alt="pinout"><br>
<img src="https://github.com/noon92/luckfox/blob/main/luckfox_pico_mini_original_wiring_diagram.jpg" alt="pinout"></p>

    </div>
  </div>
</body>

</html>
