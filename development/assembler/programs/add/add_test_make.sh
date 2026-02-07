#!/bin/bash

NAME="add"
ASM="$NAME.asm"
BIN="$NAME.bin"
HEX="$NAME.hex"
#PY="$NAME.py"

# Assemble source
python3 /home/ayin/DISL_eBPF/tools/ubpf/bin/ubpf-assembler "$ASM" "$BIN"

# Output python list
#echo "mem = [" > "$PY"
#cat "$BIN" | \
#       hexdump -v \
#               -e '1/1 "    0x"' \
#               -e '8/1 "%02X"",\n"' >> "$PY"
#echo "]" >> "$PY"

echo "0xbf00000000000000" > "$HEX"

# Hex dump
python3 /home/ayin/DISL_eBPF/tools/dump.py "$BIN" >> "$HEX"

# or use xxd
#xxd -g 8 "$BIN"

