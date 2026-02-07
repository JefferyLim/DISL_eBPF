
module vebpf_instr_storage #(
  parameter ADDR_WIDTH        = 10,
  parameter DATA_WIDTH        = 32,
  parameter FUNCTION_ID_WIDTH = 8,
  parameter F_COUNT           = 8+1,
  parameter RAM_STYLE      = "block"
)(
  input  wire                         clk,

  // Select (binary)
  input  wire [FUNCTION_ID_WIDTH-1:0]  function_ida,

  // Single Port A inputs
  input  wire                    ena,
  input  wire                    wea,
  input  wire [ADDR_WIDTH-1:0]   addra,
  input  wire [DATA_WIDTH-1:0]   dina,
  output wire [DATA_WIDTH-1:0]   douta,

  // Single Port B inputs
  input  wire [FUNCTION_ID_WIDTH-1:0]  function_idb,

  input  wire                    enb,
  input  wire                    web,
  input  wire [ADDR_WIDTH-1:0]   addrb,
  input  wire [DATA_WIDTH-1:0]   dinb,
  output wire [DATA_WIDTH-1:0]   doutb,


  input wire ptr_w,
  input wire [5-1:0] ptr_addr,
  input wire [DATA_WIDTH-1:0] ptr_data,

  input wire    ptr_req,
  input wire    [5-1:0] ptr_req_addr,
  output wire   [DATA_WIDTH-1:0] ptr_req_data
);

  // Demuxed enables/writes (only selected instance active)
  wire [F_COUNT-1:0] we_a;
  wire [F_COUNT-1:0] en_b;
  wire [DATA_WIDTH-1:0]   douta_all[0:F_COUNT-1];
  wire [DATA_WIDTH-1:0]   doutb_all[0:F_COUNT-1];
  
  reg [32-1:0]   ptr_data_all[F_COUNT-1:0];
  
  reg [FUNCTION_ID_WIDTH-1:0] function_idb_reg;
  reg [FUNCTION_ID_WIDTH-1:0] function_idb_regD;
  reg [FUNCTION_ID_WIDTH-1:0] function_ida_reg;
  reg [ADDR_WIDTH-1:0]   addraD;
  reg [DATA_WIDTH-1:0]   dinaD;
  
  
  reg [ADDR_WIDTH-1:0]   addrbD;


  // Register inputs
  always @(posedge clk) begin
    function_idb_reg <= function_idb;
    function_idb_regD <= function_idb_reg;
    function_ida_reg <= function_ida;
    dinaD <= dina;

    addraD <= addra;
    addrbD <= addrb;
  end
  
  
  
  assign ptr_req_data = ptr_data_all[function_idb];
  
  assign douta = douta_all[function_ida];
  assign doutb = doutb_all[function_idb_regD];

  genvar i;
  generate
    for (i = 0; i < F_COUNT; i=i+1) begin : g_bank
      // decode select
      assign we_a[i] = wea & (function_ida_reg == i[FUNCTION_ID_WIDTH-1:0]);
      assign en_b[i] = enb & (function_idb_reg == i[FUNCTION_ID_WIDTH-1:0]);


      // instance
      xpm_ram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .RAM_STYLE(RAM_STYLE)
      ) u_ram (
        .clka   (clk),

        .ena   (we_a[i]),
        .wea   (we_a[i]),
        .addra (addraD),          // broadcast
        .dina  (dinaD),           // broadcast
        .douta (douta_all[i]),
        .clkb   (clk),

        .enb   (en_b[i]),
        .web   (1'b0),
        .addrb (addrbD),          // broadcast
        .dinb  (),           // broadcast
        .doutb (doutb_all[i])
      );

        reg [31:0] instruction_pointers [0:31];


        always@(posedge clk)
        begin
            if(ptr_w && function_ida == i[FUNCTION_ID_WIDTH-1:0]) begin
                instruction_pointers[ptr_addr] <= ptr_data;
            end    
            if(ptr_req) begin
                ptr_data_all[i] <= instruction_pointers[ptr_req_addr];
            end    
        end
    end

  endgenerate

endmodule
