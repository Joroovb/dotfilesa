#!/bin/bash

comment() {
    echo ">> $(tput setaf 2) $@$(tput sgr0)" >&2
}

microCode() {
     PS3=$'\n'"Do you have a Intel or AMD processor?"$'\n'

     echo -e "\n"

     options=("Intel" "AMD" "None")
     select opt in "${options[@]}"
     do
        case $opt in
            "Intel")
                CPUPACK="intel-ucode"
                break
                ;;
            "AMD")
                CPUPACK="amd-ucode"
                break
                ;;
            "None")
                echo "Skipping micro code installation"
                break
                ;;
            *) echo "Invalid input";;
        esac
    done
}

graphics() {
     PS3=$'\n'"Do you have Intel Integrated graphics, a AMD GPU or a Nvidia GPU?"$'\n'

     echo -e "\n"

     options=("Intel" "AMD" "Nvidia" "None")
     select opt in "${options[@]}"
     do
        case $opt in
            "Intel")
                GRAPHICSPACKS="mesa mesa-vdpau lib32-mesa lib32-mesa-vdpau libva-mesa-driver lib32-vulkan-intel vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader"
                break
                ;;
            "AMD")
                GRAPHICSPACKS="mesa mesa-vdpau lib32-mesa lib32-mesa-vdpau libva-mesa-driver lib32-vulkan-radeon vulkan-radeon"
                break
                ;;
            "Nvidia")
                GRAPHICSPACKS="nvidia lib32-nvidia-utils"
                break
                ;;
            "None")
                echo "Skipping graphics drivers installation"
                GRAPHICSPACKS=""
                break
                ;;
            *) echo "Invalid input";;
        esac
    done
}

packages_aur() {
    arch-chroot /mnt sed -i 's/%wheel ALL=(ALL) ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
    pacman_install "git"
    arch-chroot /mnt bash -c "echo -e \"$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n\" | su $USERNAME -c \"cd /home/$USERNAME && git clone https://aur.archlinux.org/yay.git && (cd yay && makepkg -si --noconfirm) && rm -rf yay\""
    aur_install "autotiling bitwarden-cli lf ncspot networkmanager-dmenu nerd-fonts-fira-code picom-ibhagwan-git pistol-git polybar fortune-mod-calvin"
    arch-chroot /mnt sed -i 's/%wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
}

aur_install() {
    AUR_COMMAND="yay -Syu --noconfirm --needed $1"
    arch-chroot /mnt bash -c "echo -e \"$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n\" | su $USER_NAME -c \"$AUR_COMMAND\""
}

pacman_install() {
    arch-chroot /mnt pacman -Syu --noconfirm --needed \
        # Utility
        fish \
        nano \
        # Bootloader
        dosfstools \
        efibootmgr \
        grub \
        mtools \
        os-prober \
        # Networking
        dialog \
        wpa_supplicant \
        dhcpcd \
        netctl \
}
https://raw.githubusercontent.com/Joroovb/dotfiles/master/installer.sh

### SETUP ###

# Install Fish & nano
#sudo pacman -S \
#    fish \
#    nano 

# Set Time Zone
#comment "Set correct time zone and set hardware clock accordingly"
#ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
#hwclock --systohc

# Set Locale
#comment "Set default locales and generate locales"
#echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
#echo "nl_NL.UTF-8 UTF-8" >> /etc/locale.gen
#locale-gen

#comment "Set default language to American English"
#echo LANG=en_US.UTF-8 >> /mnt/etc/locale.conf
#comment "Set time format to display as 24:00"
#echo LC_TIME=nl_NL.UTF-8 >> /mnt/etc/locale.conf

# Set hostname
#echo -n "What should this computer be called?"
#read HOSTNAME
#echo "$HOSTNAME" > /etc/hostname

#cp -f ${PWD}/hosts /etc/hosts
#echo -e "\n127.0.1.1\t$HOSTNAME.localdomain\t$HOSTNAME" >> /etc/hosts

# Setup root Password
#comment "Set root password"
#passwd

# Setup User
#comment "Create user and add to relevant group"
#echo -n "What is your username? "
#read USERNAME
#useradd -m -g users -G wheel,audio,video,optical,storage $USERNAME

#comment "Set password of new user"
#passwd $USERNAME

#comment "Enable sudo access for group wheel"
#echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/sudo-for-wheel-group

# Install micro code
# comment "Install micro code"
# microCode

# Install graphics drivers
#comment "Install graphics drivers"
#graphics

### INSTALL GRUB ###
#comment "Install bootloader"
#sudo pacman -S \
#    dosfstools \
#    efibootmgr \
#    grub \
#    mtools \
#    os-prober

#comment "Making boot folder at /boot/EFI"
#mkdir /boot/EFI

#lsblk
#comment "What is your boot partition?"
#read BOOTPART
#mount $PARTITION_BOOT /boot/EFI

#comment "Installing Grub"
#grub-install --target=x86_64-efi  --bootloader-id=grub_uefi --recheck
#grub-mkconfig -o /boot/grub/grub.cfg

comment "Copy dotfiles to new user"
cp -r ${PWD} /home/$USERNAME

#comment "Install networking"
# sudo pacman -S \
#    dialog \
#    wpa_supplicant \
#    dhcpcd \
#    netctl

# Enable services
systemctl enable systemd-resolved.service

### maybe pile ###
# xcape

# Install yay & AUR packages
# packages_aur

# Change Shell after installing yay
arch-chroot /mnt chsh -s "$(which fish)" $USERNAME

echo Done!
