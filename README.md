---


---

<img src="https://github.com/noon92/luckfox/blob/main/luckfox_pico_mini_tiny_linux_board.jpg" width="400">
<h1 id="femtofox----subsubthe-tiny-low-power-linux-meshtastic-node">Femtofox &nbsp;&nbsp;&nbsp;<sub><sub>The tiny, low power Linux Meshtastic node</sub></sub></h1>
<h4 id="the-luckfox-pico-mini-is-a-compact-and-power-efficient-linux-capable-board-capable-of-running-ubuntu.-femtofox-is-an-expansion-of-the-luckfoxs-capabilities-integrating-it-with-a-lora-radio-to-create-a-power-efficient-cheap-and-small-meshtastic-linux-node.">The Luckfox Pico Mini is a compact and power efficient Linux capable board, capable of running Ubuntu. Femtofox is an expansion of the Luckfox’s capabilities, integrating it with a LoRa radio to create a power efficient, cheap and small Meshtastic Linux node.</h4>
<p><strong>Advantages:</strong></p>
<ul>
<li>Tiny size (~28x21mm for the Kitchen Sink Edition, X for the Smol Edition)</li>
<li>Power efficiency (~0.38w)</li>
<li>Full Linux CLI (Ubuntu) via our pre-built Foxbuntu image.</li>
<li>Meshtastic native client support via SPI</li>
<li>USB host support</li>
<li>Wifi over USB</li>
<li>RTC support</li>
</ul>
<p><strong>Accomplished:</strong></p>
<ul>
<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" checked="true" disabled=""> Meshtastic native client controlling a LoRa radio (see <a href="supported_hardware.md">supported hardware</a>)</li>
<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" checked="true" disabled=""> WIFI over USB (see <a href="supported_hardware.md">supported hardware</a>)</li>
<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" checked="true" disabled=""> Ethernet over USB (see <a href="supported_hardware.md">supported hardware</a>)</li>
<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" checked="true" disabled=""> Ethernet over pins (see <em>Networking</em> below and wiring diagram at bottom of page)</li>
<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" checked="true" disabled=""> UART communications with Meshtastic nodes (2 pin pairs) such as RAK Wisblock</li>
<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" checked="true" disabled=""> USB serial communications with Meshtastic nodes (see <a href="supported_hardware.md">supported hardware</a>)</li>
<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" checked="true" disabled=""> USB mass storage</li>
<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" checked="true" disabled=""> Real time clock (RTC) support (see <a href="supported_hardware.md">supported hardware</a>)</li>
<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" checked="true" disabled=""> Activity LED disabled. User LED will blink for 5 seconds when boot is complete</li>
<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" checked="true" disabled=""> Pressing the “BOOT” button triggers reboot</li>
<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" checked="true" disabled=""> Ability to reconfigure wifi via USB flash drive</li>
<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" checked="true" disabled=""> Meshtasticd to run LoRa radio over SPI (accomplished, updated image and instructions coming soon)</li>
<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" checked="true" disabled=""> Allow editing of config files by plugging in thumb drive</li>
<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" checked="true" disabled=""> Ability to activate or deactivate WIFI via Meshtastic admin</li>
</ul>
<p><strong>Project goals:</strong></p>
<ul>
<li>A solar-deployable Meshtastic node running Linux, without needing a giant solar panel / battery</li>
<li>Wifi capabilities (with ability to disable/enable wifi via mesh for power savings)</li>
</ul>
<p>Login for the “fresh” image is <code>root:root</code> or <code>pico:luckfox</code>.  Login for the configured BBS images is <code>root:root</code>,  <code>bbs:mesh</code> or <code>femto:fox</code>.</p>
<p>The preconfigured images will reboot every 24 hours. In theory, this should happen at 3am, if the internal clock is accurate. Time is set on boot with the following logic:</p>
<ol>
<li>If the system recognizes an RTC module connected via i2c, it will use that.</li>
<li>If no RTC module is recognized, time will be set to midnight 2024-1-1 midnight.</li>
<li>If network is available, time will be retrieved from google and system time (and RTC time if present) will be set from that.</li>
</ol>
<p>Reboot timing is set in <code>crontab</code>. Time logic is in <code>/etc/rc.local</code>.</p>
<h3 id="supported-hardware---click-here"><a href="supported_hardware.md">Supported hardware - click here</a></h3>
<h3 id="networking">Networking:</h3>
<p>There are four methods to get online:</p>
<ol>
<li>Ethernet over USB - most adapters should be supported, but I’ve only tested the RTL8152 chipset.</li>
<li>Preconfigured Ubuntu images: ethernet via the castellated pins at the bottom of the board. See pinout at the bottom of this readme. Note that the MAC address for onboard ethernet is hardcoded to 1a:cf:50:33:5f:92 - if you need to change this, <code>sudo nano /etc/network/interfaces</code>.</li>
<li>USB wifi - still a work in progress, but working with a couple different chipsets so far. Note we’re using wpa_supplicant, as networkmanager (nmcli) caused hard crashes.</li>
<li>RDNIS via usb - <a href="https://web.archive.org/web/20241006173648/https://wiki.luckfox.com/Luckfox-Pico/Luckfox-Pico-Network-Sharing-1/">see this guide</a>. Note that in the preconfigured images USB is set to host mode, so you’ll have to switch back to peripheral with <code>sudo luckfox-config</code>. This is not really recommended, but can be used in a pinch.</li>
</ol>
<h3 id="installation---connection-to-meshtastic-node-via-uart-or-usb">Installation - connection to Meshtastic node via UART or USB:</h3>
<ol>
<li>Flash the image your MicroSD card using <a href="https://etcher.balena.io/">Balena Etcher</a> or your favorite flashing program. You will likely get a warning that the image appears to be invalid or has no partition table. This is normal.</li>
<li>Insert the microSD card into the Luckfox Pico Mini.</li>
<li>Configure the system with a USB drive as described in <a href="usb_config.md">USB Configuration Tool</a>.</li>
</ol>
<h3 id="pinout">Pinout:</h3>

