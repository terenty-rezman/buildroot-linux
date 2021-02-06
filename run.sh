#!/bin/sh

IMAGE_DIR=./buildroot/output/images

qemu-system-x86_64 \
  -kernel ${IMAGE_DIR}/bzImage \
  -initrd ${IMAGE_DIR}/rootfs.cpio \
  -nographic \
  -append "console=ttyS0" \
  #--enable-kvm
