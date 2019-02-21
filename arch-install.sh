#!/bin/bash

set -ex

# Update the system clock 
# https://wiki.archlinux.org/index.php/Installation_guide#Update_the_system_clock
timedatectl set-ntp true

# Partition the disks
# https://wiki.archlinux.org/index.php/Installation_guide#Partition_the_disks
DISK_DEVICE="/dev/sda"
declare -i DISK_SIZE=`blockdev --getsz "$DISK_DEVICE"`
declare -i ROOT_SIZE=$((DISK_SIZE / 4))
declare -i ROOT_SIZE_IN_MIB=$((ROOT_SIZE / 2048))
declare -i MEM_SIZE_IN_KIB=`grep MemTotal /proc/meminfo | awk '{ print $2 }'`
declare -i MEM_SIZE_IN_MIB=$((MEM_SIZE_IN_KIB / 1024))
declare -i SWAP_SIZE_IN_MIB=$((MEM_SIZE_IN_MIB + 512))

declare -i EFI_SIZE_IN_MIB=512
declare -i ROOT_END_IN_MIB=$((ROOT_SIZE_IN_MIB + EFI_SIZE_IN_MIB))
declare -i SWAP_END_IN_MIB=$((ROOT_END_IN_MIB + SWAP_SIZE_IN_MIB))

if [[ -d /sys/firmware/efi/efivars ]]; then
  parted -s -a optimal "$DISK_DEVICE" mklabel gpt
  parted -s -a optimal "$DISK_DEVICE" mkpart fat32 "0%" "${EFI_SIZE_IN_MIB}MiB"
  parted -s -a optimal "$DISK_DEVICE" name 1 boot
  parted -s -a optimal "$DISK_DEVICE" set 1 boot on
  parted -s -a optimal "$DISK_DEVICE" set 1 esp on
  parted -s -a optimal "$DISK_DEVICE" mkpart xfs "${EFI_SIZE_IN_MIB}MiB" "${ROOT_END_IN_MIB}MiB"
  parted -s -a optimal "$DISK_DEVICE" name 2 root
  parted -s -a optimal "$DISK_DEVICE" mkpart linux-swap "${ROOT_END_IN_MIB}MiB" "${SWAP_END_IN_MIB}MiB"
  parted -s -a optimal "$DISK_DEVICE" name 3 swap
  parted -s -a optimal "$DISK_DEVICE" mkpart xfs "${SWAP_END_IN_MIB}MiB" "100%"
  parted -s -a optimal "$DISK_DEVICE" name 4 home

  # Format the partitions
  # https://wiki.archlinux.org/index.php/Installation_guide#Format_the_partitions

  # Format EFI
  # https://wiki.archlinux.org/index.php/EFI_system_partition#Format_the_partition
  mkfs.fat -F32 /dev/sda1

  # Format root
  mkfs.xfs -f -L root /dev/sda2

  # Format and activate swap
  mkswap -L swap /dev/sda3
  sleep 1
  swapon /dev/disk/by-label/swap

  # Format home
  mkfs.xfs -f -L home /dev/sda4
else
  parted -s -a optimal "$DISK_DEVICE" mklabel gpt
  parted -s -a optimal "$DISK_DEVICE" mkpart primary "0%" "2MiB"
  parted -s -a optimal "$DISK_DEVICE" name 1 bios
  parted -s -a optimal "$DISK_DEVICE" set 1 boot on
  parted -s -a optimal "$DISK_DEVICE" set 1 bios_grub on
  parted -s -a optimal "$DISK_DEVICE" mkpart ext2 "2MiB" "${EFI_SIZE_IN_MIB}MiB"
  parted -s -a optimal "$DISK_DEVICE" name 2 boot
  parted -s -a optimal "$DISK_DEVICE" mkpart xfs "${EFI_SIZE_IN_MIB}MiB" "${ROOT_END_IN_MIB}MiB"
  parted -s -a optimal "$DISK_DEVICE" name 3 root
  parted -s -a optimal "$DISK_DEVICE" mkpart linux-swap "${ROOT_END_IN_MIB}MiB" "${SWAP_END_IN_MIB}MiB"
  parted -s -a optimal "$DISK_DEVICE" name 4 swap
  parted -s -a optimal "$DISK_DEVICE" mkpart xfs "${SWAP_END_IN_MIB}MiB" "100%"
  parted -s -a optimal "$DISK_DEVICE" name 5 home

  # Format the partitions
  # https://wiki.archlinux.org/index.php/Installation_guide#Format_the_partitions

  # Format boot
  # https://wiki.archlinux.org/index.php/EFI_system_partition#Format_the_partition
  mkfs.ext2 -L boot /dev/sda2

  # Format root
  mkfs.xfs -f -L root /dev/sda3

  # Format and activate swap
  mkswap -L swap /dev/sda4
  sleep 1
  swapon /dev/disk/by-label/swap

  # Format home
  mkfs.xfs -f -L home /dev/sda5
fi

# Mount the file systems
# https://wiki.archlinux.org/index.php/Installation_guide#Mount_the_file_systems
mount /dev/disk/by-label/root /mnt
mkdir -p /mnt/{boot,home}
mount /dev/disk/by-partlabel/boot /mnt/boot
mount /dev/disk/by-label/home /mnt/home

# Install the base packages
# https://wiki.archlinux.org/index.php/Installation_guide#Install_the_base_packages
pacstrap /mnt base base-devel git ansible efibootmgr

# Fstab
# https://wiki.archlinux.org/index.php/Installation_guide#Fstab
genfstab -L /mnt >> /mnt/etc/fstab

# Copy post-chroot script
cp arch-install-inchroot.sh /mnt/root/

# Chroot
# https://wiki.archlinux.org/index.php/Installation_guide#Chroot
NEWHOSTNAME="${NEWHOSTNAME:-archlinux}" arch-chroot /mnt /root/arch-install-inchroot.sh
