#!/bin/sh

qemu-system-x86_64 \
  -kernel ./bzImage \
  -initrd ./rootfs.cpio \
  -nographic \
  -append "console=ttyS0" \
  #--enable-kvm
