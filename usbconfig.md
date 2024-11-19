---


---


<table>
<thead>
<tr>
<th>LED blink pattern</th>
<th>Meaning</th>
</tr>
</thead>
<tbody>
<tr>
<td>
|LED blink pattern |Meaning|
|--|--|
|⚠️  One very long blink, lasting 4 seconds</td>
<td>|

Failed to mount USB drive. Ignoring.</td>
</tr>
<tr>
<td>|

|⚠️  3 long blinks, each lasting 1.5 seconds</td>
<td>

USB drive mounted successfully but femtofox-config.txt was not found. Ignoring.</td>
</tr>
<tr>
<td>

|⚠️  5 long blinks, each lasting 1.5 seconds</td>
<td>

USB drive mounted successfully and femtofox-config.txt was found but did not contain readable configuration data. Ignoring.</td>
</tr>
<tr>
<td>

|✅ 5 very fast blinks, each lasting 1/8th of a second</td>
<td>

|USB drive mounted successfully, and femtofox-config.txt was found and contained valid configuration data which was deployed. System will now reboot. Unplug the USB drive or the system will continue to reboot repeatedly.</td>
</tr>
<tr>
<td>

|✅ 5 medium blinks, each lasting 1/2 a second</td>
<td>||Boot complete. Always appears last.</td>
</tr>
</tbody>
</table><p>|

|Boot codes can appear in sequence - for example: one long (4 second) blink, followed by 5 medium (half second) blinks means the attempt to mount the USB drive failed, and that boot is complete.</p>

<!--stackedit_data:
eyJoaXN0b3J5IjpbLTExNzgyMTgwMzZdfQ==
-->