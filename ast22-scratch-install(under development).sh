#!/bin/bash

# VICIdial Auto Installer for AlmaLinux 9 with ViciPhone and Asterisk 22 LTS
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

# Install dependencies for Asterisk 22
echo "[*] Installing Asterisk 22 dependencies..."
yum groupinstall -y "Development Tools"
yum install -y ncurses-devel libxml2-devel libuuid-devel jansson-devel libedit-devel openssl-devel wget

# Install Asterisk 22
echo "[*] Downloading and compiling Asterisk 22..."
cd /usr/src
wget https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-22-current.tar.gz
tar xvf asterisk-22-current.tar.gz
cd asterisk-22.*
contrib/scripts/get_mp3_source.sh
./configure
make -j$(nproc)
make install
make samples
make config
ldconfig

# Install MariaDB and Apache
echo "[*] Installing MariaDB and Apache..."
yum install -y mariadb-server mariadb httpd php php-mysqlnd php-pdo php-process php-gd php-mbstring php-xml php-cli php-common

systemctl enable mariadb --now
systemctl enable httpd --now

# Clone VICIdial installer and skip Asterisk part
echo "[*] Cloning VICIdial installer..."
cd /usr/src
git clone https://github.com/carpenox/vicidial-install-scripts.git
cd vicidial-install-scripts

# Modify the main installer to skip Asterisk if needed, or continue...
echo "[*] Running VICIdial installer script (Asterisk step skipped)..."
chmod +x main-installer.sh
./main-installer.sh

# Start Asterisk
echo "[*] Starting Asterisk in a screen session..."
cd /var/log/astguiclient
screen -dmS asterisk bash -c 'ulimit -n 65536 && /usr/sbin/asterisk -vvvvvvvvvvvvvvvvvvvvvgcT'

# Apache fix
echo "[*] Disabling SSL Apache config if present..."
mv /etc/httpd/conf.d/viciportal-ssl.conf /etc/httpd/conf.d/viciportalssl.conf-noload 2>/dev/null

# Stop firewall (optional)
echo "[*] Stopping firewall..."
systemctl stop firewalld 2>/dev/null

# Fix permissions
echo "[*] Fixing VICIdial image directory permissions..."
chmod 755 /usr/src/astguiclient/trunk/www/vicidial/images/

# Restart Apache
systemctl restart httpd

# Reload Asterisk modules
echo "[*] Reloading Asterisk modules..."
asterisk -rx "dialplan reload"
asterisk -rx "pjsip reload"
asterisk -rx "module reload app_voicemail.so"
asterisk -rx "moh reload"

# ViciPhone Setup
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

# Final info
echo "[*] ViciPhone installed successfully."
echo "[*] All steps completed. Please log into the VICIdial Admin panel to configure:"
echo "Admin → System Settings → Webphone URL"
echo "Set Webphone URL to: https://your.domain.com/agc/sip_js/src/viciphone.php"
