#!/bin/bash
# sudo su root
#apt-get install qemu-user-static debootstrap binfmt-support

DISTRO=stretch
ROOT=/tmp/userland
CHROOT=$ROOT/rootfs

mkdir $ROOT
mkdir $CHROOT

debootstrap --no-check-gpg --foreign --variant minbase --arch=armhf $DISTRO $CHROOT http://archive.raspbian.org/raspbian
cp /usr/bin/qemu-arm-static $CHROOT/usr/bin

cp chroot.sh $CHROOT/
# chroot $CHROOT /debootstrap/debootstrap --second-stage
chroot $CHROOT ./chroot.sh
#sudo rm -f $CHROOT/usr/bin/qemu-arm-static
