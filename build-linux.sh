#!/bin/bash

# Set variables
OUTPUT_TARGET=$1
VIVADO=$2
ARCH=$3
CROSS_COMPILE=$4
DEVICETREE=$5

# Config
source /opt/Xilinx/Vivado/$VIVADO/settings64.sh
export ARCH=$ARCH
export CROSS_COMPILE=$CROSS_COMPILE

# Get ref
cp -r linux_ref "linux_$DEVICETREE"
# Build linux
cd "linux_$DEVICETREE"
make zynq_xcomm_adv7511_defconfig
make UIMAGE_LOADADDR=0x8000 uImage
#make zynq-zed-adv7511-ad9361-fmcomms2-3
make "$DEVICETREE.dtb"
#make zynq-zed-adv7511-ad9361.dtb
cp arch/arm/boot/uImage "$OUTPUT_TARGET/uImage"
cp "arch/arm/boot/dts/$DEVICETREE.dts"  "$OUTPUT_TARGET/devicetree.dtb"
cd ..

# Check
echo "Checking Linux build output"
if [ ! -f $OUTPUT_TARGET/uImage ]; then
	echo "Linux build failed"
	exit 1
fi
if [ ! -f $OUTPUT_TARGET/devicetree.dtb ]; then
	echo "Linux build failed"
	exit 1
fi

# Cleanup
echo "Cleaning up"
rm -rf "linux_$DEVICETREE"
exit 0
