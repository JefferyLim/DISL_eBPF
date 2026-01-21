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
