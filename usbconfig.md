---


---

<h2 id="usb-configuration">USB configuration</h2>
<p>To configure Femtofox wifi settings, you can insert a USB flash drive containing a configuration file named <code>femtofox-config.txt</code>. The system will automatically recognize, mount and implement the settings you specify.<br>
The USB drive must be formatted with a single FAT32, exFAT, NTFS (read only) or ext4 partition. Add a file named <code>femtofox-config.txt</code> and add the following lines, keeping in mind this is CaSe sEnSiTiVe:</p>
<pre><code>ssid="Your SSID name"
psk="wifipassword"
country="US"
</code></pre>
<blockquote>
<p>[!NOTE]<br>
For country, insert your country’s two letter code (such as CA or IN) in capital letters.</p>
</blockquote>
<p>To apply your configuration, reboot the Femtofox with the USB drive plugged in. No other USB drives can be plugged in at the same time.</p>
<h3 id="boot-codes">Boot codes</h3>
<p>When the Femtofox is finished booting, it will blink its User LED (see below) in a pattern which can be used to gather info on its status or help diagnose issues.<br>
<img src="https://github.com/noon92/femtofox/blob/main/leds.png" alt="LEDs"></p>

<table>
<thead>
<tr>
<th>LED blink pattern</th>
<th>Meaning</th>
<th>Possible causes</th>
<th>Solutions</th>
</tr>
</thead>
<tbody>
<tr>
<td>⚠️ One very long blink, lasting 4 seconds</td>
<td>Failed to mount USB drive. Ignoring.</td>
<td><li>Invalid filesystem</li><li>Corrupted partition table</li><li>Defective USB drive</li></td>
<td><li>Use a supported partition (FAT32, exFAT, NTFS, ext4)</li><li>Repair partition table</li><li>Try another USB drive</li></td>
</tr>
<tr>
<td>⚠️ 3 long blinks, each lasting 1.5 seconds</td>
<td>USB drive mounted successfully but femtofox-config.txt was not found. Ignoring.</td>
<td>Config file missing.</td>
<td>Create configuration file as described above.</td>
</tr>
<tr>
<td>⚠️ 5 long blinks, each lasting 1.5 seconds</td>
<td>USB drive mounted successfully and femtofox-config.txt was found but did not contain readable configuration data. Ignoring.</td>
<td>Configuration file improperly formatted or contains no data.</td>
<td>Check configuration file contents as described above.</td>
</tr>
<tr>
<td>✅ 10 very fast blinks, each lasting 1/8th of a second</td>
<td>USB drive mounted successfully, and femtofox-config.txt was found and contained valid configuration data which was deployed. Wifi will now restart and boot will proceed. You can disconnect the USB drive.</td>
<td>Note that this does not mean that the information in the config file is correct - only that we were able to copy it to system configuration.</td>
<td></td>
</tr>
<tr>
<td>✅ 5 medium blinks, each lasting 0.5 seconds</td>
<td>Boot complete. Always appears last.</td>
<td></td>
<td></td>
</tr>
</tbody>
</table><blockquote>
<p>[!NOTE]<br>
Boot codes can appear in sequence - for example: one long (4 second) blink, followed by 5 medium (half second) blinks means the attempt to mount the USB drive failed, and that boot is complete.</p>
</blockquote>

