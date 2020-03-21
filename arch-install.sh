#!/bin/bash

HOSTNAME=VM
RPASS=root
DISK=/dev/vda
PARTNO=1
LOCALE=en_US.UTF-8

# Partition disk
printf "n\np\n\n\n\nw\n" | fdisk $DISK
#(
#echo n # Add a new partition
#echo p # Primary partition
#echo   # Partition number
#echo   # First sector (Accept default: 1)
#echo   # Last sector (Accept default: varies)
#echo w # Write changes
#) | fdisk $DISK
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

# Set hostname and make hosts file
echo $HOSTNAME > /mnt/etc/hostname
printf "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t$HOSTNAME.localdomain $HOSTNAME" > /mnt/etc/hosts

# Enable networking on boot and qemu guest agent
arch-chroot /mnt systemctl enable dhcpcd qemu-ga

# Make boot files and setup grub
arch-chroot /mnt mkinitcpio -P
arch-chroot /mnt sh -c "echo root:$RPASS | chpasswd"
sed "s/GRUB_TIMEOUT=\d*/GRUB_TIMEOUT=\"0\"/" /mnt/etc/default/grub
arch-chroot /mnt grub-install $DISK
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Add my repo to pacman.conf
printf "[Chizi123]\nSigLevel = Optional TrustAll\nServer = https://repo.joelg.cf/x86_64\n" >> /mnt/etc/pacman.conf

reboot
