#!/bin/bash

lol() {
	echo $1
}

DEVICE_SATA="false"
DEVICE_NVME="false"
DEVICE_MMC="false"
DEVICE="drive"

PS3=$'\n'"What kind of drive will you be installing Arch to?"$'\n'$'\n'

echo -e "\n"

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
       	PARTITION_BOOT="${DEVICE}1"
        PARTITION_SWAP="${DEVICE}2"
        DEVICE_ROOT="${DEVICE}3"
fi

if [ "$DEVICE_NVME" == "true" ]; then
        PARTITION_BOOT="${DEVICE}p1"
        PARTITION_SWAP="${DEVICE}p2"
        DEVICE_ROOT="${DEVICE}p3"
fi

if [ "$DEVICE_MMC" == "true" ]; then
        PARTITION_BOOT="${DEVICE}p1"
        PARTITION_SWAP="${DEVICE}p2"
        DEVICE_ROOT="${DEVICE}p3"
fi

lol plzwork

echo -e 
echo $PARTITION_BOOT
echo $PARTITION_SWAP
echo $DEVICE_ROOT
