#!/bin/bash

comment() {
    echo ">> $(tput setaf 2) $@$(tput sgr0)" >&2
}

fail() {
    echo "$(tput bold; tput setaf 5)$@$(tput sgr0)" >&2
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
    arch-chroot /mnt bash -c "echo -e \"$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n\" | su $USERNAME -c \"cd /home/$USERNAME && git clone https://aur.archlinux.org/yay.git && (cd yay && makepkg -si --noconfirm) && rm -rf yay\""
    aur_install "autotiling bitwarden-cli lf ncspot networkmanager-dmenu nerd-fonts-fira-code picom-ibhagwan-git pistol-git polybar fortune-mod-calvin"
    arch-chroot /mnt sed -i 's/%wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
}

aur_install() {
    AUR_COMMAND="yay -Syu --noconfirm --needed $1"
    arch-chroot /mnt bash -c "echo -e \"$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n\" | su $USER_NAME -c \"$AUR_COMMAND\""
}

PACKS="fish nano git dosfstools efibootmgr grub mtools os-prober dialog wpa_supplicant dhcpcd netctl dialog wpa_supplicant dhcpcd netctl"

# CONFIG
comment "What is your username? "
read USERNAME

comment "Set password of new user"
read -s PASSWORD

comment "Set root password"
read -s ROOT_PASSWORD

comment "What should this computer be called?"
read HOSTNAME

microCode

graphics

PACKAGES_PACMAN="$PACKS $GRAPHICSPACKS $CPUPACK"

# Set clock
timedatectl set-ntp true

# Prepare disk for Installation
lsblk
comment "Where do you want to install Arch?"
read DISK
DISKPATH="/dev/$DISK"

echo "We will install on $(tput bold; tput setaf 1)$DISK$(tput sgr0)! This is the last moment to press Ctrl+C."
echo -n "Enter to continue..."
read

comment "Create partitions for EFI and system"
# o y: Create a new empty GUID partition table (GPT) and confirm
# n 1 '' $EFI_PARTITION_SIZE ef00: create new partition with id 1, at the beginning, size $EFI_PARTITION_SIZE, and type ef00 (EFI System)
# n 2 '' '' 8300: create new partition with id2, after 1, size rest of the disk, and type 8300 (Linux filesystem)
# w y: Write table to disk and exit
if ! echo 'o
y
n
1

+550M
ef00
n
2

+8G
8200
n
3


8300
w
y' | gdisk "$DISKPATH"
then
    fail "Cannot setup device partitions"
    exit 1
fi

DEVICE_SATA="false"
DEVICE_NVME="false"
DEVICE_MMC="false"

PS3=$'\n'"What kind of drive is your install target?"$'\n'$'\n'

echo -e

drives=("HHD" "NVME" "MMC")
select driveOpt in "${drives[@]}"
do
	case $driveOpt in
		"HHD")
			DEVICE_SATA="true"
			break
			;;
		"NVME")
			DEVICE_NVME="true"
			break
			;;
		"MMC")
			DEVICE_MMC="true"
			break
			;;
		*) echo "Invalid input";;
	esac
done

if [ "$DEVICE_SATA" == "true" ]; then
       	PARTITION_BOOT="${DISKPATH}1"
        PARTITION_SWAP="${DISKPATH}2"
        DEVICE_ROOT="${DISKPATH}3"
fi

if [ "$DEVICE_NVME" == "true" ]; then
        PARTITION_BOOT="${DISKPATH}p1"
        PARTITION_SWAP="${DISKPATH}p2"
        DEVICE_ROOT="${DISKPATH}p3"
fi

if [ "$DEVICE_MMC" == "true" ]; then
        PARTITION_BOOT="${DISKPATH}p1"
        PARTITION_SWAP="${DISKPATH}p2"
        DEVICE_ROOT="${DISKPATH}p3"
fi

# Format Partitions
comment "Formatting partitions"
mkfs.fat -F32 $PARTITION_BOOT
mkswap $PARTITION_SWAP
swapon $PARTITION_SWAP
mkfs.ext4 $DEVICE_ROOT -F

# Mount the root partition
comment "Mounting root partitions"
mount $DEVICE_ROOT /mnt

# Select mirrors
comment "Install reflector tool and rate best download mirrors"
pacman -Sy --noconfirm reflector
reflector --country Netherlands --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Enable Pacman features
sed -i 's/#Color/Color/' /etc/pacman.conf
sed -i 's/#TotalDownload/TotalDownload/' /etc/pacman.conf

# Install base system
comment "Installing base system"
pacstrap /mnt base base-devel linux linux-headers linux-firmware

# Generate fstab
comment "Generate /etc/fstab"
genfstab -U /mnt >> /mnt/etc/fstab

# Enable 32-bits packages
echo "" >> /mnt/etc/pacman.conf
echo "[multilib]" >> /mnt/etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" >> /mnt/etc/pacman.conf
echo "" >> /mnt/etc/pacman.conf

# Set Time Zone
comment "Set correct time zone and set hardware clock accordingly"
arch-chroot /mnt ln -s -f /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
arch-chroot /mnt hwclock --systohc

# Set Locale
comment "Set default locales and generate locales"
echo "en_US.UTF-8 UTF-8" >> /mnt/etc/locale.gen
echo "nl_NL.UTF-8 UTF-8" >> /mnt/etc/locale.gen
arch-chroot /mnt locale-gen

comment "Set default language to American English"
echo LANG=en_US.UTF-8 >> /mnt/etc/locale.conf
comment "Set time format to display as 24:00"
echo LC_TIME=nl_NL.UTF-8 >> /mnt/etc/locale.conf

# Set hostname
echo "$HOSTNAME" > /mnt/etc/hostname

# GOTTA FIX THIS
# cp -f ${PWD}/hosts /etc/hosts
# echo -e "\n127.0.1.1\t$HOSTNAME.localdomain\t$HOSTNAME" >> /etc/hosts

# Setup root Password
#arch-chroot /mnt passwd
printf "$ROOT_PASSWORD\n$ROOT_PASSWORD" | arch-chroot /mnt passwd

# Setup User
comment "Create user and add to relevant group"
arch-chroot /mnt useradd -m -g users -G wheel,audio,video,optical,storage $USERNAME

comment "Set password of new user"
# arch-chroot /mnt passwd $USERNAME
printf "$PASSWORD\n$PASSWORD" | arch-chroot /mnt passwd $USERNAME

comment "Enable sudo access for group wheel"
echo "%wheel ALL=(ALL) ALL" > /mnt/etc/sudoers.d/sudo-for-wheel-group

# Install packages
# MAKE PACKS LIST AND FEED INTO PACMAN
comment "Installing packages"
arch-chroot /mnt pacman -Syu --noconfirm --needed $PACKAGES_PACMAN

comment "Making boot folder at /boot/EFI"
mkdir /mnt/boot/EFI

comment "Mounting boot partition"
mount $PARTITION_BOOT /mnt/boot/EFI

comment "Installing Grub"
arch-chroot /mnt grub-install --target=x86_64-efi  --bootloader-id=grub_uefi --recheck
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

comment "Installing yay & packages"
# packages_aur
# Installing yay doesn't work

echo "First Test Done" 