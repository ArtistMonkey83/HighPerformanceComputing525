`timescale 1ns / 1ps

module dm_cache_fsm_tb;
    // Inputs
    reg clk;
    reg rst;
    reg cpu_req_valid;
    reg cpu_req_rw;
    reg [31:0] cpu_req_data;
    reg [31:0] cpu_req_addr;

    // Outputs
    wire mem_req_rw;
    wire [31:0] mem_req_addr;
    wire [127:0] mem_req_data;
    wire mem_req_valid;
    wire [31:0] cpu_res_data;
    wire cpu_res_ready;

    dm_cache_fsm uut (
        .clk(clk),
        .rst(rst),
        .cpu_req({cpu_req_data, cpu_req_addr, cpu_req_rw, cpu_req_valid}),
        .mem_req({mem_req_data, mem_req_addr, mem_req_rw, mem_req_valid}),
        .cpu_res({cpu_res_data, cpu_res_ready})
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initialize inputs
        rst = 1;
        cpu_req_valid = 0;
        cpu_req_rw = 0;
        cpu_req_data = 0;
        cpu_req_addr = 0;

        // Wait for some time to let the reset settle
        #10 rst = 0;

        // Test case 1: Read hit
        cpu_req_valid = 1;
        cpu_req_rw = 0;
        cpu_req_data = 0;
        cpu_req_addr = 32'h80004000;
        #10;
        cpu_req_valid = 0;
        #100;

        // Test case 2: Write hit
        cpu_req_valid = 1;
        cpu_req_rw = 1;
        cpu_req_data = 32'h01234567;
        cpu_req_addr = 32'h80004004;
        #10;
        cpu_req_valid = 0;
        #100;

        // Test case 3: Read miss
        cpu_req_valid = 1;
        cpu_req_rw = 0;
        cpu_req_data = 0;
        cpu_req_addr = 32'h80004010;
        #10;
        cpu_req_valid = 0;
        #100;

        // Test case 4: Write miss
        cpu_req_valid = 1;
        cpu_req_rw = 1;
        cpu_req_data = 32'h89ABCDEF;
        cpu_req_addr = 32'h80004008;
        #10;
        cpu_req_valid = 0;
        #100;

        // Test case 5: Write-back
        cpu_req_valid = 1;
        cpu_req_rw = 0;
        cpu_req_data = 0;
        cpu_req_addr = 32'h80004000;
        #10;
        cpu_req_valid = 0;
        #100;
    end

endmodule
