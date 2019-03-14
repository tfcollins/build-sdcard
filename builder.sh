#!/bin/bash

# Build SD Card
HDLBRANCH='hdl_2018_r1'
LINUXBRANCH='2018_R1'
VIVADO='2017.4'
#THREADS=$(nproc)
THREADS=4
TARGET='SDCARD'

# Config
source /opt/Xilinx/Vivado/$VIVADO/settings64.sh
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

# Init target
mkdir $TARGET

# Get source
source get_sources.sh

# Build HDL
source build-hdl.sh hdl_2018_r1 SDCARD pluto
