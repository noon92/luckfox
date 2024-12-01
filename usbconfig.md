---


---

<h2 id="usb-configuration">USB configuration</h2>
<p>To configure some Femtofox settings such as wifi, you can insert a USB flash drive containing a configuration file. The system will automatically recognize, mount and implement the settings you specify.<br>
Configurable settings are:</p>
<ul>
<li>Wifi SSID</li>
<li>Wifi PSK (password)</li>
<li>Wifi country</li>
<li>Timezone</li>
<li>Meshtastic:
<ul>
<li>LoRa radio model</li>
<li><a href="https://meshtastic.org/docs/software/python/cli/#--seturl-seturl">URL</a> (used to configure LoRa settings and channels)</li>
<li>Security: Add Admin Key</li>
<li>Security: Clear Admin Key List</li>
<li>Security: <a href="https://meshtastic.org/docs/configuration/radio/security/#admin-channel-enabled">Legacy Admin Channel</a> enable/disable<br>
<br></li>
</ul>
</li>
</ul>
<h3 id="instructions">Instructions</h3>
<p>The USB drive must be formatted with a single FAT32, exFAT, NTFS (read only) or ext4 partition. Add a file named <code>femtofox-config.txt</code> and whichever of the the following lines you want to set, keeping in mind this is CaSe sEnSiTiVe:</p>
<pre><code>	wifi_ssid="Your SSID name"
	wifi_psk="wifipassword"
	wifi_country="US"
	timezone="America/New_York"
	meshtastic_lora_radio="ebyte-e22-900m30s"
	meshtastic_url="https://meshtastic.org/e/#CgMSAQESCAgBOAFAA0gB"
	meshtastic_admin_key="T/b8EGvi/Nqi6GyGefJt/jOQr+5uWHHZuBavkNcUwWQ="
	meshtastic_admin_key_clear="true"
	meshtastic_legacy_admin="true"
</code></pre>
<blockquote>
<p>[!NOTE]<br>
Enter as many or as few settings as you like.</p>
<p>For wifi country, insert your country’s two letter code (such as CA or IN) in capital letters.</p>
<p>Use a timezone as it appears in <a href="https://en.wikipedia.org/wiki/List_of_tz_database_time_zones">the tz database</a>.</p>
<p><strong>Meshtastic</strong><br>
For LoRa radio, choose your radio from the supported hardware list.<br>
Options are:</p>
<ul>
<li>ebyte-e22-900m30sm</li>
<li>ebyte-e22-900m22s</li>
<li>e22-900mm22s</li>
<li>heltec-ht-ra62</li>
<li>seeed-wio-sx1262</li>
<li>waveshare-sx126x-xxxm</li>
<li>ai-thinker-ra-01sh</li>
<li>none <em>(for simradio)</em></li>
</ul>
<p>You cannot set URL and security settings in the same operation - if you must set both, set the URL first, then edit the femtofox-config.txt file on the USB drive to remove the URL and add in your security settings.</p>
<p>Clearing the admin key list: The admin key list can contain up to three keys - if more are added they will be ignored. The USB configuration tool supports clearing the admin key list, after which you will need to re-add your admin key/s in a second operation.</p>
</blockquote>
<p>To apply your configuration, reboot the Femtofox with the USB drive plugged in. No other USB drives can be plugged in at the same time.<br>
<br></p>
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
<td>USB drive mounted successfully, and femtofox-config.txt was found and contained valid configuration data which was deployed. Any affected services will now restart. You can disconnect the USB drive.</td>
<td>This does not mean that the information in the config file is correct - only that it was readable.<br>Note that the “success” boot code will flash if at least one setting is successfully read - even if some data was not read successfully.</td>
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

