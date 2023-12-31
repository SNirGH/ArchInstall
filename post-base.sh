#!/usr/bin/env bash

# Setting Up Locales
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 >/etc/locale.conf
export LANG=en_US.UTF-8

# Setting Timezone
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc --utc

# Hostname
echo "Setting Hostname: "
read hostname
echo ${hostname} >/etc/hostname
echo "Finished Setting Hostname"

# Enabling multilib
echo "Enabling Multilib and ParallelDownloads"
sed -i 's/^#Color/Color/;s/^#ParallelDownloads/ParallelDownloads/;/ParallelDownloads/a ILoveCandy' /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy
echo "Finished Enabling"

# Setting Root and User Password
echo "Enter Root Password:"
passwd
useradd -m -g users -G wheel,storage,power -s /bin/bash zero
echo "Created User"
echo "Enter User Password"
passwd zero

# Wheel group and using root password as default
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
echo "Defaults rootpw" >>/etc/sudoers

# Mounting EFI
mount -t efivarfs efivarfs /sys/firmware/efi/efivars

# Bootloader install
bootctl install

cat <<EOT >>/boot/loader/entries/booster.conf
title Arch Linux
linux /vmlinuz-linux-zen
initrd /intel-ucode.img
initrd /booster-linux-zen.img
EOT
echo "options root=UUID=$(blkid -s UUID -o value /dev/sda3) rootflags=subvol=@ rw" >>/boot/loader/entries/booster.conf

cat <<EOT >>/etc/booster.yaml
compress: zstd
modules: btrfs
EOT
/usr/lib/booster/regenerate_images

systemctl enable NetworkManager.service
systemctl enable sddm.service

sed -i '/Current=/ s/&/breeze/' /usr/lib/sddm/sddm.conf.d/default.conf

exit
