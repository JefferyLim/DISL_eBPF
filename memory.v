module memory(address, data_in, data_out, write_enable, clk);

        parameter data_size = 64;
        parameter address_size = 12;
        parameter memory_depth = 2**address_size;  // do not specify this when using module
        parameter instruction = 0;
        input [address_size-1:0] address;
        input [data_size-1:0] data_in;
        output [data_size-1:0] data_out;
        input write_enable;
        input clk;

        reg [data_size-1:0] mem [0:memory_depth-1];
        assign data_out = mem [address];

        always @(posedge clk) begin
                case (write_enable)
                        1: mem [address] = data_in;
                endcase
        end

        // testing
        // MSB                                                        LSB
    // | Byte 8 | Byte 7  | Byte 5-6       | Byte 1-4               |
    // +--------+----+----+----------------+------------------------+
    // |opcode  | src| dst|          offset|               immediate|
    // +--------+----+----+----------------+------------------------+
    // 63     56   52   48               32                        0

 integer i;
        // Initialize memory from an external hex file at the beginning of simulation
  initial begin

   $display("%m %d %d\n", data_size, memory_depth);

    if(instruction) 
        $readmemh("memory.hex", mem); // Load memory from a hex file

    // Dump first 16 entries
    $display("=== MEMORY CONTENTS ===");
    for (i = 0; i < 16; i=i+1) begin
       $display("mem[%0d] = %h", i, mem[i]);
    end

  end

endmodule

