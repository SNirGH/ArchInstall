#!/usr/bin/env bash

DISK="/dev/sda"

# Setup Partitions
mkfs.fat -F32 ${DISK}1
mkswap ${DISK}2
swapon ${DISK}2
mkfs.btrfs ${DISK}3

mount ${DISK}3 /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home

cd /
umount /mnt
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@ ${DISK}3 /mnt
mkdir /mnt/home
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@home ${DISK}3 /mnt/home
mkdir -p /mnt/boot/efi
mount ${DISK}2 /mnt/boot/efi

# Update pacman
pacman -Sy --noconfirm

# Mirrorlist
reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
cp /etc/pacman./mirrorlist /etc/pacman.d/mirrorlist.backup

# Install base system
pacstrap -i /mnt base base-devel linux-zen linux-firmware intel-ucode nano bash-completion linux-zen-headers networkmanager
2
genfstab -U /mnt >>/mnt/etc/fstab
arch-chroot /mnt
