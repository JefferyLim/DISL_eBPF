# Install

## Verilator
```
sudo apt-get install git help2man perl python3 make autoconf g++ flex bison ccache
sudo apt-get install libgoogle-perftools-dev numactl perl-doc
sudo apt-get install libfl2  # Ubuntu only (ignore if gives error)
sudo apt-get install libfl-dev  # Ubuntu only (ignore if gives error)
sudo apt-get install zlibc zlib1g zlib1g-dev  # Ubuntu only (ignore if gives error)
git clone https://github.com/verilator/verilator
cd verilator
git pull
autoconf
./configure
make -j `nproc`
sudo make install

```


# VeBPF code

You can write either assembly or C code.


Some links on the eBPF assembly:

https://qmonnet.github.io/whirl-offload/2020/04/12/llvm-ebpf-asm/


Instruction Set Specification:

https://www.kernel.org/doc/html/v6.1/bpf/instruction-set.html
https://github.com/iovisor/bpf-docs/blob/master/eBPF.md
https://github.com/emilmasoumi/ebpf-assembler


You will need a python environment, so create one and install the necessary packages with `pip install -r requirements.txt`

## Assembler
Write your assembly code and then copy the is\_prime\_make.sh example to compile assembly to a hex file

Copy your hex file to memory.hex to the root directory and then run make

## C
Write your C code and then copy the prime\_make.sh example to compile C to a hex file

As far as I can tell, the first function in the code will become your "main".

The first argument will use R1, second will use R2, etc.

This script will also generate an objdump for you to view the assembly.

Copy your hex file to memory.hex to the root directory and then run make


# DISL_eBPF
eBPF Module for DISL


Current State:

Functional BPFB CPU
Tested all eBPF opcodes using hBPF test files


To Do: 

BPFB Peripheral Module Development

Peripheral Modules Unit Testing

Data Packet Filtering Testing

Call Handler Module Development (w/ Hardware Accelerated Instructions)

BPFB System Testing (using C Code compiled to eBPF asm)

Integration into DISL memory subsystem

Integrated Memory Subsystem Testing
