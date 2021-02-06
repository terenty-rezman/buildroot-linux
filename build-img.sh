#!/usr/bin/env bash

# creates bootable disk image as file (e.g. linux.img)
# places kernel image and initrd image on this disk 
# and uses grub install to make it bootable
# then you can test it with smthng like 'qemu-system-x86_64 linux.img'
# or you can write it to usb flash drive with smthing like 'dd if=/linux.img of=/dev/sdb' to make usb flash bootable

echo

set -e # terminate script on error

# img size in mb
IMG_SIZE=30
OUTPUT_IMG_NAME=linux.img
IMAGE_DIR=./buildroot/output/images
KERNEL_IMG=$IMAGE_DIR/bzImage
INITRD_IMG=$IMAGE_DIR/rootfs.cpio

# create zeroed file
dd if=/dev/zero of="$OUTPUT_IMG_NAME" bs=1024k count=$IMG_SIZE
echo

# now map out file on pseudo device to work with it as if it was a hdd
# also store the device name into variable
# need sudo for losetup
echo need sudo for 'losetup':
PSEUDO_HDD=$(sudo losetup --find --show "$OUTPUT_IMG_NAME")
echo device created: $PSEUDO_HDD
echo

# create label (msdos) and partition on our pseudo hdd aka file 
# need sudo for parted
sudo parted -a optimal $PSEUDO_HDD --script -- mklabel msdos > /dev/null
sudo parted -a optimal $PSEUDO_HDD --script -- mkpart primary 1 100% > /dev/null
# print disk info
sudo parted $PSEUDO_HDD --script -- p

# create ext4 filesystem on new partition
# below naming trick might fail ?
PART_DEVICE=${PSEUDO_HDD}p1

sudo mkfs.ext4 $PART_DEVICE

# mount partition to mnt directory
mkdir -p ./mnt
sudo mount $PART_DEVICE ./mnt

# create boot dir and copy kernel and initrd imgs
sudo mkdir -p ./mnt/boot
sudo cp $KERNEL_IMG ./mnt/boot/vmlinuz
sudo cp $INITRD_IMG ./mnt/boot/initrd.img

# install grub to pseudo hdd with root directory set to out partition
sudo grub-install --root-directory=$(pwd)/mnt $PSEUDO_HDD 

# create basic grub.cfg
sudo tee ./mnt/boot/grub/grub.cfg > /dev/null << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod ext2
set root=(hd0,msdos1)

insmod vbe
insmod vga
insmod gfxterm

loadfont /boot/grub/fonts/unicode.pf2
set gfxmode=auto
set gfxpayload=keep
terminal_output gfxterm

menuentry "linux" {
        linux  /boot/vmlinuz logo.nologo
        initrd /boot/initrd.img        
}
EOF
# unmount pseudo hdd
sudo umount ./mnt

# unmap pseudo hdd
sudo losetup -d $PSEUDO_HDD &&  echo device unmaped: $PSEUDO_HDD

# now you can test the image with qemu with smthing like 'qemu-system-X86_64 linux.img'
# or you can write it to usb flash drive with smthing like 'dd if=/linux.img of=/dev/sdb' to make usb flash bootable
# all your usb flash drive data will be lost !!
