#!/bin/bash

AUR="yay"
USER_PASSWORD=""
USER_NAME=""

arch-chroot /mnt sed -i 's/%wheel ALL=(ALL) ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
arch-chroot /mnt bash -c "echo -e \"$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\" | sudo -u $USERNAME -S bash -c \"cd /home/$USERNAME && git clone https://aur.archlinux.org/yay.git && (cd yay && makepkg -si --noconfirm) && rm -rf yay\""
arch-chroot /mnt sed -i 's/%wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

echo "All done! "