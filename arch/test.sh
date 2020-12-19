#!/bin/bash

# Enable 32-bits packages
echo "" >> /mnt/etc/pacman.conf
echo "[multilib]" >> /mnt/etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" >> /mnt/etc/pacman.conf
echo "" >> /mnt/etc/pacman.conf


sed -i 's/#Color/Color/' /mnt/etc/pacman.conf
sed -i 's/#TotalDownload/TotalDownload/' /mnt/etc/pacman.conf
