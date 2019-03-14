#!/bin/bash

# Set variables
DEFCONFIG=$1
OUTPUT_TARGET=$2
VIVADO=$3
ARCH=$4
CROSS_COMPILE=$5
DEVICE=$6

# Config
source /opt/Xilinx/Vivado/$VIVADO/settings64.sh
export ARCH=$ARCH
export CROSS_COMPILE=$CROSS_COMPILE

# Get ref
cp -r u-boot-xlnx_ref "u-boot-xlnx_$DEVICE"
# Build u-boot
cd "u-boot-xlnx_$DEVICE"
echo "Building u-boot"
git fetch && git fetch --tags
git checkout xilinx-v$VIVADO
make $DEFCONFIG
make
# Check
if [ ! -f "u-boot" ]; then
    echo "u-boot build failed"
    exit 1
fi
cp u-boot ../$OUTPUT_TARGET/u-boot.elf
cd ..
# Cleanup
echo "Cleaning up"
rm -rf "u-boot-xlnx_$DEVICE"
exit 0
