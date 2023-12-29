#!/usr/bin/env bash

# Setup locale and localtime
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 >/etc/locale.conf
export LANG=en_US.UTF-8
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc --utc

# Set up root and user
echo primordial >/etc/hostname
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm --needed

# Root
read root_pass
passwd
$root_pass
$root_pass

# Add user
useradd -m -g users -G wheel,storage,power -s /bin/bash zero
read user_pass
passwd zero
$user_pass
$user_pass

# Sudoers permissions
sed -i "/\%wheel ALL=\(ALL\) ALL/"'s/^#//' /etc/sudoers
echo "Defaults roopw" >>/etc/sudoers

# Mount EFI
mount -t efivarfs efivarfs /sys/firmware/efi/efivars

# GRUB Install
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Arch Linux"

# Booster Setup
echo "compress: zstd" >>/etc/booster.yaml
echo "modules: btrfs" >>/etc/booster.yaml
/usr/lib/booster/regenerate_images
grub-mkconfig -o /boot/grub/grub.cfg

# Enable Network Manager
systemctl enable NetworkManager.service

# Finish
echo "FINISHED"
exit
umount -R /mnt
reboot
