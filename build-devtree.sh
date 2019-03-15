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
cp -r linux_ref "linux_$ARCH"
# Build linux
cd "linux_$ARCH"
make "$DEVICETREE.dtb"
cd ..
cp "linux_$DEVICETREE/arch/arm/boot/dts/$DEVICETREE.dts"  "$OUTPUT_TARGET/devicetree.dtb"

# Check
echo "Checking Devicetree build output"
if [ ! -f $OUTPUT_TARGET/devicetree.dtb ]; then
	echo "Devicetree build failed"
	exit 1
fi

# Cleanup
#echo "Cleaning up"
#rm -rf "linux_$DEVICETREE"
exit 0
