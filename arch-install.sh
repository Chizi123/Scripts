#!/bin/bash
# Basic install script for an archlinux VM
# To use as a basic hardware install script, remove qemu-guest-agent from pacstrap's arguments and qemu-ga from systemctl
# Can comment out my repository if you like, I tend to use it for my VMs

HOSTNAME=VM
RPASS=root
DISK=/dev/vda
PARTNO=1
LOCALE=en_US.UTF-8
TIMEZONE=UTC # location in zoneinfo, e.g. Australia/Melbourne

# Partition disk will create a new partition on the rest of the empty free space
printf "n\np\n\n\n\nw\n" | fdisk $DISK
mkfs.btrfs "$DISK$PARTNO"

# Mount and install
mount -o compress=zstd "$DISK$PARTNO" /mnt
pacstrap /mnt base linux linux-firmware grub dhcpcd vim qemu-guest-agent btrfs-progs
genfstab -U /mnt >> /mnt/etc/fstab

# Setup locale
arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
sed -i -e "s/#$LOCALE/$LOCALE/" /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=$LOCALE" > /mnt/etc/locale.conf

# Set hostname and make hosts file
echo $HOSTNAME > /mnt/etc/hostname
printf "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t$HOSTNAME.localdomain $HOSTNAME" > /mnt/etc/hosts

# Enable networking on boot and qemu guest agent
arch-chroot /mnt systemctl enable dhcpcd qemu-ga

# Make boot files and setup grub
arch-chroot /mnt mkinitcpio -P
arch-chroot /mnt sh -c "echo root:$RPASS | chpasswd"
sed -i "s/GRUB_TIMEOUT=\d*/GRUB_TIMEOUT=\"0\"/" /mnt/etc/default/grub
arch-chroot /mnt grub-install $DISK
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Add my repo to pacman.conf
printf "[Chizi123]\nSigLevel = Optional TrustAll\nServer = https://repo.joelg.cf/x86_64\n" >> /mnt/etc/pacman.conf

reboot
