#!/bin/bash

# Set variables
OUTPUT_TARGET=$1
VIVADO=$2
ARCH=$3
CROSS_COMPILE=$4
THREADS=2
#$(nproc)

# Config
source /opt/Xilinx/Vivado/$VIVADO/settings64.sh
export ARCH=$ARCH
export CROSS_COMPILE=$CROSS_COMPILE

# Get ref
cp -r linux_ref "linux_$ARCH"
# Build linux
cd "linux_$ARCH"
make zynq_xcomm_adv7511_defconfig
make -j$THREADS UIMAGE_LOADADDR=0x8000 uImage
cd ..
cp "linux_$ARCH/arch/arm/boot/uImage" "$OUTPUT_TARGET/uImage"

# Check
echo "Checking Linux build output"
if [ ! -f $OUTPUT_TARGET/uImage ]; then
	echo "Linux build failed"
	exit 1
fi

# Cleanup
#echo "Cleaning up"
#rm -rf "linux_$DEVICETREE"
exit 0
