# vicidial-scratch-install-V2

V2 tutorial to install VICIdial from scratch on AlmaLinux 9 with Asterisk 18  
<hr>

### 📋 Instructions

Follow the instructions provided in the `.txt` file. Just use your brain and some basic copy-paste skills — don't do it blindly.

<hr>

### 🔧 IMPORTANT NOTE

At **line number 90** in the installer, update `your.own.domain` to your actual domain that you **own** and have proper DNS authority over.

For SSL/TLS:
- You can use a **custom SSL certificate**, or
- Easily generate one using **Let's Encrypt (Certbot)**.

<hr>

### 🔐 SSH Password Authentication

If you want to enable **password-based SSH login** instead of key-only auth, run the following:

```bash
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null
sudo systemctl restart sshd
```

<hr>
🛠 New Addition: Automated Installer
A new file named auto-vicidial-installer.sh is now included in this repo. It is an automated version of the manual script and performs most of the tasks for you, including:

System prep

Git cloning

VICIdial installation

Asterisk startup

Webphone (ViciPhone) setup

⚠️ NOTE: If the final two steps in the script (cloning the ViciPhone repo and renaming the folder) fail due to network, GitHub, or file system issues, just do them manually using the original manual-vicidial-installer.txt.

Manual fix:

```bash
cd /var/www/html/agc
rm -rf sip_js
git clone https://github.com/vicimikec/ViciPhone.git
mv ViciPhone sip_js
chown -R apache:apache sip_js
chmod -R 755 sip_js
```
<hr>
Good luck!

