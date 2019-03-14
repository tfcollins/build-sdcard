#!/bin/bash

# Set variables
OUTPUT_TARGET=$1
VIVADO=$2
ARCH=$3
CROSS_COMPILE=$4

# Config
source /opt/Xilinx/Vivado/$VIVADO/settings64.sh
export ARCH=$ARCH
export CROSS_COMPILE=$CROSS_COMPILE

# Build BOOT.BIN
cd $OUTPUT_TARGET
wget https://raw.githubusercontent.com/analogdevicesinc/wiki-scripts/master/zynq_boot_bin/build_boot_bin.sh
chmod +x build_boot_bin.sh
./build_boot_bin.sh system_top.hdf u-boot.elf
rm build_boot_bin.sh
