GCC_VERSION = 13.1.0
BINUTILS_VERSION = 2.40

GCC_URL = "https://ftp.gnu.org/gnu/gcc/gcc-$(GCC_VERSION)/gcc-$(GCC_VERSION).tar.gz"
BINUTILS_URL = "https://ftp.gnu.org/gnu/binutils/binutils-$(BINUTILS_VERSION).tar.gz"
PREFIX="$(HOME)/opt/cross"
MAKEOPTS="-j$(nproc)"
TARGET=i686-elf
export PATH := $(PREFIX)/bin:$(PATH)

# Download binutils
binutils_download:
	mkdir -p build-binutils && \
	cd build-binutils && \
	wget $(BINUTILS_URL) && \
	tar -xvf binutils-$(BINUTILS_VERSION).tar.gz

# Build binutils
binutils_build: binutils_download
	cd build-binutils/binutils-$(BINUTILS_VERSION) && \
	mkdir build && \
	cd build && \
	../configure --target=$(TARGET) --prefix=$(PREFIX) --with-sysroot --disable-nls --disable-werror && \
	make $(MAKEOPTS) && \
	make install

# Download GCC
gcc_download:
	mkdir -p build-gcc && \
	cd build-gcc && \
	wget $(GCC_URL) && \
	tar -xvf gcc-$(GCC_VERSION).tar.gz

# Build GCC
gcc_build: gcc_download
	cd build-gcc/gcc-$(GCC_VERSION) && \
	mkdir build && \
	cd build && \
	../configure --target=$(TARGET) --enable-m --prefix=$(PREFIX) --disable-nls --enable-languages=c,c++ --without-headers && \
	make all-gcc && \
	make all-target-libgcc && \
	make install-gcc && \
	make install-target-libgcc

# Clean
clean_crosscompiler:
	rm -rf build-gcc build-binutils && \
	@echo "Cleaned"

clean:
	rm -rf *.o *.bin *.iso *.img *.elf *.iso *.iso
add_to_path:
	@printf "remember to add $(PREFIX)/bin to your PATH :D \nfor example add: 'export PATH=\"$(PREFIX)/bin:\$$PATH\' to your .bashrc"

# Default target

build_kernel:
	i686-elf-as src/boot.s -o boot.o && \
	i686-elf-gcc -c src/kernel.c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra && \
	i686-elf-gcc -c $(filter-out src/kernel.c, $(wildcard src/*.c)) -o objects.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra && \
	i686-elf-gcc -T src/linker.ld -o myos.bin -ffreestanding -O2 -nostdlib $(wildcard *.o) -lgcc
	
run_kernel: build_kernel
	qemu-system-i386 -kernel myos.bin

all_crosscompiler: binutils_build gcc_build add_to_path
