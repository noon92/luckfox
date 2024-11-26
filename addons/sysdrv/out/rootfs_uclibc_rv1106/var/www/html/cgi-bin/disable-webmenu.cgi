#!/bin/sh
echo "Content-type: text/plain"
echo ""
sudo systemctl stop busybox-httpd && sudo systemctl disable busybox-httpd

