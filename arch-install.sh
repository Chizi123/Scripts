#!/bin/bash

HOSTNAME=VM
RPASS=root

# Partition disk
(
echo n # Add a new partition
echo p # Primary partition
echo 1 # Partition number
echo   # First sector (Accept default: 1)
echo   # Last sector (Accept default: varies)
echo w # Write changes
) | sudo fdisk /dev/sda
mkfs.ext4 /dev/sda1

# Mount and install
mount /dev/sda1 /mnt
pacstrap base linux linux-firmware grub dhcpcd vim qemu-guest-agent
genfstab -U /mnt >> /mnt/etc/fstab

# Setup system in chroot
arch-chroot /mnt "ln -sf /usr/share/zoneinfo/UTC /etc/localtime;
				  echo en_US.UTF-8 >> /etc/locale.gen;
				  locale-gen;
				  echo LANG=en_US.UTF-8 > /etc/locale.conf;
				  echo $HOSTNAME > /etc/hostname;
				  printf \"127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t$HOSTNAME.localdomain $HOSTNAME\" > /etc/hostname;
				  systemctl enable dhcpcd qemu-guest-agent;
				  mkinitcpio -P;
				  echo root:$RPASS | chpasswd;
				  grub-install /dev/sda;
				  grub-mkconfig -o /boot/grub/grub.cfg"

reboot
