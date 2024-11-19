---


---

<hr>
<hr>
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
</td></tr></tbody></table><p>

Failed to mount USB drive. Ignoring.</p>


|
<p>|

|⚠️  3 long blinks, each lasting 1.5 seconds</p>

<p>|USB drive mounted successfully but femtofox-config.txt was not found. Ignoring.</p>



<p>|

|⚠️  5 long blinks, each lasting 1.5 seconds</p>

<p>|USB drive mounted successfully and femtofox-config.txt was found but did not contain readable configuration data. Ignoring.</p>



<p>|

|✅ 5 very fast blinks, each lasting 1/8th of a second</p>

<p>|USB drive mounted successfully, and femtofox-config.txt was found and contained valid configuration data which was deployed. System will now reboot. Unplug the USB drive or the system will continue to reboot repeatedly.</p>



<p>|

|✅ 5 medium blinks, each lasting 1/2 a second</p>
||Boot complete. Always appears last.
|

<p>|
</p><p>|Boot codes can appear in sequence - for example: one long (4 second) blink, followed by 5 medium (half second) blinks means the attempt to mount the USB drive failed, and that boot is complete.</p>

<!--stackedit_data:
eyJoaXN0b3J5IjpbLTExOTA2MjUwMjNdfQ==
-->