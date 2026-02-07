//------------------------------------------------------------------------------
// True Dual-Port RAM (TDP) - Vivado inference-friendly
// - Two independent ports (A/B), each can read or write
// - Optional initialization to zero (synthesis may ignore init for BRAM)
// - Read-during-write behavior: "WRITE_FIRST" (as coded below)
//------------------------------------------------------------------------------
// Parameters:
//   ADDR_WIDTH : number of address bits (depth = 2**ADDR_WIDTH)
//   DATA_WIDTH : width of each memory word
//   RAM_STYLE  : "block" (BRAM) or "distributed" (LUTRAM)
//
// Notes:
// - For block RAM inference, use RAM_STYLE="block" and a large enough depth.
// - If you need "read_first" or "no_change", adjust the read logic accordingly.
//------------------------------------------------------------------------------
module xpm_ram #(
  parameter ADDR_WIDTH = 10,
  parameter DATA_WIDTH = 32,
  parameter RAM_STYLE  = "block"   // "block" or "distributed"
)(
  input  wire                   clka,

  // Port A
  input  wire                   ena,
  input  wire                   wea,
  input  wire [ADDR_WIDTH-1:0]  addra,
  input  wire [DATA_WIDTH-1:0]  dina,
  output reg  [DATA_WIDTH-1:0]  douta,

  // Port B
  input  wire                   clkb,
  input  wire                   enb,
  input  wire                   web,
  input  wire [ADDR_WIDTH-1:0]  addrb,
  input  wire [DATA_WIDTH-1:0]  dinb,
  output reg  [DATA_WIDTH-1:0]  doutb
);

  localparam DEPTH = 1 << ADDR_WIDTH;

  // Vivado RAM inference hint
  (* ram_style = RAM_STYLE *) reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Optional init (may be ignored for BRAM depending on flow)
  integer i;
  initial begin
    for (i = 0; i < DEPTH; i = i + 1) begin
      mem[i] = {DATA_WIDTH{1'b0}};
    end
  end

  // Port A: synchronous read, write-first
  always @(posedge clka) begin
    if (ena) begin
      if (wea) begin
        mem[addra] <= dina;
        douta      <= dina;        // WRITE_FIRST behavior
      end else begin
        douta      <= mem[addra];
      end
    end
  end

  // Port B: synchronous read, write-first
  always @(posedge clkb) begin
    if (enb) begin
      if (web) begin
        mem[addrb] <= dinb;
        doutb      <= dinb;        // WRITE_FIRST behavior
      end else begin
        doutb      <= mem[addrb];
      end
    end
  end

endmodule
