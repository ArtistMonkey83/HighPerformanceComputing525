`timescale 1ns / 1ps

module dm_cache_fsm_tb;

  // Parameters
  parameter CACHE_BLOCK_SIZE = 128; // Cache block size in bytes
  parameter CACHE_SIZE = 1024;      // Cache size in bytes
  parameter MEM_SIZE = 32768;       // Memory size in bytes

  // Inputs
  logic clk;
  logic rst;
  logic [31:0] cpu_req_data;
  logic cpu_req_rw;
  logic cpu_req_valid;
  logic [31:0] cpu_req_addr;
  logic [127:0] mem_data;
  logic mem_ready;

  // Outputs
  logic [31:0] cpu_res_data;
  logic cpu_res_ready;
  logic [31:0] mem_req_addr;
  logic [127:0] mem_req_data;
  logic mem_req_rw;
  logic mem_req_valid;

  // Instantiate the module
  dm_cache_fsm dut(clk, rst, {cpu_req_addr, cpu_req_data, cpu_req_rw, cpu_req_valid}, {mem_data, mem_ready},
                  {mem_req_addr, mem_req_data, mem_req_rw, mem_req_valid}, {cpu_res_data, cpu_res_ready});

  // Clock generation
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // Reset generation
  initial begin
    rst = 1'b1;
    #10;
    rst = 1'b0;
  end

  // Test case
  initial begin
    // CPU read miss
    cpu_req_valid = 1'b1;
    cpu_req_rw = 1'b0;
    cpu_req_addr = 32'h00000000;
    cpu_req_data = 32'h00000000;
    #100;
    assert(cpu_res_ready === 1'b1);
    assert(cpu_res_data === 32'h11111111);

    // CPU write miss
    cpu_req_valid = 1'b1;
    cpu_req_rw = 1'b1;
    cpu_req_addr = 32'h00000000;
    cpu_req_data = 32'h11111111;
    #100;
    assert(cpu_res_ready === 1'b1);

    // CPU read hit
    cpu_req_valid = 1'b1;
    cpu_req_rw = 1'b0;
    cpu_req_addr = 32'h00000000;
    cpu_req_data = 32'h00000000;
    #100;
    assert(cpu_res_ready === 1'b1);
    assert(cpu_res_data === 32'h11111111);

    // CPU write hit
    cpu_req_valid = 1'b1;
    cpu_req_rw = 1'b1;
    cpu_req_addr = 32'h00000000;
    cpu_req_data = 32'h00000000;
    #100;
    assert(cpu_res_ready === 1'b1);

    $display("All test cases passed!");
    $finish;
  end

endmodule
