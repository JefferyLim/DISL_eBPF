`timescale 1ns/1ps

module tb_vebpf_scheduler;

  // Parameters (match DUT defaults, override here if desired)
  localparam integer NUM_CORE          = 1;
  localparam integer ADDR_WIDTH        = 10;
  localparam integer DATA_WIDTH        = 32;
  localparam integer FUNCTION_ID_WIDTH = 8;
  localparam integer F_COUNT           = 8+1;
  localparam         RAM_STYLE         = "block";

  // Clock / reset
  reg clk;
  reg rst;

  // DUT signals
  reg  [FUNCTION_ID_WIDTH-1:0] function_ida;
  reg                          ena;
  reg                          wea;
  reg  [ADDR_WIDTH-1:0]        addra;
  reg  [DATA_WIDTH-1:0]        dina;
  wire [DATA_WIDTH-1:0]        douta;

  reg  [FUNCTION_ID_WIDTH-1:0] function_idb;
  reg                          enb;
  reg                          web;
  reg  [ADDR_WIDTH-1:0]        addrb;
  reg  [DATA_WIDTH-1:0]        dinb;
  wire [DATA_WIDTH-1:0]        doutb;

  reg                          ptr_w;
  reg  [5-1:0]                 ptr_addr;
  reg  [DATA_WIDTH-1:0]        ptr_data;

  reg                          ptr_req;
  reg  [5-1:0]                 ptr_req_addr;
  wire [DATA_WIDTH-1:0]        ptr_req_data;

  reg  [FUNCTION_ID_WIDTH-1:0] vebpf_core_req;
  reg                          vebpf_request;
  reg  [63:0]                  vebpf_r1;
  reg  [63:0]                  vebpf_r2;
  reg  [63:0]                  vebpf_r3;

  wire [63:0]                  vebpf_r0;
  wire                         vebpf_r0_valid;
  wire                         vebpf_core_resp;

  // -------------------------
  // Instantiate DUT
  // -------------------------
  vebpf_scheduler #(
    .NUM_CORE(NUM_CORE),
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .FUNCTION_ID_WIDTH(FUNCTION_ID_WIDTH),
    .F_COUNT(F_COUNT),
    .RAM_STYLE(RAM_STYLE)
  ) dut (
    .clk(clk),
    .rst(rst),

    .function_ida(function_ida),

    .ena(ena),
    .wea(wea),
    .addra(addra),
    .dina(dina),
    .douta(douta),

    .function_idb(function_idb),

    .enb(enb),
    .web(web),
    .addrb(addrb),
    .dinb(dinb),
    .doutb(doutb),

    .ptr_w(ptr_w),
    .ptr_addr(ptr_addr),
    .ptr_data(ptr_data),

    .ptr_req(ptr_req),
    .ptr_req_addr(ptr_req_addr),
    .ptr_req_data(ptr_req_data),

    .vebpf_core_req(vebpf_core_req),
    .vebpf_request(vebpf_request),
    .vebpf_r1(vebpf_r1),
    .vebpf_r2(vebpf_r2),
    .vebpf_r3(vebpf_r3),

    .vebpf_r0(vebpf_r0),
    .vebpf_r0_valid(vebpf_r0_valid),
    .vebpf_core_resp(vebpf_core_resp)
  );

  // -------------------------
  // Clock gen
  // -------------------------
  initial clk = 1'b0;
  always #5 clk = ~clk; // 100MHz

  // -------------------------
  // Basic tasks
  // -------------------------
  task automatic apply_reset;
    begin
      rst = 1'b1;
      repeat (5) @(posedge clk);
      rst = 1'b0;
      repeat (2) @(posedge clk);
    end
  endtask

  task automatic send_core_request(
    input [FUNCTION_ID_WIDTH-1:0] fid,
    input [63:0] r1,
    input [63:0] r2,
    input [63:0] r3
  );
    begin
      // Drive request for 1 cycle
      @(posedge clk);
      vebpf_core_req = fid;
      vebpf_r1       = r1;
      vebpf_r2       = r2;
      vebpf_r3       = r3;
      vebpf_request  = 1'b1;

      @(posedge clk);
      vebpf_request  = 1'b0;
    end
  endtask

  // Wait for response/valid with timeout
  task automatic wait_for_resp(
    input integer max_cycles
  );
    integer k;
    begin
    
       @(posedge vebpf_r0_valid);

      if (!(vebpf_r0_valid || vebpf_core_resp)) begin
        $display("[%0t] ERROR: Timeout waiting for vebpf response", $time);
        $fatal(1);
      end else begin
        $display("[%0t] Response seen: core_resp=%0b r0_valid=%0b r0=0x%016h",
                 $time, vebpf_core_resp, vebpf_r0_valid, vebpf_r0);
      end
    end
  endtask

  // -------------------------
  // Optional: monitor
  // -------------------------
  initial begin
    $display("time  rst  req  fid  core_resp r0_valid r0");
    $monitor("%0t  %0b    %0b   0x%0h    %0b       %0b     0x%016h",
             $time, rst, vebpf_request, vebpf_core_req,
             vebpf_core_resp, vebpf_r0_valid, vebpf_r0);
  end

  // -------------------------
  // Stimulus
  // Primarily testing vebpf_core_req / vebpf_request path
  // -------------------------
  initial begin
    // Defaults
    rst           = 1'b1;

    function_ida  = 0;
    ena           = 1'b0;
    wea           = 1'b0;
    addra         = 0;
    dina          = 0;

    function_idb  = 0;
    enb           = 1'b0;
    web           = 1'b0;
    addrb         = 0;
    dinb          = 0;

    ptr_w         = 1'b0;
    ptr_addr      = 0;
    ptr_data      = 0;

    ptr_req       = 1'b0;
    ptr_req_addr  = 0;

    vebpf_core_req = 0;
    vebpf_request  = 1'b0;
    vebpf_r1       = 64'h0;
    vebpf_r2       = 64'h0;
    vebpf_r3       = 64'h0;

    apply_reset();

    // ---- Test 1: Single request ----
    $display("[%0t] TEST1: single request", $time);
    send_core_request(8'h01, 64'h4, 64'h2222, 64'h3333);
    @(posedge clk);
    wait_for_resp(200);

    // ---- Test 2: Back-to-back requests (1-cycle gap) ----
    $display("[%0t] TEST2: back-to-back requests", $time);
    send_core_request(8'h02, 64'h15, 64'h0, 64'h1);
    @(posedge clk);
    wait_for_resp(200);

    send_core_request(8'h03, 64'h11, 64'h55, 64'h66);
    @(posedge clk);
    wait_for_resp(200);

    // ---- Test 3: Rapid fire (no gap besides task internals) ----
    $display("[%0t] TEST3: rapid fire", $time);
    repeat (5) begin : RF
      send_core_request($random, {$random,$random}, {$random,$random}, {$random,$random});
      wait_for_resp(400);
    end

    $display("[%0t] ALL TESTS DONE", $time);
    $finish;
  end

endmodule
