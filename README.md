__minimal linux with buildroot__

> __NOTE:__  work in progress

1) download __buildroot__ to `./buildroot` directory
2) copy `defconfig` file to `./buildroot/.config`
3) ```$ cd buildroot && make``` to build buildroot
4) use `build-img.sh` and to build disk image from build root images
and `run.sh` to test the disk image with __qemu__
