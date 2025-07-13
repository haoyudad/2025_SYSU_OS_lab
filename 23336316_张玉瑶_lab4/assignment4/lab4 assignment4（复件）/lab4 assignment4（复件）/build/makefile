ASM_COMPILER = nasm
C_COMPILER = gcc
CXX_COMPILER = g++
CXX_COMPILER_FLAGS = -g -Wall -march=i386 -m32 -nostdlib -fno-builtin -ffreestanding -fno-pic -fno-stack-protector
LINKER = ld
LDFLAGS = -melf_i386 -N -Ttext 0x00020000

SRCDIR = ../src
RUNDIR = ../run
BUILDDIR = build
INCLUDE_PATH = ../include

# 源文件定义
CXX_SOURCES = $(wildcard $(SRCDIR)/kernel/*.cpp)
ASM_SOURCES = $(SRCDIR)/utils/asm_utils.asm
BOOT_SOURCES = $(SRCDIR)/boot/mbr.asm $(SRCDIR)/boot/bootloader.asm $(SRCDIR)/boot/entry.asm

# 目标文件定义
CXX_OBJS = $(notdir $(CXX_SOURCES:.cpp=.o))
ASM_OBJS = asm_utils.o
BOOT_OBJS = mbr.bin bootloader.bin entry.obj

# 默认目标
all: run

# 主构建目标
build: mbr.bin bootloader.bin kernel.bin
	dd if=mbr.bin of=$(RUNDIR)/hd.img bs=512 count=1 seek=0 conv=notrunc
	dd if=bootloader.bin of=$(RUNDIR)/hd.img bs=512 count=5 seek=1 conv=notrunc
	dd if=kernel.bin of=$(RUNDIR)/hd.img bs=512 count=145 seek=6 conv=notrunc

# 引导加载程序
mbr.bin: $(SRCDIR)/boot/mbr.asm
	$(ASM_COMPILER) -o $@ -f bin -I$(INCLUDE_PATH)/ $<

bootloader.bin: $(SRCDIR)/boot/bootloader.asm
	$(ASM_COMPILER) -o $@ -f bin -I$(INCLUDE_PATH)/ $<

entry.obj: $(SRCDIR)/boot/entry.asm
	$(ASM_COMPILER) -o $@ -f elf32 $<

# 内核构建
kernel.bin: kernel.o
	objcopy -O binary $< $@

kernel.o: entry.obj $(CXX_OBJS) $(ASM_OBJS)
	$(LINKER) -o $@ $(LDFLAGS) entry.obj $(CXX_OBJS) $(ASM_OBJS) -e enter_kernel

# C++源文件编译
%.o: $(SRCDIR)/kernel/%.cpp
	$(CXX_COMPILER) $(CXX_COMPILER_FLAGS) -I$(INCLUDE_PATH) -c $< -o $@

# 汇编源文件编译
asm_utils.o: $(SRCDIR)/utils/asm_utils.asm
	$(ASM_COMPILER) -o $@ -f elf32 $<

# 清理
clean:
	rm -f *.o *.obj *.bin

# 运行QEMU
run: build
	qemu-system-i386 -hda $(RUNDIR)/hd.img -serial null -parallel stdio -no-reboot

# 调试目标
debug: build
	qemu-system-i386 -S -s -parallel stdio -hda $(RUNDIR)/hd.img -serial null & \
	sleep 1 && \
	gnome-terminal -e "gdb -q -tui -x $(RUNDIR)/gdbinit"

.PHONY: all build clean run debug
