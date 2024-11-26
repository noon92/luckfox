#!/bin/sh
echo "Content-type: text/html"
echo ""

# Get Wi-Fi connection status using wpa_cli
WIFI_STATUS=$(wpa_cli status)

# Extract connection status details
STATE=$(echo "$WIFI_STATUS" | grep 'wpa_state=' | cut -d= -f2)
SSID=$(echo "$WIFI_STATUS" | grep '^ssid=' | cut -d= -f2)
IP=$(echo "$WIFI_STATUS" | grep '^ip_address=' | cut -d= -f2)

# Display connection status at the top of the HTML
echo "<html><body>"

echo "<h2>Wi-Fi Status</h2>"
echo "<p><strong>Connection State:</strong> $STATE</p>"
[ -n "$SSID" ] && echo "<p><strong>Connected SSID:</strong> $SSID</p>"
[ -n "$IP" ] && echo "<p><strong>IP Address:</strong> $IP</p>"

# HTML Form for Wi-Fi Configuration
echo "<h1>Wi-Fi Configuration</h1>"
echo "<form method=\"POST\" action=\"/cgi-bin/configure-wifi.sh\">"
echo "  <label for=\"ssid\">SSID:</label><br>"
echo "  <input type=\"text\" id=\"ssid\" name=\"ssid\" required><br><br>"
echo "  <label for=\"password\">Password:</label><br>"
echo "  <input type=\"password\" id=\"password\" name=\"password\"><br><br>"
echo "  <button type=\"submit\">Submit</button>"
echo "</form>"

echo "</body></html>"
