#!/bin/bash
/debootstrap/debootstrap --second-stage
# chroot $CHROOT /debootstrap/debootstrap --second-stage

export distro=stretch
export LANG=C

cat <<EOT > /etc/apt/sources.list
deb http://ftp.jp.debian.org/debian $distro main contrib non-free
deb-src http://ftp.jp.debian.org/debian $distro main contrib non-free
deb http://ftp.debian.org/debian $distro-updates main contrib non-free
deb-src http://ftp.debian.org/debian $distro-updates main contrib non-free
deb http://security.debian.org/debian-security $distro/updates main contrib non-free
deb-src http://security.debian.org/debian-security $distro/updates main contrib non-free
EOT

cat << EOT > /etc/apt/apt.conf.d/71-no-recommends
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOT

apt-get install -y --force-yes debian-archive-keyring
apt-key update
apt-get update
apt-get install -y locales dialog
#dpkg-reconfigure locales
apt-get install -y openssh-server ntpdate resolvconf sudo less hwinfo ntp vim
apt-get install -y git wget curl
apt-get install -y build-essential device-tree-compiler
apt-get install -y screen bash-completion time
apt-get install -y python python-pip python3 python3-pip
apt-get install -y nfs-common samba distcc

exit
