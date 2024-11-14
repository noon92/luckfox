---


---

<img src="https://github.com/noon92/luckfox/blob/main/luckfox_pico_mini_tiny_linux_board.jpg" width="400">
<h3 id="the-luckfox-pico-mini-is-a-compact-and-power-efficient-0.25w-linux-capable-board-ideal-for-running-tc2-meshtastic-bbs-or-anything-else.">The Luckfox Pico Mini is a compact and power efficient (~0.25w) Linux capable board, ideal for running <a href="https://github.com/TheCommsChannel/TC2-BBS-mesh">TC2 Meshtastic BBS</a> (or anything else).</h3>
<p><strong>Advantages:</strong></p>
<ul>
<li>Tiny size (~28x21mm)</li>
<li>Power efficiency (~0.25w)</li>
<li>Full Linux CLI (Ubuntu, Buildroot, Alpine)</li>
<li>USB host support</li>
<li>Cheap - $7-8 on <a href="https://www.waveshare.com/luckfox-pico-min.htm">Waveshare</a> (also available on Amazon)! Get the A model - the B just has added flash storage that’s too small for our purposes.</li>
</ul>
<p><strong>Disadvantages:</strong></p>
<ul>
<li>By default, no simple way to get online (no built in wifi/BLE/ethernet). Ethernet can be easily added - wifi still work in progress - see <em>Networking</em> below)</li>
<li>Annoying SDK for building firmware images</li>
<li>No simple way to compile drivers (no available Linux headers - if anyone manages to compile the headers, please let me know)</li>
<li>USB seems very power limited - highest observed current is low - just 0.08a at 5v (0.4w). It seems that if power draw exceeds this limit, the device will bootloop or hard crash.</li>
</ul>
<p><strong>Accomplished:</strong></p>
<ul>
<li>Ethernet over USB (see <em>supported hardware</em> below)</li>
<li>Ethernet over pins (see <em>Networking</em> below and wiring diagram at bottom of page)</li>
<li>UART communications with Meshtastic nodes (2 pin pairs)</li>
<li>USB serial communications with Meshtastic nodes (see <em>supported hardware</em> below)</li>
<li>Meshtastic native client controlling a LoRa radio (see <em>supported hardware</em> below)</li>
<li>USB mass storage</li>
<li>Real time clock (RTC) support (see <em>supported hardware</em> below)</li>
<li>Activity LED disabled. User LED will blink for 5 seconds when boot is complete.</li>
</ul>
<p><strong>Issues / to do / in progress:</strong></p>
<ul>
<li>WIFI over USB or UART (accomplished, unstable, optimizing)</li>
<li>Meshtasticd to run LoRa radio over SPI (accomplished, updated image and instructions coming soon)</li>
<li>Custom carrier PCB with LoRa radio</li>
</ul>
<p><strong>Project goals:</strong></p>
<ul>
<li>A solar-deployable Meshtastic node running Linux, without needing a giant solar panel or battery.</li>
<li>Wifi capabilities.</li>
</ul>
<h3 id="ive-built-three-ubuntu-22.04.5-lts-images-with-luckfoxs-sdk">I’ve built three Ubuntu 22.04.5 LTS images with Luckfox’s SDK:</h3>
<ol>
<li><a href="https://drive.google.com/file/d/17ofd-bt6IVE3EDBe9cu1_IK2BuYEeg_a/view?usp=sharing">A ‘fresh’ image with no changes but with the added drivers for usb ethernet, wifi, serial, RTC and mass storage.</a></li>
<li><a href="https://drive.google.com/file/d/1YSlR-At4rCv29A_f9hgME6Z_D2mZ1WO3/view?usp=drive_link">An image preconfigured with the TC2-BBS for comms over UART4.</a></li>
<li><a href="https://drive.google.com/file/d/1iXApWAXAhl-iirATAJVD0Ilr2K8OdY3i/view?usp=sharing">An image preconfigured with the TC2-BBS for comms over USB.</a> This assumes the USB device is recognized as /dev/ttyACM0.</li>
</ol>
<p>Login for the “fresh” image is <code>root:root</code> or <code>pico:luckfox</code>.  Login for the configured BBS images is <code>bbs:mesh</code>.</p>
<p>The preconfigured images will reboot every 24 hours, and restart the BBS every other hour. In theory, this should happen at 7am UTC (because both the US and Europe are generally inactive at that time). Time is set on boot with the following logic:</p>
<ol>
<li>If the system recognizes an RTC module connected via i2c, it will use that.</li>
<li>If no RTC module is recognized, time will be set to midnight 24/1/1.</li>
<li>If network is available, time will be retrieved from google and system time (and RTC time if present) will be set from that.</li>
</ol>
<p>Reboot timing is set in <code>crontab</code>. Time logic is in <code>/etc/rc.local</code>.</p>
<h3 id="networking">Networking</h3>
<p>There are three methods to get online:</p>
<ol>
<li>RDNIS via usb - <a href="https://web.archive.org/web/20241006173648/https://wiki.luckfox.com/Luckfox-Pico/Luckfox-Pico-Network-Sharing-1/">see this guide</a>. Note that in the preconfigured images USB is set to host mode, so you’ll have to switch back to peripheral with <code>sudo luckfox-config</code>.</li>
<li>Ethernet over USB - most adapters should be supported, but I’ve only tested the RTL8152 chipset.</li>
<li>Preconfigured ubuntu images: ethernet via the castellated pins at the bottom of the board. See pinout at the bottom of this readme. Note that the MAC address for onboard ethernet is 1a:cf:50:33:5f:92 - if you need to change this, <code>sudo nano /etc/network/interfaces</code>.</li>
</ol>
<h3 id="supported-hardware">Supported hardware</h3>
<p>The following hardware is confirmed working with the linked Ubuntu images.</p>

