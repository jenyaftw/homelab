#!/usr/bin/env bash
set -euxo pipefail

LABEL="PERSIST"

boot_dev="$(findmnt -no SOURCE /iso || true)"
if [ -z "$boot_dev" ]; then
  echo "Could not detect /iso mount — not running from live USB?"
  exit 1
fi

usb_dev="${boot_dev%%[0-9]*}"
echo "Detected boot USB device: $usb_dev"

if blkid | grep -q "LABEL=\"$LABEL\""; then
  echo "Persistence partition already exists."
  exit 0
fi

last_end="$(parted -m "$usb_dev" unit MB print | awk -F: '/^[0-9]+:/{end=$3} END{print end}' | tr -d 'MB[:space:]')"

if [ -z "$last_end" ]; then
  last_end=1
fi

start_mb=$(( ${last_end%.*} + 1 ))
start="${start_mb}MB"

echo "Creating persistence partition starting at $start to end of device..."
parted -s "$usb_dev" mkpart primary ext4 "$start" 100%
sync
udevadm settle

new_part="$(lsblk -rno NAME "$usb_dev" | tail -n1)"
echo "Formatting /dev/$new_part as ext4..."
mkfs.ext4 -L "$LABEL" "/dev/$new_part"

mkdir -p /persist
mount "/dev/$new_part" /persist
echo "✅ Created and mounted /persist on /dev/$new_part"
