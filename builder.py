import os
import subprocess
from multiprocessing.pool import ThreadPool
import threading
import time

def lu(i):
    if 0:
        return "Todo"
    elif 1:
        return "Built"
    else:
        return "Failed"

class BoardConfig:
    def __init__(self,project,fpga,devtree,arch,cc,ubootconfig):
        self.project = project
        self.fpga = fpga
        self.devtree = devtree
        self.arch = arch
        self.cc = cc
        self.ubootconfig = ubootconfig
        # 0 not started | 1 Passed | 2 Failed
        self.LINUX_BUILD = 0
        self.HDL_BUILD = 0
        self.UBOOT_BUILD = 0
        self.BOOTBIN_BUILD = 0

class BootBuilder():
    def __init__(self):
        self.VIVADO = '2017.4'
        self.HDLBRANCH = 'hdl_2018_r1'
        self.LINUXBRANCH = '2018_R1'
        self.Jobs = 2 # Concurrent Tasks
        self.Boards = []
        self.TARGET_DIR = 'SDCARD'

        self.read_board_configs()

    def create_target_dirs(self):
        if not os.path.exists(self.TARGET_DIR):
            os.makedirs(self.TARGET_DIR)
        for board in self.Boards:
            folder = self.TARGET_DIR+"/"+board.devtree
            if not os.path.exists(folder):
                os.makedirs(folder)

    def process_boards(self):
        pool = ThreadPool(processes=self.Jobs)
        results = []
        while(self.Boards):
            time.sleep(1)
            config = self.Boards.pop()
            results.append(pool.apply_async(self.build_hdl, (config,)))

        pool.close()  # Done adding tasks.
        pool.join()  # Wait for all tasks to complete.
        self.Boards = results

    def process_stage_all(self,funcs):
        pool = ThreadPool(processes=self.Jobs)
        results = []
        for f in funcs:
            for config in self.Boards:
            # while(self.Boards):
                time.sleep(1)
                # config = self.Boards.pop()
                results.append(pool.apply_async(f, (config,)))

        pool.close()  # Done adding tasks.
        pool.join()  # Wait for all tasks to complete.

    def process_stage(self,builder):
        pool = ThreadPool(processes=self.Jobs)
        results = []
        for config in self.Boards:
        # while(self.Boards):
            time.sleep(1)
            # config = self.Boards.pop()
            results.append(pool.apply_async(builder, (config,)))

        pool.close()  # Done adding tasks.
        pool.join()  # Wait for all tasks to complete.

    def sys_call(self,cmd):
        print(cmd)
        try:
            #subprocess.check_call(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            subprocess.check_call(cmd, stderr=subprocess.DEVNULL)
            return True
        except subprocess.CalledProcessError:
            print("ERROR")
            pass # handle errors in the called executable
            return False
        except OSError:
            print("ERROR")
            pass # executable not found
            return False


    def read_board_configs(self):
        filepath = 'boards_test.csv'
        with open(filepath) as fp:
           line = fp.readline() # Skip first line
           line = fp.readline()
           while line:
               d = line.split(",")
               line = fp.readline()
               dt = d[0].lower().strip()
               project = d[1].lower().strip()
               fpga = d[2].lower().strip()
               ubootconfig = d[3].lower().strip()

               if dt.split("-")[0] == "zynq":
                   arch = "arm"
                   # 2017.4
                   cc = "arm-linux-gnueabihf-"
               elif dt.split("-")[0] == "zynqmp":
                  arch = "aarch64"
                  cc = "aarch64-linux-gnu-"
               else:
                  continue

               self.Boards.append(BoardConfig(project,fpga,dt,arch,cc,ubootconfig))

    def build_hdl(self,config):
        print("Building hdl %s for %s" % (config.project,config.fpga))
        TG = self.TARGET_DIR+"/"+config.devtree
        cmd = ["./build-hdl.sh",self.HDLBRANCH,TG,self.VIVADO,config.arch,config.cc,config.project,config.fpga]
        if self.sys_call(cmd):
            config.HDL_BUILD = 1
        else:
            config.HDL_BUILD = 2

    def build_uboot(self,config):
        print("Building uboot %s for %s" % (config.project,config.fpga))
        TG = self.TARGET_DIR+"/"+config.devtree
        cmd = ["./build-uboot.sh",config.ubootconfig,TG,self.VIVADO,config.arch,config.cc,config.project]
        if self.sys_call(cmd):
            config.UBOOT_BUILD = 1
        else:
            config.UBOOT_BUILD = 2

    def build_linux_devtree(self,config):
        print("Building linux device tree %s for %s" % (config.project,config.fpga))
        TG = self.TARGET_DIR+"/"+config.devtree
        cmd = ["./build-linux-devtree.sh",self.VIVADO,TG,config.arch,config.cc,config.devtree]
        if self.sys_call(cmd):
            config.LINUX_BUILD = 1
        else:
            config.LINUX_BUILD = 2

    def build_linux(self,config):
        print("Building linux %s for %s" % (config.project,config.fpga))
        TG = self.TARGET_DIR+"/"+config.devtree
        cmd = ["./build-linux.sh",self.VIVADO,TG,config.arch,config.cc,config.devtree]
        if self.sys_call(cmd):
            config.LINUX_BUILD = 1
        else:
            config.LINUX_BUILD = 2

    def build_bootbin(self,config):
        if config.HDL_BUILD==1 and config.UBOOT_BUILD==1 and config.LINUX_BUILD==1:
            print("Building bootbin %s for %s" % (config.project,config.fpga))
        else:
            print("BOOTBIN for %s cannot be built" % (config.devtree))
            return
        TG = self.TARGET_DIR+"/"+config.devtree
        cmd = ["./build-bootbin.sh",TG,self.VIVADO,config.arch,config.cc]
        if self.sys_call(cmd):
            config.BOOTBIN_BUILD = 1
        else:
            config.BOOTBIN_BUILD = 2

    def build_hdl_pipeline(self):
        self.process_stage(self.build_hdl)

    def build_uboot_pipeline(self):
        self.process_stage(self.build_uboot)

    def build_linux_pipeline(self):
        self.process_stage(self.build_linux)

    def build_bootbin_pipeline(self):
        self.process_stage(self.build_bootbin)

    def get_sources(self):
        print("Downloading linux")
        cmd = ["git","clone","--single-branch","-b",self.LINUXBRANCH,"https://github.com/analogdevicesinc/linux.git","linux_ref"]
        self.sys_call(cmd)
        print("Downloading hdl")
        cmd = ["git","clone","--single-branch","-b",self.HDLBRANCH,"https://github.com/analogdevicesinc/hdl.git","hdl_ref"]
        self.sys_call(cmd)
        print("Downloading uboot")
        cmd = ["git","clone","https://github.com/Xilinx/u-boot-xlnx.git","u-boot-xlnx_ref"]
        self.sys_call(cmd)

    def print_results(self):
        print("--- Board Build Status --")
        for b in self.Boards:
            print("%s | Linux: %s | u-boot: %s | HDL: %s | boot.bin: %s\n" % (b.devtree,lu(b.LINUX_BUILD),lu(b.UBOOT_BUILD),lu(b.HDL_BUILD),lu(b.BOOTBIN_BUILD)))

    def build_complete_pipeline_flood(self):
        self.create_target_dirs()
        self.get_sources()
        tasks = [self.build_hdl,self.build_uboot,self.build_linux]
        self.process_stage_all(tasks)
        self.build_bootbin_pipeline()
        self.print_results()

    def build_complete_pipeline(self):
        self.create_target_dirs()
        self.get_sources()
        self.build_hdl_pipeline()
        self.build_uboot_pipeline()
        self.build_linux_pipeline()
        self.build_bootbin_pipeline()
        self.print_results()

if __name__== "__main__":
  bb = BootBuilder()
  #bb.build_linux_pipeline()
  #bb.print_results()
  #bb.build_complete_pipeline()
  bb.build_complete_pipeline_flood()