<table>
<thead>
<tr>
<th>Hardware</th>
<th>Confirmed working</th>
<th>Expected to work</th>
<th>Notes</th>
</tr>
</thead>
<tbody>
<tr>
<td>RTC (real time clock)</td>
<td><a href="https://vi.aliexpress.com/item/1005007143842437.html">DS3231</a>, <a href="https://vi.aliexpress.com/item/1005007143542894.html">DS1307</a></td>
<td>DS1337, DS1338, DS1340</td>
<td>Some DS3231 modules are listed as have a supercapacitor - these are usually actually lithium coin cells.</td>
</tr>
<tr>
<td>LoRa radios (working with Meshtasticd)</td>
<td><a href="https://www.waveshare.com/sx1262-lorawan-hat.htm?sku=22002">Waveshare RPi LoRa hat without GNSS</a></td>
<td>Any SPI LoRa radio that’s Meshtastic compatible</td>
<td>Waveshare RPi hat is not recommended as it has issues with sending longer messages.</td>
</tr>
<tr>
<td>Meshtastic nodes</td>
<td>USB+UART: RAK4631 with RAK19007 or RAK19003 base boards</td>
<td></td>
<td>RAK4630 and 4631 are the same.</td>
</tr>
<tr>
<td>USB wifi adapter chipsets</td>
<td>RTL8188EUS, MT7601U</td>
<td></td>
<td>USB power limitations are causing many issues. Unreliable - work in progress.</td>
</tr>
<tr>
<td>Misc. hardware</td>
<td>USB hubs, thumb drives, SD card readers</td>
<td></td>
<td>Highest observed current is low - just 0.08a at 5v (0.4w). It seems that if power draw exceeds this limit, the device will bootloop or hard crash.</td>
</tr>
</tbody>
</table><h3 id="installation---connection-to-meshtastic-node-via-uart-or-usb">Installation - connection to Meshtastic node via UART or USB</h3>
<p><strong>Choosing a MicroSD card:</strong> Any reasonably fast MicroSD card of 32gb or higher should work, but ideally use a card that supports UHS-1 or higher, and is rated for high endurance.</p>
<ol>
<li>Uncompress the 7z file - will require ~29gb of space. In windows, use <a href="https://www.7-zip.org/">7-zip</a>.</li>
<li>Flash the image your MicroSD card using <a href="https://etcher.balena.io/">Balena Etcher</a> or your favorite flashing program. You will likely get a warning that the image appears to be invalid or has no partition table. This is normal.</li>
<li>Insert the microSD card into the Pico Mini.</li>
<li>Connect Pico Mini to Meshtastic radio via pins or USB, depending on image flashed. If using pins - use pins 10 and 11 on the Luckfox board.</li>
<li>For the rak19007 or rak19003 (with the rak4631/rak4630 daughter board):</li>
</ol>
<ul>
<li>In Position settings, set <code>GPS: NOT_PRESENT</code>. The Rak does not support GPS and UART simultaneously at this time.</li>
<li>If using UART comms, Serial Module settings:
<ul>
<li><code>Serial: Enabled</code></li>
<li><code>Echo: off</code></li>
<li><code>RX: 15</code> (rak19007 and rak19003 with TX1/RX1), <code>19</code> (rak19003 with TX0/RX0)`</li>
<li><code>TX: 16</code> (rak19007 and rak19003 with TX1/RX1), <code>20</code> (rak19003 with TX0/RX0)`</li>
<li><code>Serial baud rate: 115200</code></li>
<li><code>Timeout: 0</code></li>
<li><code>Serial mode: PROTO</code></li>
<li><code>Override console serial port: off</code></li>
</ul>
</li>
</ul>
<ol start="6">
<li>Rak19003 will require different pin numbers - probably <code>19,20</code> but this is untested.</li>
<li>Remember - connect TX on the Luckfox to RX on the Meshtastic board, and vice-versa.</li>
<li>Power can be supplied to the RAK board via the 3.3v out pin on the Luckfox.</li>
<li>If communications is via UART, you must bridge the grounds of the two boards.</li>
<li>Supply power to the Luckfox via pins or USB.</li>
<li>It should Just Work.</li>
<li>You can connect to the Luckfox via ethernet or UART serial as described <a href="https://wiki.luckfox.com/Luckfox-Pico/Luckfox-Pico-RV1103/Luckfox-Pico-Login-UART/">here</a>.</li>
</ol>
<p>glhf</p>
<p><img src="https://github.com/noon92/luckfox/blob/main/luckfox_pico_mini_wiring_diagram.png" alt="pinout"><br>
<img src="https://github.com/noon92/luckfox/blob/main/luckfox_pico_mini_original_wiring_diagram.jpg" alt="pinout"></p>

