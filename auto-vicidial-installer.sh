#!/bin/bash

# VICIdial Auto Installer for AlmaLinux 9 with ViciPhone
# Author: Debjit Pal (Beltalk Tech)
# Please run this script as root

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

echo "[*] Setting timezone..."
timedatectl set-timezone America/New_York

echo "[*] Updating system packages..."
yum check-update
yum update -y
yum install -y epel-release git kernel* --exclude=kernel-debug*

echo "[*] Disabling SELinux..."
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

echo "[*] Cloning VICIdial install script..."
cd /usr/src
git clone https://github.com/carpenox/vicidial-install-scripts.git
cd vicidial-install-scripts/
chmod +x main-installer.sh

echo "[*] Running VICIdial installer script..."
./main-installer.sh

echo "[*] Starting Asterisk in a screen session..."
cd /var/log/astguiclient
screen -dmS asterisk bash -c 'ulimit -n 65536 && /usr/sbin/asterisk -vvvvvvvvvvvvvvvvvvvvvgcT'

echo "[*] Disabling SSL Apache config (if present)..."
mv /etc/httpd/conf.d/viciportal-ssl.conf /etc/httpd/conf.d/viciportalssl.conf-noload 2>/dev/null

echo "[*] Stopping firewall..."
systemctl stop firewalld 2>/dev/null

echo "[*] Fixing VICIdial image directory permissions..."
chmod 755 /usr/src/astguiclient/trunk/www/vicidial/images/

echo "[*] Restarting Apache services..."
systemctl restart httpd 2>/dev/null

echo "[*] Reloading Asterisk modules..."
asterisk -rx "dialplan reload"
asterisk -rx "sip reload"
asterisk -rx "module reload app_voicemail.so"
asterisk -rx "moh reload"

echo "[*] Installing ViciPhone..."

if [ ! -d "/var/www/html/agc" ]; then
  echo "[!] ERROR: Directory /var/www/html/agc does not exist. Creating it..."
  mkdir -p /var/www/html/agc
  chown apache:apache /var/www/html/agc
fi

cd /var/www/html/agc || { echo "[!] Failed to cd into /var/www/html/agc"; exit 1; }

echo "[*] Removing old sip_js directory (if any)..."
rm -rf sip_js

echo "[*] Cloning ViciPhone..."
git clone https://github.com/vicimikec/ViciPhone.git || { echo "[!] git clone failed. Check network and git install."; exit 1; }

mv ViciPhone sip_js
chown -R apache:apache sip_js
chmod -R 755 sip_js

echo "[*] ViciPhone installed successfully."

echo "[*] All steps completed. Please log into the VICIdial Admin panel to configure:"
echo "Admin → System Settings → Webphone URL"
echo "Set Webphone URL to: https://your.domain.com/agc/sip_js/src/viciphone.php"
