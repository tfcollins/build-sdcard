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
#export ARCH=aarch64
#export CROSS_COMPILE=arm-xilinx-linux-gnueabi-
export CROSS_COMPILE=arm-linux-gnueabihf-
#ZYNQMP export CROSS_COMPILE=aarch64-linux-gnu-

# Target
mkdir $TARGET

# Build hdl
git clone --single-branch -b $HDLBRANCH https://github.com/analogdevicesinc/hdl.git
cd hdl
make --no-print-directory -C projects/fmcomms2/zed
find -iname '*.hdf' -exec cp {} ../$TARGET \;
cd ..
# Check
#exit 1

# Build u-boot
# #git clone https://github.com/analogdevicesinc/u-boot-xlnx.git
git clone https://github.com/Xilinx/u-boot-xlnx.git
cd u-boot-xlnx
git fetch && git fetch --tags
git checkout xilinx-v$VIVADO
make zynq_zed_defconfig
make -j$THREADS
cp u-boot ../$TARGET/u-boot.elf
cd ..
#exit 1

# Build linux
git clone --single-branch -b $LINUXBRANCH https://github.com/analogdevicesinc/linux.git
cd linux
make zynq_xcomm_adv7511_defconfig
make -j$THREADS UIMAGE_LOADADDR=0x8000 uImage
#make zynq-zed-adv7511-ad9361-fmcomms2-3 
make zynq-zed-adv7511-ad9361-fmcomms2-3.dtb
#make zynq-zed-adv7511-ad9361.dtb
cp arch/arm/boot/uImage ../SDCARD/uImage
cp arch/arm/boot/dts/zynq-zed-adv7511-ad9361-fmcomms2-3.dts  ../SDCARD/devicetree.dtb
cd ..
#exit 1

# Build BOOT.BIN
cd SDCARD
wget https://raw.githubusercontent.com/analogdevicesinc/wiki-scripts/master/zynq_boot_bin/build_boot_bin.sh
chmod +x build_boot_bin.sh
./build_boot_bin.sh system_top.hdf u-boot.elf
