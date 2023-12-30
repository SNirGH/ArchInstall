#!/bin/bash

# Format partitions
echo "Formatting Partitions"
sgdisk -Z /dev/sda
sgdisk -a 2048 -o /dev/sda
sgdisk -n 1::+1024M --typecode=1:ef00 --change-name=1:'boot' /dev/sda
sgdisk -n 2::+8G --typecode=2:8200 --change-name=2:'swap' /dev/sda
sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'root' /dev/sda
partprobe /dev/sda
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.btrfs /dev/sda3
echo "Completed Formatting"

# Mounting Partitions
echo "Mounting Partitions"
mount /dev/sda3 /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home

cd /
umount /mnt
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@ /dev/sda3 /mnt
mkdir /mnt/home
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@home /dev/sda3 /mnt/home
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
echo "Finished Mounting"

# Rankmirrors
echo "Ranking Mirrors"
reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
echo "Finished Ranking Mirrors"

# Pacstrap
echo "Starting Pacstrap"
pacstrap -i /mnt base base-devel linux-zen linux-zen-headers linux-firmware intel-ucode nano bash-completion networkmanager firefox neovim plasma plasma-wayland-session sddm xorg-server xorg-apps xorg-xinit xorg-twm xorg-xclock xterm kitty okular dolphin gwenview btop fish starship kate
echo "Finished Pacstrap"

# Genfstab
echo "Generating fstab"
genfstab -U /mnt >>/mnt/etc/fstab
echo "Finished Generating fstab"

# Arch-Chroot into /mnt
arch-chroot /mnt
