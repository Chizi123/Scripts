#!/bin/bash

HOSTNAME=VM
RPASS=root
DISK=/dev/vda
PARTNO=1
LOCALE=en_US.UTF-8

# Partition disk
(
echo n # Add a new partition
echo p # Primary partition
echo   # Partition number
echo   # First sector (Accept default: 1)
echo   # Last sector (Accept default: varies)
echo w # Write changes
) | sudo fdisk $DISK
mkfs.ext4 "$DISK$PARTNO"

# Mount and install
mount "$DISK$PARTNO" /mnt
pacstrap /mnt base linux linux-firmware grub dhcpcd vim qemu-guest-agent
genfstab -U /mnt >> /mnt/etc/fstab

# Setup locale
arch-chroot /mnt ln -sf /usr/share/zoneinfo/UTC /etc/localtime
sed -i -e "s/#$LOCALE/$LOCALE/" /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=$LOCALE" > /mnt/etc/locale.conf
echo $HOSTNAME > /mnt/etc/hostname
printf "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t$HOSTNAME.localdomain $HOSTNAME" > /mnt/etc/hosts
arch-chroot /mnt systemctl enable dhcpcd qemu-ga
arch-chroot /mnt mkinitcpio -P
arch-chroot /mnt sh -c "echo root:$RPASS | chpasswd"
arch-chroot /mnt grub-install $DISK
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

reboot
