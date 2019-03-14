#!/bin/bash

# Usage
#   build-hdl.sh <hdl branch> <SDCARD build output directory> <fmc card> <fpga board>
#   build-hdl.sh <hdl branch> <SDCARD build output directory> <som/singleton device>

# Example
#   ./build-hdl.sh hdl_2018_r1 SDCARD fmcomms2 zed
#   ./build-hdl.sh hdl_2018_r1 SDCARD pluto

# Set variables
HDLBRANCH=$1
OUTPUT_TARGET=$2
VIVADO=$3
ARCH=$4
CROSS_COMPILE=$5
DEVICE=$6
if [ ! -z "$7" ]
then
  BOARD=$7
fi

# Config
source /opt/Xilinx/Vivado/$VIVADO/settings64.sh
export ARCH=$ARCH
export CROSS_COMPILE=$CROSS_COMPILE

# Get ref
cp -r hdl_ref "hdl_$DEVICE"
# Build HDL
cd "hdl_$DEVICE"
echo "Building HDL"
if [ ! -z "$BOARD" ]
then
  make --no-print-directory -C projects/$DEVICE/$BOARD
else
  make --no-print-directory -C projects/$DEVICE
fi
find -iname '*.hdf' -exec cp {} ../$OUTPUT_TARGET \;
cd ..
# Check
echo "Checking HDL build output"
if [ ! -f $OUTPUT_TARGET/system_top.hdf ]; then
    echo "HDL build failed"
    exit 1
fi
# Cleanup
echo "Cleaning up"
rm -rf "hdl_$DEVICE"
exit 0