<table>
<thead>
<tr>
<th>Pin #</th>
<th>Pin ID</th>
<th>Function</th>
<th>Luckfox</th>
<th>Pin #</th>
<th>Pin ID</th>
<th>Function</th>
</tr>
</thead>
<tbody>
<tr>
<td>1</td>
<td>VBus</td>
<td>5V in/out</td>
<td></td>
<td>22</td>
<td>1V8</td>
<td>1.8V out</td>
</tr>
<tr>
<td>2</td>
<td>GND</td>
<td></td>
<td></td>
<td>21</td>
<td>GND</td>
<td></td>
</tr>
<tr>
<td>3</td>
<td>3V3</td>
<td>3.3V out</td>
<td></td>
<td>20</td>
<td>4C1</td>
<td>1v8 IO, SARADC</td>
</tr>
<tr>
<td>4/42</td>
<td>1B2</td>
<td>Debug UART2-TX</td>
<td></td>
<td>19</td>
<td>4C0</td>
<td>1v8 IO, SARADC</td>
</tr>
<tr>
<td>5/43</td>
<td>1B3</td>
<td>Debug UART2-RX</td>
<td></td>
<td>18/4</td>
<td>0A4</td>
<td>3v3 IO</td>
</tr>
<tr>
<td>6/48</td>
<td>1C0</td>
<td>CS0, IO</td>
<td></td>
<td>17/55</td>
<td>1C7</td>
<td>IRQ, IO</td>
</tr>
<tr>
<td>7/49</td>
<td>1C1</td>
<td>CLK, IO</td>
<td></td>
<td>16/54</td>
<td>1C6</td>
<td>BUSY, IO</td>
</tr>
<tr>
<td>8/50</td>
<td>1C2</td>
<td>MOSI, IO</td>
<td></td>
<td>15/59</td>
<td>1D3</td>
<td>i2c SCL</td>
</tr>
<tr>
<td>9/51</td>
<td>1C3</td>
<td>MISO, IO</td>
<td></td>
<td>14/58</td>
<td>1D2</td>
<td>i2c SDA</td>
</tr>
<tr>
<td>10/52</td>
<td>1C4</td>
<td>UART4-TX</td>
<td></td>
<td>13/57</td>
<td>1D1</td>
<td>UART3-RX, NRST</td>
</tr>
<tr>
<td>11/53</td>
<td>1C5</td>
<td>UART4-RX</td>
<td></td>
<td>12/56</td>
<td>1D0</td>
<td>UART3-TX, RXEN</td>
</tr>
</tbody>
</table><p>Pin ID explanation: <strong>1C6</strong> = GPIO bank <strong>1</strong>, group <strong>C</strong>, pin <strong>6</strong>.<br>
In Meshtasticd’s config.yaml we use GPIO bank 1, and subtract 32 from the pin number.</p>
<p><img src="https://github.com/noon92/luckfox/blob/main/luckfox_pinout.png" alt="pinout"><br>
<img src="https://github.com/noon92/luckfox/blob/main/luckfox_pico_mini_original_wiring_diagram.jpg" alt="pinout"></p>
<blockquote>
<p>[!NOTE]<br>
The information on this page is given without warranty or guarantee. Links to vendors of products are for informational purposes only.<br>
Meshtastic® is a registered trademark of Meshtastic LLC. Meshtastic software components are released under various licenses, see GitHub for details. No warranty is provided - use at your own risk.</p>
</blockquote>

