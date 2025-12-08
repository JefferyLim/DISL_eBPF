module memory(address, data_in, data_out, write_enable, clk);

	parameter data_size = 64; 
	parameter address_size = 12;
	parameter memory_depth = 2**address_size;  // do not specify this when using module
	 
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
	
	// Initialize memory from an external hex file at the beginning of simulation
  initial begin
      $readmemh("memory_data.hex", mem); // Load memory from a hex file
  end

endmodule
