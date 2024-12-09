---


---

<h2 id="usb-configuration-tool">USB Configuration Tool</h2>
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
<li>Security: <a href="https://meshtastic.org/docs/configuration/radio/security/#admin-channel-enabled">Legacy Admin Channel</a> enable/disable</li>
</ul>
</li>
</ul>
<h3 id="instructions">Instructions</h3>
<p>The USB drive must be formatted with a single FAT32, exFAT, NTFS (read only - log will not be saved to drive) or ext4 partition. Add a file named <code>femtofox-config.txt</code> and whichever of the the following lines you want to set, keeping in mind this is CaSe sEnSiTiVe:</p>
<pre><code>wifi_ssid="Your SSID name"
wifi_psk="wifipassword"
wifi_country="US"
timezone="America/New_York"
meshtastic_lora_radio="ebyte-e22-900m30s"
meshtastic_url="https://meshtastic.org/e/#CgMSAQESCAgBOAFAA0gB"
meshtastic_admin_key="base64:T/b8EGvi/Nqi6GyGefJt/jOQr+5uWHHZuBavkNcUwWQ="
meshtastic_legacy_admin="true"
</code></pre>
<blockquote>
<p>[!NOTE]<br>
Enter as many or as few settings as you like.</p>
<p>For <code>wifi_country</code>, insert your country’s two letter code (such as CA or IN) in capital letters.</p>
<p>Use a timezone as it appears in <a href="https://en.wikipedia.org/wiki/List_of_tz_database_time_zones">the tz database</a>.</p>
<p><strong>Meshtastic</strong><br>
For <code>meshtastic_lora_radio</code>, choose your radio from the supported hardware list.<br>
Options are:</p>
<ul>
<li><code>ebyte-e22-900m30sm</code></li>
<li><code>ebyte-e22-900m22s</code></li>
<li><code>e22-900mm22s</code></li>
<li><code>heltec-ht-ra62</code></li>
<li><code>seeed-wio-sx1262</code></li>
<li><code>waveshare-sx126x-xxxm</code></li>
<li><code>ai-thinker-ra-01sh</code></li>
<li><code>none</code> <em>(for simradio)</em></li>
</ul>
<p><strong>Important:</strong> You cannot set URL and security settings in the same operation - if you must set both, set the URL first, then edit the <code>femtofox-config.txt</code> file on the USB drive to remove the URL and add in your security settings.</p>
<p>To add a <code>meshtastic_admin_key</code>, copy it from the app and add <code>base64:</code> to the beginning (<code>meshtastic_admin_key="base64:T/b8EGvi/Nqi6GyGefJt/jOQr+5uWHHZuBavkNcUwWQ="</code>).</p>
<p>Clearing the <code>meshtastic_admin_key</code> list: The admin key list can contain up to three keys - <em>if more are added they will be ignored</em>. The USB configuration tool supports clearing the admin key list, after which you will need to re-add your admin key/s in a second operation. To clear the admin key list, enter <code>meshtastic_admin_key="0"</code>, without <code>base64:</code>.</p>
</blockquote>
<blockquote>
<p>[!CAUTION]<br>
Attempting to set wifi settings via USB configuration tool without a wifi adapter connected will lead to a 5 minute hang while the configuration tool runs - either disconnect and reconnect power or wait the full 5 minutes to to recover.</p>
</blockquote>
<p><strong>To apply your configuration, reboot the Femtofox with the USB drive plugged in. No other USB drives can be plugged in at the same time.</strong><br>
A log (<code>femtofox-config.log</code>) is saved to <code>/home/femto</code> and the USB drive (except on NTFS, which is read only).<br>
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
<td><center>⚠️<br>________________<br>1 very long blink, lasting 5 seconds</center></td>
<td>Failed to mount USB drive. Ignoring.</td>
<td><li>Invalid filesystem</li><li>Corrupted partition table</li><li>Defective USB drive</li><li>Defective USB OTG adapter</li></td>
<td><li>Use a supported partition (FAT32, exFAT, NTFS, ext4)</li><li>Repair partition table</li><li>Try another USB drive</li><li>Try another USB OTG adapter</li></td>
</tr>
<tr>
<td><center>⚠️<br>_____&nbsp;&nbsp;_____&nbsp;&nbsp;_____<br>3 long blinks, each lasting 1.5 seconds</center></td>
<td>USB drive mounted successfully but femtofox-config.txt was not found. Ignoring.</td>
<td>Config file missing.</td>
<td>Create configuration file as described above.</td>
</tr>
<tr>
<td><center>⚠️<br>_____&nbsp;&nbsp;_____&nbsp;&nbsp;_____&nbsp;&nbsp;_____&nbsp;&nbsp;_____<br>5 long blinks, each lasting 1.5 seconds</center></td>
<td>USB drive mounted successfully and femtofox-config.txt was found but did not contain readable configuration data. Ignoring.</td>
<td>Configuration file improperly formatted or contains no data.</td>
<td>Check configuration file contents as described above.</td>
</tr>
<tr>
<td><center>⚠️<br>___&nbsp;&nbsp;___&nbsp;&nbsp;_&nbsp;&nbsp;_&nbsp;&nbsp;___&nbsp;&nbsp;___&nbsp;&nbsp;_&nbsp;&nbsp;_<br>2 long blinks, each lasting 1 seconds, then 2 short blinks, each lasting 1/4 of a second. Repeats twice</center></td>
<td>Error while trying to implement a Meshtastic setting after 3 attempts. Some settings may have been implemented successfully.</td>
<td><li>The error may be transient.</li><li>Configuration file may contain improper data.</li></td>
<td><li>Try again.</li><li>Check configuration file contents as described above.</li><li>Check the log.<br><br>This pattern may flash before other patterns. The pattern will repeat once for each failed setting.</li></td>
</tr>
<tr>
<td><center>✅<br>. . . . . . . . . .<br>10 very fast blinks, each lasting 1/8th of a second</center></td>
<td>USB drive mounted successfully, and femtofox-config.txt was found and contained configuration data which was sent for deployment. Any affected services will now restart. You can disconnect the USB drive.</td>
<td>This does not mean that the information in the config file is correct - only that it was readable.<br>Note that the “success” boot code will flash if at least one setting is successfully read - even if the setting was not implemented successfully.</td>
<td></td>
</tr>
<tr>
<td><center>✅<br>__&nbsp;&nbsp;__&nbsp;&nbsp;__&nbsp;&nbsp;__&nbsp;&nbsp;__<br>5 medium blinks, each lasting 0.5 seconds</center></td>
<td>Boot complete. Appears on every successful boot and always appears last.</td>
<td></td>
<td></td>
</tr>
</tbody>
</table><blockquote>
<p>[!NOTE]<br>
Boot codes can appear in sequence - for example: one long (4 second) blink, followed by 5 medium (half second) blinks means the attempt to mount the USB drive failed, and that boot is complete.</p>
</blockquote>

