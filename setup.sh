#!/bin/bash

comment() {
    echo ">> $(tput setaf 2) $@$(tput sgr0)" >&2
}

### SETUP ###

# Install Neovim
sudo pacman -S \
    fish \
    neovim 

# Set Time Zone
comment "Set correct time zone and set hardware clock accordingly"
ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc

# Set Locale
comment "Set default locales and generate locales"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "nl_NL.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

comment "Set default language to American English"
echo LANG=en_US.UTF-8 >> /etc/locale.conf
comment "Set time format to display as 24:00"
echo LC_TIME=nl_NL.UTF-8 >> /etc/locale.conf

# Set hostname
echo -n "What should this computer be called? "
read HOSTNAME
echo "$HOSTNAME" > /etc/hostname

cp -f ${PWD}/hosts /etc/hosts
echo -e "\n127.0.1.1\t$HOSTNAME.localdomain\t$HOSTNAME" >> /etc/hosts

# Setup root Password
comment "Set root password"
passwd

# Setup User
comment "Create user and add to relevant group"
echo -n "What is your username? "
read USERNAME
useradd -m -g users -G wheel,audio,video,optical,storage -s "$(which fish)" $USERNAME

comment "Set password of new user"
passwd $USERNAME

comment "Enable sudo access for group wheel"
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/sudo-for-wheel-group

### INSTALL GRUB ###
comment "Install bootloader"
sudo pacman -S \
    dosfstools \
    efibootmgr \
    grub \
    mtools \
    os-prober

comment "Making boot folder at /boot/EFI"
mkdir /boot/EFI

lsblk
comment "What is your boot partition?"
read BOOTPART
mount /dev/$BOOTPART /boot/EFI

comment "Installing Grub"
grub-install --target=x86_64-efi  --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

comment "Copy dotfiles to new user"
cp -r ${PWD} /home/$USERNAME

comment "Install networking"
sudo pacman -S \
    dialog \
    wpa_supplicant \
    dhcpcd \
    netctl

# Enable services
systemctl enable systemd-resolved.service

### maybe pile ###
# xcape

echo Done!
