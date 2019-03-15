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
export SWT_GTK3=0

# Build BOOT.BIN
cd "$OUTPUT_TARGET"
wget https://raw.githubusercontent.com/analogdevicesinc/wiki-scripts/master/zynq_boot_bin/build_boot_bin.sh
sed -i 's/xsdk/xvfb-run xsdk/g' build_boot_bin.sh
chmod +x build_boot_bin.sh
./build_boot_bin.sh system_top.hdf u-boot.elf
cp output_boot_bin/BOOT.BIN .

# Cleanup
rm build_boot_bin.sh
rm -rf output_boot_bin
rm -rf build_boot_bin
