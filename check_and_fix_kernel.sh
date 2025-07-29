#!/bin/bash

COMPATIBLE_KERNEL="5.14.0-570.28.1.el9_6.x86_64"
CURRENT_KERNEL=$(uname -r)

echo "Current Kernel: $CURRENT_KERNEL"
echo "Compatible Kernel: $COMPATIBLE_KERNEL"

if [[ "$CURRENT_KERNEL" == "$COMPATIBLE_KERNEL" ]]; then
    echo "✅ System is running the compatible kernel."
    exit 0
fi

# Try installing if not found
if ! ls /boot/vmlinuz-$COMPATIBLE_KERNEL &>/dev/null; then
    echo "⏬ Installing compatible kernel..."
    dnf install -y kernel-core-$COMPATIBLE_KERNEL kernel-$COMPATIBLE_KERNEL || {
        echo "❌ Failed to install the kernel package."
        exit 1
    }
fi

# Get GRUB menu index
INDEX=$(awk -F"'" '/menuentry / { print i++ " : " $2 }' /boot/grub2/grub.cfg | \
        grep "$COMPATIBLE_KERNEL" | awk -F ' :' '{print $1}' | head -n1)

if [[ -z "$INDEX" ]]; then
    echo "❌ Compatible kernel not found in GRUB after install."
    exit 1
fi

echo "⚠️  Switching to compatible kernel (index $INDEX)..."
grub2-set-default "$INDEX"

echo "🔁 Rebooting in 10 seconds..."
sleep 10
reboot
