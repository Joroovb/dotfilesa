#!/bin/bash

comment() {
    echo ">> $(tput setaf 2) $@$(tput sgr0)" >&2
}

fail() {
    echo "$(tput bold; tput setaf 5)$@$(tput sgr0)" >&2
}

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

# echo -e "\n"

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
mkfs.ext4 $PARTITION_ROOT

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


echo "First Test Done"