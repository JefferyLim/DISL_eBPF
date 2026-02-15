#!/bin/bash

S=`basename $0`
P="$( dirname "$( readlink -f "$0" )" )"
F="bubble"
objdump="llvm-objdump"
objcopy="llvm-objcopy"

rm -rf "${F}.hex"

clang \
	-target bpf \
	-Wall -O0 \
	-c "${F}.c" \
	-o "${F}.o"

#readelf -x .text "${F}.o"

$objdump \
	--disassemble \
	"${F}.o" > "${F}.lst"

$objcopy \
	-O binary \
	--only-section=.text \
	"${F}.o" "${F}.bin"
chmod 644 "${F}.bin"

#cat "${F}.bin" | \
#        hexdump -v \
#                -e '1/1 "0x"' \
#                -e '8/1 "%02X""\n"'
#echo


# extra instruction necessary as we increment the instruction pointer too fast
python3 ../../../../tools/dump.py "${F}.bin" >> "${F}.hex"

# or use xxd
#xxd -g 8 "${F}.bin"

llvm-objdump -d ${F}.o > ${F}.dump
